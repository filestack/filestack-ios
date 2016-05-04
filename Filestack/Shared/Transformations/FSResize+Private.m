//
//  FSResize+Private.m
//  Filestack
//
//  Created by Łukasz Cichecki on 04/02/16.
//  Copyright © 2016 Filestack. All rights reserved.
//

#import "FSResize+Private.h"

@implementation FSResize (Private)

- (NSString *)toQuery {
    if (!self.width && !self.height) {
        return nil;
    }

    NSMutableArray *queryArray = [[NSMutableArray alloc] init];

    if (self.width) {
        [queryArray addObject:[NSString stringWithFormat:@"width:%ld", (long)(self.width).integerValue]];
    }

    if (self.height) {
        [queryArray addObject:[NSString stringWithFormat:@"height:%ld", (long)(self.height).integerValue]];
    }

    if (self.fit) {
        [queryArray addObject:[NSString stringWithFormat:@"fit:%@", self.fit]];
    }

    if (self.align) {
        [queryArray addObject:[NSString stringWithFormat:@"align:%@", self.align]];
    }

    return [NSString stringWithFormat:@"%@=%@", @"resize", [queryArray componentsJoinedByString:@","]];
}

@end
