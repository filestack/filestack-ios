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
    if ((self = [super init])) {
        self.blob = blob;
        self.size = size;
        self.position = position;
    }
    return self;
}

@end
