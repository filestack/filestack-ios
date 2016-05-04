//
//  FSAPIURL.m
//  Filestack
//
//  Created by Łukasz Cichecki on 28/01/16.
//  Copyright © 2016 Filestack. All rights reserved.
//

#import "FSAPIURL.h"

NSString *const FSURLBaseURL = @"https://www.filestackapi.com/";
NSString *const FSURLTransformationURL = @"https://process.filestackapi.com";

@implementation FSAPIURL

+ (NSString *)URLForStoreOptions:(FSStoreOptions *)storeOptions storeURL:(BOOL)isStoreURL andApiKey:(NSString *)apiKey {
    if (isStoreURL) {
        if (storeOptions) {
            return [NSString stringWithFormat:@"%@/%@?key=%@", FSURLStorePath, storeOptions.storeLocation, apiKey];
        }
        return [NSString stringWithFormat:@"%@/%@?key=%@", FSURLStorePath, @"S3", apiKey];
    } else {
        if (storeOptions) {
            return [NSString stringWithFormat:@"%@%@/%@?key=%@", FSURLBaseURL, FSURLStorePath, storeOptions.storeLocation, apiKey];
        }
        return [NSString stringWithFormat:@"%@%@/%@?key=%@", FSURLBaseURL, FSURLStorePath, @"S3", apiKey];
    }
}

+ (NSString *)URLFilePathWithBlobURL:(NSString *)blobURL {
    NSString *blobHandle = [NSURL URLWithString:blobURL].lastPathComponent;
    NSString *URL = [NSString stringWithFormat:@"%@/%@", FSURLFilePath, blobHandle];
    return URL;
}

+ (NSString *)URLMetadataPathWithBlobURL:(NSString *)blobURL {
    NSString *blobHandle = [NSURL URLWithString:blobURL].lastPathComponent;
    NSString *URL = [NSString stringWithFormat:@"/%@%@", blobHandle, FSURLMetadataPath];
    return URL;
}

@end
