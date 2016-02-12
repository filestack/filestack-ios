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
        self.blur = blur;
        self.opacity = opacity;
        self.vector = vector;
        self.color = color;
        self.background = background;
    }
    return self;
}

@end
