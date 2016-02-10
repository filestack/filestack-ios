//
//  FSCollage.h
//  Filestack
//
//  Created by Łukasz Cichecki on 10/02/16.
//  Copyright © 2016 Filestack. All rights reserved.
//

#import "FSTransform.h"
#import "FSBlob.h"

@interface FSCollage : FSTransform

@property (nonatomic, nullable, strong) NSString *color;
@property (nonatomic, nullable, strong) NSNumber *margin;
@property (nonatomic, nonnull, strong) NSArray<FSBlob *> *files;
@property (nonatomic, nonnull, strong) NSNumber *width;
@property (nonatomic, nonnull, strong) NSNumber *height;

- (instancetype _Nullable)initWithFiles:(NSArray<FSBlob *> * _Nonnull)files width:(NSNumber * _Nonnull)width height:(NSNumber * _Nonnull)height;
- (instancetype _Nullable)initWithFiles:(NSArray<FSBlob *> * _Nonnull)files width:(NSNumber * _Nonnull)width height:(NSNumber * _Nonnull)height margin:(NSNumber * _Nullable)margin color:(NSString * _Nullable)color;

@end
