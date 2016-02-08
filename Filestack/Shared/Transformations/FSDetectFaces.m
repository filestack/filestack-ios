//
//  FSDetectFaces.m
//  Filestack
//
//  Created by Łukasz Cichecki on 08/02/16.
//  Copyright © 2016 Filestack. All rights reserved.
//

#import "FSDetectFaces.h"

@implementation FSDetectFaces


- (instancetype)initWithMinSize:(NSNumber *)minSize maxSize:(NSNumber *)maxSize color:(NSString *)color andExportToJSON:(BOOL)exportToJSON {
    if (self = [super init]) {
        self.minSize = minSize;
        self.maxSize = maxSize;
        self.color = color;
        self.exportToJSON = exportToJSON;
    }
    return self;
}

- (instancetype)initWithExportToJSON:(BOOL)exportToJSON {
    return [self initWithMinSize:nil maxSize:nil color:nil andExportToJSON:exportToJSON];
}

@end
