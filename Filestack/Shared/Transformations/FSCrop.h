//
//  FSCrop.h
//  Filestack
//
//  Created by Łukasz Cichecki on 04/02/16.
//  Copyright © 2016 Filestack. All rights reserved.
//

#import "FSTransform.h"

@interface FSCrop : FSTransform

/**
 The x coordinate. The value must be an integer from 1 to 10000.
 @warning `x` must not be `nil`.
 */
@property (nonatomic, strong, nonnull) NSNumber *x;
/**
 The y coordinate. The value must be an integer from 1 to 10000.
 @warning `y` must not be `nil`.
 */
@property (nonatomic, strong, nonnull) NSNumber *y;
/**
 The width in pixels to crop the image to. The value must be an integer from 1 to 10000.
 @warning `width` must not be `nil`.
 */
@property (nonatomic, strong, nonnull) NSNumber *width;
/**
 The height in pixels to crop the image to. The value must be an integer from 1 to 10000.
 @warning `height` must not be `nil`.
 */
@property (nonatomic, strong, nonnull) NSNumber *height;

- (instancetype _Nullable)initWithX:(NSNumber * _Nonnull)x y:(NSNumber * _Nonnull)y width:(NSNumber * _Nonnull)width height:(NSNumber * _Nonnull)height;

@end
