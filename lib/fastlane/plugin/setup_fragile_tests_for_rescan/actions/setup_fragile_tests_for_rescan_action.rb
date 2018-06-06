module Fastlane
  module Actions
    class SetupFragileTestsForRescanAction < Action
      require 'rexml/document'
      require 'rexml/xpath'
      require 'xcodeproj'
      require 'terminal-table'

      def self.run(params)
        report_file = File.open(params[:report_filepath]) { |f| REXML::Document.new(f) }
        UI.user_error!("Malformed XML test report file given") if report_file.root.nil?
        UI.user_error!("Valid XML file is not an Xcode test report") if report_file.get_elements('testsuites').empty?

        result = {
          passed_tests: [],
          failed_tests: []
        }

        # remove all testcases that failed from the report file
        # so that our subsequent steps here can just focus on finding
        # passing testcases to suppress
        report_file.elements.each('*/testsuite/testcase/failure') do |failure_element|
          testcase = failure_element.parent
          testsuite_element = testcase.parent

          result[:failed_tests] << xcodebuild_test_identifier(testsuite_element.parent, testcase)
          testsuite_element.delete_element testcase
        end

        scheme = xcscheme(params)
        is_dirty = false
        summary = []
        report_file.elements.each('testsuites') do |testsuites|
          buildable_name = testsuites.attributes['name']

          test_action = scheme.test_action
          testable = test_action.testables.find { |t| t.buildable_references[0].buildable_name == buildable_name }
          raise "Unable to find testable named #{buildable_name}" if testable.nil?

          testsuites.elements.each('testsuite/testcase') do |testcase|
            skipped_test = Xcodeproj::XCScheme::TestAction::TestableReference::SkippedTest.new
            skipped_test.identifier = xctest_identifier(testcase)
            testable.add_skipped_test(skipped_test)
            result[:passed_tests] << xcodebuild_test_identifier(testsuites, testcase)
            is_dirty = true
            summary << [skipped_test.identifier]
          end
        end
        if is_dirty
          scheme.save!
          table = Terminal::Table.new(
            title: 'setup_fragile_tests_for_rescan suppressed the following tests',
            rows: summary
          )
          UI.success("\n#{table}")
        else
          UI.error('No passing tests found for suppression')
        end
        result
      end

      def self.xcscheme(params)
        project_path = params[:project_path]
        scheme_name = params[:scheme]

        scheme_filepath = File.join(Xcodeproj::XCScheme.shared_data_dir(project_path), "#{scheme_name}.xcscheme")
        unless File.exist?(scheme_filepath)
          scheme_filepath = File.join(Xcodeproj::XCScheme.user_data_dir(project_path), "#{scheme_name}.xcscheme")
        end
        UI.user_error!("Scheme '#{scheme_name}' does not exist in Xcode project found at '#{project_path}'") unless File.exist?(scheme_filepath)

        Xcodeproj::XCScheme.new(scheme_filepath)
      end

      def self.xctest_identifier(testcase)
        testcase_class = testcase.attributes['classname']
        testcase_testmethod = testcase.attributes['name']

        is_swift = testcase_class.include?('.')
        testcase_class.gsub!(/.*\./, '')
        testcase_testmethod << '()' if is_swift
        "#{testcase_class}/#{testcase_testmethod}"
      end

      def self.xcodebuild_test_identifier(testsuites, testcase)
        # remove '.xctest' from the buildable_name
        buildable_name = File.basename(testsuites.attributes['name'], '.*')
        test_identifier = xctest_identifier(testcase).chomp('()')
        "#{buildable_name}/#{test_identifier}"
      end

      def self.description
        "Suppress stabile tests so that 'scan' can run the fragile tests again"
      end

      def self.return_value
        "A hash of the tests with arrays :passed_tests and :failed_tests which can be used with scan's :skip_testing and :test_only options"
      end

      def self.authors
        ["Lyndsey Ferguson"]
      end

      def self.details
        "Reviews the scan report file to find the passing tests in an Xcode project and then suppresses the tests in the test-suite's source file."
      end

      def self.deprecated_notes
        "⛔️\n" \
        "🚫 This action is deprecated.\n" \
        "🙏 Please use the suppress_tests_from_junit and multi_scan actions shipped with the test_center plugin.\n" \
        "😇"
      end

      def self.category
        :deprecated
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(
            key: :project_path,
            env_name: "SETUP_FRAGILE_TESTS_FOR_RESCAN_PROJECT_PATH",
            description: "The file path to the Xcode project file",
            verify_block: proc do |value|
              UI.user_error!('No project file for SetupFragileTestsForRescanAction given, pass using `project_path: \'path/to/project.xcodeproj\'`') if value.nil? || value.empty?
              UI.user_error!("SetupFragileTestsForRescanAction cannot find project file at '#{value}'") unless Dir.exist?(value)
              UI.user_error!("The project '#{value}' is not a valid Xcode project") unless File.extname(value).casecmp('.xcodeproj').zero?
              UI.user_error!("The Xcode project at '#{value}' is invalid: missing the project.pbxproj file") unless File.exist?("#{value}/project.pbxproj")
            end,
            type: String
          ),
          FastlaneCore::ConfigItem.new(
            key: :scheme,
            env_name: "SETUP_FRAGILE_TESTS_FOR_RESCAN_SCHEME",
            description: "The Xcode scheme used to manage the tests",
            verify_block: proc do |value|
              UI.user_error!('No scheme for SetupFragileTestsForRescanAction given, pass using `scheme: \'scheme name\'`') if value.nil? || value.empty?
            end,
            type: String
          ),
          FastlaneCore::ConfigItem.new(
            key: :report_filepath,
            env_name: "SETUP_FRAGILE_TESTS_FOR_RESCAN_TEST_REPORT_FILEPATH",
            description: "The file path to the test report file",
            verify_block: proc do |value|
              UI.user_error!('No test report file for SetupFragileTestsForRescanAction given, pass using `report_filepath: \'path/to/report.xml\'`') if value.nil? || value.empty?
              UI.user_error!("SetupFragileTestsForRescanAction cannot find test report file at '#{value}'") unless File.exist?(value)
            end,
            type: String
          )
        ]
      end

      def self.is_supported?(platform)
        STDOUT.puts "platform: #{platform}"
        %i[ios mac].include?(platform)
      end
    end
  end
end
