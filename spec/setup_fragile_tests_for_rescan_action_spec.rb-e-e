describe Fastlane do
  describe Fastlane::FastFile do
    describe "setup_fragile_tests_for_rescan" do
      require 'xcodeproj'

      describe '#run' do
        it 'throws an error when given a project file that does not exist' do
          fastfile = "lane :test do
            setup_fragile_tests_for_rescan(project_path: 'not/a/path.xcodeproj')
          end"
          expect { Fastlane::FastFile.new.parse(fastfile).runner.execute(:test) }.to(
            raise_error(FastlaneCore::Interface::FastlaneError) do |error|
              expect(error.message).to match(/SetupFragileTestsForRescanAction cannot find project file at /)
            end
          )
        end

        it 'throws an error when given an empty project file' do
          fastfile = "lane :test do
            setup_fragile_tests_for_rescan(project_path: '')
          end"
          expect { Fastlane::FastFile.new.parse(fastfile).runner.execute(:test) }.to(
            raise_error(FastlaneCore::Interface::FastlaneError) do |error|
              expect(error.message).to match(/No project file for SetupFragileTestsForRescanAction given/)
            end
          )
        end

        it 'throws an error when given a test report file that does not exist' do
          fastfile = "lane :test do
            setup_fragile_tests_for_rescan(report_filepath: 'not/a/path')
          end"
          expect { Fastlane::FastFile.new.parse(fastfile).runner.execute(:test) }.to(
            raise_error(FastlaneCore::Interface::FastlaneError) do |error|
              expect(error.message).to match(/SetupFragileTestsForRescanAction cannot find test report file at/)
            end
          )
        end

        it 'throws an error when given an empty test report file path' do
          fastfile = "lane :test do
            setup_fragile_tests_for_rescan(report_filepath: '')
          end"
          expect { Fastlane::FastFile.new.parse(fastfile).runner.execute(:test) }.to(
            raise_error(FastlaneCore::Interface::FastlaneError) do |error|
              expect(error.message).to match(/No test report file for SetupFragileTestsForRescanAction given/)
            end
          )
        end

        it 'throws an error when given a test report file is not an xml file' do
          fastfile = "lane :test do
            setup_fragile_tests_for_rescan(report_filepath: File.expand_path('../spec/fixtures/TestReports/not.xml'))
          end"
          expect { Fastlane::FastFile.new.parse(fastfile).runner.execute(:test) }.to(
            raise_error(FastlaneCore::Interface::FastlaneError) do |error|
              expect(error.message).to match(/Malformed XML test report file given/)
            end
          )
        end

        it 'throws an error when a given test report file is not a Xcode test report file' do
          fastfile = "lane :test do
            setup_fragile_tests_for_rescan(report_filepath: File.expand_path('../spec/fixtures/TestReports/not_test_report.xml'))
          end"
          expect { Fastlane::FastFile.new.parse(fastfile).runner.execute(:test) }.to(
            raise_error(FastlaneCore::Interface::FastlaneError) do |error|
              expect(error.message).to match(/Valid XML file is not an Xcode test report/)
            end
          )
        end

        it 'throws an error when a given project path does not end in .xcodeproj' do
          fastfile = "lane :test do
            setup_fragile_tests_for_rescan(
              project_path: '../spec/fixtures/projects',
              report_filepath: File.expand_path('../spec/fixtures/TestReports/report.xml')
            )
          end"
          expect { Fastlane::FastFile.new.parse(fastfile).runner.execute(:test) }.to(
            raise_error(FastlaneCore::Interface::FastlaneError) do |error|
              expect(error.message).to match(/The project '.*' is not a valid Xcode project/)
            end
          )
        end

        it 'throws an error when there is no project.pbxproj file in the project path directory' do
          fastfile = "lane :test do
            setup_fragile_tests_for_rescan(
              project_path: '../spec/fixtures/projects/InvalidProject/invalid.xcodeproj',
              report_filepath: File.expand_path('../spec/fixtures/TestReports/report.xml')
            )
          end"
          expect { Fastlane::FastFile.new.parse(fastfile).runner.execute(:test) }.to(
            raise_error(FastlaneCore::Interface::FastlaneError) do |error|
              expect(error.message).to match(/The Xcode project at '.*' is invalid: missing the project.pbxproj file/)
            end
          )
        end

        it 'throws an error when an invalid scheme is given' do
          fastfile = "lane :test do
            setup_fragile_tests_for_rescan(
              scheme: ''
            )
          end"
          expect { Fastlane::FastFile.new.parse(fastfile).runner.execute(:test) }.to(
            raise_error(FastlaneCore::Interface::FastlaneError) do |error|
              expect(error.message).to match(/No scheme for SetupFragileTestsForRescanAction given, pass using `scheme: 'scheme name'`/)
            end
          )
        end

        context 'with a valid Xcode Objective-C project' do
          before(:each) do
            tmpdir = Dir.mktmpdir
            @tmp_report_filepath = "#{tmpdir}/TestReports/report.xml"
            FileUtils.mkdir_p("#{tmpdir}/TestReports")
            report_filepath = File.expand_path('spec/fixtures/TestReports/report.xml')
            FileUtils.copy(report_filepath, @tmp_report_filepath)

            @tmp_xcodeproj_dirpath = "#{tmpdir}/BlackHoleFoolery"
            FileUtils.mkdir_p(@tmp_xcodeproj_dirpath)
            xcodeproj_dirpath = File.expand_path('spec/fixtures/Projects/BlackHoleFoolery/.')
            FileUtils.cp_r(xcodeproj_dirpath, tmpdir)
          end

          after(:each) do
            FileUtils.rm_rf(@tmp_report_filepath)
            FileUtils.rm_rf(@tmp_xcodeproj_dirpath)
          end

          it 'suppresses only passing tests found in a test report file in the test suite source file' do
            fastfile = "lane :test do
              setup_fragile_tests_for_rescan(
                project_path: '#{@tmp_xcodeproj_dirpath}/BlackHoleFoolery.xcodeproj',
                scheme: 'BlackHoleFoolery',
                report_filepath: '#{@tmp_report_filepath}'
              )
            end"

            result = Fastlane::FastFile.new.parse(fastfile).runner.execute(:test)

            scheme_filepath = File.join(Xcodeproj::XCScheme.shared_data_dir("#{@tmp_xcodeproj_dirpath}/BlackHoleFoolery.xcodeproj"), "BlackHoleFoolery.xcscheme")
            scheme = Xcodeproj::XCScheme.new(scheme_filepath)
            test_action = scheme.test_action
            testable = test_action.testables.find { |t| t.buildable_references[0].buildable_name == "BlackHoleFooleryUITests.xctest" }
            actual_skippedtests = testable.skipped_tests.map(&:identifier)
            expect(actual_skippedtests).to include(
              "BlackHoleFooleryUITests/testInitialViewContainsElements",
              "BlackHoleFooleryUITests/testPressingStartButtonBeginsTravellingIntoBlackHole",
              "BlackHoleFooleryUITests/testPressingStopButtonBeforeEventHorizonStops",
              "BlackHoleFooleryUITests/testPressingStopButtonBeepsWhenInEventHorizonButDoesNotStop",
              "BlackHoleFooleryUITests/testPressingStopButtonWhenInBlackHoleInitiatesBigBang",
              "BlackHoleFooleryUITests/testPressingEscapeHatchButtonEjectsPilotIntoColdBlackSpaceWhenOutsideOfEventHorizon",
              "BlackHoleFooleryUITests/testPressingEscapeHatchButtonStretchesAndDestroysPilotWhenInEventHorizon"
            )
            expect(actual_skippedtests).not_to include(
              "BlackHoleFooleryUITests/testPressingEscapeHatchButtonPunchesPilotToParadiseWhenInBlackHole"
            )
            expect(result).to have_key(:passed_tests)
            expect(result[:passed_tests]).to eq(
              [
                "BlackHoleFooleryUITests/BlackHoleFooleryUITests/testInitialViewContainsElements",
                "BlackHoleFooleryUITests/BlackHoleFooleryUITests/testPressingStartButtonBeginsTravellingIntoBlackHole",
                "BlackHoleFooleryUITests/BlackHoleFooleryUITests/testPressingStopButtonBeforeEventHorizonStops",
                "BlackHoleFooleryUITests/BlackHoleFooleryUITests/testPressingStopButtonBeepsWhenInEventHorizonButDoesNotStop",
                "BlackHoleFooleryUITests/BlackHoleFooleryUITests/testPressingStopButtonWhenInBlackHoleInitiatesBigBang",
                "BlackHoleFooleryUITests/BlackHoleFooleryUITests/testPressingEscapeHatchButtonEjectsPilotIntoColdBlackSpaceWhenOutsideOfEventHorizon",
                "BlackHoleFooleryUITests/BlackHoleFooleryUITests/testPressingEscapeHatchButtonStretchesAndDestroysPilotWhenInEventHorizon"
              ]
            )
            expect(result).to have_key(:failed_tests)
            expect(result[:failed_tests]).to eq(['BlackHoleFooleryUITests/BlackHoleFooleryUITests/testPressingEscapeHatchButtonPunchesPilotToParadiseWhenInBlackHole'])
          end

          it 'throws an error when the given scheme does not exist in the project' do
            fastfile = "lane :test do
              setup_fragile_tests_for_rescan(
                project_path: '#{@tmp_xcodeproj_dirpath}/BlackHoleFoolery.xcodeproj',
                scheme: 'NoSuchScheme',
                report_filepath: File.expand_path('../spec/fixtures/TestReports/report.xml')
              )
            end"
            expect { Fastlane::FastFile.new.parse(fastfile).runner.execute(:test) }.to(
              raise_error(FastlaneCore::Interface::FastlaneError) do |error|
                expect(error.message).to match(/Scheme 'NoSuchScheme' does not exist in Xcode project found at '.*'/)
              end
            )
          end
        end

        context 'with a valid Xcode Swift project' do
          before(:each) do
            tmpdir = Dir.mktmpdir
            @tmp_report_filepath = "#{tmpdir}/TestReports/coin_tossing_report.xml"
            FileUtils.mkdir_p("#{tmpdir}/TestReports")
            report_filepath = File.expand_path('spec/fixtures/TestReports/coin_tossing_report.xml')
            FileUtils.copy(report_filepath, @tmp_report_filepath)

            @tmp_xcodeproj_dirpath = "#{tmpdir}/CoinTossing"
            FileUtils.mkdir_p(@tmp_xcodeproj_dirpath)
            xcodeproj_dirpath = File.expand_path('spec/fixtures/Projects/CoinTossing/.')
            FileUtils.cp_r(xcodeproj_dirpath, tmpdir)
          end

          after(:each) do
            FileUtils.rm_rf(@tmp_report_filepath)
            FileUtils.rm_rf(@tmp_xcodeproj_dirpath)
          end

          it 'suppresses only passing tests found in a test report file in the test suite source file' do
            fastfile = "lane :test do
              setup_fragile_tests_for_rescan(
                project_path: '#{@tmp_xcodeproj_dirpath}/CoinTossing.xcodeproj',
                scheme: 'CoinTossingUITests',
                report_filepath: '#{@tmp_report_filepath}'
              )
            end"

            result = Fastlane::FastFile.new.parse(fastfile).runner.execute(:test)

            scheme_filepath = File.join(Xcodeproj::XCScheme.shared_data_dir("#{@tmp_xcodeproj_dirpath}/CoinTossing.xcodeproj"), "CoinTossingUITests.xcscheme")
            scheme = Xcodeproj::XCScheme.new(scheme_filepath)
            test_action = scheme.test_action
            testable = test_action.testables.find { |t| t.buildable_references[0].buildable_name == "CoinTossingUITests.xctest" }
            actual_skippedtests = testable.skipped_tests.map(&:identifier)
            expect(actual_skippedtests).to include(
              "CoinTossingUITests/testResultIsHeads()"
            )
            expect(actual_skippedtests).not_to include(
              "CoinTossingUITests/testResultIsTails()"
            )
            expect(result).to have_key(:passed_tests)
            expect(result[:passed_tests]).to eq(['CoinTossingUITests/CoinTossingUITests/testResultIsHeads'])
            expect(result).to have_key(:failed_tests)
            expect(result[:failed_tests]).to eq(['CoinTossingUITests/CoinTossingUITests/testResultIsTails'])
          end
        end
      end
    end
  end
end
