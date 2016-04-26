//
//  FSDetectFaces+Private.m
//  Filestack
//
//  Created by Łukasz Cichecki on 08/02/16.
//  Copyright © 2016 Filestack. All rights reserved.
//

#import "FSDetectFaces+Private.h"

@implementation FSDetectFaces (Private)

- (NSString *)toQuery {
    if (!self.minSize && !self.maxSize && !self.color && !self.exportToJSON) {
        return @"detect_faces";
    }

    NSMutableArray *queryArray = [[NSMutableArray alloc] init];

    if (self.minSize) {
        [queryArray addObject:[NSString stringWithFormat:@"minsize:%.02f", (self.minSize).floatValue]];
    }

    if (self.maxSize) {
        [queryArray addObject:[NSString stringWithFormat:@"maxsize:%.02f", (self.maxSize).floatValue]];
    }

    if (self.color) {
        [queryArray addObject:[NSString stringWithFormat:@"color:%@", self.color]];
    }

    if (self.exportToJSON) {
        [queryArray addObject:@"export:true"];
    }

    return [NSString stringWithFormat:@"%@=%@", @"detect_faces", [queryArray componentsJoinedByString:@","]];
}

@end
