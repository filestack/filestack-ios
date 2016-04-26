//
//  FSRotate.h
//  Filestack
//
//  Created by Łukasz Cichecki on 04/02/16.
//  Copyright © 2016 Filestack. All rights reserved.
//

#import "FSTransform.h"

@interface FSRotate : FSTransform

/**
 The degree by which to rotate the image clockwise. The value must be an integer from 0 to 359.
 */
@property (nonatomic, strong) NSNumber *degrees;
/**
 Sets the background color to display if the image is rotated less than a fill 90 degrees. This can be the word for a color, or the hex color code.
 */
@property (nonatomic, strong) NSString *background;
/**
 If `YES`, the image will be rotated based upon any exif metadata it may contain.
 */
@property (nonatomic, assign) BOOL toEXIF;
/**
 If `YES`, sets the EXIF orientation of the image to EXIF orientation 1.
 */
@property (nonatomic, assign) BOOL resetEXIF;

- (instancetype)initWithDegrees:(NSNumber *)degrees background:(NSString *)background rotateToEXIF:(BOOL)toEXIF resetEXIF:(BOOL)resetEXIF NS_DESIGNATED_INITIALIZER;

@end
