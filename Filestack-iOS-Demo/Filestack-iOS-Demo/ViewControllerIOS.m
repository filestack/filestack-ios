//
//  ViewController.m
//  Filestack-iOS-Demo
//
//  Created by Łukasz Cichecki on 20/01/16.
//  Copyright © 2016 Filestack. All rights reserved.
//

#import "ViewControllerIOS.h"
#import <MobileCoreServices/UTCoreTypes.h>

@import Photos;
@import AVFoundation;
@import AVKit;

@import FilestackIOS;

@interface ViewControllerIOS () <FSFilestackDelegate, // Filestack delegate.
    UIImagePickerControllerDelegate, UINavigationControllerDelegate, // For image and video selection
    UIPickerViewDelegate, UIPickerViewDataSource> // For picker view

@property (nonatomic, strong) NSString *cdnURL;
@property (nonatomic, strong) NSString *cdnMimetype;
@property (nonatomic) NSArray *transformData;
@property (weak, nonatomic) IBOutlet UIProgressView *uploadProgressView;
@property (weak, nonatomic) IBOutlet UIButton *transformBtn;
@property (weak, nonatomic) IBOutlet UILabel *cdnLabel;

@end

@implementation ViewControllerIOS

// Remember to use your api key.
NSString *const apiKey = @"A4kb0Ft2OSFy81feBYw68z";

- (void) awakeFromNib {
    [super awakeFromNib];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _cdnURL = nil;
    _cdnMimetype = nil;
    _transformData = @[@"Oil Paint", @"Monochrome", @"Blur", @"Sepia", @"Polaroid"];
    _transformPicker.dataSource = self;
    _transformPicker.delegate = self;
    _transformBtn.hidden = true;
    _uploadProgressView.hidden = true;
    
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
}

// Picker View Delegates

// The number of columns of data
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

// The number of rows of data
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return _transformData.count;
}

// The data to return for the row and component (column) that's being passed in
- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return _transformData[row];
}

// Catpure the picker view selection
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    // User must upload an image from camera first
    if (!_cdnURL) {
        return;
    }
    
    // Time for some transformation magic.
    FSTransformation *transformation = [[FSTransformation alloc] init];
    
    NSString *transformString = _transformData[row];
    if ([transformString isEqualToString:@"Oil Paint"]) {
        [transformation add:[[FSOilPaint alloc] initWithAmount:@7]];
    } else if ([transformString isEqualToString:@"Monochrome"]) {
        [transformation add:[[FSMonochrome alloc] init]];
    } else if ([transformString isEqualToString:@"Blur"]) {
        [transformation add:[[FSBlur alloc] initWithAmount:@10]];
    } else if ([transformString isEqualToString:@"Sepia"]) {
        [transformation add:[[FSSepia alloc] init]];
    } else if ([transformString isEqualToString:@"Polaroid"]) {
        [transformation add:[[FSPolaroid alloc] init]];
    } else {
        // should never get here but jic
        return;
    }
    
    // Create a spinner
    _transformBtn.hidden = true;
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    spinner.center = CGPointMake(self.view.frame.size.width / 2, _transformBtn.frame.origin.y);
    spinner.hidesWhenStopped = true;
    [self.view addSubview:spinner];
    [spinner startAnimating];
    
    // And finally "apply" the transformation
    Filestack *filestack = [[Filestack alloc] initWithApiKey:apiKey delegate:self];
    [filestack transformURL:_cdnURL transformation:transformation security:nil completionHandler:^(NSData *data, NSDictionary *JSON, NSError *error) {
        
         dispatch_async(dispatch_get_main_queue(), ^{
             _imageView.image = [UIImage imageWithData:data];
             NSLog(@"JSON: %@", JSON);
             NSLog(@"error: %@", error);
             [spinner stopAnimating];
             _transformBtn.hidden = false;
         });
    }];
    
    pickerView.hidden = true;
}

