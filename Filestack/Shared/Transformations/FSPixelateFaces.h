//
//  FSPixelateFaces.h
//  Filestack
//
//  Created by Łukasz Cichecki on 08/02/16.
//  Copyright © 2016 Filestack. All rights reserved.
//

#import "FSTransform.h"

typedef NSString * FSPixelateFacesType;
#define FSPixelateFacesTypeRect @"rect"
#define FSPixelateFacesTypeOval @"oval"

@interface FSPixelateFaces : FSTransform

@property (nonatomic, strong) NSNumber *minSize;
@property (nonatomic, strong) NSNumber *maxSize;
@property (nonatomic, strong) NSNumber *buffer;
@property (nonatomic, strong) NSNumber *blur;
@property (nonatomic, strong) NSNumber *amount;
@property (nonatomic, strong) FSPixelateFacesType type;
@property (nonatomic, strong) NSNumber *face;
@property (nonatomic, strong) NSArray<NSNumber *> *faces;
@property (nonatomic, assign) BOOL allFaces;

- (instancetype)initWithMinSize:(NSNumber *)minSize maxSize:(NSNumber *)maxSize type:(FSPixelateFacesType)type buffer:(NSNumber *)buffer blurAmount:(NSNumber *)blurAmount pixelateAmount:(NSNumber *)pixelateAmount;
- (instancetype)initWithAllFacesAndMinSize:(NSNumber *)minSize maxSize:(NSNumber *)maxSize type:(FSPixelateFacesType)type buffer:(NSNumber *)buffer blurAmount:(NSNumber *)blurAmount pixelateAmount:(NSNumber *)pixelateAmount;
- (instancetype)initWithMinSize:(NSNumber *)minSize maxSize:(NSNumber *)maxSize type:(FSPixelateFacesType)type buffer:(NSNumber *)buffer blurAmount:(NSNumber *)blurAmount pixelateAmount:(NSNumber *)pixelateAmount face:(NSNumber *)face;
- (instancetype)initWithMinSize:(NSNumber *)minSize maxSize:(NSNumber *)maxSize type:(FSPixelateFacesType)type buffer:(NSNumber *)buffer blurAmount:(NSNumber *)blurAmount pixelateAmount:(NSNumber *)pixelateAmount faces:(NSArray<NSNumber *> *)faces;

@end
