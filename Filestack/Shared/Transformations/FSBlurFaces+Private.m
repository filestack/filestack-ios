//
//  FSBlurFaces+Private.m
//  Filestack
//
//  Created by Łukasz Cichecki on 08/02/16.
//  Copyright © 2016 Filestack. All rights reserved.
//

#import "FSBlurFaces+Private.h"

@implementation FSBlurFaces (Private)

- (NSString *)toQuery {
    if (!self.minSize && !self.maxSize && !self.blur && !self.amount && !self.buffer && !self.face && !self.allFaces && !self.faces && !self.type) {
        return @"blur_faces";
    }

    NSMutableArray *queryArray = [[NSMutableArray alloc] init];

    if (self.minSize) {
        [queryArray addObject:[NSString stringWithFormat:@"minsize:%.02f", (self.minSize).doubleValue]];
    }

    if (self.maxSize) {
        [queryArray addObject:[NSString stringWithFormat:@"maxsize:%.02f", (self.maxSize).doubleValue]];
    }

    if (self.buffer) {
        [queryArray addObject:[NSString stringWithFormat:@"buffer:%ld", (long)(self.buffer).integerValue]];
    }

    if (self.amount) {
        [queryArray addObject:[NSString stringWithFormat:@"amount:%f", (self.amount).doubleValue]];
    }

    if (self.blur) {
        [queryArray addObject:[NSString stringWithFormat:@"blur:%f", (self.blur).doubleValue]];
    }

    if (self.type) {
        [queryArray addObject:[NSString stringWithFormat:@"type:%@", self.type]];
    }

    if (self.face || self.faces || self.allFaces) {
        if (self.allFaces) {
            [queryArray addObject:@"faces:all"];
        } else if (self.faces) {
            [queryArray addObject:[NSString stringWithFormat:@"faces:%@", [self facesArrayToString]]];
        } else {
            [queryArray addObject:[NSString stringWithFormat:@"faces:%ld", (long)(self.face).integerValue]];
        }
    }
    return [NSString stringWithFormat:@"%@=%@", @"blur_faces", [queryArray componentsJoinedByString:@","]];
}

- (NSString *)facesArrayToString {
    NSMutableArray *facesIntegerArray = [[NSMutableArray alloc] init];

    for (NSNumber *faceNumber in self.faces) {
        [facesIntegerArray addObject:@(faceNumber.integerValue)];
    }

    return [NSString stringWithFormat:@"[%@]", [facesIntegerArray componentsJoinedByString:@","]];
}

@end
