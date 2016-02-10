//
//  FSPixelateFaces.m
//  Filestack
//
//  Created by Łukasz Cichecki on 08/02/16.
//  Copyright © 2016 Filestack. All rights reserved.
//

#import "FSPixelateFaces.h"

@implementation FSPixelateFaces

- (instancetype)initWithMinSize:(NSNumber *)minSize maxSize:(NSNumber *)maxSize type:(FSPixelateFacesType)type buffer:(NSNumber *)buffer blurAmount:(NSNumber *)blurAmount pixelateAmount:(NSNumber *)pixelateAmount {
    if (self = [super init]) {
        self.minSize = minSize;
        self.maxSize = maxSize;
        self.buffer = buffer;
        self.blur = blurAmount;
        self.amount = pixelateAmount;
        self.type = type;
    }
    return self;
}

- (instancetype)initWithAllFacesAndMinSize:(NSNumber *)minSize maxSize:(NSNumber *)maxSize type:(FSPixelateFacesType)type buffer:(NSNumber *)buffer blurAmount:(NSNumber *)blurAmount pixelateAmount:(NSNumber *)pixelateAmount {
    if (self = [self initWithMinSize:minSize maxSize:maxSize type:type buffer:buffer blurAmount:blurAmount pixelateAmount:pixelateAmount]) {
        self.allFaces = YES;
    }
    return self;
}

- (instancetype)initWithMinSize:(NSNumber *)minSize maxSize:(NSNumber *)maxSize type:(FSPixelateFacesType)type buffer:(NSNumber *)buffer blurAmount:(NSNumber *)blurAmount pixelateAmount:(NSNumber *)pixelateAmount face:(NSNumber *)face {
    if (self = [self initWithMinSize:minSize maxSize:maxSize type:type buffer:buffer blurAmount:blurAmount pixelateAmount:pixelateAmount]) {
        self.face = face;
    }
    return self;
}

- (instancetype)initWithMinSize:(NSNumber *)minSize maxSize:(NSNumber *)maxSize type:(FSPixelateFacesType)type buffer:(NSNumber *)buffer blurAmount:(NSNumber *)blurAmount pixelateAmount:(NSNumber *)pixelateAmount faces:(NSArray<NSNumber *> *)faces {
    if (self = [self initWithMinSize:minSize maxSize:maxSize type:type buffer:buffer blurAmount:blurAmount pixelateAmount:pixelateAmount]) {
        self.faces = faces;
    }
    return self;
}

@end
