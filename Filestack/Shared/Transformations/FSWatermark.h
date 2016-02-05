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

@property (nonatomic, strong) FSBlob *blob;
@property (nonatomic, strong) NSNumber *size;
@property (nonatomic, strong) FSWatermarkPosition position;

- (instancetype)initWithBlob:(FSBlob *)blob size:(NSNumber *)size andPosition:(FSWatermarkPosition)position;

@end
