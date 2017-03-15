//
//  ViewController.m
//  Filestack-iOS-Demo
//
//  Created by Łukasz Cichecki on 20/01/16.
//  Copyright © 2016 Filestack. All rights reserved.
//

#import "ViewControllerIOS.h"

@import Photos;

@import FilestackIOS;

@interface ViewControllerIOS () <FSFilestackDelegate, // Filestack delegate.
    UIImagePickerControllerDelegate,
    UIPickerViewDelegate,
    UIPickerViewDataSource,
    UINavigationControllerDelegate>

@property (nonatomic, strong) NSString *imageURL;
@property (nonatomic) NSArray *transformData;
@property (weak, nonatomic) IBOutlet UIProgressView *uploadProgressView;
@property (weak, nonatomic) IBOutlet UIButton *transformBtn;

@end

@implementation ViewControllerIOS

// Remember to use your api key.
NSString *const apiKey = @"A4kb0Ft2OSFy81feBYw68z";

- (void) awakeFromNib {
    [super awakeFromNib];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _imageURL = nil;
    _transformData = @[@"Oil Paint", @"Monochrome", @"Blur", @"Sepia", @"Polaroid"];
    _transformPicker.dataSource = self;
    _transformPicker.delegate = self;
    _transformBtn.hidden = true;
    _uploadProgressView.hidden = true;
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
    if (!_imageURL) {
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
    [filestack transformURL:_imageURL transformation:transformation security:nil completionHandler:^(NSData *data, NSDictionary *JSON, NSError *error) {
        
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
    _transformPicker.hidden = false;
}

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
            _imageURL = [NSString stringWithString:blob.url];
            _uploadProgressView.hidden = true;
            _transformBtn.hidden = false;
        }
    }];
    dispatch_async(dispatch_get_main_queue(), ^{
        _imageView.image = [UIImage imageWithData:imageData];
    });
}

- (void)multiPartUpload:(NSString*)fileName withImageData:(NSData*)imageData {
    
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
    
    FSRetryOptions *retryOptions = [[FSRetryOptions alloc] init];
    retryOptions.retries = 10;
    retryOptions.factor = [NSNumber numberWithFloat:2.0];
    retryOptions.minTimeout = 1;  // seconds
    retryOptions.maxTimeout = 60; // seconds
    
    FSUploadOptions *uploadOptions = [[FSUploadOptions alloc] init];
    uploadOptions.partSize = @(5 * 1024 * 1024);
    uploadOptions.maxConcurrentUploads = @5;
    uploadOptions.retryOptions = retryOptions;
    
    [filestack upload:imageData withOptions:uploadOptions withStoreOptions:storeOptions
              onStart:nil
              onRetry:nil
             progress:^(NSProgress *uploadProgress) {
                 NSLog(@"progress: %f", uploadProgress.fractionCompleted);
                 dispatch_async(dispatch_get_main_queue(), ^{
                     [_uploadProgressView setProgress:uploadProgress.fractionCompleted animated:YES];
                 });
             } completionHandler:^(NSDictionary *result, NSError *error) {
                 if (error) {
                     NSLog(@"Error: %@", error);
                     _uploadProgressView.hidden = true;
                 } else {
                     NSLog(@"stored result: %@", result);
                     _imageURL = [NSString stringWithString:result[@"url"]];
                     _uploadProgressView.hidden = true;
                     _transformBtn.hidden = false;
                 }
             }];
    dispatch_async(dispatch_get_main_queue(), ^{
        _imageView.image = [UIImage imageWithData:imageData];
    });
}

// Delegate for Camera Roll Picker
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    // PHAssets and UIImagePickerController magic.
    NSURL *path = [info valueForKey:UIImagePickerControllerReferenceURL];
    PHFetchResult *assets = [PHAsset fetchAssetsWithALAssetURLs:@[path] options:nil];
    PHAsset *asset = assets.firstObject;
    [[PHImageManager defaultManager] requestImageDataForAsset:asset options:nil resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
        // Remember to set fileName and/or mimetype in storeOptions so it will upload as a "valid" file.
        // Without at least one of them, for NSData, we are setting mimetype as "application/octet-stream".
        NSString *fileName = [info[@"PHImageFileURLKey"] lastPathComponent];
        [self multiPartUpload:fileName withImageData:imageData];
    }];

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
