//
//  FSURLScreenshot.m
//  Filestack
//
//  Created by Łukasz Cichecki on 10/02/16.
//  Copyright © 2016 Filestack. All rights reserved.
//

#import "FSURLScreenshot.h"

@implementation FSURLScreenshot

- (instancetype)initWithWidth:(NSNumber *)width height:(NSNumber *)height agent:(FSURLScreenshotAgent)agent mode:(FSURLScreenshotMode)mode {
    if ((self = [super init])) {
        _width = width;
        _height = height;
        _agent = agent;
        _mode = mode;
    }
    return self;
}

- (instancetype)init {
    return [self initWithWidth:nil height:nil agent:nil mode:nil];
}

@end
