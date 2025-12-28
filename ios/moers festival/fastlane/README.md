fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

## iOS

### ios signing

```sh
[bundle exec] fastlane ios signing
```

Sync signing

### ios increment

```sh
[bundle exec] fastlane ios increment
```

Increment Version

### ios increment_build

```sh
[bundle exec] fastlane ios increment_build
```

Increment Build Number

### ios test_unit

```sh
[bundle exec] fastlane ios test_unit
```

Run All Unit Tests

### ios test_ui

```sh
[bundle exec] fastlane ios test_ui
```

Run All UI Tests

### ios release

```sh
[bundle exec] fastlane ios release
```

Release a new version of moers festival

### ios screenshots

```sh
[bundle exec] fastlane ios screenshots
```

Take screenshots

### ios upload_screenshots

```sh
[bundle exec] fastlane ios upload_screenshots
```

Upload screenshots

### ios increment_tvos

```sh
[bundle exec] fastlane ios increment_tvos
```

Increment Version tvOS

### ios increment_build_tvos

```sh
[bundle exec] fastlane ios increment_build_tvos
```

Increment Build Number

### ios release_tvos

```sh
[bundle exec] fastlane ios release_tvos
```

Release a new version of moers festival for tvOS

### ios match_dev_tvos

```sh
[bundle exec] fastlane ios match_dev_tvos
```

Match Development Certificate tvOS

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
