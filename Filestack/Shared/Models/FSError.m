//
//  FSError.m
//  Filestack
//
//  Created by Łukasz Cichecki on 20/01/16.
//  Copyright © 2016 Filestack. All rights reserved.
//

#import "FSError.h"

@implementation FSError

- (instancetype)initWithCode:(NSInteger)code andErrorMessage:(NSString *)errorMessage {
    if (self = [super init]) {
        self.code = code;
        self.errorMessage = errorMessage;
    }
    return self;
}

@end
