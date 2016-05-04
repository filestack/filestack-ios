//
//  FSURLScreenshot.h
//  Filestack
//
//  Created by Łukasz Cichecki on 10/02/16.
//  Copyright © 2016 Filestack. All rights reserved.
//

#import "FSTransform.h"

typedef NSString * FSURLScreenshotAgent;
#define FSURLScreenshotAgentMobile @"mobile"
#define FSURLScreenshotAgentDesktop @"desktop"

typedef NSString * FSURLScreenshotMode;
#define FSURLScreenshotModeAll @"all"
#define FSURLScreenshotModeWindow @"window"

@interface FSURLScreenshot : FSTransform

/**
 The value must be an integer from 1 to 1080. Defaults to 768.
 */
@property (nonatomic, strong) NSNumber *width;
/**
 The value must be an integer from 1 to 1920. Defaults to 1024.
 */
@property (nonatomic, strong) NSNumber *height;
@property (nonatomic, strong) FSURLScreenshotAgent agent;
@property (nonatomic, strong) FSURLScreenshotMode mode;

- (instancetype)initWithWidth:(NSNumber *)width height:(NSNumber *)height agent:(FSURLScreenshotAgent)agent mode:(FSURLScreenshotMode)mode NS_DESIGNATED_INITIALIZER;

@end
