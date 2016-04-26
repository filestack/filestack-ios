//
//  FSOilPaint+Private.m
//  Filestack
//
//  Created by Łukasz Cichecki on 10/02/16.
//  Copyright © 2016 Filestack. All rights reserved.
//

#import "FSOilPaint+Private.h"

@implementation FSOilPaint (Private)

- (NSString *)toQuery {
    if (!self.amount) {
        return @"oil_paint";
    }

    return [NSString stringWithFormat:@"oil_paint=amount:%ld", (long)(self.amount).integerValue];
}

@end
