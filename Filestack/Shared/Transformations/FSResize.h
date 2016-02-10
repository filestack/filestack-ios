//
//  FSResize.h
//  Filestack
//
//  Created by Łukasz Cichecki on 04/02/16.
//  Copyright © 2016 Filestack. All rights reserved.
//

#import "FSTransform.h"

typedef NSString * FSResizeFit;
#define FSResizeFitClip @"clip"
#define FSResizeFitCrop @"crop"
#define FSResizeFitScale @"scale"
#define FSResizeFitMax @"max"

typedef NSString * FSResizeAlign;
#define FSResizeAlignLeft @"left"
#define FSResizeAlignRight @"right"
#define FSResizeAlignTop @"top"
#define FSResizeAlignBottom @"bottom"
#define FSResizeAlignCenter @"center"
#define FSResizeAlignFaces @"faces"
#define FSResizeAlignTopLeft @"[top,left]"
#define FSResizeAlignTopRight @"[top,right]"
#define FSResizeAlignBottomLeft @"[bottom,left]"
#define FSResizeAlignBottomRight @"[bottom,right]"

@interface FSResize : FSTransform

@property (nonatomic, strong) NSNumber *width;
@property (nonatomic, strong) NSNumber *height;
@property (nonatomic, strong) FSResizeFit fit;
@property (nonatomic, strong) FSResizeAlign align;

- (instancetype)initWithHeight:(NSNumber *)height;
- (instancetype)initWithWidth:(NSNumber *)width;
- (instancetype)initWithWidth:(NSNumber *)width height:(NSNumber *)height;
- (instancetype)initWithWidth:(NSNumber *)width height:(NSNumber *)height fit:(FSResizeFit)fit;
- (instancetype)initWithWidth:(NSNumber *)width height:(NSNumber *)height fit:(FSResizeFit)fit align:(FSResizeAlign)align;

@end
