//
//  FSModulate.h
//  Filestack
//
//  Created by Łukasz Cichecki on 10/02/16.
//  Copyright © 2016 Filestack. All rights reserved.
//

#import "FSTransform.h"

@interface FSModulate : FSTransform

@property (nonatomic, strong) NSNumber *hue;
@property (nonatomic, strong) NSNumber *brightness;
@property (nonatomic, strong) NSNumber *saturation;

- (instancetype)initWithBrightness:(NSNumber *)brightness hue:(NSNumber *)hue saturation:(NSNumber *)saturation;

@end
