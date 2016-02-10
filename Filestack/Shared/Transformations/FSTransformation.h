//
//  FSTransformation.h
//  Filestack
//
//  Created by Łukasz Cichecki on 04/02/16.
//  Copyright © 2016 Filestack. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FSTransform.h"
#import "FSResize.h"
#import "FSCrop.h"
#import "FSRotate.h"
#import "FSFlip.h"
#import "FSFlop.h"
#import "FSWatermark.h"
#import "FSCropFaces.h"
#import "FSDetectFaces.h"
#import "FSPixelateFaces.h"
#import "FSBlurFaces.h"
#import "FSRoundedCorners.h"
#import "FSPolaroid.h"
#import "FSTornEdges.h"
#import "FSShadow.h"
#import "FSCircle.h"
#import "FSBorder.h"
#import "FSSharpen.h"
#import "FSBlur.h"
#import "FSMonochrome.h"

@interface FSTransformation : NSObject

- (instancetype)initWithQueryString:(NSString *)queryString;
- (void)add:(FSTransform *)transform;
- (NSString *)transformationURLWithApiKey:(NSString *)apiKey andURLToTransform:(NSString *)urlToTransform;

@end