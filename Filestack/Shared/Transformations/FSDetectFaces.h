//
//  FSDetectFaces.h
//  Filestack
//
//  Created by Łukasz Cichecki on 08/02/16.
//  Copyright © 2016 Filestack. All rights reserved.
//

#import "FSTransform.h"

@interface FSDetectFaces : FSTransform

/**
 This parameter is used to weed out objects that most likely are not faces. This can be an integer or a float in a range from 0.01 to 10000.
 */
@property (nonatomic, strong) NSNumber *minSize;
/**
 This parameter is used to weed out objects that most likely are not faces. This can be an integer or a float in a range from 0.01 to 10000.
 */
@property (nonatomic, strong) NSNumber *maxSize;
/**
 Change the color of the face object boxes and text. This can be the word for a color, or the hex color code.
 */
@property (nonatomic, copy) NSString *color;
/**
 If `YES`, it will export all face objects to a JSON object.
 */
@property (nonatomic, assign) BOOL exportToJSON;

- (instancetype)initWithMinSize:(NSNumber *)minSize maxSize:(NSNumber *)maxSize color:(NSString *)color exportToJSON:(BOOL)exportToJSON NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithExportToJSON;

@end
