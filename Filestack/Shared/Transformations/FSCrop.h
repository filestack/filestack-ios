//
//  FSCrop.h
//  Filestack
//
//  Created by Łukasz Cichecki on 04/02/16.
//  Copyright © 2016 Filestack. All rights reserved.
//

#import "FSTransform.h"

@interface FSCrop : FSTransform

@property (nonatomic, strong, nonnull) NSNumber *x;
@property (nonatomic, strong, nonnull) NSNumber *y;
@property (nonatomic, strong, nonnull) NSNumber *width;
@property (nonatomic, strong, nonnull) NSNumber *height;

- (instancetype _Nullable)initWithX:(NSNumber * _Nonnull)x y:(NSNumber * _Nonnull)y width:(NSNumber * _Nonnull)width andHeight:(NSNumber * _Nonnull)height;

@end
