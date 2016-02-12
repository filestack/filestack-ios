//
//  FSBorders+Private.m
//  Filestack
//
//  Created by Łukasz Cichecki on 08/02/16.
//  Copyright © 2016 Filestack. All rights reserved.
//

#import "FSBorder+Private.h"

@implementation FSBorder (Private)

- (NSString *)toQuery {
    if (!self.background && !self.width && !self.color) {
        return @"border";
    }

    NSMutableArray *queryArray = [[NSMutableArray alloc] init];

    if (self.width) {
        [queryArray addObject:[NSString stringWithFormat:@"width:%ld", (long)[self.width integerValue]]];
    }

    if (self.background) {
        [queryArray addObject:[NSString stringWithFormat:@"background:%@", self.background]];
    }

    if (self.color) {
        [queryArray addObject:[NSString stringWithFormat:@"color:%@", self.color]];
    }

    return [NSString stringWithFormat:@"%@=%@", @"border", [queryArray componentsJoinedByString:@","]];
}

@end
