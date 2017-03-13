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

// Remember to use your api key
// Create a .filestack file with your key
// The location of this file can be configured via Info.plist
NSString *apikey = @"";
double totalSize = 0.0;
NSMutableArray *partsArray; // keep track of number of bytes uploaded for each part

- (void)awakeFromNib {
    
    // Load the api key
    NSString *path = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"FSAPIKeyFile"];
    apikey = [NSString stringWithContentsOfFile:[path stringByExpandingTildeInPath]
                                       encoding:NSUTF8StringEncoding
                                          error:NULL];
    apikey = [apikey stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self appendTextToResultView:@"Welcome to Filestack OSX Sample App!"];
}
- (IBAction)multipartBtnAction:(id)sender {
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel setCanChooseFiles:YES];
    [panel setCanChooseDirectories:NO];
    [panel setAllowsMultipleSelection:YES]; // yes if more than one dir is allowed
    
    NSInteger clicked = [panel runModal];
    
    if (clicked == NSFileHandlingPanelOKButton) {
        totalSize = 0.0;
        partsArray = [[NSMutableArray alloc] init];
        
        for (NSURL *url in [panel URLs]) {
            NSString *path = [url path];
            NSData *data = [[NSFileManager defaultManager] contentsAtPath:path];
            double partSize = [data length];
            [partsArray addObject:[NSNumber numberWithDouble:0.0]];
            totalSize = totalSize + partSize;
        }
        
        int i = 0;
        for (NSURL *url in [panel URLs]) {
            [_uploadProgressIndicator incrementBy:-100.0]; // reset the progress bar
            [self upload:url withPart:i];
            i++;
        }
    }
}

- (void)store {
    
    Filestack *filestack = [[Filestack alloc] initWithApiKey:apikey delegate:self];
    
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
        if (!error) {
            // Now lets try to get the stored file metadata
            [filestack stat:blob withOptions:statOptions completionHandler:^(FSMetadata *metadata, NSError *error) {
                NSLog(@"file metadata: %@", metadata);
                NSLog(@"stat error: %@", error);
            }];
        }
    }];
}

- (void) appendTextToResultView:(NSString*) theText {
    NSString *theTextWithNewline = [NSString stringWithFormat:@"%@\n", theText];
    NSAttributedString* attr = [[NSAttributedString alloc] initWithString:theTextWithNewline];
    [[_resultsTextView textStorage] appendAttributedString:attr];
    [_resultsTextView scrollRangeToVisible:NSMakeRange([[_resultsTextView string] length], 0)];
}

// For large files stored locally or for bad connections, use multi-part upload
- (void)upload:(NSURL *)url withPart:(int)partNumber {
    Filestack *filestack = [[Filestack alloc] initWithApiKey:apikey delegate:self];
    
    FSStoreOptions *storeOptions = [[FSStoreOptions alloc] init];
    storeOptions.location = FSStoreLocationS3;
    storeOptions.fileName = [url lastPathComponent];
    
    FSRetryOptions *retryOptions = [[FSRetryOptions alloc] init];
    retryOptions.retries = 10;
    retryOptions.factor = [[NSNumber numberWithFloat:2.0] decimalValue];
    retryOptions.minTimeout = 1 * 1000;
    retryOptions.maxTimeout = 60 * 1000;
    
    FSUploadOptions *uploadOptions = [[FSUploadOptions alloc] init];
    uploadOptions.partSize = @(5 * 1024 * 1024);
    uploadOptions.maxConcurrentUploads = @5;
    uploadOptions.retryOptions = retryOptions;
    
    NSString *path = [url path];
    NSData *data = [[NSFileManager defaultManager] contentsAtPath:path];
    double partSize = [data length];
    
    // Lets store the sample url on S3 using provided store options.
    [filestack upload:data
          withOptions:uploadOptions
     withStoreOptions:storeOptions
             progress:^(NSProgress *uploadProgress) {
                 dispatch_async(dispatch_get_main_queue(), ^{
                     double currentPartsCompletedThisPart = [partsArray[partNumber] doubleValue];
                     double currentPartTotalComplete = partSize * uploadProgress.fractionCompleted;
                     double partsCompletedThisPart = currentPartTotalComplete - currentPartsCompletedThisPart;            // total bytes completed for this part (32,000 or something)
                     partsArray[partNumber] = [NSNumber numberWithDouble:currentPartTotalComplete];
                     
                     // Now need to calc how much to increment the bar
                     double increment = partsCompletedThisPart / totalSize * 100.0;
                     [_uploadProgressIndicator incrementBy: increment];
                 });
             }
    completionHandler:^(NSDictionary *result, NSError *error) {
        if (!error) {
            [self appendTextToResultView:[NSString stringWithFormat:@"stored file: %@", result]];
            NSLog(@"stored file: %@", result);
        } else {
            [self appendTextToResultView:[NSString stringWithFormat:@"upload error: %@", error]];
            NSLog(@"upload error: %@", error);
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
