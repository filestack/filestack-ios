//
//  FSShadow.m
//  Filestack
//
//  Created by Łukasz Cichecki on 08/02/16.
//  Copyright © 2016 Filestack. All rights reserved.
//

#import "FSShadow.h"

@implementation FSShadow

- (instancetype)initWithBlur:(NSNumber *)blur opacity:(NSNumber *)opacity vector:(NSArray<NSNumber *> *)vector color:(NSString *)color background:(NSString *)background {
    if (self = [super init]) {
        _blur = blur;
        _opacity = opacity;
        _vector = vector;
        _color = color;
        _background = background;
    }
    return self;
}

@end
