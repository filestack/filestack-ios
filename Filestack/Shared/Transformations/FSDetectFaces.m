//
//  FSDetectFaces.m
//  Filestack
//
//  Created by Łukasz Cichecki on 08/02/16.
//  Copyright © 2016 Filestack. All rights reserved.
//

#import "FSDetectFaces.h"

@implementation FSDetectFaces


- (instancetype)initWithMinSize:(NSNumber *)minSize maxSize:(NSNumber *)maxSize color:(NSString *)color exportToJSON:(BOOL)exportToJSON {
    if ((self = [super init])) {
        _minSize = minSize;
        _maxSize = maxSize;
        _color = color;
        _exportToJSON = exportToJSON;
    }
    return self;
}

- (instancetype)initWithExportToJSON {
    return [self initWithMinSize:nil maxSize:nil color:nil exportToJSON:YES];
}

- (instancetype)init {
    return [self initWithMinSize:nil maxSize:nil color:nil exportToJSON:NO];
}

@end
