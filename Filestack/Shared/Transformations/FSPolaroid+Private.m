//
//  FSPolaroid+Private.m
//  Filestack
//
//  Created by Łukasz Cichecki on 08/02/16.
//  Copyright © 2016 Filestack. All rights reserved.
//

#import "FSPolaroid+Private.h"

@implementation FSPolaroid (Private)

- (NSString *)toQuery {
    if (!self.rotate && !self.background && !self.color) {
        return @"polaroid";
    }

    NSMutableArray *queryArray = [[NSMutableArray alloc] init];

    if (self.rotate) {
        [queryArray addObject:[NSString stringWithFormat:@"rotate:%ld", [self.rotate integerValue]]];
    }

    if (self.background) {
        [queryArray addObject:[NSString stringWithFormat:@"background:%@", self.background]];
    }

    if (self.color) {
        [queryArray addObject:[NSString stringWithFormat:@"color:%@", self.color]];
    }

    return [NSString stringWithFormat:@"%@=%@", @"polaroid", [queryArray componentsJoinedByString:@","]];
}

@end
