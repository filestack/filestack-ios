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
    if (!self.mode && !self.buffer && !self.face && !self.allFaces && !self.faces) {
        return @"crop_faces";
    }

    NSMutableArray *queryArray = [[NSMutableArray alloc] init];

    if (self.mode) {
        [queryArray addObject:[NSString stringWithFormat:@"mode:%@", self.mode]];
    }

    if (self.buffer) {
        [queryArray addObject:[NSString stringWithFormat:@"buffer:%ld", [self.buffer integerValue]]];
    }

    if (self.face || self.faces || self.allFaces) {
        if (self.allFaces) {
            [queryArray addObject:@"faces:all"];
        } else if (self.faces) {
            [queryArray addObject:[NSString stringWithFormat:@"faces:%@", [self facesArrayToString]]];
        } else {
            [queryArray addObject:[NSString stringWithFormat:@"faces:%ld", [self.face integerValue]]];
        }
    }
    return [NSString stringWithFormat:@"%@=%@", @"crop_faces", [queryArray componentsJoinedByString:@","]];
}

- (NSString *)facesArrayToString {
    return [NSString stringWithFormat:@"[%@]", [self.faces componentsJoinedByString:@","]];
}

@end
