//
//  FSRoundedCorners.h
//  Filestack
//
//  Created by Łukasz Cichecki on 08/02/16.
//  Copyright © 2016 Filestack. All rights reserved.
//

#import "FSTransform.h"

@interface FSRoundedCorners : FSTransform

/**
 The radius of the rounded corner effect on your image. The value for this parameter can be any integer in a range from 1 to 10000.
 */
@property (nonatomic, strong) NSNumber *radius;
/**
 Specify the amount of blur to apply to the rounded edges of the image. This parameter will accept any float in a range from 0 to 20.
 */
@property (nonatomic, strong) NSNumber *blur;
/**
 Sets the background color to display where the rounded corners have removed part of the image. This can be the word for a color, or the hex color code.
 */
@property (nonatomic, strong) NSString *background;
/**
 If `YES`, will set rounded corner radius to max value possible.
 */
@property (nonatomic, assign) BOOL maxRadius;

- (instancetype)initWithRadius:(NSNumber *)radius blur:(NSNumber *)blur background:(NSString *)background NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithMaxRadiusAndBlur:(NSNumber *)blur background:(NSString *)background;

@end
