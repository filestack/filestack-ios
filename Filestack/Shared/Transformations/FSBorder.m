//
//  FSBorders.m
//  Filestack
//
//  Created by Łukasz Cichecki on 08/02/16.
//  Copyright © 2016 Filestack. All rights reserved.
//

#import "FSBorder.h"

@implementation FSBorder

- (instancetype)initWithWidth:(NSNumber *)width color:(NSString *)color andBackground:(NSString *)background {
    if (self = [super init]) {
        self.width = width;
        self.color = color;
        self.background = background;
    }
    return self;
}

@end
