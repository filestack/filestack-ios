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
        self.writeable = dictionary[@"writeable"] ?: [NSNumber numberWithBool:[dictionary[@"writeable"] boolValue]];
    }
    return self;
}

- (instancetype)initWithURL:(NSString *)url {
    return [self initWithDictionary:@{@"url": url}];
}

- (NSString *)s3url {
    if (_container && _key) {
        return [NSString stringWithFormat:@"https://%@.s3.amazonaws.com/%@", _container, _key];
    }
    return nil;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"\nurl: %@\nfilename: %@\nsize: %ld\nmimetype: %@\nkey: %@ \
                                      \ncontainer: %@\npath: %@\nwriteable: %@\ns3url: %@",
            _url, _fileName, (long)_size, _mimeType, _key, _container, _path, _writeable, self.s3url];
}

@end
