//
//  FSBlurFaces.m
//  Filestack
//
//  Created by Łukasz Cichecki on 08/02/16.
//  Copyright © 2016 Filestack. All rights reserved.
//

#import "FSBlurFaces.h"

@implementation FSBlurFaces

- (instancetype)initWithMinSize:(NSNumber *)minSize maxSize:(NSNumber *)maxSize type:(FSPBlurFacesType)type buffer:(NSNumber *)buffer blurAmount:(NSNumber *)blurAmount obscureAmount:(NSNumber *)obscureAmount {
    if ((self = [super init])) {
        _minSize = minSize;
        _maxSize = maxSize;
        _buffer = buffer;
        _blur = blurAmount;
        _amount = obscureAmount;
        _type = type;
    }
    return self;
}

- (instancetype)initWithAllFacesAndMinSize:(NSNumber *)minSize maxSize:(NSNumber *)maxSize type:(FSPBlurFacesType)type buffer:(NSNumber *)buffer blurAmount:(NSNumber *)blurAmount obscureAmount:(NSNumber *)obscureAmount {
    if ((self = [self initWithMinSize:minSize maxSize:maxSize type:type buffer:buffer blurAmount:blurAmount obscureAmount:obscureAmount])) {
        _allFaces = YES;
    }
    return self;
}

- (instancetype)initWithMinSize:(NSNumber *)minSize maxSize:(NSNumber *)maxSize type:(FSPBlurFacesType)type buffer:(NSNumber *)buffer blurAmount:(NSNumber *)blurAmount obscureAmount:(NSNumber *)obscureAmount face:(NSNumber *)face {
    if ((self = [self initWithMinSize:minSize maxSize:maxSize type:type buffer:buffer blurAmount:blurAmount obscureAmount:obscureAmount])) {
        _face = face;
    }
    return self;
}

- (instancetype)initWithMinSize:(NSNumber *)minSize maxSize:(NSNumber *)maxSize type:(FSPBlurFacesType)type buffer:(NSNumber *)buffer blurAmount:(NSNumber *)blurAmount obscureAmount:(NSNumber *)obscureAmount faces:(NSArray<NSNumber *> *)faces {
    if ((self = [self initWithMinSize:minSize maxSize:maxSize type:type buffer:buffer blurAmount:blurAmount obscureAmount:obscureAmount])) {
        _faces = faces;
    }
    return self;
}

- (instancetype)init {
    return [self initWithMinSize:nil maxSize:nil type:nil buffer:nil blurAmount:nil obscureAmount:nil faces:nil];
}

@end
