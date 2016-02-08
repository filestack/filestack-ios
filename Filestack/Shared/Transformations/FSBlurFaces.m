//
//  FSBlurFaces.m
//  Filestack
//
//  Created by Łukasz Cichecki on 08/02/16.
//  Copyright © 2016 Filestack. All rights reserved.
//

#import "FSBlurFaces.h"

@implementation FSBlurFaces

- (instancetype)initWithMinSize:(NSNumber *)minSize maxSize:(NSNumber *)maxSize type:(FSPBlurFacesType)type buffer:(NSNumber *)buffer blurAmount:(NSNumber *)blurAmount andObscureAmount:(NSNumber *)obscureAmount {
    if (self = [super init]) {
        self.minSize = minSize;
        self.maxSize = maxSize;
        self.buffer = buffer;
        self.blur = blurAmount;
        self.amount = obscureAmount;
        self.type = type;
    }
    return self;
}

- (instancetype)initWithAllFacesAndMinSize:(NSNumber *)minSize maxSize:(NSNumber *)maxSize type:(FSPBlurFacesType)type buffer:(NSNumber *)buffer blurAmount:(NSNumber *)blurAmount andObscureAmount:(NSNumber *)obscureAmount {
    if (self = [self initWithMinSize:minSize maxSize:maxSize type:type buffer:buffer blurAmount:blurAmount andObscureAmount:obscureAmount]) {
        self.allFaces = YES;
    }
    return self;
}

- (instancetype)initWithMinSize:(NSNumber *)minSize maxSize:(NSNumber *)maxSize type:(FSPBlurFacesType)type buffer:(NSNumber *)buffer blurAmount:(NSNumber *)blurAmount obscureAmount:(NSNumber *)obscureAmount andFace:(NSNumber *)face {
    if (self = [self initWithMinSize:minSize maxSize:maxSize type:type buffer:buffer blurAmount:blurAmount andObscureAmount:obscureAmount]) {
        self.face = face;
    }
    return self;
}

- (instancetype)initWithMinSize:(NSNumber *)minSize maxSize:(NSNumber *)maxSize type:(FSPBlurFacesType)type buffer:(NSNumber *)buffer blurAmount:(NSNumber *)blurAmount obscureAmount:(NSNumber *)obscureAmount andFaces:(NSArray<NSNumber *> *)faces {
    if (self = [self initWithMinSize:minSize maxSize:maxSize type:type buffer:buffer blurAmount:blurAmount andObscureAmount:obscureAmount]) {
        self.faces = faces;
    }
    return self;
}

@end
