//
//  FSASCII+Private.m
//  Filestack
//
//  Created by Łukasz Cichecki on 10/02/16.
//  Copyright © 2016 Filestack. All rights reserved.
//

#import "FSASCII+Private.h"

@implementation FSASCII (Private)

- (NSString *)toQuery {
    if (!self.background && !self.foreground && !self.colored && !self.reverse && !self.size) {
        return @"ascii";
    }

    NSMutableArray *queryArray = [[NSMutableArray alloc] init];

    if (self.background) {
        [queryArray addObject:[NSString stringWithFormat:@"background:%@", self.background]];
    }

    if (self.foreground) {
        [queryArray addObject:[NSString stringWithFormat:@"foreground:%@", self.foreground]];
    }

    if (self.colored) {
        [queryArray addObject:@"colored:true"];
    }

    if (self.reverse) {
        [queryArray addObject:@"reverse:true"];
    }

    if (self.size) {
        [queryArray addObject:[NSString stringWithFormat:@"size:%ld", (long)(self.size).integerValue]];
    }

    return [NSString stringWithFormat:@"%@=%@", @"ascii", [queryArray componentsJoinedByString:@","]];
}

@end
