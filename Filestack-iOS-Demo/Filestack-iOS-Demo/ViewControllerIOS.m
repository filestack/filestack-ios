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

@interface ViewControllerIOS () <FSFilestackDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate> // Filestack delegate.

@end

@implementation ViewControllerIOS

- (void)viewDidLoad {
    [super viewDidLoad];

    // Remember to use your api key.
    Filestack *filestack = [[Filestack alloc] initWithApiKey:@"YOUR_API_KEY" delegate:self];

    // Either like this...
    FSStatOptions *statOptions = [[FSStatOptions alloc] initWithDictionary:@{@"size": @YES, @"uploaded": @YES, @"writeable": @YES}];
    // Or like this.
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
            [filestack stat:blob withOptions:statOptions completionHandler:^(FSMetadata *metadata, NSError *error) {
                NSLog(@"file metadata: %@", metadata);
                NSLog(@"stat error: %@", error);
            }];
        }
    }];

    // Time for some transformation magic.
    FSTransformation *transformation = [[FSTransformation alloc] init];

    // URL to an image of the ASTP crew.
    NSString *urlToTransform = @"https://d1wtqaffaaj63z.cloudfront.net/images/Portrait_of_ASTP_crews.jpg";

    // First, we will crop one of the faces on the image. The first one to be specific.
    FSCropFaces *cropFaces = [[FSCropFaces alloc] initWithMode:nil width:nil height:nil buffer:nil face:@1];
    [transformation add:cropFaces];

    // Now, lets blur it.
    FSBlur *blur = [[FSBlur alloc] initWithAmount:@3];
    [transformation add:blur];

    // And finally "apply" the transformation
    [filestack transformURL:urlToTransform transformation:transformation security:nil completionHandler:^(NSData *data, NSDictionary *JSON, NSError *error) {
        _imageView.image = [UIImage imageWithData:data];
        // Wall of text so lets comment this off.
        // NSLog(@"data: %@", data);
        NSLog(@"JSON: %@", JSON);
        NSLog(@"error: %@", error);
    }];
}

- (IBAction)selectImage {
    UIImagePickerController *pickerController = [[UIImagePickerController alloc] init];
    pickerController.delegate = self;
    [self presentViewController:pickerController animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    // PHAssets and UIImagePickerController magic.
    NSURL *path = [info valueForKey:UIImagePickerControllerReferenceURL];
    PHFetchResult *assets = [PHAsset fetchAssetsWithALAssetURLs:@[path] options:nil];
    PHAsset *asset = assets.firstObject;
    [[PHImageManager defaultManager] requestImageDataForAsset:asset options:nil resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
        // Remember to set fileName and/or mimetype in storeOptions so it will upload as a "valid" file.
        // Without at least one of them, for NSData, we are setting mimetype as "application/octet-stream".
        NSString *fileName = [info[@"PHImageFileURLKey"] lastPathComponent];
        Filestack *filestack = [[Filestack alloc] initWithApiKey:@"YOUR_API_KEY" delegate:self];
        FSStoreOptions *storeOptions = [[FSStoreOptions alloc] init];
        storeOptions.fileName = fileName;
        storeOptions.access = FSAccessPublic;
        [filestack store:imageData withOptions:storeOptions progress:^(NSProgress *progress) {
            NSLog(@"progress: %f", progress.fractionCompleted);
        } completionHandler:^(FSBlob *blob, NSError *error) {
            NSLog(@"stored data blob: %@", blob);
        }];
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
