//
//  FSBorders.h
//  Filestack
//
//  Created by Łukasz Cichecki on 08/02/16.
//  Copyright © 2016 Filestack. All rights reserved.
//

#import "FSTransform.h"

@interface FSBorder : FSTransform

/**
 Sets the width in pixels of the border to render around the image. The value for this parameter must be an integer in a range from 1 to 1000. The default value is 2.
 */
@property (nonatomic, strong) NSNumber *width;
/**
 Sets the color of the border to render around the image. This can be the word for a color, or the hex color code. The default value is black.
 */
@property (nonatomic, copy) NSString *color;
/**
 Sets the background color to display behind the image. This can be the word for a color, or the hex color code. The default value is white.
 */
@property (nonatomic, copy) NSString *background;

- (instancetype)initWithWidth:(NSNumber *)width color:(NSString *)color background:(NSString *)background NS_DESIGNATED_INITIALIZER;

@end
