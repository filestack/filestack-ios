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
        [queryArray addObject:[NSString stringWithFormat:@"spread:[%@]", [self.spread componentsJoinedByString:@","]]];
    }

    if (self.background) {
        [queryArray addObject:[NSString stringWithFormat:@"background:%@", self.background]];
    }

    return [NSString stringWithFormat:@"%@=%@", @"torn_edges", [queryArray componentsJoinedByString:@","]];
}

@end
