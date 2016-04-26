//
//  FSSecurity.h
//  Filestack
//
//  Created by Łukasz Cichecki on 21/01/16.
//  Copyright © 2016 Filestack. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FSSecurity : NSObject

@property (nonatomic, readonly, nonnull, copy) NSString *policy;
@property (nonatomic, readonly, nonnull, copy) NSString *signature;

/*!
 @brief Initializes FSSecurity instance with policy and signature.
 @param policy Policy found in Developer portal's Security section.
 @param signature Signature found in Developer portal's Security section.
 */
- (instancetype)initWithPolicy:(NSString * _Nonnull)policy signature:(NSString * _Nonnull)signature NS_DESIGNATED_INITIALIZER;

@end
