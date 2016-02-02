//
//  FSMetadata.m
//  Filestack
//
//  Created by Łukasz Cichecki on 20/01/16.
//  Copyright © 2016 Filestack. All rights reserved.
//

#import "FSMetadata.h"

@interface FSMetadata ()

@property (nonatomic, readwrite, assign) NSInteger size;
@property (nonatomic, readwrite, strong) NSString *mimeType;
@property (nonatomic, readwrite, strong) NSString *fileName;
@property (nonatomic, readwrite, assign) NSInteger width;
@property (nonatomic, readwrite, assign) NSInteger height;
@property (nonatomic, readwrite, assign) NSInteger uploaded;
@property (nonatomic, readwrite, strong) NSNumber *writeable;
@property (nonatomic, readwrite, strong) NSString *md5;
@property (nonatomic, readwrite, strong) NSString *location;
@property (nonatomic, readwrite, strong) NSString *path;
@property (nonatomic, readwrite, strong) NSString *container;

@end

@implementation FSMetadata

- (NSString *)s3url {
    if (_container && _path) {
        return [NSString stringWithFormat:@"https://%@.s3.amazonaws.com/%@", _container, _path];
    }
    return nil;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"\nsize: %ld\nfilename: %@\nmimetype: %@\nwidth: %ld \
            \nheight: %ld\nuploaded: %ld\nwriteable: %@\nmd5: %@\nlocation: %@\npath: %@\ncontainer: %@\ns3url: %@",
            (long)_size, _fileName, _mimeType, (long)_width, (long)_height, (long)_uploaded, _writeable, _md5, _location, _path, _container, self.s3url];
}

@end
