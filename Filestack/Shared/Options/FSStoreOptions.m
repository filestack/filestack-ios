//
//  FSStoreOptions.m
//  Filestack
//
//  Created by Łukasz Cichecki on 21/01/16.
//  Copyright © 2016 Filestack. All rights reserved.
//

#import "FSStoreOptions.h"

@implementation FSStoreOptions

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    if (self = [super init]) {
        self.fileName = dictionary[@"filename"];
        self.location = dictionary[@"location"];
        self.mimeType = dictionary[@"mimetype"];
        self.path = dictionary[@"path"];
        self.container = dictionary[@"container"];
        self.access = dictionary[@"access"];
        self.base64decode = dictionary[@"base64decode"];
        self.security = dictionary[@"security"];
    }
    return self;
}

- (NSDictionary *)toQueryParameters {
    NSMutableDictionary *queryParameters = [[NSMutableDictionary alloc] init];

    if (_fileName) {
        queryParameters[@"filename"] = _fileName;
    }

    if (_mimeType) {
        queryParameters[@"mimetype"] = _mimeType;
    }

    if (_path) {
        queryParameters[@"path"] = _path;
    }

    if (_container) {
        queryParameters[@"container"] = _container;
    }

    if (_access) {
        queryParameters[@"access"] = _access;
    }

    if (_base64decode) {
        queryParameters[@"base64decode"] = @"true";
    }

    if (_security) {
        queryParameters[@"policy"] = _security.policy;
        queryParameters[@"signature"] = _security.signature;
    }

    return queryParameters;
}

- (NSString *)storeLocation {
    if (_location) {
        return _location;
    }
    return @"S3";
}

@end
