//
//  FSSecurity.m
//  Filestack
//
//  Created by Łukasz Cichecki on 21/01/16.
//  Copyright © 2016 Filestack. All rights reserved.
//

#import "FSSecurity.h"

@interface FSSecurity ()

@property (nonatomic, readwrite, copy) NSString *policy;
@property (nonatomic, readwrite, copy) NSString *signature;

@end

@implementation FSSecurity

- (instancetype)initWithPolicy:(NSString *)policy signature:(NSString *)signature {
    if ((self = [super init])) {
        _policy = policy;
        _signature = signature;
    }
    return self;
}

@end
