//
//  FSRotate+Private.m
//  Filestack
//
//  Created by Łukasz Cichecki on 04/02/16.
//  Copyright © 2016 Filestack. All rights reserved.
//

#import "FSRotate+Private.h"

@implementation FSRotate (Private)

- (NSString *)toQuery {
    NSMutableArray *queryArray = [[NSMutableArray alloc] init];

    if (self.toEXIF) {
        [queryArray addObject:@"deg:exif"];
    } else if (self.degrees) {
        [queryArray addObject:[NSString stringWithFormat:@"deg:%ld", [self.degrees integerValue]]];
    }

    if (self.resetEXIF) {
        [queryArray addObject:@"exif:false"];
    }

    if (self.background) {
        [queryArray addObject:[NSString stringWithFormat:@"background:%@", self.background]];
    }

    return [NSString stringWithFormat:@"%@=%@", @"rotate", [queryArray componentsJoinedByString:@","]];
}

@end
