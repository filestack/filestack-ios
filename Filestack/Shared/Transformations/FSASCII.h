//
//  FSASCII.h
//  Filestack
//
//  Created by Łukasz Cichecki on 10/02/16.
//  Copyright © 2016 Filestack. All rights reserved.
//

#import "FSTransform.h"

@interface FSASCII : FSTransform

/**
 This can be the word for a color, or the hex color code. Defaults to "black".
 */
@property (nonatomic, strong) NSString *foreground;
/**
 This can be the word for a color, or the hex color code. Defaults to "white".
 */
@property (nonatomic, strong) NSString *background;
/**
 The value must be an integer from 10 to 100. Defaults to 100.
 */
@property (nonatomic, strong) NSNumber *size;
/**
 Defaults to NO.
 */
@property (nonatomic, assign) BOOL reverse;
/**
 Defaults to NO.
 */
@property (nonatomic, assign) BOOL colored;

- (instancetype)initWithForeground:(NSString *)foreground background:(NSString *)background size:(NSNumber *)size reverse:(BOOL)reverse colored:(BOOL)colored NS_DESIGNATED_INITIALIZER;

@end
