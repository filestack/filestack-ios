//
//  FSAPIURL.h
//  Filestack
//
//  Created by Łukasz Cichecki on 28/01/16.
//  Copyright © 2016 Filestack. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FSStoreOptions.h"

FOUNDATION_EXPORT NSString *const FSURLBaseURL;
FOUNDATION_EXPORT NSString *const FSURLTransformationURL;

typedef NSString * FSURL;
#define FSURLPickPath @"api/pick"
#define FSURLMetadataPath @"/metadata"
#define FSURLFilePath @"api/file"
#define FSURLStorePath @"api/store"
#define FSURLContentPath @"api/path"
#define FSURLClientPath @"api/client"

@interface FSAPIURL : NSObject

+ (NSString *)URLForStoreOptions:(FSStoreOptions *)storeOptions storeURL:(BOOL)isStoreURL andApiKey:(NSString *)apiKey;
+ (NSString *)URLFilePathWithBlobURL:(NSString *)blobURL;
+ (NSString *)URLMetadataPathWithBlobURL:(NSString *)blobURL;

@end
