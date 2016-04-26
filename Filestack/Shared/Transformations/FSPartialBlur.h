//
//  FSPartialBlur.h
//  Filestack
//
//  Created by Łukasz Cichecki on 10/02/16.
//  Copyright © 2016 Filestack. All rights reserved.
//

#import "FSTransform.h"

typedef NSString * FSPPartialBlurType;
#define FSPPartialBlurTypeRect @"rect"
#define FSPPartialBlurTypeOval @"oval"

@interface FSPartialBlur : FSTransform

/**
 The space to extend the blur effect around the selected area. The value for this parameter can be any integer in a range from 0 to 1000.
 */
@property (nonatomic, strong, nullable) NSNumber *buffer;
/**
 The amount to blur the image. The value for this parameter can be any float in a range from 0 to 20 . The default value for this parameter is 4.0.
 */
@property (nonatomic, strong, nullable) NSNumber *amount;
/**
 The amount to blur the image. The value for this parameter can be any float in a range from 0 to 20. The default value for this parameter is 4.0.
 */
@property (nonatomic, strong, nullable) NSNumber *blur;
/**
 The shape of the pixelated area. The default value for this parameter is FSPPartialBlurTypeRect.
 */
@property (nonatomic, strong, nullable) FSPPartialBlurType type;
/**
 The area(s) of the image to blur. This variable is an array of arrays. Each array input for this parameter defines a different section of the image and must have exactly 4 integers: "x coordinate, y coordinate, width, height"
 @warning `objects` must not be `nil` and must contain at least one element (array of exactly 4 integer: [x, y, width, height]).
 */
@property (nonatomic, strong, nonnull) NSArray<NSArray<NSNumber *> *> *objects;

- (instancetype _Nullable)initWithObjects:(NSArray<NSArray<NSNumber *> *> * _Nonnull)objects;
- (instancetype _Nullable)initWithObjects:(NSArray<NSArray<NSNumber *> *> * _Nonnull)objects buffer:(NSNumber * _Nullable)buffer amount:(NSNumber * _Nullable)amount blur:(NSNumber * _Nullable)blur type:(FSPPartialBlurType _Nullable)type NS_DESIGNATED_INITIALIZER;

@end
