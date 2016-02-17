//
//  FSCrop+Private.m
//  Filestack
//
//  Created by Łukasz Cichecki on 04/02/16.
//  Copyright © 2016 Filestack. All rights reserved.
//

#import "FSCrop+Private.h"

@implementation FSCrop (Private)

- (NSString *)toQuery {
    if (!self.x || !self.y || !self.width || !self.height) {
        return nil;
    }

    return [NSString stringWithFormat:@"crop=dim:[%ld,%ld,%ld,%ld]", (long)[self.x integerValue], (long)[self.y integerValue], (long)[self.width integerValue], (long)[self.height integerValue]];
}

@end
