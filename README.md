# Filestack iOS SDK

<a href="https://www.filestack.com"><img src="https://filestack.com/themes/filestack/assets/images/press-articles/color.svg" align="left" hspace="10" vspace="6"></a>
This is the official Swift iOS for Filestack — API and content management system that makes it easy to add powerful file uploading and transformation capabilities to any web or mobile application.

## Resources

* [Filestack](https://www.filestack.com)
* [Documentation](https://www.filestack.com/docs)
* [API Reference](https://filestack.github.io/filestack-ios/)

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
    pod 'Filestack', '~> 0.5-pre2'
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

`github "filestack/filestack-ios" ~> 0.5-pre2`

Run `carthage update` to build the framework and drag the built `Filestack.framework` into your Xcode project. Additionally, add `Filestack.framework`, `FilestackSDK.framework`, `Alamofire.framework`, and `Arcane.framework` to the embedded frameworks build phase of your app's target.

### Manually

#### Embedded Framework

Open up Terminal, cd into your top-level project directory, and run the following command "if" your project is not initialized as a git repository:

`$ git init`

Add Filestack and its dependencies as git submodules by running the following commands:

```shell
$ git submodule add https://github.com/filestack/filestack-ios.git
$ git submodule add https://github.com/filestack/filestack-swift.git
$ git submodule add https://github.com/Alamofire/Alamofire.git
$ git submodule add https://github.com/onmyway133/Arcane.git
```

Open the new `filestack-ios` folder, and drag the `Filestack.xcodeproj` into the Project Navigator of your application's Xcode project.

It should appear nested underneath your application's blue project icon. Whether it is above or below all the other Xcode groups does not matter.
Select the `Filestack.xcodeproj` in the Project Navigator and verify the deployment target matches that of your application target.

Next, select your application project in the Project Navigator (blue project icon) to navigate to the target configuration window and select the application target under the "Targets" heading in the sidebar.

In the tab bar at the top of that window, open the "General" panel.

Click on the + button under the "Embedded Binaries" section and choose the `Filestack.framework` for iOS.

Repeat the same process for adding `Alamofire`, `Arcane`, and `FilestackSDK` dependent frameworks.

## Usage

### Importing Required Frameworks

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

let filestack = Filestack(apiKey: "YOUR-API-KEY", security: security)
```

### Uploading Local Files

```swift
let localURL = URL(string: "file:///an-app-sandbox-friendly-local-url")!

let uploadRequest = filestack.upload(from: localURL, uploadProgress: { (progress) in
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

### Uploading Photos and Videos from the Photo Library or Camera

```swift
// The view controller that will be presenting the image picker.
let presentingViewController = self

// The source type (e.g. `.camera`, `.photoLibrary`)
let sourceType: UIImagePickerControllerSourceType = .camera

let uploadRequest = filestack.uploadFromImagePicker(viewController: presentingViewController, sourceType: sourceType, uploadProgress: { (progress) in
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

In both uploading examples, an upload may be cancelled at anytime by calling `cancel()` on the `MultipartUpload` object returned by any of the functions above:

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

filestack.folderList(provider: provider, path: path, pageToken: nil, appURLScheme: appURLScheme) { response in
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

Please also make sure to add the following function to your `AppDelegate` to allow resuming any folder list request after authentication against a cloud provider. Again, the `appURLScheme` must be set to an URL scheme your app is registered to handle:

```swift
func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {

    if url.scheme?.lowercased() == appURLScheme.lowercased() && url.host == "Filestack" {
        NotificationCenter.default.post(name: Filestack.resumeCloudRequestNotification, object: url)
    }
    
    // Your custom handling here.

    return true
}
```

### Storing contents from a cloud provider into a store location

```swift
// The cloud provider to use
let provider: CloudProvider = .googleDrive

// A path to a file in the cloud
let path = "/some-large-image.jpg"

// The store options representing the store location, region, access, etc. for your file store.
let storeOptions = StorageOptions(location: .dropbox)

filestack.store(provider: provider, path: path, storeOptions: storeOptions) { (response) in
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

### Notes

- Some of the functions above support additional optional parameters, consult the [API Reference](https://filestack.github.io/filestack-ios/Classes/Filestack.html) for more details.

## Versioning

Filestack iOS SDK follows the [Semantic Versioning](http://semver.org/).

## Issues

If you have problems, please create a [Github Issue](https://github.com/filestack/filestack-ios/issues).

## Contributing

Please see [CONTRIBUTING.md](https://github.com/filestack/filestack-ios/blob/master/CONTRIBUTING.md) for details.

## Credits

Thank you to all the [contributors](https://github.com/filestack/filestack-ios/graphs/contributors).
