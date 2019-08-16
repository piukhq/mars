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
### ios setup
```
fastlane ios setup
```
Retrieve all the certificates for all targets and configures your machine to compile against devices
### ios setupForce
```
fastlane ios setupForce
```
Retrieve and force update all the certificates for all targets and configures your machine to compile against devices, including new ones. NOTE: This should only be run if new devices are required in the profiles and certificates
### ios addDevice
```
fastlane ios addDevice
```
Adds a device to the portal
### ios release
```
fastlane ios release
```
Build for the App Store

You MUST specify a version and build number

eg. fastlane appstore version:1.2.3 build:120

This uploads a build but does not touch any other settings in iTunes Connect such as description
### ios gamma
```
fastlane ios gamma
```
Build and submit Gamma to Fabric
### ios mr
```
fastlane ios mr
```
Build MR and submit to Fabric
### ios nightly
```
fastlane ios nightly
```
Build Nightly and submit to Fabric
### ios dev
```
fastlane ios dev
```
Build the develop branch once a commit has been pushed (or merge request built)

----

This README.md is auto-generated and will be re-generated every time [fastlane](https://fastlane.tools) is run.
More information about fastlane can be found on [fastlane.tools](https://fastlane.tools).
The documentation of fastlane can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
