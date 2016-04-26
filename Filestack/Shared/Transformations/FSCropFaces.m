//
//  FSCropFaces.m
//  Filestack
//
//  Created by Łukasz Cichecki on 08/02/16.
//  Copyright © 2016 Filestack. All rights reserved.
//

#import "FSCropFaces.h"

@implementation FSCropFaces


- (instancetype)initWithMode:(FSCropFacesMode)mode width:(NSNumber *)width height:(NSNumber *)height buffer:(NSNumber *)buffer {
    if ((self = [super init])) {
        _mode = mode;
        _width = width;
        _height = height;
        _buffer = buffer;
    }
    return self;
}

- (instancetype)initWithMode:(FSCropFacesMode)mode width:(NSNumber *)width height:(NSNumber *)height buffer:(NSNumber *)buffer face:(NSNumber *)face {
    if ((self = [self initWithMode:mode width:width height:height buffer:buffer])) {
        _face = face;
    }
    return self;
}

- (instancetype)initWithMode:(FSCropFacesMode)mode width:(NSNumber *)width height:(NSNumber *)height buffer:(NSNumber *)buffer faces:(NSArray<NSNumber *> *)faces {
    if ((self = [self initWithMode:mode width:width height:height buffer:buffer])) {
        _faces = faces;
    }
    return self;
}

- (instancetype)initAllFacesWithMode:(FSCropFacesMode)mode width:(NSNumber *)width height:(NSNumber *)height buffer:(NSNumber *)buffer {
    if ((self = [self initWithMode:mode width:width height:height buffer:buffer])) {
        _allFaces = YES;
    }
    return self;
}

- (instancetype)init {
    return [self initAllFacesWithMode:nil width:nil height:nil buffer:nil];
}

@end
