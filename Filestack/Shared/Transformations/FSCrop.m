//
//  FSCrop.m
//  Filestack
//
//  Created by Łukasz Cichecki on 04/02/16.
//  Copyright © 2016 Filestack. All rights reserved.
//

#import "FSCrop.h"

@implementation FSCrop

- (instancetype)initWithX:(NSNumber *)x y:(NSNumber *)y width:(NSNumber *)width height:(NSNumber *)height {
    if (self = [super init]) {
        _x = x;
        _y = y;
        _width = width;
        _height = height;
    }
    return self;
}

@end
