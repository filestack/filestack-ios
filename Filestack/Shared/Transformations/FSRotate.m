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
    if (self = [super init]) {
        self.degrees = degrees;
        self.background = background;
        self.toEXIF = toEXIF;
        self.resetEXIF = resetEXIF;
    }
    return self;
}

@end
