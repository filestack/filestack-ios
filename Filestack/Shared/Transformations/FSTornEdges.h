//
//  FSTornEdges.h
//  Filestack
//
//  Created by Łukasz Cichecki on 08/02/16.
//  Copyright © 2016 Filestack. All rights reserved.
//

#import "FSTransform.h"

@interface FSTornEdges : FSTransform

/**
 Sets the spread of the tearing effect. The values must be an array of two integers in a range from 1 to 50.
 */
@property (nonatomic, copy) NSArray<NSNumber *> *spread;
/**
 Sets the background color to display behind the torn edge effect. This can be the word for a color, or the hex color code.
 */
@property (nonatomic, copy) NSString *background;

- (instancetype)initWithSpread:(NSArray<NSNumber *> *)spread background:(NSString *)background NS_DESIGNATED_INITIALIZER;

@end
