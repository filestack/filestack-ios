//
//  FSRetryOptions.m
//  Filestack
//
//  Created by Kevin Minnick on 3/8/17.
//  Copyright © 2017 Filestack. All rights reserved.
//

#import "FSRetryOptions.h"

@implementation FSRetryOptions

- (id)copyWithZone:(NSZone *)zone {
    FSRetryOptions *newOptions = [[[self class] allocWithZone:zone] init];
    
    if (newOptions) {
        newOptions.retries = self.retries;
        newOptions.factor = self.factor;
        newOptions.minTimeout = self.minTimeout;
        newOptions.maxTimeout = self.maxTimeout;
    }
    
    return newOptions;
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    if ((self = [super init])) {
        _retries = [dictionary[@"retries"] integerValue];
        _factor = [dictionary[@"factor"] decimalValue];
        _minTimeout = [dictionary[@"minTimeout"] integerValue];
        _maxTimeout = [dictionary[@"maxTimeout"] integerValue];
    }
    
    return self;
}

- (instancetype)init {
    return [self initWithDictionary:@{}];
}

@end
