//
//  FSRoundedCorners+Private.m
//  Filestack
//
//  Created by Łukasz Cichecki on 08/02/16.
//  Copyright © 2016 Filestack. All rights reserved.
//

#import "FSRoundedCorners+Private.h"

@implementation FSRoundedCorners (Private)

- (NSString *)toQuery {
    if (!self.radius && !self.maxRadius && !self.blur && !self.background) {
        return @"rounded_corners";
    }

    NSMutableArray *queryArray = [[NSMutableArray alloc] init];

    if (self.radius || self.maxRadius) {
        if (self.maxRadius) {
            [queryArray addObject:@"radius:max"];
        } else {
            [queryArray addObject:[NSString stringWithFormat:@"radius:%ld", (long)[self.radius integerValue]]];
        }
    }

    if (self.blur) {
        [queryArray addObject:[NSString stringWithFormat:@"blur:%f", [self.blur floatValue]]];
    }

    if (self.background) {
        [queryArray addObject:[NSString stringWithFormat:@"background:%@", self.background]];
    }

    return [NSString stringWithFormat:@"%@=%@", @"rounded_corners", [queryArray componentsJoinedByString:@","]];
}

@end
