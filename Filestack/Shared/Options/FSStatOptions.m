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
        self.size = dictionary[@"size"];
        self.mimeType = dictionary[@"mimeType"];
        self.fileName = dictionary[@"fileName"];
        self.width = dictionary[@"width"];
        self.height = dictionary[@"height"];
        self.uploaded = dictionary[@"uploaded"];
        self.writeable = dictionary[@"writeable"];
        self.md5 = dictionary[@"md5"];
        self.location = dictionary[@"location"];
        self.path = dictionary[@"path"];
        self.container = dictionary[@"container"];
    }
    return self;
}

- (NSDictionary *)toQueryParameters {
    NSMutableDictionary *queryParameters = [[NSMutableDictionary alloc] init];

    if (_size) {
        queryParameters[@"size"] = @"true";
    }

    if (_mimeType) {
        queryParameters[@"mimeType"] = @"true";
    }

    if (_fileName) {
        queryParameters[@"fileName"] = @"true";
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
