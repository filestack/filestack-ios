//
//  FSSecurity.m
//  Filestack
//
//  Created by Łukasz Cichecki on 21/01/16.
//  Copyright © 2016 Filestack. All rights reserved.
//

#import "FSSecurity.h"

@interface FSSecurity ()

@property (nonatomic, readwrite, strong) NSString *policy;
@property (nonatomic, readwrite, strong) NSString *signature;

@end

@implementation FSSecurity

- (instancetype)initWithPolicy:(NSString *)policy andSignature:(NSString *)signature {
    if (self = [super init]) {
        self.policy = policy;
        self.signature = signature;
    }
    return self;
}

@end
