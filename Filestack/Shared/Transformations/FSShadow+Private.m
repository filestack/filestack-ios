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
        [queryArray addObject:[NSString stringWithFormat:@"blur:%ld", (long)(self.blur).integerValue]];
    }

    if (self.color) {
        [queryArray addObject:[NSString stringWithFormat:@"color:%@", self.color]];
    }

    if (self.opacity) {
        [queryArray addObject:[NSString stringWithFormat:@"opacity:%ld", (long)(self.opacity).integerValue]];
    }

    if (self.vector) {
        [queryArray addObject:[NSString stringWithFormat:@"vector:%@", [self vectorArrayToString]]];
    }

    if (self.background) {
        [queryArray addObject:[NSString stringWithFormat:@"background:%@", self.background]];
    }

    return [NSString stringWithFormat:@"%@=%@", @"shadow", [queryArray componentsJoinedByString:@","]];
}

- (NSString *)vectorArrayToString {
    NSMutableArray *vectorIntegerArray = [[NSMutableArray alloc] init];

    for (NSNumber *vectorComponent in self.vector) {
        [vectorIntegerArray addObject:@(vectorComponent.integerValue)];
    }

    return [NSString stringWithFormat:@"[%@]", [vectorIntegerArray componentsJoinedByString:@","]];
}

@end
