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
        self.x = x;
        self.y = y;
        self.width = width;
        self.height = height;
    }
    return self;
}

@end
