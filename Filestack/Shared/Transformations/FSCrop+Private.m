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
    return [NSString stringWithFormat:@"crop=dim:[%ld,%ld,%ld,%ld]", [self.x integerValue], [self.y integerValue], [self.width integerValue], [self.height integerValue]];
}

@end
