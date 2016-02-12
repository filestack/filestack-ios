//
//  FSModulate+Private.m
//  Filestack
//
//  Created by Łukasz Cichecki on 10/02/16.
//  Copyright © 2016 Filestack. All rights reserved.
//

#import "FSModulate+Private.h"

@implementation FSModulate (Private)

- (NSString *)toQuery {
    if (!self.hue && !self.saturation && !self.brightness) {
        return @"modulate";
    }

    NSMutableArray *queryArray = [[NSMutableArray alloc] init];

    if (self.hue) {
        [queryArray addObject:[NSString stringWithFormat:@"hue:%ld", (long)[self.hue integerValue]]];
    }

    if (self.brightness) {
        [queryArray addObject:[NSString stringWithFormat:@"brightness:%ld", (long)[self.brightness integerValue]]];
    }

    if (self.saturation) {
        [queryArray addObject:[NSString stringWithFormat:@"saturation:%ld", (long)[self.saturation integerValue]]];
    }

    return [NSString stringWithFormat:@"%@=%@", @"modulate", [queryArray componentsJoinedByString:@","]];
    
}

@end
