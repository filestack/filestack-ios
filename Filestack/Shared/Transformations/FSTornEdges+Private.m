//
//  FSTornEdges+Private.m
//  Filestack
//
//  Created by Łukasz Cichecki on 08/02/16.
//  Copyright © 2016 Filestack. All rights reserved.
//

#import "FSTornEdges+Private.h"

@implementation FSTornEdges (Private)

- (NSString *)toQuery {
    if (!self.spread && !self.background) {
        return @"torn_edges";
    }

    NSMutableArray *queryArray = [[NSMutableArray alloc] init];

    if (self.spread) {
        [queryArray addObject:[NSString stringWithFormat:@"spread:%@", [self spreadArrayToString]]];
    }

    if (self.background) {
        [queryArray addObject:[NSString stringWithFormat:@"background:%@", self.background]];
    }

    return [NSString stringWithFormat:@"%@=%@", @"torn_edges", [queryArray componentsJoinedByString:@","]];
}

- (NSString *)spreadArrayToString {
    NSMutableArray *spreadIntegerArray = [[NSMutableArray alloc] init];

    for (NSNumber *spreadComponent in self.spread) {
        [spreadIntegerArray addObject:[NSNumber numberWithInteger:[spreadComponent integerValue]]];
    }

    return [NSString stringWithFormat:@"[%@]", [spreadIntegerArray componentsJoinedByString:@","]];
}

@end
