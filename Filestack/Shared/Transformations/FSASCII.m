//
//  FSASCII.m
//  Filestack
//
//  Created by Łukasz Cichecki on 10/02/16.
//  Copyright © 2016 Filestack. All rights reserved.
//

#import "FSASCII.h"

@implementation FSASCII

- (instancetype)initWithForeground:(NSString *)foreground background:(NSString *)background size:(NSNumber *)size reverse:(BOOL)reverse colored:(BOOL)colored {
    if (self = [super init]) {
        self.foreground = foreground;
        self.background = background;
        self.size = size;
        self.reverse = reverse;
        self.colored = colored;
    }
    return self;
}

@end
