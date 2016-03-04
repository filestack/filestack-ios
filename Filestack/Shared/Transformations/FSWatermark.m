//
//  FSWatermark.m
//  Filestack
//
//  Created by Łukasz Cichecki on 05/02/16.
//  Copyright © 2016 Filestack. All rights reserved.
//

#import "FSWatermark.h"

@implementation FSWatermark

- (instancetype)initWithBlob:(FSBlob *)blob size:(NSNumber *)size position:(FSWatermarkPosition)position {
    if (self = [super init]) {
        _blob = blob;
        _size = size;
        _position = position;
    }
    return self;
}

@end
