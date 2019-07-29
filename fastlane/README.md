fastlane documentation
================
# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```
xcode-select --install
```

Install _fastlane_ using
```
[sudo] gem install fastlane -NV
```
or alternatively using `brew cask install fastlane`

# Available Actions
## iOS
### ios increment
```
fastlane ios increment
```
Increment Version
### ios increment_build
```
fastlane ios increment_build
```
Increment Build Number
### ios test_unit
```
fastlane ios test_unit
```
Run All Unit Tests
### ios test_ui
```
fastlane ios test_ui
```
Run All UI Tests
### ios release
```
fastlane ios release
```
Release a new version of Mein Moers
### ios screenshots
```
fastlane ios screenshots
```
Take Screenshots and Upload them to AppStore Connect

----

This README.md is auto-generated and will be re-generated every time [fastlane](https://fastlane.tools) is run.
More information about fastlane can be found on [fastlane.tools](https://fastlane.tools).
The documentation of fastlane can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
