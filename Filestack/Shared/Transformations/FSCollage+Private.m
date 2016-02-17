//
//  FSCollage+Private.m
//  Filestack
//
//  Created by Łukasz Cichecki on 10/02/16.
//  Copyright © 2016 Filestack. All rights reserved.
//

#import "FSCollage+Private.h"

@implementation FSCollage (Private)

- (NSString *)toQuery {
    if (!self.files.firstObject || !self.width || !self.height) {
        return nil;
    }

    NSMutableArray *queryArray = [[NSMutableArray alloc] init];

    [queryArray addObject:[self filesArrayToString]];
    [queryArray addObject:[NSString stringWithFormat:@"width:%ld", (long)[self.width integerValue]]];
    [queryArray addObject:[NSString stringWithFormat:@"height:%ld", (long)[self.height integerValue]]];

    if (self.color) {
        [queryArray addObject:[NSString stringWithFormat:@"color:%@", self.color]];
    }

    if (self.margin) {
        [queryArray addObject:[NSString stringWithFormat:@"margin:%ld", (long)[self.margin integerValue]]];
    }

    return [NSString stringWithFormat:@"%@=%@", @"collage", [queryArray componentsJoinedByString:@","]];
}

- (NSString *)filesArrayToString {
    NSMutableArray *objectsString = [[NSMutableArray alloc] init];

    for (FSBlob *blob in self.files) {
        [objectsString addObject:[[NSURL URLWithString:blob.url] lastPathComponent]];
    }

    return [NSString stringWithFormat:@"files:[%@]", [objectsString componentsJoinedByString:@","]];
}

@end
