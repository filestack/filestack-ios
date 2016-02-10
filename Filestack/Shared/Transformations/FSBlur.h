//
//  FSBlur.h
//  Filestack
//
//  Created by Łukasz Cichecki on 10/02/16.
//  Copyright © 2016 Filestack. All rights reserved.
//

#import "FSTransform.h"

@interface FSBlur : FSTransform

@property (nonatomic, strong) NSNumber *amount;

- (instancetype)initWithAmount:(NSNumber *)amount;

@end
