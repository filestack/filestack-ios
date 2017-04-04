//
//  FSUploadOptions.m
//  Filestack
//
//  Created by Kevin Minnick on 3/8/17.
//  Copyright © 2017 Filestack. All rights reserved.
//

#import "FSUploadOptions.h"

@implementation FSUploadOptions

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    if ((self = [super init])) {
        _partSize = dictionary[@"partSize"];
        _maxConcurrentUploads = dictionary[@"maxConcurrentUploads"];
        _retryOptions = dictionary[@"retryOptions"];
    }
    
    return self;
}

- (instancetype)init {
    return [self initWithDictionary:@{}];
}

@end