// Button Actions
- (IBAction)transformBtnTouchUpInside:(id)sender {
    if ([_cdnMimetype isEqualToString:@"video/quicktime"]) {
        // Play video from CDN
        NSURL *url = [NSURL URLWithString:_cdnURL];
        AVPlayer *player = [AVPlayer playerWithURL:url];
        AVPlayerViewController *videoController = [[AVPlayerViewController alloc] init];
        videoController.player = player;
        [self presentViewController:videoController animated:YES completion:nil];
        [player play];
    } else {
        _transformPicker.hidden = false;
    }
}

// Not currently used
- (IBAction)storeURLTouchUpInside:(id)sender {
    Filestack *filestack = [[Filestack alloc] initWithApiKey:apiKey delegate:self];
    
    FSStoreOptions *storeOptions = [[FSStoreOptions alloc] init];
    storeOptions.fileName = @"sample.png";
    // Configure S3 storage in your developer portal
    storeOptions.access = FSAccessPublic;
    storeOptions.location = FSStoreLocationS3;
    storeOptions.path = @"my-folder/";
    
    NSString *sampleURL = @"https://dev.filestack.com/static/assets/icons/logo-primary.png";
    
    // Lets store the sample url on S3 using provided store options.
    [filestack storeURL:sampleURL withOptions:storeOptions completionHandler:^(FSBlob *blob, NSError *error) {
        NSLog(@"stored blob: %@", blob);
        NSLog(@"storeURL error: %@", error);
        if (!error) {
            // Now lets try to get the stored file metadata
            FSStatOptions *statOptions = [[FSStatOptions alloc] initWithDictionary:@{@"size": @YES, @"uploaded": @YES, @"writeable": @YES}];
            [filestack stat:blob withOptions:statOptions completionHandler:^(FSMetadata *metadata, NSError *error) {
                NSLog(@"file metadata: %@", metadata);
                NSLog(@"stat error: %@", error);
            }];
        }
    }];
}

- (IBAction)selectImage {
    UIImagePickerController *pickerController = [[UIImagePickerController alloc] init];
    pickerController.delegate = self;
    pickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    pickerController.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    [self presentViewController:pickerController animated:YES completion:nil];
}

// Private method to store image using store method (vs multipart-upload)
- (void)storeImage:(NSString*)fileName withImageData:(NSData*)imageData {
    Filestack *filestack = [[Filestack alloc] initWithApiKey:apiKey delegate:self];
    FSStoreOptions *storeOptions = [[FSStoreOptions alloc] init];
    storeOptions.fileName = fileName;
    storeOptions.access = FSAccessPublic;
    [_uploadProgressView setProgress:0.0];
    _uploadProgressView.hidden = false;
    _transformBtn.hidden = true;
    [filestack store:imageData withOptions:storeOptions progress:^(NSProgress *uploadProgress) {
        NSLog(@"progress: %f", uploadProgress.fractionCompleted);
        dispatch_async(dispatch_get_main_queue(), ^{
            [_uploadProgressView setProgress:uploadProgress.fractionCompleted animated:YES];
        });
    } completionHandler:^(FSBlob *blob, NSError *error) {
        if (error) {
            NSLog(@"Error: %@", error);
            _uploadProgressView.hidden = true;
        } else {
            NSLog(@"stored data blob: %@", blob);
            _cdnURL = [NSString stringWithString:blob.url];
            _uploadProgressView.hidden = true;
            _transformBtn.hidden = false;
        }
    }];
    dispatch_async(dispatch_get_main_queue(), ^{
        _imageView.image = [UIImage imageWithData:imageData];
    });
}

