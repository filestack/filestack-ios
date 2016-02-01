//
//  FSBlob+Private.m
//  Filestack
//
//  Created by Łukasz Cichecki on 20/01/16.
//  Copyright © 2016 Filestack. All rights reserved.
//

#import "FSMetadata+Private.h"

@implementation FSMetadata (Private)

@dynamic size, mimeType, fileName, width, height, uploaded, writeable, md5, location, path, container;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    if (self = [super init]) {
        self.size = [dictionary[@"size"] integerValue];
        self.mimeType = dictionary[@"mimetype"];
        self.fileName = dictionary[@"filename"];
        self.width = [dictionary[@"width"] integerValue];
        self.height = [dictionary[@"height"] integerValue];
        self.uploaded = [dictionary[@"uploaded"] integerValue];
        self.writeable = dictionary[@"writeable"] ?: [NSNumber numberWithBool:[dictionary[@"writeable"] boolValue]];
        self.md5 = dictionary[@"md5"];
        self.location = dictionary[@"location"];
        self.path = dictionary[@"path"];
        self.container = dictionary[@"container"];
    }
    return self;
}

@end
