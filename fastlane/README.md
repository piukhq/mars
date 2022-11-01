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

### ios setup

```sh
[bundle exec] fastlane ios setup
```

Retrieve all the certificates for all targets and configures your machine to compile against devices

### ios addDevice

```sh
[bundle exec] fastlane ios addDevice
```

Adds a device to the portal

### ios setupForce

```sh
[bundle exec] fastlane ios setupForce
```

Retrieve and force update all the certificates for all targets and configures your machine to compile against devices, including new ones. NOTE: This should only be run if new devices are required in the profiles and certificates

### ios mr

```sh
[bundle exec] fastlane ios mr
```

Submit merge request build to TestFlight

### ios nightly

```sh
[bundle exec] fastlane ios nightly
```

Submit nightly Develop build to TestFlight

### ios develop

```sh
[bundle exec] fastlane ios develop
```

Submit Develop build to TestFlight

### ios beta

```sh
[bundle exec] fastlane ios beta
```

Submit production build to TestFlight

### ios bump

```sh
[bundle exec] fastlane ios bump
```

Increment the build number and commit to git

### ios beta_dsym

```sh
[bundle exec] fastlane ios beta_dsym
```

Submit dysm to Sentry for Firebase App Distribution

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
