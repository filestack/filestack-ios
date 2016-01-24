# Filestack for iOS & Mac
## Requirements

- iOS 8.0+ / Mac OS X 10.9+

##Installation
###Using CocoaPods
[CocoaPods](http://cocoapods.org) is a dependency manager for Cocoa projects.

```bash
$ gem install cocoapods
```
To integrate WootricSDK into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
pod "Filestac", "~> 0.1.0"
```
Then, run the following command:

```bash
$ pod install
```

##Usage

#### Methods available:

```objectivec
- initWithApiKey:
- initWithApiKey:andDelegate:
- pickURL:completionHandler:
- remove:completionHandler:
- stat:withOptions:completionHandler:
- storeURL:withOptions:completionHandler:
- store:withOptions:completionHandler:
```

## License

Filestack is released under the MIT license. See LICENSE for details.
