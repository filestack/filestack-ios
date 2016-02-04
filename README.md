# Filestack for iOS & Mac

## TODO

- [x] pickURL
- [x] Store
- [x] StoreURL
- [x] Stat
- [x] Remove
- [x] Download
- [x] Implement Delegate
- [ ] Progress
- [ ] Filestack's Convert Implementation
- [ ] iOS-picker's FFPickerController Reimplementation
- [ ] Unit Test Coverage
- [ ] Download method response serialization
- [ ] iOS & Mac Example Apps
- [ ] Complete Documentation

## Requirements

- iOS 8.4+ / Mac OS X 10.9+

##Installation
###Using CocoaPods
[CocoaPods](http://cocoapods.org) is a dependency manager for Cocoa projects.

```bash
$ gem install cocoapods
```
To integrate WootricSDK into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
pod "Filestack", "~> 0.1.4"
```
Then, run the following command:

```bash
$ pod install
```

## Usage

#### Available methods:

```objectivec
- initWithApiKey:
- initWithApiKey:andDelegate:
- pickURL:completionHandler:
- remove:completionHandler:
- stat:withOptions:completionHandler:
- download:completionHandler:
- storeURL:withOptions:completionHandler:
- store:withOptions:completionHandler:
```

#### Examples:

```objectivec
// pickURL Example
Filestack *filestack = [[Filestack alloc] initWithApiKey:@"MYAPIKEY"];
NSString *url = @"https://example.com/image.png"

[filestack pickURL:url completionHandler:^(FSBlob *blob, NSError *error) {
    NSLog(@"blob: %@", blob);
    NSLog(@"error: %@", error);
}];

// stat Example
Filestack *filestack = [[Filestack alloc] initWithApiKey:@"MYAPIKEY"];
FSBlob *blob = [[FSBlob alloc] initWithUrl:@"https://cdn.filestackcontent.com/FILEHANDLER"]

[filestack stat:blob withOptions:statOptions completionHandler:^(FSMetadata *metadata, NSError *error) {
    NSLog(@"metadata: %@", metadata);
    NSLog(@"error: %@", error);
}];

// or...
NSString *url = @"https://example.com/image.png"
[filestack pickURL:url completionHandler:^(FSBlob *blob, NSError *error) {
    NSLog(@"blob: %@", blob);
    NSLog(@"error: %@", error);
    if (error == nil) {
        [filestack stat:blob withOptions:nil completionHandler:^(FSMetadata *metadata, NSError *error) {
            NSLog(@"metadata: %@", metadata);
            NSLog(@"error: %@", error);
        }];
    }
}];
```

#### FSBlob class:

Filestack's "blob". Object available in completionHandler of most of the methods after successful request, standard JSON containing information about the file, serialized to this class.

Properties are as follows:
- **url** (NSString)
  - The most critical part of the file, the url points to where the file is stored and acts as a sort of "file path".
- **fileName** (NSString)
  - The name of the file, if available
- **mimeType** (NSString)
  - The mimetype of the file, if available.
- **size** (NSInteger)
  - The size of the file in bytes, if available.
- **key** (NSString)
  - If the file was stored in one of the file stores you specified or configured (S3, Rackspace, Azure, etc.), this parameter will tell you where in the file store this file was put.
- **container** (NSString)
  - If the file was stored in one of the file stores you specified or configured (S3, Rackspace, Azure, etc.), this parameter will tell you in which container this file was put.
- **path** (NSString)
  - The path of the Blob indicates its position in the hierarchy of files uploaded.
- **writeable** (NSNumber)
  - This flag specifies whether the underlying file is writeable. In most cases this will be true, but if a user uploads a photo from Facebook, for instance, the original file cannot be written to.
  - This will return either ```0```, ```1``` or ```nil``` if the flag is unknown or wasn't returned from the request.
- **s3url** (NSString, readonly)
  - ("Experimental") The direct path to the file on S3, if available. This will return invalid link if the file was stored on different storage.

#### FSMetadata class:

"Read-only" class available in completionHandler of ```stat:withOptions:completionHandler:``` or in ```filestackStatSuccess:``` delegate method if request was successful.

Properties you can access:
- **size** (NSInteger)
- **mimeType** (NSString)
- **fileName** (NSString)
- **width** (NSInteger)
- **height** (NSInteger)
- **uploaded** (NSInteger)
- **writeable** (NSNumber)
- **md5** (NSString)
- **location** (NSString)
- **path** (NSString)
- **container** (NSString)
- **s3url** (NSString, experimental)

#### FSStatOptions class:

Convenience class to create options object for ```stat:withOptions:completionHandler:``` method. An optional object that specify what metadata you want back. By default, we return any metadata we get without having to run over the contents of the file (currently: size, mimetype, filename, uploaded, writeable, location, path, container).
FSStatOptions can be initialized with either ```NSDictionary``` or by default ```[[FSStatOptions alloc] init]``` and then setting the values "by hand". All variables are BOOL.

```objectivec
// Example
FSStatOptions *options = [[FSStatOptions alloc] init];
options.mimeType = YES;
options.md5 = YES;

// Example
FSStatOptions *options = [[FSStatOptions alloc] initWithDictionary:@{@"mimetype": @YES, @"md5": @YES};
```

Available dictionary keys (and properties):
- **size**
  - Specify that you want the size of the file returned, as a number in bytes.
- **mimetype** (mimeType if get/set as property)
  - Specify that you want the type of the file returned, as a string.
- **filename** (fileName if get/set as property)
  - Specify that you want the name of the file returned, as a string.
- **width**
  - Specify that you want the width of the image returned, as a number in pixels. If the file is not an image, width is set to 0.
- **height**
  - Specify that you want the height of the image returned, as a number in pixels. If the file is not an image, height is set to 0.
- **uploaded**
  - Specify that you want the timestamp of when the file was uploaded to Filestack, UNIX Timestamp to miliseconds (13 digit long).
- **writeable**
  - Specify that you want whether the file is writeable, as a BOOL.
- **md5**
  - Specify that you want to know the md5 hash of the file returned, as a string.
- **location**
  - Specify that you want to know the storage location (S3, etc.) of a stored file, if available, as a string.
- **path**
  - Specify that you want to know the storage path of a stored file, if available, as a string.
- **container**
  - Specify that you want to know the storage container of a stored file, if available, as a string.

#### FSStoreOptions class

Convenience class to create options object for ```store:withOptions:completionHandler:``` and ```storeURL:withOptions:completionHandler:``` methods. An optional object that configure how to store the data. FSStoreOptions can be initialized with either ```NSDictionary``` or by default ```[[FSStoreOptions alloc] init]``` and then setting the values "by hand".

```objectivec
// Example
FSStoreOptions *options = [[FSStoreOptions alloc] init];
options.location = FSStoreLocationS3;
options.fileName = @"myFile.png";

// Example
FSStoreOptions *options = [[FSStoreOptions alloc] initWithDictionary:@{@"location": FSStoreLocationS3, @"filename": @"myFile.png"};
```

Available dictionary keys (and properties):
- **filename** (fileName if get/set as property, NSString)
  - The name of the file as it will be stored. If this isn't provided, we do the best we can to come up with one.
- **mimetype** (mimeType if get/set as property, NSString, unavailable in ```storeURL``` method)
  - The type of the file as it will be stored. If this isn't provided, we do the best we can, defaulting to "application/octet-stream" if you give us raw data.
- **location** (FSStoreLocation typedef of NSString, FSStoreLocationAzure, FSStoreLocationDropbox, FSStoreLocationRackspace or FSStoreLocationGoogleCloud)
  - Where to store the file. The default is S3 (FSStoreLocationS3). Other options are 'azure', 'dropbox', 'rackspace' and 'gcs' (```FSStoreLocationAzure```, ```FSStoreLocationDropbox```, ```FSStoreLocationRackspace``` and ```FSStoreLocationGoogleCloud```). You must have configured your storage in the developer portal to enable this feature.
- **path** (NSString)
  - The path to store the file at within the specified file store. For S3, this is the key where the file will be stored at. By default, Filestack stores the file at the root at a unique id, followed by an underscore, followed by the filename, for example "3AB239102DB_myphoto.png". If the provided path ends in a '/', it will be treated as a folder, so if the provided path is "myfiles/" and the uploaded file is named "myphoto.png", the file will be stored at "myfiles/909DFAC9CB12_myphoto.png", for example.
- **container** (NSString)
  - The bucket or container in the specified file store where the file should end up. This is especially useful if you have different containers for testing and production and you want to use them both on the same Filestack app. If this parameter is omitted, the file is stored in the default container specified in your developer portal. Note that this parameter does not apply to the Dropbox file store.
- **access** (FSAccess typedef of NSString, either FSAccessPublic or FSAccessPrivate, unavailable in ```storeURL``` method)
  - Indicates that the file should be stored in a way that allows public access going directly to the underlying file store. For instance, if the file is stored on S3, this will allow the S3 url to be used directly. This has no impact on the ability of users to read from the Filestack file URL. Defaults to 'private'.
- **base64decode** (BOOL)
  - Specify that you want the data to be first decoded from base64 before being written to the file. For example, if you have base64 encoded image data, you can use this flag to first decode the data before writing the image file.
- **security** (FSSecurity)
  - If you have security enabled, you'll need to have a valid Filestack.com policy and signature in order to perform the requested call. This allows you to select who can and cannot perform certain actions on your site. [Read more about security and how to generate policies and signatures](https://www.filestack.com/docs/security)

#### FSSecurity class

A simple class to store your security policy and signature. **FSSecurity** instance is a ```security``` parameter in **FSStoreOptions**.
[Read more about security and how to generate policies and signatures](https://www.filestack.com/docs/security)

```- initWithPolicy:andSignature:```

## License

Filestack for iOS & Mac is released under the MIT license. See LICENSE for details.

