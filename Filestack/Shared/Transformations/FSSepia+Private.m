//
//  FSSepia+Private.m
//  Filestack
//
//  Created by Łukasz Cichecki on 10/02/16.
//  Copyright © 2016 Filestack. All rights reserved.
//

#import "FSSepia+Private.h"

@implementation FSSepia (Private)

- (NSString *)toQuery {
    if (!self.tone) {
        return @"sepia";
    }

    return [NSString stringWithFormat:@"sepia=tone:%ld", (long)(self.tone).integerValue];
}

@end
