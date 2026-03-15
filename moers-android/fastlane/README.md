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

### ios upload

```sh
[bundle exec] fastlane ios upload
```



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

----


## Android

### android increment_version_code

```sh
[bundle exec] fastlane android increment_version_code
```

Increment version code (Build number)

### android increment_version

```sh
[bundle exec] fastlane android increment_version
```

Increment version (Version name)

### android test

```sh
[bundle exec] fastlane android test
```

Runs all the tests

### android debug_build

```sh
[bundle exec] fastlane android debug_build
```

Build a debug APK

### android deploy_internal

```sh
[bundle exec] fastlane android deploy_internal
```

Deploy a new version to internal track

### android deploy_beta

```sh
[bundle exec] fastlane android deploy_beta
```

Deploy a new version to beta track

### android deploy_production

```sh
[bundle exec] fastlane android deploy_production
```

Deploy a new version to production track

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
