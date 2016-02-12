//
//  FSBlur.h
//  Filestack
//
//  Created by Łukasz Cichecki on 10/02/16.
//  Copyright © 2016 Filestack. All rights reserved.
//

#import "FSTransform.h"

@interface FSBlur : FSTransform

/**
 The amount to blur the image. The value for this parameter can be any integer in a range from 1 to 20. The default value for this parameter is 2.
 */
@property (nonatomic, strong) NSNumber *amount;

- (instancetype)initWithAmount:(NSNumber *)amount;

@end
