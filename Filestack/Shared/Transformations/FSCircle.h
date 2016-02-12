//
//  FSCircle.h
//  Filestack
//
//  Created by Łukasz Cichecki on 08/02/16.
//  Copyright © 2016 Filestack. All rights reserved.
//

#import "FSTransform.h"

@interface FSCircle : FSTransform

/**
 Sets the background color to display behind the image. This can be the word for a color, or the hex color code. The default value is white.
 */
@property (nonatomic, strong) NSString *background;

- (instancetype)initWithBackground:(NSString *)background;

@end
