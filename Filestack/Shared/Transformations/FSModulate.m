//
//  FSModulate.m
//  Filestack
//
//  Created by Łukasz Cichecki on 10/02/16.
//  Copyright © 2016 Filestack. All rights reserved.
//

#import "FSModulate.h"

@implementation FSModulate


- (instancetype)initWithBrightness:(NSNumber *)brightness hue:(NSNumber *)hue saturation:(NSNumber *)saturation {
    if (self = [super init]) {
        _brightness = brightness;
        _hue = hue;
        _saturation = saturation;
    }
    return self;
}

@end
