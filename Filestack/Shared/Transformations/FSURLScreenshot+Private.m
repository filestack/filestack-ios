//
//  FSURLScreenshot+Private.m
//  Filestack
//
//  Created by Łukasz Cichecki on 10/02/16.
//  Copyright © 2016 Filestack. All rights reserved.
//

#import "FSURLScreenshot+Private.h"

@implementation FSURLScreenshot (Private)

- (NSString *)toQuery {
    if (!self.height && !self.width && !self.agent && !self.mode) {
        return @"urlscreenshot";
    }

    NSMutableArray *queryArray = [[NSMutableArray alloc] init];

    if (self.width) {
        [queryArray addObject:[NSString stringWithFormat:@"width:%ld", (long)(self.width).integerValue]];
    }

    if (self.height) {
        [queryArray addObject:[NSString stringWithFormat:@"height:%ld", (long)(self.height).integerValue]];
    }

    if (self.agent) {
        [queryArray addObject:[NSString stringWithFormat:@"agent:%@", self.agent]];
    }

    if (self.mode) {
        [queryArray addObject:[NSString stringWithFormat:@"mode:%@", self.mode]];
    }

    return [NSString stringWithFormat:@"%@=%@", @"urlscreenshot", [queryArray componentsJoinedByString:@","]];
}

@end
