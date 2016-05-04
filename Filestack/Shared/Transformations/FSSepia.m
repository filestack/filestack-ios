//
//  FSSepia.m
//  Filestack
//
//  Created by Łukasz Cichecki on 10/02/16.
//  Copyright © 2016 Filestack. All rights reserved.
//

#import "FSSepia.h"

@implementation FSSepia

- (instancetype)initWithTone:(NSNumber *)tone {
    if ((self = [super init])) {
        _tone = tone;
    }
    return self;
}

- (instancetype)init {
    return [self initWithTone:nil];
}

@end
