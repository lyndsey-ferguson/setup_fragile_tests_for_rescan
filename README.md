# ❗ setup_fragile_tests_for_rescan plugin is deprecated ❗

![Deprecated](https://cdn.pixabay.com/photo/2014/12/29/14/02/classic-car-582812_960_720.jpg)

Please use the `:suppress_tests_from_junit` and `:multi_scan` actions shipped with the [`test_center`](https://github.com/lyndsey-ferguson/fastlane-plugin-test_center) plugin

![fastlane Plugin Badge](https://img.shields.io/badge/setup__fragile__tests__for__rescan-deprecated-red.svg)

## Getting Started

This project is a [fastlane](https://github.com/fastlane/fastlane) plugin. To get started with `fastlane-plugin-setup_fragile_tests_for_rescan`, add it to your project by running:

```bash
fastlane add_plugin setup_fragile_tests_for_rescan
```

## About setup_fragile_tests_for_rescan

Xcode UI tests are notoriously fragile. This plugin examines the junit
test report that is produced by the `scan` action to suppress all passing
tests in preparation to re-scan the tests that failed to determine if they
were really failing or only failing because of Xcode's unstable test framework.

## Example

Check out the [example `Fastfile`](fastlane/Fastfile) to see how to use this plugin. Try it by cloning the repo, running `fastlane install_plugins` and `bundle exec fastlane test`.


## Run tests for this plugin

To run both the tests, and code style validation, run

```
rake
```

To automatically fix many of the styling issues, use
```
rubocop -a
```

## Issues and Feedback

For any other issues and feedback about this plugin, please submit it to this repository.

## Troubleshooting

If you have trouble using plugins, check out the [Plugins Troubleshooting](https://github.com/fastlane/fastlane/blob/master/fastlane/docs/PluginsTroubleshooting.md) doc in the main `fastlane` repo.

## Using `fastlane` Plugins

For more information about how the `fastlane` plugin system works, check out the [Plugins documentation](https://github.com/fastlane/fastlane/blob/master/fastlane/docs/Plugins.md).

## About `fastlane`

`fastlane` is the easiest way to automate beta deployments and releases for your iOS and Android apps. To learn more, check out [fastlane.tools](https://fastlane.tools).
