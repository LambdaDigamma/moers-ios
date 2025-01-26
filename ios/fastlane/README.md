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

### ios increment

```sh
[bundle exec] fastlane ios increment
```

Increment version number

### ios increment_version

```sh
[bundle exec] fastlane ios increment_version
```

Increment version number (patch, minor, major)

### ios increment_build

```sh
[bundle exec] fastlane ios increment_build
```

Increment build number across all targets

### ios build_release

```sh
[bundle exec] fastlane ios build_release
```

Build the iOS app for release

### ios upload_release

```sh
[bundle exec] fastlane ios upload_release
```

Upload to TestFlight / ASC

### ios upload

```sh
[bundle exec] fastlane ios upload
```



### ios load_asc_api_key

```sh
[bundle exec] fastlane ios load_asc_api_key
```

Load ASC API Key information to use in subsequent lanes

### ios upload_metadata

```sh
[bundle exec] fastlane ios upload_metadata
```

Upload metadata to App Store Connect

### ios screenshots

```sh
[bundle exec] fastlane ios screenshots
```

Capture and frame screenshots

### ios upload_screenshots

```sh
[bundle exec] fastlane ios upload_screenshots
```

Upload screenshots to App Store Connect

### ios deliver_screenshots

```sh
[bundle exec] fastlane ios deliver_screenshots
```

Take screenshots and upload to App Store Connect

### ios release

```sh
[bundle exec] fastlane ios release
```

Release a new version of Mein Moers

### ios signing

```sh
[bundle exec] fastlane ios signing
```

Sync code signing for development and app store

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
