//
//  FSSecurity.h
//  Filestack
//
//  Created by Łukasz Cichecki on 21/01/16.
//  Copyright © 2016 Filestack. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FSSecurity : NSObject

@property (nonatomic, readonly, strong) NSString *policy;
@property (nonatomic, readonly, strong) NSString *signature;

- (instancetype)initWithPolicy:(NSString *)policy andSignature:(NSString *)signature;

@end
