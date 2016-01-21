//
//  FSStoreOptions.h
//  Filestack
//
//  Created by Łukasz Cichecki on 21/01/16.
//  Copyright © 2016 Filestack. All rights reserved.
//

#import <Foundation/Foundation.h>
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

@property (nonatomic, strong) NSString *fileName;
@property (nonatomic, strong) FSStoreLocation location;
@property (nonatomic, strong) NSString *mimeType;
@property (nonatomic, strong) NSString *path;
@property (nonatomic, strong) NSString *container;
@property (nonatomic, strong) FSAccess access;
@property (nonatomic, assign) BOOL base64decode;
@property (nonatomic, strong) FSSecurity *security;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;
- (NSDictionary *)toQueryParameters;
- (NSString *)storeLocation;

@end
