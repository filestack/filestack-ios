//
//  FSDetectFaces.h
//  Filestack
//
//  Created by Łukasz Cichecki on 08/02/16.
//  Copyright © 2016 Filestack. All rights reserved.
//

#import "FSTransform.h"

@interface FSDetectFaces : FSTransform

@property (nonatomic, strong) NSNumber *minSize;
@property (nonatomic, strong) NSNumber *maxSize;
@property (nonatomic, strong) NSString *color;
@property (nonatomic, assign) BOOL exportToJSON;

- (instancetype)initWithMinSize:(NSNumber *)minSize maxSize:(NSNumber *)maxSize color:(NSString *)color exportToJSON:(BOOL)exportToJSON;
- (instancetype)initWithExportToJSON:(BOOL)exportToJSON;

@end
