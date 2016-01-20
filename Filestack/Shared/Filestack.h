//
//  Filestack.h
//  Filestack
//
//  Created by Łukasz Cichecki on 20/01/16.
//  Copyright © 2016 Filestack. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FSBlob.h"
#import "FSMetadata.h"
#import "FSStatOptions.h"

typedef NSString * FSURL;
#define FSURLPickPath @"api/pick"
#define FSURLMetadataPath @"/metadata"

@protocol FSFilestackDelegate <NSObject>

@end

@interface Filestack : NSObject

- (instancetype)initWithApiKey:(NSString *)apiKey;
- (instancetype)initWithApiKey:(NSString *)apiKey andDelegate:(id <FSFilestackDelegate>)delegate;
- (void)pickWithURL:(NSString *)url completionHandler:(void (^)(FSBlob *blob, NSError *error))completionHandler;
- (void)stat:(FSBlob *)blob withOptions:(FSStatOptions *)statOptions completionHandler:(void (^)(FSMetadata *metadata, NSError *error))completionHandler;

@end
