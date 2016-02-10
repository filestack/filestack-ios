//
//  FSPolaroid.h
//  Filestack
//
//  Created by Łukasz Cichecki on 08/02/16.
//  Copyright © 2016 Filestack. All rights reserved.
//

#import "FSTransform.h"

@interface FSPolaroid : FSTransform

@property (nonatomic, strong) NSString *color;
@property (nonatomic, strong) NSString *background;
@property (nonatomic, strong) NSNumber *rotate;

- (instancetype)initWithColor:(NSString *)color background:(NSString *)background rotation:(NSNumber *)rotate;

@end
