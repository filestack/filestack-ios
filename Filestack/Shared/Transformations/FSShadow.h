//
//  FSShadow.h
//  Filestack
//
//  Created by Łukasz Cichecki on 08/02/16.
//  Copyright © 2016 Filestack. All rights reserved.
//

#import "FSTransform.h"

@interface FSShadow : FSTransform

/**
 Sets the level of blur for the shadow effect. The value must be an integer in a range from 0 to 20. Defaults to 4.
 */
@property (nonatomic, strong) NSNumber *blur;
/**
 Sets the opacity level of the shadow effect. The values must be an integer in a range from 0 to 100. Defaults to 60.
 */
@property (nonatomic, strong) NSNumber *opacity;
/**
 Sets the vector of the shadow effect. The values must be an array of two integers in a range from -1000 to 1000.
    These are the X and Y parameters that determine the position of the shadow. Defaults to [4,4].
 */
@property (nonatomic, strong) NSArray<NSNumber *> *vector;
/**
 Sets the shadow color. This can be the word for a color, or the hex color code. The default value is black.
 */
@property (nonatomic, strong) NSString *color;
/**
 Sets the background color to display behind the image, like a matte the shadow is cast on. This can be the word for a color, or the hex color code. The default value is white.
 */
@property (nonatomic, strong) NSString *background;

- (instancetype)initWithBlur:(NSNumber *)blur opacity:(NSNumber *)opacity vector:(NSArray<NSNumber *> *)vector color:(NSString *)color background:(NSString *)background;

@end
