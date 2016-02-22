# Filestack for iOS & Mac

[![CocoaPods](https://img.shields.io/cocoapods/v/Filestack.svg)]() [![CocoaPods](https://img.shields.io/cocoapods/p/Filestack.svg)]()

- Table of contents
  - [TODO](#todo)
  - [Requirements](#requirements)
  - [Installation](#installation)
  - [Usage](#usage)
  - [Image Transformations](#image-transformations)

## TODO

- [x] pickURL
- [x] Store
- [x] StoreURL
- [x] Stat
- [x] Remove
- [x] Download
- [x] Implement Delegate
- [x] Filestack's Transformations Implementation
- [x] Store Progress
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
To integrate Filestack into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
pod "Filestack", "~> 0.2.8"
```
Then, run the following command:

```bash
$ pod install
```

## Usage

#### Available methods:

```objectivec
- initWithApiKey:
- initWithApiKey:delegate:
- pickURL:completionHandler:
- remove:completionHandler:
- stat:withOptions:completionHandler:
- download:completionHandler:
- storeURL:withOptions:completionHandler:
- store:withOptions:progress:completionHandler:
- transformURL:transformation:security:completionHandler:
```

#### Delegate methods:

```objectivec
// FSFilestackDelegate
- filestackTransformSuccess:
- filestackTransformSuccessJSON:
- filestackStatSuccess:
- filestackDownloadSuccess:
- filestackRequestError:
- filestackPickURLSuccess:
- filestackStoreSuccess:
- filestackRemoveSuccess
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
]
[filestack stat:blob withOptions:nil completionHandler:^(FSMetadata *metadata, NSError *error) {
    NSLog(@"metadata: %@", metadata);
    NSLog(@"error: %@", error);
}];

// or...
NSString *url = @"https://example.com/image.png"
[filestack pickURL:url completionHandler:^(FSBlob *blob, NSError *error) {
    if (error) {
        NSLog(@"error: %@", error);
    } else {
        NSLog(@"blob: %@", blob);
        FSStatOptions *options = [[FSStatOptions alloc] initWithDictionary:@{@"mimetype": @YES, @"md5": @YES};
        [filestack stat:blob withOptions:options completionHandler:^(FSMetadata *metadata, NSError *error) {
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

```- initWithPolicy:signature:```

## Image Transformations

> Filestack's transformation engine brings the addition of more complicated transformations in a powerful and flexible package. Gone is the requirement that you have a Filestack URL before you can convert a file. Now you can pass us any publicly accessible URL and we will slice and dice it into the format you need. Your conversions can also be more sophisticated as we have created a conversion task router that allows for a real order of operations for file conversions. So now you can make sure your image is cropped before it is resized, or resized before it is cropped, or even resized before it is cropped, rotated and watermarked.

> https://www.filestack.com/docs/image-transformations/image-transformations

#### **FSTransformation**

```FSTransformation``` is the main transformations class. You are building your final transformation by adding ```FSTransform``` objects to the instance of ```FSTransformation```.

```objectivec
FSTransformation *transformation = [[FSTransformation alloc] init];
FSResize *resize = [[FSResize alloc] initWithWidth:@150 height:nil fit:FSResizeFitClip align:FSResizeAlignFaces];

[transformation add:resize];
```

**properties:**
```objectivec
BOOL debug
```

**initializers:**
```objectivec
- initWithQueryString:
```

```- initWithQueryString:``` can be used if you have prepared the query yourself, for example you have a blur faces and torn edges transformations string ready ```"blur_faces=maxsize:0.35,type:oval,faces:[1,2]/torn_edges=spread:[10,10]"``` in this case you can initialize ```FSTransformation``` like this:

```objectivec
FSTransformation *transformation = [[FSTransformation alloc] initWithQueryString:@"blur_faces=maxsize:0.35,type:oval,faces:[1,2]/torn_edges=spread:[10,10]"];
```

so you don't have to create and add ```FSBlurFaces``` and ```FSTornEdges``` to ```FSTransformation``` instance.

**methods:**
```objectivec
- add:
- transformationURLWithApiKey:URLToTransform:
```

```- add:``` is the main method you are going to use to add a single transformation to the "transformations collection".

```- transformationURLWithApiKey:security:URLToTransform:``` will return a complete url for provided api key, security, url to transform and all transformations currently "in collection". For example:
```objectivec
NSString *urlToTransform = @"https://d1wtqaffaaj63z.cloudfront.net/images/Portrait_of_ASTP_crews.jpg";
FSTransformation *transformation = [[FSTransformation alloc] init];
FSBlurFaces *blurFaces = [[FSBlurFaces alloc] initWithMinSize:nil maxSize:@0.35 type:FSPBlurFacesTypeOval buffer:nil blurAmount:nil obscureAmount:nil faces:@[@1, @2]];
FSTornEdges *tornEdges = [[FSTornEdges alloc] initWithSpread:@[@10, @10] background:nil];

[transformation add:blurFaces];
[transformation add:tornEdges];

NSString *transformationURL = [transformation transformationURLWithApiKey:@"APIKEY" security:nil URLToTransform:urlToTransform];

// NSLog("%@", transformationURL);
// https://process.filestackapi.com/APIKEY/blur_faces=maxsize:0.350000,type:oval,faces:[1,2]/torn_edges=spread:[10,10]/https://d1wtqaffaaj63z.cloudfront.net/images/Portrait_of_ASTP_crews.jpg
```

##### Debug mode:
> https://www.filestack.com/docs/image-transformations/debug

To enable debug mode for transformation:
```objectivec
FSTransformation *transformation = [[FSTransformation alloc] init];
transformation.debug = YES;
```

### Chaining Transformation Tasks
> https://www.filestack.com/docs/image-transformations/chained-transformations

**BE ADVISED THAT THE ORDER IN WHICH YOU ARE ADDING TRANSFORMATIONS DOES MATTER!**

To chain transformations tasks simply create and add additional ```FSTransform``` object.

```objectivec
FSTransformation *transformation = [[FSTransformation alloc] init];
FSResize *resize = [[FSResize alloc] initWithWidth:@150 height:nil fit:FSResizeFitClip align:FSResizeAlignFaces];
FSCrop *crop = [[FSCrop alloc] initWithX:@0 y:@0 width:@300 height:@400];
FSRotate *rotate = [[FSRotate alloc] initWithDegrees:@120 background:@"black" rotateToEXIF:NO resetEXIF:YES];

[transformation add:resize];
[transformation add:crop];
[transformation add:rotate];
```

### Usage

To use transformations you need to combine it with Filestack's ```- transformURL:transformation:security:completionHandler:``` method. For example:

```objectivec
Filestack *filestack = [[Filestack alloc] initWithApiKey:@"APIKEY" delegate:self];
NSString *urlToTransform = @"https://d1wtqaffaaj63z.cloudfront.net/images/Portrait_of_ASTP_crews.jpg";
FSTransformation *transformation = [[FSTransformation alloc] init];
FSCrop *crop = [[FSCrop alloc] initWithX:@0 y:@0 width:@300 height:@400];
FSRotate *rotate = [[FSRotate alloc] initWithDegrees:@120 background:@"black" rotateToEXIF:NO resetEXIF:YES];

[transformation add:crop];
[transformation add:rotate];

[filestack transformURL:urlToTransform transformation:transformation security:nil completionHandler:^(NSData *data, NSDictionary *JSON, NSError *error) {
    NSLog(@"data: %@", data);
    NSLog(@"JSON: %@", JSON);
    NSLog(@"error: %@", error);
}];

// ...

- (void)filestackTransformSuccess:(NSData *)data {
    NSLog(@"data: %@", data);
}

- (void)filestackTransformSuccessJSON:(NSDictionary *)JSON {
    NSLog(@"JSON: %@", JSON);
}
```

There are three special cases when you will get ```JSON``` instead of ```data```. First, for every transformation when you are in debug mode (```transformation.debug = YES;```), second, when you are using ```FSDetectFaces``` with ```exportToJSON = YES``` and third case with ```FSOutput``` with requested docinfo (```docInfo = YES```). All other cases will return either data or error. Error will have an additional key ```"com.filestack.serialization.response.error"``` in ```userInfo``` dictionary, containing error message serialized to string.

### Available transformations
Please refer to Filestack's documentation, as **there is no client-side parameters validation**, so it's on your shoulders to provide a valid values (or face the consequences of an error! :D).
> "With great power comes great responsibility."

Every ```FSTransform``` object can be created by either initializer(s) with parameters or by setting the properties yourself. Few of the transformations takes no parameters whatsoever.

```objectivec
// FSResize init with parameters example
FSResize *resizeTransformation = [[FSResize alloc] initWithWidth:@200 height:@300 fit:FSResizeFitScale andAlign:FSResizeAlignLeft];

// FSResize init and setting the properties example:
FSResize *resizeTransformation = [[FSResize alloc] init];
resizeTransformation.width = @200;
resizeTransformation.height = @300;
resizeTransformation.fit = FSResizeFitScale;
resizeTransformation.align = FSResizeFitAlignLeft;
```

##### **Important**

- Multiple ```FSTransform``` accepts ```color``` and ```background``` as parameters, these parameters are of type ```NSString``` instead of ```UIColor``` to maintain consistency with our web transformations. This string can be either a color keyword or HEX code (with alpha, e.g. 000000FF for black).
For accepted color keywords please visit [Color Options](https://www.filestack.com/docs/image-transformations/colors).
- If transformation has a required property(ies), passing ```nil``` value(s) will skip whole transformation in constructed query string.

- Transformations list:
  - [FSResize](#fsresize)
  - [FSCrop](#fscrop)
  - [FSRotate](#fsrotate)
  - [FSFlip and FSFlop](#fsflip-and-fsflop)
  - [FSWatermark](#fswatermark)
  - [FSDetectFaces](#fsdetectfaces)
  - [FSCropFaces](#fscropfaces)
  - [FSPixelateFaces](#fspixelatefaces)
  - [FSBlurFaces](#fsblurfaces)
  - [FSRoundedCorners](#fsroundedcorners)
  - [FSPolaroid](#fspolaroid)
  - [FSTornEdges](#fstornedges)
  - [FSShadow](#fsshadow)
  - [FSCircle](#fscircle)
  - [FSBorder](#fsborder)
  - [FSSharpen](#fssharpen)
  - [FSBlur](#fsblur)
  - [FSMonochrome](#fsmonochrome)
  - [FSSepia](#fssepia)
  - [FSPixelate](#fspixelate)
  - [FSOilPaint](#fsoilpaint)
  - [FSModulate](#fsmodulate)
  - [FSPartialPixelate](#fspartialpixelate)
  - [FSPartialBlur](#fspartialblur)
  - [FSCollage](#fscollage)
  - [FSURLScreenshot](#fsurlscreenshot)
  - [FSASCII](#fsascii)
  - [FSOutput](#fsoutput)

#### **FSResize**
> https://www.filestack.com/docs/image-transformations/resize

properties:
```objectivec
NSNumber *width
NSNumber *height
FSResizeFit fit
FSResizeAlign align
```
typedefs "helpers":
```objectivec
// FSResizeFit
FSResizeFitClip
FSResizeFitCrop
FSResizeFitScale
FSResizeFitMax

// FSResizeAlign
FSResizeAlignLeft
FSResizeAlignRight
FSResizeAlignTop
FSResizeAlignBottom
FSResizeAlignCenter
FSResizeAlignFaces
FSResizeAlignTopLeft
FSResizeAlignTopRight
FSResizeAlignBottomLeft
FSResizeAlignBottomRight
```

initializers:
```objectivec
- initWithHeight:
- initWithWidth:
- initWithWidth:height:
- initWithWidth:height:fit:
- initWithWidth:height:fit:align:
```

#### **FSCrop**
> https://www.filestack.com/docs/image-transformations/crop

properties:
```objectivec
NSNumber *x
NSNumber *y
NSNumber *width
NSNumber *height
```

initializers:
```objectivec
- initWithX:y:width:height:
```

#### **FSRotate**
> https://www.filestack.com/docs/image-transformations/rotate#rotate

properties:
```objectivec
NSNumber *degrees
NSString *background
BOOL toEXIF
BOOL resetEXIF
```

initializers:
```objectivec
- initWithDegrees:background:rotateToEXIF:resetEXIF:;
```

#### **FSFlip** and **FSFlop**
> https://www.filestack.com/docs/image-transformations/rotate#flip

> https://www.filestack.com/docs/image-transformations/rotate#flop

#### **FSWatermark**
> https://www.filestack.com/docs/image-transformations/watermark

Instead of Filestack handle, FSWatermark is accepting FSBlob in place of ```file``` parameter.

typedefs “helpers”:
```objectivec
// FSWatermarkPosition
FSWatermarkPositionLeft
FSWatermarkPositionRight
FSWatermarkPositionBottom
FSWatermarkPositionCenter
FSWatermarkPositionTop
FSWatermarkPositionTopLeft
FSWatermarkPositionBottomLeft
FSWatermarkPositionTopRight
FSWatermarkPositionBottomRight
FSWatermarkPositionTopCenter
FSWatermarkPositionBottomCenter
```

properties:
```objectivec
FSBlob *blob
NSNumber *size
FSWatermarkPosition position
```

initializers:
```objectivec
- initWithBlob:size:position:position
```

#### **FSDetectFaces**
> https://www.filestack.com/docs/image-transformations/facial-detection#detect_faces

properties:
```objectivec
NSNumber *minSize
NSNumber *maxSize
NSString *color
BOOL exportToJSON
```

initializers:
```objectivec
- initWithMinSize:maxSize:color:exportToJSON:
- initWithExportToJSON
```

#### **FSCropFaces**
> https://www.filestack.com/docs/image-transformations/facial-detection#crop_faces

typedefs "helpers""

```objectivec
// FSCropFacesMode
FSCropFacesModeThumb
FSCropFacesModeCrop
FSCropFacesModeFill
```

properties:
```objectivec
FSCropFacesMode mode
NSNumber *width
NSNumber *height
NSNumber *buffer
NSNumber *face
NSArray<NSNumber *> *faces
BOOL allFaces
```

initializers:
```objectivec
- initWithMode:width:height:buffer:
- initWithMode:width:height:buffer:face:
- initWithMode:width:height:buffer:faces:
- initAllFacesWithMode:width:height:buffer:
```

#### **FSPixelateFaces**
> https://www.filestack.com/docs/image-transformations/facial-detection#pixelate_faces

typedef "helpers":
```objectivec
// FSPixelateFacesType
FSPixelateFacesTypeRect
FSPixelateFacesTypeOval
```

properties:
```objectivec
NSNumber *minSize
NSNumber *maxSize
NSNumber *buffer
NSNumber *blur
NSNumber *amount
FSPixelateFacesType type
NSNumber *face
NSArray<NSNumber *> *faces
BOOL allFaces
```

initializers:
```objectivec
- (instancetype)initWithMinSize:maxSize:type:buffer:blurAmount:pixelateAmount:
- (instancetype)initWithAllFacesAndMinSize:maxSize:type:buffer:blurAmount:pixelateAmount:
- (instancetype)initWithMinSize:maxSize:type:buffer:blurAmount:pixelateAmount:face:
- (instancetype)initWithMinSize:maxSize:type:buffer:blurAmount:pixelateAmount:faces:
```

#### **FSBlurFaces**
> https://www.filestack.com/docs/image-transformations/facial-detection#blur_faces

typedef "helpers":
```objectivec
// FSPBlurFacesType
FSBlurFacesTypeRect
FSBlurFacesTypeOval
```

properties:
```objectivec
NSNumber *minSize
NSNumber *maxSize
NSNumber *buffer
NSNumber *blur
NSNumber *amount
FSPBlurFacesType type
NSNumber *face
NSArray<NSNumber *> *faces
BOOL allFaces
```

initializers:
```objectivec
- (instancetype)initWithMinSize:maxSize:type:buffer:blurAmount:pixelateAmount:
- (instancetype)initWithAllFacesAndMinSize:maxSize:type:buffer:blurAmount:pixelateAmount:
- (instancetype)initWithMinSize:maxSize:type:buffer:blurAmount:pixelateAmount:face:
- (instancetype)initWithMinSize:maxSize:type:buffer:blurAmount:pixelateAmount:faces:
```

#### **FSRoundedCorners**
> https://www.filestack.com/docs/image-transformations/borders-and-effects#rounded-corners

properties:
```objectivec
NSNumber *radius
NSNumber *blur
NSString *background
BOOL maxRadius
```

initializers:
```objectivec
- initWithRadius:blur:background:
- initWithMaxRadiusAndBlur:background:
```

#### **FSPolaroid**
> https://www.filestack.com/docs/image-transformations/borders-and-effects#polaroid

properties:
```objectivec
NSString *color
NSString *background
NSNumber *rotate
```

initializers:
```objectivec
- initWithColor:background:rotation:
```

#### **FSTornEdges**
> https://www.filestack.com/docs/image-transformations/borders-and-effects#torn-edges

properties:
```objectivec
NSArray<NSNumber *> *spread
NSString *background
```

initializers:
```objectivec
- initWithSpread:background:
```

#### **FSShadow**
> https://www.filestack.com/docs/image-transformations/borders-and-effects#shadow

properties:
```objectivec
NSNumber *blur
NSNumber *opacity
NSArray<NSNumber *> *vector
NSString *color
NSString *background
```

initializers:
```objectivec
- initWithBlur:opacity:vector:color:background:
```

#### **FSCircle**
> https://www.filestack.com/docs/image-transformations/borders-and-effects#circle

properties:
```objectivec
NSString *background
```

initializers:
```objectivec
- initWithBackground:
```

#### **FSBorder**
> https://www.filestack.com/docs/image-transformations/borders-and-effects#border

properties:
```objectivec
NSNumber *width
NSString *color
NSString *background
```

initializers:
```objectivec
- initWithWidth:color:background:
```

#### **FSSharpen**
> https://www.filestack.com/docs/image-transformations/filter#sharpen

properties:
```objectivec
NSNumber *amount
```

initializers:
```objectivec
- initWithAmount:
```

#### **FSBlur**
> https://www.filestack.com/docs/image-transformations/filter#blur

properties:
```objectivec
NSNumber *amount
```

initializers:
```objectivec
- initWithAmount:
```

#### **FSMonochrome**
> https://www.filestack.com/docs/image-transformations/filter#monochrome

#### **FSSepia**
> https://www.filestack.com/docs/image-transformations/filter#sepia

properties:
```objectivec
NSNumber *tone
```

initializers:
```objectivec
- initWithTone:
```

#### **FSPixelate**
> https://www.filestack.com/docs/image-transformations/filter#pixelate

properties:
```objectivec
NSNumber *amount
```

initializers:
```objectivec
- initWithAmount:
```

#### **FSOilPaint**
> https://www.filestack.com/docs/image-transformations/filter#oil_paint

properties:
```objectivec
NSNumber *amount
```

initializers:
```objectivec
- initWithAmount:
```

#### **FSModulate**
> https://www.filestack.com/docs/image-transformations/filter#modulate

properties:
```objectivec
NSNumber *hue
NSNumber *brightness
NSNumber *saturation
```

initializers:
```objectivec
- initWithBrightness:hue:saturation:
```

#### **FSPartialPixelate**
> https://www.filestack.com/docs/image-transformations/filter#partial_pixelate

typedef "helpers":
```objectivec
// FSPPartialPixelateType
FSPPartialPixelateTypeRect
FSPPartialPixelateTypeOval
```

properties:
```objectivec
NSNumber *buffer
NSNumber *amount
NSNumber *blur
FSPPartialPixelateType type
NSArray<NSArray<NSNumber *> *> *objects
```

initializers:
```objectivec
- initWithObjects:
- initWithObjects:buffer:amount:blur:type:
```

#### **FSPartialBlur**
> https://www.filestack.com/docs/image-transformations/filter#partial_blur

typedef "helpers":
```objectivec
// FSPPartialBlurType
FSPPartialBlurTypeRect
FSPPartialBlurTypeOval
```

properties:
```objectivec
NSNumber *buffer
NSNumber *amount
NSNumber *blur
FSPPartialBlurType type
NSArray<NSArray<NSNumber *> *> *objects
```

initializers:
```objectivec
- initWithObjects:
- initWithObjects:buffer:amount:blur:type:
```

#### **FSCollage**
> https://www.filestack.com/docs/image-transformations/collage

Instead of an array of filestack handles, FSCollage is accepting array of FSBlobs in place of ```files``` parameter. 

properties:
```objectivec
NSString *color
NSNumber *margin
NSArray<FSBlob *> *files
NSNumber *width
NSNumber *height
```

initializers:
```objectivec
- initWithFiles:width:height:
- initWithFiles:width:height:margin:color:
```

#### **FSURLScreenshot**
> https://www.filestack.com/docs/image-transformations/url-screenshot

typedef "helpers":
// FSURLScreenshotAgent
FSURLScreenshotAgentMobile
FSURLScreenshotAgentDesktop

FSURLScreenshotMode
FSURLScreenshotModeAll
FSURLScreenshotModeWindow

properties:
```objectivec
NSNumber *width
NSNumber *height
FSURLScreenshotAgent agent
FSURLScreenshotMode mode
```

initializers:
```objectivec
- initWithWidth:height:agent:mode:
```

#### **FSASCII**
> https://www.filestack.com/docs/image-transformations/img-to-ascii

properties:
```objectivec
NSString *foreground
NSString *background
NSNumber *size
BOOL reverse
BOOL colored
```

initializers:
```objectivec
- initWithForeground:background:size:reverse:colored:
```

#### **FSOutput**
> https://www.filestack.com/docs/image-transformations/output

typedef "helpers":
```objectivec
// FSOutputFormat
FSOutputFormatPDF
FSOutputFormatDOC
FSOutputFormatDOCX
FSOutputFormatODT
FSOutputFormatXLS
FSOutputFormatXLSX
FSOutputFormatODS
FSOutputFormatPPT
FSOutputFormatPPTX
FSOutputFormatODP
FSOutputFormatBMP
FSOutputFormatGIF
FSOutputFormatJPG
FSOutputFormatPNG
FSOutputFormatTIFF
FSOutputFormatAI
FSOutputFormatPSD
FSOutputFormatSVG
FSOutputFormatHTML
FSOutputFormatTXT

// FSOutputColorspace
FSOutputColorspaceRGB
FSOutputColorspaceCMYK
FSOutputColorspaceInput
```

properties:
```objectivec
FSOutputFormat format
FSOutputColorspace colorspace
NSNumber *page
NSNumber *density
NSNumber *quality
BOOL compress
BOOL secure
BOOL docInfo
```

initializers:
```objectivec
- initWithFormat:colorspace:page:density:compress:quality:secure:
- initWithFormat:
- initWithDocInfo:
```

## License

Filestack for iOS & Mac is released under the MIT license. See LICENSE for details.