- (void)multiPartUpload:(NSString*)fileName withData:(NSData*)data withMimetype:(NSString *)mimetype {
    
    // UI stuff
    [_uploadProgressView setProgress:0.0];
    _uploadProgressView.hidden = false;
    _transformBtn.hidden = true;

    // Filestack setup and call
    Filestack *filestack = [[Filestack alloc] initWithApiKey:apiKey delegate:self];
    
    FSStoreOptions *storeOptions = [[FSStoreOptions alloc] init];
    storeOptions.fileName = fileName;
    storeOptions.location = FSStoreLocationS3;
    storeOptions.access = FSAccessPublic;
    storeOptions.mimeType = mimetype;
    
    FSRetryOptions *retryOptions = [[FSRetryOptions alloc] init];
    retryOptions.retries = 10;
    retryOptions.factor = [NSNumber numberWithFloat:2.0];
    retryOptions.minTimeout = 1;  // seconds
    retryOptions.maxTimeout = 60; // seconds
    
    FSUploadOptions *uploadOptions = [[FSUploadOptions alloc] init];
    uploadOptions.partSize = @(5 * 1024 * 1024);
    uploadOptions.maxConcurrentUploads = @5;
    uploadOptions.retryOptions = retryOptions;
    
    [filestack upload:data withOptions:uploadOptions withStoreOptions:storeOptions
              onStart:nil
              onRetry:nil
             progress:^(NSProgress *uploadProgress) {
                 NSLog(@"progress: %f", uploadProgress.fractionCompleted);
                 dispatch_async(dispatch_get_main_queue(), ^{
                     [_uploadProgressView setProgress:uploadProgress.fractionCompleted animated:YES];
                 });
             } completionHandler:^(NSDictionary *result, NSError *error) {
                 dispatch_async(dispatch_get_main_queue(), ^{
                     if (error) {
                         NSLog(@"Error: %@", error);
                         _uploadProgressView.hidden = true;
                         _cdnLabel.text = @"";
                     } else {
                         NSLog(@"stored result: %@", result);
                         _cdnURL = [NSString stringWithString:result[@"url"]];
                         _uploadProgressView.hidden = true;
                         _cdnLabel.text = _cdnURL;
                         _cdnMimetype = mimetype;
                         _transformBtn.hidden = false;

                         if ([mimetype isEqualToString:@"video/quicktime"]) {
                             [_transformBtn setTitle:@"Play Video" forState:UIControlStateNormal];
                         } else {
                             [_transformBtn setTitle:@"Transform Image" forState:UIControlStateNormal];
                             
                             // Now pull the image from the CDN
                             NSURL *url = [NSURL URLWithString:_cdnURL];
                             NSData *cdnData = [NSData dataWithContentsOfURL:url];
                             _imageView.image = [UIImage imageWithData:cdnData];
                         }
                     }
                 });
             }];
}

// Delegate for Camera Roll Picker
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    
    // Get media type
    NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];

    // Handle a movie capture
    if (CFStringCompare ((__bridge_retained CFStringRef)mediaType, kUTTypeMovie, 0) == kCFCompareEqualTo) {
        NSURL *videoURL = (NSURL*)[info objectForKey:UIImagePickerControllerMediaURL];
        NSString *fileName = [videoURL lastPathComponent];
        NSData *videoData = [NSData dataWithContentsOfURL:videoURL];
        [self multiPartUpload:fileName withData:videoData withMimetype:@"video/quicktime"];

    } else { // image
        // PHAssets and UIImagePickerController magic.
        NSURL *path = [info valueForKey:UIImagePickerControllerReferenceURL];
        PHFetchResult *assets = [PHAsset fetchAssetsWithALAssetURLs:@[path] options:nil];
        PHAsset *asset = assets.firstObject;
        [[PHImageManager defaultManager] requestImageDataForAsset:asset options:nil resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
            // Remember to set fileName and/or mimetype in storeOptions so it will upload as a "valid" file.
            // Without at least one of them, for NSData, we are setting mimetype as "application/octet-stream".
            NSString *fileName = [info[@"PHImageFileURLKey"] lastPathComponent];
            [self multiPartUpload:fileName withData:imageData withMimetype:@"image/jpeg"];
        }];
    }

    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)filestackStoreSuccess:(FSBlob *)blob {
    NSLog(@"blob store success (hi from delegate!): %@", blob);
}

// Other delegate methods available:
//- (void)filestackStatSuccess:(FSMetadata *)metadata;
//- (void)filestackDownloadSuccess:(NSData *)data;
//- (void)filestackRequestError:(NSError *)error;
//- (void)filestackPickURLSuccess:(FSBlob *)blob;
//- (void)filestackStoreSuccess:(FSBlob *)blob;
//- (void)filestackRemoveSuccess;
//- (void)filestackTransformSuccess:(NSData *)data;
//- (void)filestackTransformSuccessJSON:(NSDictionary *)JSON;

@end
