//
//  FSShadow+Private.m
//  Filestack
//
//  Created by Łukasz Cichecki on 08/02/16.
//  Copyright © 2016 Filestack. All rights reserved.
//

#import "FSShadow+Private.h"

@implementation FSShadow (Private)

- (NSString *)toQuery {
    if (!self.blur && !self.opacity && !self.vector && !self.color && !self.background) {
        return @"shadow";
    }

    NSMutableArray *queryArray = [[NSMutableArray alloc] init];

    if (self.blur) {
        [queryArray addObject:[NSString stringWithFormat:@"blur:%ld", [self.blur integerValue]]];
    }

    if (self.color) {
        [queryArray addObject:[NSString stringWithFormat:@"color:%@", self.color]];
    }

    if (self.opacity) {
        [queryArray addObject:[NSString stringWithFormat:@"opacity:%ld", [self.opacity integerValue]]];
    }

    if (self.vector) {
        [queryArray addObject:[NSString stringWithFormat:@"vector:[%@]", [self.vector componentsJoinedByString:@","]]];
    }

    if (self.background) {
        [queryArray addObject:[NSString stringWithFormat:@"background:%@", self.background]];
    }

    return [NSString stringWithFormat:@"%@=%@", @"shadow", [queryArray componentsJoinedByString:@","]];
}

@end
