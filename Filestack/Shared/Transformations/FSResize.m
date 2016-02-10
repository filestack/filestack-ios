//
//  FSResize.m
//  Filestack
//
//  Created by Łukasz Cichecki on 04/02/16.
//  Copyright © 2016 Filestack. All rights reserved.
//

#import "FSResize.h"

@interface FSResize ()

@end

@implementation FSResize

- (instancetype)initWithWidth:(NSNumber *)width height:(NSNumber *)height fit:(FSResizeFit)fit align:(FSResizeAlign)align {
    if (self = [super init]) {
        self.width = width;
        self.height = height;
        self.fit = fit;
        self.align = align;
    }
    return self;
}

- (instancetype)initWithWidth:(NSNumber *)width height:(NSNumber *)height {
    return [self initWithWidth:width height:height fit:nil align:nil];
}

- (instancetype)initWithWidth:(NSNumber *)width height:(NSNumber *)height fit:(FSResizeFit)fit {
    return [self initWithWidth:width height:height fit:fit align:nil];
}

- (instancetype)initWithHeight:(NSNumber *)height {
    return [self initWithWidth:nil height:height fit:nil align:nil];
}

- (instancetype)initWithWidth:(NSNumber *)width {
    return [self initWithWidth:width height:nil fit:nil align:nil];
}

@end
