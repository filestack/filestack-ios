//
//  FSStoreOptions.m
//  Filestack
//
//  Created by Łukasz Cichecki on 21/01/16.
//  Copyright © 2016 Filestack. All rights reserved.
//

#import "FSStoreOptions.h"

@implementation FSStoreOptions

- (id)copyWithZone:(NSZone *)zone {
    FSStoreOptions *newOptions = [[[self class] allocWithZone:zone] init];

    if (newOptions) {
        newOptions.fileName = self.fileName;
        newOptions.location = self.location;
        newOptions.mimeType = self.mimeType;
        newOptions.path = self.path;
        newOptions.container = self.container;
        newOptions.access = self.access;
        newOptions.base64decode = self.base64decode;
        newOptions.security = self.security;
    }

    return newOptions;
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    if ((self = [super init])) {
        _fileName = dictionary[@"filename"];
        _location = dictionary[@"location"];
        _mimeType = dictionary[@"mimetype"];
        _path = dictionary[@"path"];
        _container = dictionary[@"container"];
        _access = dictionary[@"access"];
        _base64decode = [dictionary[@"base64decode"] boolValue];
        _security = dictionary[@"security"];
    }

    return self;
}

- (instancetype)init {
    return [self initWithDictionary:@{}];
}

- (NSDictionary *)toQueryParameters {
    NSMutableDictionary *queryParameters = [[NSMutableDictionary alloc] init];

    if (self.fileName) {
        queryParameters[@"filename"] = self.fileName;
    }

    if (self.mimeType) {
        queryParameters[@"mimetype"] = self.mimeType;
    }

    if (self.path) {
        queryParameters[@"path"] = self.path;
    }

    if (self.container) {
        queryParameters[@"container"] = self.container;
    }

    if (self.access) {
        queryParameters[@"access"] = self.access;
    }

    if (self.base64decode) {
        queryParameters[@"base64decode"] = @"true";
    }

    if (self.security) {
        queryParameters[@"policy"] = self.security.policy;
        queryParameters[@"signature"] = self.security.signature;
    }

    return queryParameters;
}

- (NSString *)storeLocation {
    if (self.location) {
        return self.location;
    }

    return @"S3";
}

@end
