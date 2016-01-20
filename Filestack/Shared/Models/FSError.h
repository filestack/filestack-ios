//
//  FSError.h
//  Filestack
//
//  Created by Łukasz Cichecki on 20/01/16.
//  Copyright © 2016 Filestack. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FSError : NSObject

@property (nonatomic, assign) NSInteger code;
@property (nonatomic, strong) NSString *errorMessage;

- (instancetype)initWithCode:(NSInteger)code andErrorMessage:(NSString *)errorMessage;

@end
