//
//  FSPartialBlur.h
//  Filestack
//
//  Created by Łukasz Cichecki on 10/02/16.
//  Copyright © 2016 Filestack. All rights reserved.
//

#import "FSTransform.h"

typedef NSString * FSPPartialBlurType;
#define FSPPartialBlurTypeeRect @"rect"
#define FSPPartialBlurTypeOval @"oval"

@interface FSPartialBlur : FSTransform

@property (nonatomic, strong, nullable) NSNumber *buffer;
@property (nonatomic, strong, nullable) NSNumber *amount;
@property (nonatomic, strong, nullable) NSNumber *blur;
@property (nonatomic, strong, nullable) FSPPartialBlurType type;
@property (nonatomic, strong, nonnull) NSArray<NSArray<NSNumber *> *> *objects;

- (instancetype _Nullable)initWithObjects:(NSArray<NSArray<NSNumber *> *> * _Nonnull)objects;
- (instancetype _Nullable)initWithObjects:(NSArray<NSArray<NSNumber *> *> * _Nonnull)objects buffer:(NSNumber * _Nullable)buffer amount:(NSNumber * _Nullable)amount blur:(NSNumber * _Nullable)blur type:(FSPPartialBlurType _Nullable)type;

@end
