# Filestack iOS SDK

<a href="https://www.filestack.com"><img src="https://filestack.com/themes/filestack/assets/images/press-articles/color.svg" align="left" hspace="10" vspace="6"></a>
This is the official Swift iOS for Filestack — API and content management system that makes it easy to add powerful file uploading and transformation capabilities to any web or mobile application.

## Resources

* [Filestack](https://www.filestack.com)
* [Documentation](https://www.filestack.com/docs)
* [API Reference](https://filestack.github.io/filestack-ios/)

## Requirements

* Xcode 8.3 or later
* Swift 3.2 / Objective-C
* iOS 9 or later

## Installing

### CocoaPods

[CocoaPods](http://cocoapods.org/) is a dependency manager for Cocoa projects. You can install it with the following command:

`$ gem install cocoapods`

To integrate Filestack into your Xcode project using CocoaPods, specify it in your `Podfile`:

```
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '9.0'
use_frameworks!

target '<Your Target Name>' do
    pod 'Filestack', '~> 1.0'
end
```

Then, run the following command:

`$ pod install`

### Carthage

[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager that builds your dependencies and provides you with binary frameworks.

You can install Carthage with [Homebrew](http://brew.sh/) using the following command:

```
$ brew update
$ brew install carthage
```

To integrate Filestack into your Xcode project using Carthage, specify it in your `Cartfile`:

`github "filestack/filestack-ios" ~> 1.0`

Run `carthage update` to build the framework and drag the built `Filestack.framework` into your Xcode project. Additionally, add `Filestack.framework`, `FilestackSDK.framework`, `Alamofire.framework`, and `CryptoSwift.framework` to the embedded frameworks build phase of your app's target.

### Manually

#### Embedded Framework

Open up Terminal, cd into your top-level project directory, and run the following command "if" your project is not initialized as a git repository:

`$ git init`

Add Filestack and its dependencies as git submodules by running the following commands:

```shell
$ git submodule add https://github.com/filestack/filestack-ios.git
$ git submodule add https://github.com/filestack/filestack-swift.git
$ git submodule add https://github.com/Alamofire/Alamofire.git
$ git submodule add https://github.com/krzyzanowskim/CryptoSwift.git
```

Open the new `filestack-ios` folder, and drag the `Filestack.xcodeproj` into the Project Navigator of your application's Xcode project.

It should appear nested underneath your application's blue project icon. Whether it is above or below all the other Xcode groups does not matter.
Select the `Filestack.xcodeproj` in the Project Navigator and verify the deployment target matches that of your application target.

Next, select your application project in the Project Navigator (blue project icon) to navigate to the target configuration window and select the application target under the "Targets" heading in the sidebar.

In the tab bar at the top of that window, open the "General" panel.

Click on the + button under the "Embedded Binaries" section and choose the `Filestack.framework` for iOS.

Repeat the same process for adding `Alamofire`, `CryptoSwift`, and `FilestackSDK` dependent frameworks.

## Usage

### Importing required frameworks

Any source files that need to use the Filestack iOS SDK should import the `Filestack` and `FilestackSDK` frameworks:

```swift
import Filestack
import FilestackSDK
```

### Instantiating a Filestack object

```swift
// Initialize a `Policy` with the expiry time and permissions you need.
let oneDayInSeconds: TimeInterval = 60 * 60 * 24 // expires tomorrow
let policy = Policy(// Set your expiry time (24 hours in our case)
                    expiry: Date(timeIntervalSinceNow: oneDayInSeconds),
                    // Set the permissions you want your policy to have
                    call: [.pick, .read, .store])

// Initialize a `Security` object by providing a `Policy` object and your app secret.
// You can find and/or enable your app secret in the Developer Portal.
guard let security = try? Security(policy: policy, appSecret: "YOUR-APP-SECRET") else {
    return
}

// Create `Config` object.
let config = Filestack.Config()

// Make sure to assign an app scheme URL that matches the one configured in your info.plist.
config.appURLScheme = "filestackdemo"

let client = Filestack.Client(apiKey: "YOUR-API-KEY", security: security, config: config)
```

### Uploading local files

```swift
let localURL = URL(string: "file:///an-app-sandbox-friendly-local-url")!

let uploadRequest = client.upload(from: localURL, uploadProgress: { (progress) in
    // Here you may update the UI to reflect the upload progress.
    print("progress = \(String(describing: progress))")
}) { (response) in
    // Try to obtain Filestack handle
    if let json = response?.json, let handle = json["handle"] as? String {
        // Use Filestack handle
    } else if let error = response?.error {
        // Handle error
    }
}
```

### Uploading photos and videos from the Photo Library or Camera

```swift
// The view controller that will be presenting the image picker.
let presentingViewController = self

// The source type (e.g. `.camera`, `.photoLibrary`)
let sourceType: UIImagePickerControllerSourceType = .camera

let uploadRequest = client.uploadFromImagePicker(viewController: presentingViewController, sourceType: sourceType, uploadProgress: { (progress) in
    // Here you may update the UI to reflect the upload progress.
    print("progress = \(String(describing: progress))")
}) { (response) in
    // Try to obtain Filestack handle
    if let json = response?.json, let handle = json["handle"] as? String {
        // Use Filestack handle
    } else if let error = response?.error {
        // Handle error
    }
}
```

### Uploading files from device, iCloud Drive or another third-party cloud provider

```swift
// The view controller that will be presenting the image picker.
let presentingViewController = self

let uploadRequest = client.uploadFromDocumentPicker(viewController: presentingViewController, uploadProgress: { (progress) in
    // Here you may update the UI to reflect the upload progress.
    print("progress = \(String(describing: progress))")
}) { (response) in
    // Try to obtain Filestack handle
    if let json = response?.json, let handle = json["handle"] as? String {
        // Use Filestack handle
    } else if let error = response?.error {
        // Handle error
    }
}
```

In all the previous uploading examples, an upload may be cancelled at anytime by calling `cancel()` on the `CancellableRequest` conforming object returned by any of the functions above:

```swift
uploadRequest.cancel()
```

### Listing contents from a cloud provider

```swift
// The cloud provider to use (it may require authentication)
let provider: CloudProvider = .googleDrive

// The cloud provider's path (e.g. "/" for the root's folder)
let path = "/"

// An URL scheme that your app can handle.
let appURLScheme = "FilestackDemo"

client.folderList(provider: provider, path: path, pageToken: nil) { response in
    if let error = response.error {
        // Handle error
        return
    }

    if let contents = response.contents {
        // Contents received — do something with them.
        print("Received \(contents.count) entries.")
    }

    if let nextToken = response.nextToken {
    	 // More contents are available — to retrieve next page, pass this `nextToken` as a parameter in the `folderList` function.
    } else {
    	 // No more contents available — we are done.
    }
}
```

Remember also to add this piece of code to your `AppDelegate` so the auth flow can complete:

```swift
func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {

    if url.scheme == "YOUR-APP-URL-SCHEME" && url.host == "Filestack" {
        if #available(iOS 11.0, *) {
            // NO-OP
        } else {
            NotificationCenter.default.post(name: Filestack.Client.resumeCloudRequestNotification,
                                            object: url)
        }

        return true
    }

    // Here we just state that any other URLs should not be handled by this app.
    return false
}
```

### Storing contents from a cloud provider into a store location

```swift
// The cloud provider to use
let provider: CloudProvider = .googleDrive

// A path to a file in the cloud
let path = "/some-large-image.jpg"

// Store options for your uploaded files.
// Here we are saying our storage location is S3 and access for uploaded files should be public.
let storeOptions = StorageOptions(location: .s3, access: .public)

client.store(provider: provider, path: path, storeOptions: storeOptions) { (response) in
    if let error = response.error {
        // Handle error
        return
    }

    if let contents = response.contents {
        // Contents received describing the request's result.
    }
}
```

Please make sure to authenticate against the cloud provider first by using the `folderList` function before calling `store`.


### Launching picker UI

This is a code fragment broken into pieces taken from the [Demo app](https://github.com/filestack/filestack-ios/tree/master/Demo) describing the process of launching the picker UI using some of the most relevant config options:

#### 1. Setting up Policy and Security objects

```swift
// In case your Filestack account has security enabled, you will need to instantiate a `Security` object.
// We can do this by either configuring a `Policy` and instantiating a `Security` object by passing
// the `Policy` and an `appSecret`, or by instantiating a `Security` object directly by passing an already
// encoded policy together with its corresponding signature — in this example, we will use the 1st method.

// Create `Policy` object with an expiry time and call permissions.
let policy = Policy(expiry: .distantFuture,
                    call: [.pick, .read, .stat, .write, .writeURL, .store, .convert, .remove, .exif])

// Create `Security` object based on our previously created `Policy` object and app secret obtained from
// [Filestack Developer Portal](https://dev.filestack.com/).
guard let security = try? Security(policy: policy, appSecret: "YOUR-APP-SECRET-HERE") else {
    fatalError("Unable to instantiate Security object.")
}
```

#### 2. Setting up Config object

```swift
// Create `Config` object.
let config = Filestack.Config()

// IMPORTANT: - Make sure to assign an app scheme URL that matches the one(s) configured in your info.plist
config.appURLScheme = "YOUR-APP-URL-SCHEME"

// Video quality for video recording (and sometimes exporting.)
config.videoQuality = .typeHigh

if #available(iOS 11.0, *) {
    // On iOS 11, you can export images in HEIF or JPEG by setting this value to `.current` or `.compatible`
    // respectively.
    // Here we state we prefer HEIF for image export.
    config.imageURLExportPreset = .current
    // On iOS 11, you can decide what format and quality will be used for exported videos.
    // Here we state we want to export HEVC at the highest quality.
    config.videoExportPreset = AVAssetExportPresetHEVCHighestQuality
}

// Here you can enumerate the available local sources for the picker.
// If you simply want to enumerate all the local sources, you may use `LocalSource.all()`, but if you would
// like to enumerate, let's say the camera source only, you could set it like this:
//
//   config.availableLocalSources = [.camera]
//
config.availableLocalSources = LocalSource.all()

// Here you can enumerate the available cloud sources for the picker.
// If you simply want to enumerate all the cloud sources, you may use `CloudSource.all()`, but if you would
// like to enumerate selected cloud sources, you could set these like this:
//
//   config.availableCloudSources = [.dropbox, .googledrive, .googlephotos, .customSource]
//
config.availableCloudSources = CloudSource.all()
```

#### 3. Setting up Client object

```swift
// Instantiate the Filestack `Client` by passing an API key obtained from [Filestack Developer Portal](https://dev.filestack.com/),
// together with a `Security` and `Config` object.
// If your account does not have security enabled, then you can omit this parameter or set it to `nil`.
let client = Filestack.Client(apiKey: "YOUR-API-KEY-HERE", security: security, config: config)
```

#### 4. Instantiating the picker with custom storage options

```swift
// Store options for your uploaded files.
// Here we are saying our storage location is S3 and access for uploaded files should be public.
let storeOptions = StorageOptions(location: .s3, access: .public)

// Instantiate picker by passing the `StorageOptions` object we just set up.
let picker = client.picker(storeOptions: storeOptions)
```

#### 5. Presenting the picker on the screen

```swift
yourViewController.present(picker, animated: true)
```

Finally, remember that you'll need this piece of code in your `AppDelegate` for the auth flow to complete:

```swift
func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {

    if url.scheme == "YOUR-APP-URL-SCHEME" && url.host == "Filestack" {
        if #available(iOS 11.0, *) {
            // NO-OP
        } else {
            NotificationCenter.default.post(name: Filestack.Client.resumeCloudRequestNotification,
                                            object: url)
        }

        return true
    }

    // Here we just state that any other URLs should not be handled by this app.
    return false
}
```

### Final notes on usage

- Some of the functions and objects used above support additional parameters and properties, consult the [API Reference](https://filestack.github.io/filestack-ios/) for more details.

## Demo

Check the [Demo app](https://github.com/filestack/filestack-ios/tree/master/Demo) for an example on how to launch the picker UI with all the settings and options discussed above.

## Versioning

Filestack iOS SDK follows the [Semantic Versioning](http://semver.org/).

## Issues

If you have problems, please create a [Github Issue](https://github.com/filestack/filestack-ios/issues).

## Contributing

Please see [CONTRIBUTING.md](https://github.com/filestack/filestack-ios/blob/master/CONTRIBUTING.md) for details.

## Credits

Thank you to all the [contributors](https://github.com/filestack/filestack-ios/graphs/contributors).
