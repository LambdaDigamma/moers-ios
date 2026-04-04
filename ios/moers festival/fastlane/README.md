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

### ios load_asc_api_key

```sh
[bundle exec] fastlane ios load_asc_api_key
```

Load ASC API Key from base64 env var

### ios register_dev_devices

```sh
[bundle exec] fastlane ios register_dev_devices
```

Register development devices with Apple Developer Portal

### ios match_appstore

```sh
[bundle exec] fastlane ios match_appstore
```

Sync appstore certificates and provisioning profiles

### ios match_development

```sh
[bundle exec] fastlane ios match_development
```

Sync development certificates and provisioning profiles

### ios signing

```sh
[bundle exec] fastlane ios signing
```

Register devices and sync all certificates

### ios increment_build

```sh
[bundle exec] fastlane ios increment_build
```

Increment build number across all targets

### ios increment_version

```sh
[bundle exec] fastlane ios increment_version
```

Increment version number (type: patch, minor, or major)

### ios build_release

```sh
[bundle exec] fastlane ios build_release
```

Build the app for release

### ios upload_testflight

```sh
[bundle exec] fastlane ios upload_testflight
```

Upload build to TestFlight

### ios upload_release_notes

```sh
[bundle exec] fastlane ios upload_release_notes
```

Upload release notes to App Store Connect

### ios ensure_app_version

```sh
[bundle exec] fastlane ios ensure_app_version
```

Create a new App Store version if needed

### ios upload

```sh
[bundle exec] fastlane ios upload
```

Sign, build, and upload to TestFlight

### ios release

```sh
[bundle exec] fastlane ios release
```

Bump version, build, and upload to TestFlight

### ios capture

```sh
[bundle exec] fastlane ios capture
```

Capture raw screenshots from simulator (config from Snapfile)

### ios render_stills

```sh
[bundle exec] fastlane ios render_stills
```

Render processed stills via Remotion

### ios replace_screenshots

```sh
[bundle exec] fastlane ios replace_screenshots
```

Copy Remotion-rendered stills into the snapshots folder for upload

### ios upload_screenshots

```sh
[bundle exec] fastlane ios upload_screenshots
```

Upload screenshots to App Store Connect

### ios screenshots_pipeline

```sh
[bundle exec] fastlane ios screenshots_pipeline
```

Full screenshot pipeline: capture, render, replace, upload

### ios increment_tvos

```sh
[bundle exec] fastlane ios increment_tvos
```

Increment tvOS version

### ios increment_build_tvos

```sh
[bundle exec] fastlane ios increment_build_tvos
```

Increment tvOS build number

### ios match_dev_tvos

```sh
[bundle exec] fastlane ios match_dev_tvos
```

Sync development certificates for tvOS

### ios release_tvos

```sh
[bundle exec] fastlane ios release_tvos
```

Release a new version for tvOS

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
