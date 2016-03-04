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
