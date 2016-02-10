//
//  FSTornEdges.m
//  Filestack
//
//  Created by Łukasz Cichecki on 08/02/16.
//  Copyright © 2016 Filestack. All rights reserved.
//

#import "FSTornEdges.h"

@implementation FSTornEdges

- (instancetype)initWithSpread:(NSArray<NSNumber *> *)spread background:(NSString *)background {
    if (self = [super init]) {
        self.spread = spread;
        self.background = background;
    }
    return self;
}

@end
