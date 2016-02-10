//
//  FSShadow.h
//  Filestack
//
//  Created by Łukasz Cichecki on 08/02/16.
//  Copyright © 2016 Filestack. All rights reserved.
//

#import "FSTransform.h"

@interface FSShadow : FSTransform

@property (nonatomic, strong) NSNumber *blur;
@property (nonatomic, strong) NSNumber *opacity;
@property (nonatomic, strong) NSArray<NSNumber *> *vector;
@property (nonatomic, strong) NSString *color;
@property (nonatomic, strong) NSString *background;

- (instancetype)initWithBlur:(NSNumber *)blur opacity:(NSNumber *)opacity vector:(NSArray<NSNumber *> *)vector color:(NSString *)color background:(NSString *)background;

@end
