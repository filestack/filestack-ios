//
//  FSTransformation.m
//  Filestack
//
//  Created by Łukasz Cichecki on 04/02/16.
//  Copyright © 2016 Filestack. All rights reserved.
//

#import "FSTransformation.h"
#import "FSTransform+Private.h"

@interface FSTransformation ()

@property (nonatomic, strong) NSMutableArray *transformationsArray;

@end

@implementation FSTransformation

- (instancetype)init {
    if (self = [super init]) {
        self.transformationsArray = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)add:(FSTransform *)transform {
    NSString *transformQuery = [transform toQuery];

    if (transformQuery) {
        [_transformationsArray addObject:transformQuery];
    }

    NSLog(@"%@", _transformationsArray);
}

@end
