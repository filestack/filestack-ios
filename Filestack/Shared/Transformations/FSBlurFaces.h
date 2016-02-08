//
//  FSBlurFaces.h
//  Filestack
//
//  Created by Łukasz Cichecki on 08/02/16.
//  Copyright © 2016 Filestack. All rights reserved.
//

#import "FSTransform.h"

typedef NSString * FSPBlurFacesType;
#define FSPBlurFacesTypeRect @"rect"
#define FSPBlurFacesTypeOval @"oval"

@interface FSBlurFaces : FSTransform

@property (nonatomic, strong) NSNumber *minSize;
@property (nonatomic, strong) NSNumber *maxSize;
@property (nonatomic, strong) NSNumber *buffer;
@property (nonatomic, strong) NSNumber *blur;
@property (nonatomic, strong) NSNumber *amount;
@property (nonatomic, strong) FSPBlurFacesType type;
@property (nonatomic, strong) NSNumber *face;
@property (nonatomic, strong) NSArray<NSNumber *> *faces;
@property (nonatomic, assign) BOOL allFaces;

- (instancetype)initWithMinSize:(NSNumber *)minSize maxSize:(NSNumber *)maxSize type:(FSPBlurFacesType)type buffer:(NSNumber *)buffer blurAmount:(NSNumber *)blurAmount andObscureAmount:(NSNumber *)obscureAmount;
- (instancetype)initWithAllFacesAndMinSize:(NSNumber *)minSize maxSize:(NSNumber *)maxSize type:(FSPBlurFacesType)type buffer:(NSNumber *)buffer blurAmount:(NSNumber *)blurAmount andObscureAmount:(NSNumber *)obscureAmount;
- (instancetype)initWithMinSize:(NSNumber *)minSize maxSize:(NSNumber *)maxSize type:(FSPBlurFacesType)type buffer:(NSNumber *)buffer blurAmount:(NSNumber *)blurAmount obscureAmount:(NSNumber *)obscureAmount andFace:(NSNumber *)face;
- (instancetype)initWithMinSize:(NSNumber *)minSize maxSize:(NSNumber *)maxSize type:(FSPBlurFacesType)type buffer:(NSNumber *)buffer blurAmount:(NSNumber *)blurAmount obscureAmount:(NSNumber *)obscureAmount andFaces:(NSArray<NSNumber *> *)faces;

@end
