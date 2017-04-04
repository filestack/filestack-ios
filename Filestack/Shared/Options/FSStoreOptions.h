//
//  FSStoreOptions.h
//  Filestack
//
//  Created by Łukasz Cichecki on 21/01/16.
//  Copyright © 2016 Filestack. All rights reserved.
//

@import Foundation;
#import "FSSecurity.h"

typedef NSString * FSStoreLocation;
#define FSStoreLocationS3 @"S3"
#define FSStoreLocationDropbox @"dropbox"
#define FSStoreLocationRackspace @"rackspace"
#define FSStoreLocationAzure @"azure"
#define FSStoreLocationGoogleCloud @"gcs"

typedef NSString * FSAccess;
#define FSAccessPublic @"public"
#define FSAccessPrivate @"private"

@interface FSStoreOptions : NSObject

@property (nonatomic, copy) NSString *fileName;
@property (nonatomic, copy) NSString *mimeType;
@property (nonatomic, copy) NSString *path;
@property (nonatomic, copy) NSString *container;
@property (nonatomic, assign) BOOL base64decode;
@property (nonatomic, strong) FSAccess access;
@property (nonatomic, strong) FSSecurity *security;
@property (nonatomic, strong) FSStoreLocation location;
@property (nonatomic, readonly, copy) NSDictionary *toQueryParameters;
@property (nonatomic, readonly, copy) NSString *storeLocation;
@property (nonatomic, copy) NSString *region;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary NS_DESIGNATED_INITIALIZER;

@end
