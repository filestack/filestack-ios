//
//  FSPixelate.m
//  Filestack
//
//  Created by Łukasz Cichecki on 10/02/16.
//  Copyright © 2016 Filestack. All rights reserved.
//

#import "FSPixelate.h"

@implementation FSPixelate

- (instancetype)initWithAmount:(NSNumber *)amount {
    if (self = [super init]) {
        _amount = amount;
    }
    return self;
}

@end
