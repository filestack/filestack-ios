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
@property (nonatomic, readwrite, assign) NSString *mimeType;
@property (nonatomic, readwrite, assign) NSString *fileName;
@property (nonatomic, readwrite, assign) NSInteger width;
@property (nonatomic, readwrite, assign) NSInteger height;
@property (nonatomic, readwrite, assign) NSInteger uploaded;
@property (nonatomic, readwrite, assign) BOOL writeable;
@property (nonatomic, readwrite, assign) NSString *md5;
@property (nonatomic, readwrite, assign) NSString *location;
@property (nonatomic, readwrite, assign) NSString *path;
@property (nonatomic, readwrite, assign) NSString *container;

@end

@implementation FSMetadata

- (NSString *)description {
    return [NSString stringWithFormat:@"\nsize: %ld\nfilename: %@\nmimetype: %@\nwidth: %ld \
            \nheight: %ld\nuploaded: %ld\nwriteable: %d\nmd5: %@\nlocation: %@\npath: %@\ncontainer: %@",
            _size, _fileName, _mimeType, _width, _height, _uploaded, _writeable, _md5, _location, _path, _container];
}

@end
