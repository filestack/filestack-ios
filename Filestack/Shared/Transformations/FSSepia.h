//
//  FSSepia.h
//  Filestack
//
//  Created by Łukasz Cichecki on 10/02/16.
//  Copyright © 2016 Filestack. All rights reserved.
//

#import "FSTransform.h"

@interface FSSepia : FSTransform

/**
 The tone of the sepia. The value for this parameter can be any integer in a range from 0 to 100. The default value for this parameter is 80. 
 */
@property (nonatomic, strong) NSNumber *tone;

- (instancetype)initWithTone:(NSNumber *)tone NS_DESIGNATED_INITIALIZER;

@end
