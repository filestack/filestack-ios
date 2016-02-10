//
//  FSPolaroid.m
//  Filestack
//
//  Created by Łukasz Cichecki on 08/02/16.
//  Copyright © 2016 Filestack. All rights reserved.
//

#import "FSPolaroid.h"

@implementation FSPolaroid

- (instancetype)initWithColor:(NSString *)color background:(NSString *)background rotation:(NSNumber *)rotate {
    if (self = [super init]) {
        self.color = color;
        self.background = background;
        self.rotate = rotate;
    }
    return self;
}

@end
