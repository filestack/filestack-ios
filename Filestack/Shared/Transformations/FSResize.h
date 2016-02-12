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

/**
 The width in pixels to resize the image to. The value must be an integer from 1 to 10000.
 @warning `width` must not be `nil` if `height` is `nil`.
 */
@property (nonatomic, strong) NSNumber *width;
/**
 The height in pixels to resize the image to. The value must be an integer from 1 to 10000.
 @warning `height` must not be `nil` if `height` is `nil`.
 */
@property (nonatomic, strong) NSNumber *height;
/**
 The way to resize the image to fit the specified parameters. The default value for the fit parameter is FSResizeFitClip.
 */
@property (nonatomic, strong) FSResizeFit fit;
/**
 The area of the image to focus on. The default value for the align parameter is FSResizeAlignCenter.
 */
@property (nonatomic, strong) FSResizeAlign align;

- (instancetype)initWithHeight:(NSNumber *)height;
- (instancetype)initWithWidth:(NSNumber *)width;
- (instancetype)initWithWidth:(NSNumber *)width height:(NSNumber *)height;
- (instancetype)initWithWidth:(NSNumber *)width height:(NSNumber *)height fit:(FSResizeFit)fit;
- (instancetype)initWithWidth:(NSNumber *)width height:(NSNumber *)height fit:(FSResizeFit)fit align:(FSResizeAlign)align;

@end
