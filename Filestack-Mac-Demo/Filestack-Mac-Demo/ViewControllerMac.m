//
//  ViewController.m
//  Filestack-Mac-Demo
//
//  Created by Łukasz Cichecki on 01/02/16.
//  Copyright © 2016 Filestack. All rights reserved.
//

#import "ViewControllerMac.h"
@import FilestackMac;

@interface ViewControllerMac () <FSFilestackDelegate> // Filestack delegate.

@end

@implementation ViewControllerMac

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

    NSString *sampleURL = @"https://assets.filestackapi.com/web/8d93688/img/upload-illustration.png";

    // Lets store the sample url on S3 using provided store options.
    [filestack storeURL:sampleURL withOptions:storeOptions completionHandler:^(FSBlob *blob, NSError *error) {
        NSLog(@"stored blob: %@", blob);
        NSLog(@"storeURL error: %@", error);
        if (error == nil) {
            // Now lets try to get the stored file metadata
            [filestack stat:blob withOptions:statOptions completionHandler:^(FSMetadata *metadata, NSError *error) {
                NSLog(@"file metadata: %@", metadata);
                NSLog(@"stat error: %@", error);
            }];
        }
    }];
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];
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
