//
//  FSOutput+Private.m
//  Filestack
//
//  Created by Łukasz Cichecki on 10/02/16.
//  Copyright © 2016 Filestack. All rights reserved.
//

#import "FSOutput+Private.h"

@implementation FSOutput (Private)

- (NSString *)toQuery {

    NSMutableArray *queryArray = [[NSMutableArray alloc] init];

    if (self.format) {
        [queryArray addObject:[NSString stringWithFormat:@"format:%@", self.format]];
    }

    if (self.page) {
        [queryArray addObject:[NSString stringWithFormat:@"page:%ld", [self.page integerValue]]];
    }

    if (self.density) {
        [queryArray addObject:[NSString stringWithFormat:@"blur:%ld", [self.density integerValue]]];
    }

    if (self.compress) {
        [queryArray addObject:@"compress:true"];
    }

    if (self.quality) {
        [queryArray addObject:[NSString stringWithFormat:@"quality:%ld", [self.quality integerValue]]];
    }

    if (self.secure) {
        [queryArray addObject:@"secure:true"];
    }

    if (self.docInfo) {
        [queryArray addObject:@"docinfo:true"];
    }

    return [NSString stringWithFormat:@"%@=%@", @"output", [queryArray componentsJoinedByString:@","]];
}

@end
