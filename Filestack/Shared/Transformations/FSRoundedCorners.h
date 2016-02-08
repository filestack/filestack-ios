//
//  FSRoundedCorners.h
//  Filestack
//
//  Created by Łukasz Cichecki on 08/02/16.
//  Copyright © 2016 Filestack. All rights reserved.
//

#import "FSTransform.h"

@interface FSRoundedCorners : FSTransform

@property (nonatomic, strong) NSNumber *radius;
@property (nonatomic, strong) NSNumber *blur;
@property (nonatomic, strong) NSString *background;
@property (nonatomic, assign) BOOL maxRadius;

- (instancetype)initWithRadius:(NSNumber *)radius blur:(NSNumber *)blur andBackground:(NSString *)background;
- (instancetype)initWithMaxRadiusAndBlur:(NSNumber *)blur andBackground:(NSString *)background;

@end
