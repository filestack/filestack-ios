//
//  FSBorders.h
//  Filestack
//
//  Created by Łukasz Cichecki on 08/02/16.
//  Copyright © 2016 Filestack. All rights reserved.
//

#import "FSTransform.h"

@interface FSBorder : FSTransform

@property (nonatomic, strong) NSNumber *width;
@property (nonatomic, strong) NSString *color;
@property (nonatomic, strong) NSString *background;

- (instancetype)initWithWidth:(NSNumber *)width color:(NSString *)color andBackground:(NSString *)background;

@end
