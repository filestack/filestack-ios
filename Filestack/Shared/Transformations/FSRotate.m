//
//  FSRotate.m
//  Filestack
//
//  Created by Łukasz Cichecki on 04/02/16.
//  Copyright © 2016 Filestack. All rights reserved.
//

#import "FSRotate.h"

@implementation FSRotate

- (instancetype)initWithDegrees:(NSNumber *)degrees background:(NSString *)background rotateToEXIF:(BOOL)toEXIF resetEXIF:(BOOL)resetEXIF {
    if ((self = [super init])) {
        _degrees = degrees;
        _background = background;
        _toEXIF = toEXIF;
        _resetEXIF = resetEXIF;
    }
    return self;
}

- (instancetype)init {
    return [self initWithDegrees:nil background:nil rotateToEXIF:NO resetEXIF:NO];
}

@end
