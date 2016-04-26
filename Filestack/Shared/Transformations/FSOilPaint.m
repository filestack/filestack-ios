//
//  FSOilPaint.m
//  Filestack
//
//  Created by Łukasz Cichecki on 10/02/16.
//  Copyright © 2016 Filestack. All rights reserved.
//

#import "FSOilPaint.h"

@implementation FSOilPaint

- (instancetype)initWithAmount:(NSNumber *)amount {
    if ((self = [super init])) {
        _amount = amount;
    }
    return self;
}

- (instancetype)init {
    return [self initWithAmount:nil];
}

@end
