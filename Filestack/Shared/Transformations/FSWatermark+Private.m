//
//  FSWatermark+Private.m
//  Filestack
//
//  Created by Łukasz Cichecki on 05/02/16.
//  Copyright © 2016 Filestack. All rights reserved.
//

#import "FSWatermark+Private.h"

@implementation FSWatermark (Private)

- (NSString *)toQuery {
    if (!self.blob.url) {
        return nil;
    }

    NSMutableArray *queryArray = [[NSMutableArray alloc] init];
    NSString *fileHandle = [NSURL URLWithString:self.blob.url].lastPathComponent;
    [queryArray addObject:[NSString stringWithFormat:@"file:%@", fileHandle]];

    if (self.size) {
        [queryArray addObject:[NSString stringWithFormat:@"size:%ld", (long)(self.size).integerValue]];
    }

    if (self.position) {
        [queryArray addObject:[NSString stringWithFormat:@"position:%@", self.position]];
    }

    return [NSString stringWithFormat:@"%@=%@", @"watermark", [queryArray componentsJoinedByString:@","]];
}

@end
