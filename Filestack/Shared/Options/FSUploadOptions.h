//
//  FSUploadOptions.h
//  Filestack
//
//  Created by Kevin Minnick on 3/8/17.
//  Copyright © 2017 Filestack. All rights reserved.
//

@import Foundation;
#import "FSRetryOptions.h"

@interface FSUploadOptions : NSObject

@property (nonatomic) NSNumber *partSize;
@property (nonatomic) NSNumber *maxConcurrentUploads;
@property (nonatomic, copy) FSRetryOptions *retryOptions;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary NS_DESIGNATED_INITIALIZER;

@end
