//
//  FSSharpen+Private.m
//  Filestack
//
//  Created by Łukasz Cichecki on 10/02/16.
//  Copyright © 2016 Filestack. All rights reserved.
//

#import "FSSharpen+Private.h"

@implementation FSSharpen (Private)

- (NSString *)toQuery {
    if (!self.amount) {
        return @"sharpen";
    }

    return [NSString stringWithFormat:@"sharpen=amount:%ld", (long)[self.amount integerValue]];
}

@end
