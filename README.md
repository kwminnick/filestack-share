## Filestack Share

### General information

**Filestack Share** is a simple "demo" app which purpose is to show how [FSPicker](https://github.com/filestack/FSPicker) and [Filestack-ios](https://github.com/filestack/filestack-ios) could be implemented in your application.

You can download this app for iOS at [AppStore](https://itunes.apple.com/en/app/filestack-share/id1134892554).

### Installation for development

This application depends on several ```pods```, to install them, first make sure you have ```Cocoapods``` installed on your machine.

- Clone this repository
- `$ gem install cocoapods`
- `$ pod install`
- Open `FilestackShare.xcworkspace`
- Go to Apple Developer Portal create new application `Bundle identifier`, `Provisioning` and `App Group`
- Change `Bundle Identifier` in General target settings for both targets: `Filestack Share` and `ShareExtension` - same as in Apple Developer Portal
- Set up provisionings for both targets in Target Build Settings  ( or setup Apple Developer team in General target settings )
- Set App Group in target Capabilities for both targets - same as in Apple Developer Portal
- Finally, you need to locate the ```Settings.swift``` file and provide your Filestack api key for ```apiKey``` constant.

**Filestack Share** uses `Crashlytics` framework for automated crash reports. If you'd like to remove it, open `Podfile` and delete lines `pod Fabric` and `pod Crashlytics`, remove lines `import Fabric`, `import Crashlytics` and `Fabric.with([Crashlytics.self])` from `AppDelegate.swift`. After that, run `pod install` again. If you'd like to keep it the way it is, please create account at [fabric.io](https://fabric.io) and follow their installation guide.

## License
Filestack Share is released under the MIT license. See LICENSE for details.
