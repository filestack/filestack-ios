//
//  FSRoundedCorners.m
//  Filestack
//
//  Created by Łukasz Cichecki on 08/02/16.
//  Copyright © 2016 Filestack. All rights reserved.
//

#import "FSRoundedCorners.h"

@implementation FSRoundedCorners


- (instancetype)initWithRadius:(NSNumber *)radius blur:(NSNumber *)blur andBackground:(NSString *)background {
    if (self = [super init]) {
        self.radius = radius;
        self.blur = blur;
        self.background = background;
    }
    return self;
}

- (instancetype)initWithMaxRadiusAndBlur:(NSNumber *)blur andBackground:(NSString *)background {
    if (self = [self initWithRadius:nil blur:blur andBackground:background]) {
        self.maxRadius = YES;
    }
    return self;
}

@end
