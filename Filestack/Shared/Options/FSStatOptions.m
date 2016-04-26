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
    if ((self = [super init])) {
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

- (instancetype)init {
    return [self initWithDictionary:@{}];
}

- (NSDictionary *)toQueryParameters {
    NSMutableDictionary *queryParameters = [[NSMutableDictionary alloc] init];

    if (self.size) {
        queryParameters[@"size"] = @"true";
    }

    if (self.mimeType) {
        queryParameters[@"mimetype"] = @"true";
    }

    if (self.fileName) {
        queryParameters[@"filename"] = @"true";
    }

    if (self.width) {
        queryParameters[@"width"] = @"true";
    }

    if (self.height) {
        queryParameters[@"height"] = @"true";
    }

    if (self.uploaded) {
        queryParameters[@"uploaded"] = @"true";
    }

    if (self.writeable) {
        queryParameters[@"writeable"] = @"true";
    }

    if (self.md5) {
        queryParameters[@"md5"] = @"true";
    }

    if (self.location) {
        queryParameters[@"location"] = @"true";
    }

    if (self.path) {
        queryParameters[@"path"] = @"true";
    }

    if (self.container) {
        queryParameters[@"container"] = @"true";
    }

    return queryParameters;
}

@end
