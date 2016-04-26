//
//  FSBlurFaces.h
//  Filestack
//
//  Created by Łukasz Cichecki on 08/02/16.
//  Copyright © 2016 Filestack. All rights reserved.
//

#import "FSTransform.h"

typedef NSString * FSPBlurFacesType;
#define FSBlurFacesTypeRect @"rect"
#define FSBlurFacesTypeOval @"oval"

@interface FSBlurFaces : FSTransform

/**
 This parameter is used to weed out objects that most likely are not faces. This can be an integer or a float in a range from 0.01 to 10000.
 */
@property (nonatomic, strong) NSNumber *minSize;
/**
 This parameter is used to weed out objects that most likely are not faces. This can be an integer or a float in a range from 0.01 to 10000.
 */
@property (nonatomic, strong) NSNumber *maxSize;
/**
 Adjusts the buffer around the face object as a percentage of the original object. Must be an integer in a range from 0 to 1000.
 */
@property (nonatomic, strong) NSNumber *buffer;
/**
 The amount to blur the obscured faces. The value for this parameter can be any float in a range from 0 to 20. The default value for this parameter is 4.0.
 */
@property (nonatomic, strong) NSNumber *blur;
/**
 The amount of blur to apply to the selected faces. The value for this parameter can be any float in a range from 0 to 20. The default value for this parameter is 4.0.
 */
@property (nonatomic, strong) NSNumber *amount;
/**
 The shape of the pixelated faces.
 */
@property (nonatomic, strong) FSPBlurFacesType type;
/**
 Specify a single face object to choose. The value must be an integer.
 */
@property (nonatomic, strong) NSNumber *face;
/**
 Specify an array of face objects to choose. The value must be an array of integers. Takes precedence over `face` property.
 */
@property (nonatomic, strong) NSArray<NSNumber *> *faces;
/**
 If `YES`, it will choose all face objects available. Takes precedence over `face` and/or `faces` properties.
 */
@property (nonatomic, assign) BOOL allFaces;

- (instancetype)initWithMinSize:(NSNumber *)minSize maxSize:(NSNumber *)maxSize type:(FSPBlurFacesType)type buffer:(NSNumber *)buffer blurAmount:(NSNumber *)blurAmount obscureAmount:(NSNumber *)obscureAmount NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithAllFacesAndMinSize:(NSNumber *)minSize maxSize:(NSNumber *)maxSize type:(FSPBlurFacesType)type buffer:(NSNumber *)buffer blurAmount:(NSNumber *)blurAmount obscureAmount:(NSNumber *)obscureAmount;
- (instancetype)initWithMinSize:(NSNumber *)minSize maxSize:(NSNumber *)maxSize type:(FSPBlurFacesType)type buffer:(NSNumber *)buffer blurAmount:(NSNumber *)blurAmount obscureAmount:(NSNumber *)obscureAmount face:(NSNumber *)face;
- (instancetype)initWithMinSize:(NSNumber *)minSize maxSize:(NSNumber *)maxSize type:(FSPBlurFacesType)type buffer:(NSNumber *)buffer blurAmount:(NSNumber *)blurAmount obscureAmount:(NSNumber *)obscureAmount faces:(NSArray<NSNumber *> *)faces;

@end
