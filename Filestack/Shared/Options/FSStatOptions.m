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
        self.size = [dictionary[@"size"] isEqual:@YES];
        self.mimeType = [dictionary[@"mimetype"] isEqual:@YES];
        self.fileName = [dictionary[@"filename"] isEqual:@YES];
        self.width = [dictionary[@"width"] isEqual:@YES];
        self.height = [dictionary[@"height"] isEqual:@YES];
        self.uploaded = [dictionary[@"uploaded"] isEqual:@YES];
        self.writeable = [dictionary[@"writeable"] isEqual:@YES];
        self.md5 = [dictionary[@"md5"] isEqual:@YES];
        self.location = [dictionary[@"location"] isEqual:@YES];
        self.path = [dictionary[@"path"] isEqual:@YES];
        self.container = [dictionary[@"container"] isEqual:@YES];
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
