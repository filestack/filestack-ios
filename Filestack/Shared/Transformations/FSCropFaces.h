//
//  FSCropFaces.h
//  Filestack
//
//  Created by Łukasz Cichecki on 08/02/16.
//  Copyright © 2016 Filestack. All rights reserved.
//

#import "FSTransform.h"

typedef NSString * FSCropFacesMode;
#define FSCropFacesModeThumb @"thumb"
#define FSCropFacesModeCrop @"crop"
#define FSCropFacesModeFill @"fill"

@interface FSCropFaces : FSTransform

/**
 Specify the buffer mode around the face object.
 */
@property (nonatomic, strong) FSCropFacesMode mode;
/**
 Specify the width of the crop in pixels. The value must be an integer from 1 to 10000.
 */
@property (nonatomic, strong) NSNumber *width;
/**
 Specify the height of the crop in pixels. The value must be an integer from 1 to 10000.
 */
@property (nonatomic, strong) NSNumber *height;
/**
 Adjusts the buffer around the face object as a percentage of the original object.
 */
@property (nonatomic, strong) NSNumber *buffer;
/**
 Specify a single face object to choose. The value must be an integer.
 */
@property (nonatomic, strong) NSNumber *face;
/**
 Specify an array of face objects to choose. The value must be an array of integers. Takes precedence over `face` property.
 */
@property (nonatomic, strong) NSArray<NSNumber *> *faces;
/**
 If `YES`, it will choose all face objects available. Takes precedence over `face` and/or `faces` properties.
 */
@property (nonatomic, assign) BOOL allFaces;

- (instancetype)initWithMode:(FSCropFacesMode)mode width:(NSNumber *)width height:(NSNumber *)height buffer:(NSNumber *)buffer NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithMode:(FSCropFacesMode)mode width:(NSNumber *)width height:(NSNumber *)height buffer:(NSNumber *)buffer face:(NSNumber *)face;
- (instancetype)initWithMode:(FSCropFacesMode)mode width:(NSNumber *)width height:(NSNumber *)height buffer:(NSNumber *)buffer faces:(NSArray<NSNumber *> *)faces;
- (instancetype)initAllFacesWithMode:(FSCropFacesMode)mode width:(NSNumber *)width height:(NSNumber *)height buffer:(NSNumber *)buffer;

@end
