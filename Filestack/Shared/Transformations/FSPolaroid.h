//
//  FSPolaroid.h
//  Filestack
//
//  Created by Łukasz Cichecki on 08/02/16.
//  Copyright © 2016 Filestack. All rights reserved.
//

#import "FSTransform.h"

@interface FSPolaroid : FSTransform

/**
 Sets the polaroid frame color. This can be the word for a color, or the hex color code.
 */
@property (nonatomic, copy) NSString *color;
/**
 Sets the background color to display behind the polaroid if it has been rotated at all. This can be the word for a color, or the hex color code.
 */
@property (nonatomic, copy) NSString *background;
/**
 The degree by which to rotate the image clockwise. This can be an integer in a range from 0 to 359.
 */
@property (nonatomic, strong) NSNumber *rotate;

- (instancetype)initWithColor:(NSString *)color background:(NSString *)background rotation:(NSNumber *)rotate;

@end
