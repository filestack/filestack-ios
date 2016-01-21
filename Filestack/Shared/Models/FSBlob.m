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
    if (self = [super init]) {
        self.url = dictionary[@"url"];
        self.fileName = dictionary[@"filename"];
        self.mimeType = dictionary[@"mimetype"] ?: dictionary[@"type"];
        self.size = [dictionary[@"size"] integerValue];
        self.key = dictionary[@"key"];
        self.container = dictionary[@"container"];
        self.path = dictionary[@"path"];
        self.writeable = YES;
    }
    return self;
}

- (instancetype)initWithURL:(NSString *)url {
    return [self initWithDictionary:@{@"url": url}];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"\nurl: %@\nfilename: %@\nsize: %ld\nkey: %@ \
                                      \ncontainer: %@\npath: %@\nwriteable: %d",
            _url, _fileName, _size, _key, _container, _path, _writeable];
}

@end
