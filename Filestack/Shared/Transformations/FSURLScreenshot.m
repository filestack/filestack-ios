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
    if (self = [super init]) {
        self.width = width;
        self.height = height;
        self.agent = agent;
        self.mode = mode;
    }
    return self;
}

@end
