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
    if (self = [super init]) {
        self.mode = mode;
        self.width = width;
        self.height = height;
    }
    return self;
}

- (instancetype)initWithMode:(FSCropFacesMode)mode width:(NSNumber *)width height:(NSNumber *)height buffer:(NSNumber *)buffer face:(NSNumber *)face {
    if (self = [self initWithMode:mode width:width height:height buffer:buffer]) {
        self.face = face;
    }
    return self;
}

- (instancetype)initWithMode:(FSCropFacesMode)mode width:(NSNumber *)width height:(NSNumber *)height buffer:(NSNumber *)buffer faces:(NSArray<NSNumber *> *)faces {
    if (self = [self initWithMode:mode width:width height:height buffer:buffer]) {
        self.faces = faces;
    }
    return self;
}

- (instancetype)initAllFacesWithMode:(FSCropFacesMode)mode width:(NSNumber *)width height:(NSNumber *)height buffer:(NSNumber *)buffer {
    if (self = [self initWithMode:mode width:width height:height buffer:buffer]) {
        self.allFaces = YES;
    }
    return self;
}

@end
