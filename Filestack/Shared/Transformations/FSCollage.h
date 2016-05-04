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

/**
 Sets the border color for the collage. This can be the word for a color, or the hex color code. The default color is white.
 */
@property (nonatomic, nullable, copy) NSString *color;
/**
 Sets the size of the border between and around the images. This must be an integer in a range from 1 to 100. The default value is 10.
 */
@property (nonatomic, nullable, strong) NSNumber *margin;
/**
 An array of Filestack's image blobs. These are the images that will comprise the other images in the collage. The order in which they appear in the array dictates how the images will be arranged.
 @warning `files` must not be `nil`.
 */
@property (nonatomic, nonnull, copy) NSArray<FSBlob *> *files;
/**
 Sets the general width of the collage as a whole. This must be an integer in a range from 1 to 10000.
 @warning `width` must not be `nil`.
 */
@property (nonatomic, nonnull, strong) NSNumber *width;
/**
 Sets the general height of the collage as a whole. This must be an integer in a range from 1 to 10000.
 @warning `height` must not be `nil`.
 */
@property (nonatomic, nonnull, strong) NSNumber *height;

- (instancetype _Nullable)initWithFiles:(NSArray<FSBlob *> * _Nonnull)files width:(NSNumber * _Nonnull)width height:(NSNumber * _Nonnull)height;
- (instancetype _Nullable)initWithFiles:(NSArray<FSBlob *> * _Nonnull)files width:(NSNumber * _Nonnull)width height:(NSNumber * _Nonnull)height margin:(NSNumber * _Nullable)margin color:(NSString * _Nullable)color NS_DESIGNATED_INITIALIZER;

@end
