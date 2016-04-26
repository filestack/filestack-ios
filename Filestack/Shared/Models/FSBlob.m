//
//  FSBlob.m
//  Filestack
//
//  Created by Łukasz Cichecki on 20/01/16.
//  Copyright © 2016 Filestack. All rights reserved.
//

#import "FSBlob.h"

@implementation FSBlob

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    if ((self = [super init])) {
        _url = dictionary[@"url"];
        _fileName = dictionary[@"filename"];
        _mimeType = dictionary[@"mimetype"] ?: dictionary[@"type"];
        _size = [dictionary[@"size"] integerValue];
        _key = dictionary[@"key"];
        _container = dictionary[@"container"];
        _path = dictionary[@"path"];
        _writeable = dictionary[@"writeable"] == nil ? nil : @([dictionary[@"writeable"] boolValue]);
    }
    return self;
}

- (instancetype)initWithURL:(NSString *)url {
    if (url != nil) {
        return [self initWithDictionary:@{@"url": url}];
    }
    return [self initWithDictionary:@{}];
}

- (NSString *)s3url {
    if (self.container && self.key) {
        return [NSString stringWithFormat:@"https://%@.s3.amazonaws.com/%@", self.container, self.key];
    }
    return nil;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"\nurl: %@\nfilename: %@\nsize: %ld\nmimetype: %@\nkey: %@ \
                                      \ncontainer: %@\npath: %@\nwriteable: %@\ns3url: %@",
            self.url, self.fileName, (long)self.size, self.mimeType, self.key, self.container, self.path, self.writeable, self.s3url];
}

@end
