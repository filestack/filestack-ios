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

@property (nonatomic, strong) FSCropFacesMode mode;
@property (nonatomic, strong) NSNumber *width;
@property (nonatomic, strong) NSNumber *height;
@property (nonatomic, strong) NSNumber *buffer;
@property (nonatomic, strong) NSNumber *face;
@property (nonatomic, strong) NSArray<NSNumber *> *faces;
@property (nonatomic, assign) BOOL allFaces;

- (instancetype)initWithMode:(FSCropFacesMode)mode width:(NSNumber *)width height:(NSNumber *)height andBuffer:(NSNumber *)buffer;
- (instancetype)initWithMode:(FSCropFacesMode)mode width:(NSNumber *)width height:(NSNumber *)height buffer:(NSNumber *)buffer andFace:(NSNumber *)face;
- (instancetype)initWithMode:(FSCropFacesMode)mode width:(NSNumber *)width height:(NSNumber *)height buffer:(NSNumber *)buffer andFaces:(NSArray<NSNumber *> *)faces;
- (instancetype)initAllFacesWithMode:(FSCropFacesMode)mode width:(NSNumber *)width height:(NSNumber *)height andBuffer:(NSNumber *)buffer;

@end
