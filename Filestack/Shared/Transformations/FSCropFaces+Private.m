//
//  FSCropFaces+Private.m
//  Filestack
//
//  Created by Łukasz Cichecki on 08/02/16.
//  Copyright © 2016 Filestack. All rights reserved.
//

#import "FSCropFaces+Private.h"

@implementation FSCropFaces (Private)

- (NSString *)toQuery {
    if (!self.mode && !self.buffer && !self.face && !self.allFaces && !self.faces && !self.width && !self.height) {
        return @"crop_faces";
    }

    NSMutableArray *queryArray = [[NSMutableArray alloc] init];

    if (self.width) {
        [queryArray addObject:[NSString stringWithFormat:@"width:%ld", (long)[self.width integerValue]]];
    }

    if (self.height) {
        [queryArray addObject:[NSString stringWithFormat:@"height:%ld", (long)[self.height integerValue]]];
    }

    if (self.buffer) {
        [queryArray addObject:[NSString stringWithFormat:@"buffer:%ld", (long)[self.buffer integerValue]]];
    }

    if (self.mode) {
        [queryArray addObject:[NSString stringWithFormat:@"mode:%@", self.mode]];
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
    return [NSString stringWithFormat:@"%@=%@", @"crop_faces", [queryArray componentsJoinedByString:@","]];
}

- (NSString *)facesArrayToString {
    NSMutableArray *facesIntegerArray = [[NSMutableArray alloc] init];

    for (NSNumber *faceNumber in self.faces) {
        [facesIntegerArray addObject:[NSNumber numberWithInteger:[faceNumber integerValue]]];
    }

    return [NSString stringWithFormat:@"[%@]", [facesIntegerArray componentsJoinedByString:@","]];
}

@end
