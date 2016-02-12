//
//  FSPixelateFaces+Private.m
//  Filestack
//
//  Created by Łukasz Cichecki on 08/02/16.
//  Copyright © 2016 Filestack. All rights reserved.
//

#import "FSPixelateFaces+Private.h"

@implementation FSPixelateFaces (Private)

- (NSString *)toQuery {
    if (!self.minSize && !self.maxSize && !self.blur && !self.amount && !self.buffer && !self.face && !self.allFaces && !self.faces && !self.type) {
        return @"pixelate_faces";
    }

    NSMutableArray *queryArray = [[NSMutableArray alloc] init];

    if (self.minSize) {
        [queryArray addObject:[NSString stringWithFormat:@"minsize:%f", [self.minSize floatValue]]];
    }

    if (self.maxSize) {
        [queryArray addObject:[NSString stringWithFormat:@"maxsize:%f", [self.maxSize floatValue]]];
    }

    if (self.buffer) {
        [queryArray addObject:[NSString stringWithFormat:@"buffer:%ld", (long)[self.buffer integerValue]]];
    }

    if (self.amount) {
        [queryArray addObject:[NSString stringWithFormat:@"amount:%ld", (long)[self.amount integerValue]]];
    }

    if (self.blur) {
        [queryArray addObject:[NSString stringWithFormat:@"amount:%f", [self.blur floatValue]]];
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
            [queryArray addObject:[NSString stringWithFormat:@"faces:%ld", (long)[self.face integerValue]]];
        }
    }
    return [NSString stringWithFormat:@"%@=%@", @"pixelate_faces", [queryArray componentsJoinedByString:@","]];
}

- (NSString *)facesArrayToString {
    return [NSString stringWithFormat:@"[%@]", [self.faces componentsJoinedByString:@","]];
}

@end
