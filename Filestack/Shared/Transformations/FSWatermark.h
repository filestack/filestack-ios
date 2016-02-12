//
//  FSWatermark.h
//  Filestack
//
//  Created by Łukasz Cichecki on 05/02/16.
//  Copyright © 2016 Filestack. All rights reserved.
//

#import "FSTransform.h"
#import "FSBlob.h"

typedef NSString * FSWatermarkPosition;
#define FSWatermarkPositionLeft @"left"
#define FSWatermarkPositionRight @"right"
#define FSWatermarkPositionBottom @"bottom"
#define FSWatermarkPositionCenter @"center"
#define FSWatermarkPositionTop @"top"
#define FSWatermarkPositionTopLeft @"[top,left]"
#define FSWatermarkPositionBottomLeft @"[bottom,left]"
#define FSWatermarkPositionTopRight @"[top,right]"
#define FSWatermarkPositionBottomRight @"[bottom,right]"
#define FSWatermarkPositionTopCenter @"[top,center]"
#define FSWatermarkPositionBottomCenter @"[bottom,center]"

@interface FSWatermark : FSTransform

/**
 The Filestack's image blob that you want to layer on top of another image as a watermark.
 @warning `file` must not be `nil`.
 */
@property (nonatomic, nonnull, strong) FSBlob *blob;
/**
 The size of the overlayed image as a percentage of its original size. The value must be an integer between 1 and 500.
 */
@property (nonatomic, nullable, strong) NSNumber *size;
/**
 The position of the overlayed image.
 */
@property (nonatomic, nullable, strong) FSWatermarkPosition position;

- (instancetype _Nullable)initWithBlob:(FSBlob * _Nonnull)blob size:(NSNumber * _Nullable)size position:(FSWatermarkPosition _Nullable)position;

@end
