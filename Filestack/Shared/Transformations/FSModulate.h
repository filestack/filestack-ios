//
//  FSModulate.h
//  Filestack
//
//  Created by Łukasz Cichecki on 10/02/16.
//  Copyright © 2016 Filestack. All rights reserved.
//

#import "FSTransform.h"

@interface FSModulate : FSTransform

/**
 The degree to set the hue to. The value for this parameter can be any integer in a range from 0 to 359, where 0 is the equivalent of red and 180 is the equivalent of cyan. The default value for this parameter is 0.
 */
@property (nonatomic, strong) NSNumber *hue;
/**
 The amount to change the brightness of an image. The value for this parameter can be any integer in a range from 0 to 10000. The default value for this parameter is 100.
 */
@property (nonatomic, strong) NSNumber *brightness;
/**
 The amount to change the saturation of the image. The value for this parameter can be any integer in a range from 0 to 10000. The default value for this parameter is 100.
 */
@property (nonatomic, strong) NSNumber *saturation;

- (instancetype)initWithBrightness:(NSNumber *)brightness hue:(NSNumber *)hue saturation:(NSNumber *)saturation;

@end
