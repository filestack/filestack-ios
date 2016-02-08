//
//  FSCircle+Private.m
//  Filestack
//
//  Created by Łukasz Cichecki on 08/02/16.
//  Copyright © 2016 Filestack. All rights reserved.
//

#import "FSCircle+Private.h"

@implementation FSCircle (Private)

- (NSString *)toQuery {
    if (!self.background) {
        return @"circle";
    }

    return [NSString stringWithFormat:@"%@=%@", @"circle", [NSString stringWithFormat:@"background:%@", self.background]];
}

@end
