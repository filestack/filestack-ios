//
//  FSStatOptions.m
//  Filestack
//
//  Created by Łukasz Cichecki on 20/01/16.
//  Copyright © 2016 Filestack. All rights reserved.
//

#import "FSStatOptions.h"

@implementation FSStatOptions

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    if (self = [super init]) {
        _size = [dictionary[@"size"] isEqual:@YES];
        _mimeType = [dictionary[@"mimetype"] isEqual:@YES];
        _fileName = [dictionary[@"filename"] isEqual:@YES];
        _width = [dictionary[@"width"] isEqual:@YES];
        _height = [dictionary[@"height"] isEqual:@YES];
        _uploaded = [dictionary[@"uploaded"] isEqual:@YES];
        _writeable = [dictionary[@"writeable"] isEqual:@YES];
        _md5 = [dictionary[@"md5"] isEqual:@YES];
        _location = [dictionary[@"location"] isEqual:@YES];
        _path = [dictionary[@"path"] isEqual:@YES];
        _container = [dictionary[@"container"] isEqual:@YES];
    }
    return self;
}

- (NSDictionary *)toQueryParameters {
    NSMutableDictionary *queryParameters = [[NSMutableDictionary alloc] init];

    if (_size) {
        queryParameters[@"size"] = @"true";
    }

    if (_mimeType) {
        queryParameters[@"mimetype"] = @"true";
    }

    if (_fileName) {
        queryParameters[@"filename"] = @"true";
    }

    if (_width) {
        queryParameters[@"width"] = @"true";
    }

    if (_height) {
        queryParameters[@"height"] = @"true";
    }

    if (_uploaded) {
        queryParameters[@"uploaded"] = @"true";
    }

    if (_writeable) {
        queryParameters[@"writeable"] = @"true";
    }

    if (_md5) {
        queryParameters[@"md5"] = @"true";
    }

    if (_location) {
        queryParameters[@"location"] = @"true";
    }

    if (_path) {
        queryParameters[@"path"] = @"true";
    }

    if (_container) {
        queryParameters[@"container"] = @"true";
    }

    return queryParameters;
}

@end
