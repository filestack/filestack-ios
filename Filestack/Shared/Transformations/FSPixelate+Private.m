//
//  FSPixelate+Private.m
//  Filestack
//
//  Created by Łukasz Cichecki on 10/02/16.
//  Copyright © 2016 Filestack. All rights reserved.
//

#import "FSPixelate+Private.h"

@implementation FSPixelate (Private)

- (NSString *)toQuery {
    if (!self.amount) {
        return @"pixelate";
    }

    return [NSString stringWithFormat:@"pixelate=amount:%ld", (long)(self.amount).integerValue];
}

@end
