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
or alternatively using `brew install fastlane`

# Available Actions
## iOS
### ios setup
```
fastlane ios setup
```
Retrieve all the certificates for all targets and configures your machine to compile against devices
### ios addDevice
```
fastlane ios addDevice
```
Adds a device to the portal
### ios setupForce
```
fastlane ios setupForce
```
Retrieve and force update all the certificates for all targets and configures your machine to compile against devices, including new ones. NOTE: This should only be run if new devices are required in the profiles and certificates
### ios beta
```
fastlane ios beta
```
Submit branch to TestFlight
### ios beta_dsym
```
fastlane ios beta_dsym
```
Submit dysm to Sentry for Firebase App Distribution

----

This README.md is auto-generated and will be re-generated every time [fastlane](https://fastlane.tools) is run.
More information about fastlane can be found on [fastlane.tools](https://fastlane.tools).
The documentation of fastlane can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
