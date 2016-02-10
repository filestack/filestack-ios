//
//  FSSepia.h
//  Filestack
//
//  Created by Łukasz Cichecki on 10/02/16.
//  Copyright © 2016 Filestack. All rights reserved.
//

#import "FSTransform.h"

@interface FSSepia : FSTransform

@property (nonatomic, strong) NSNumber *tone;

- (instancetype)initWithTone:(NSNumber *)tone;

@end
