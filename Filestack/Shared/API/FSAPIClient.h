//
//  FSAPIClient.h
//  Filestack
//
//  Created by Łukasz Cichecki on 28/01/16.
//  Copyright © 2016 Filestack. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FSStoreOptions.h"
#import "FSStatOptions.h"
#import "FSMetadata.h"
#import "FSBlob.h"

@interface FSAPIClient : NSObject

- (void)GET:(NSString *)getURL parameters:(NSDictionary *)parameters completionHandler:(void (^)(NSData *data, NSError *error))completionHandler;
- (void)GET:(NSString *)getURL parameters:(NSDictionary *)parameters options:(FSStatOptions *)statOptions sessionSettings:(NSDictionary *)sessionSettings completionHandler:(void (^)(FSMetadata *metadata, NSError *error))completionHandler;
- (void)DELETE:(NSString *)deleteURL parameters:(NSDictionary *)parameters completionHandler:(void (^)(NSError *error))completionHandler;
- (void)POST:(NSString *)postURL parameters:(NSDictionary *)parameters options:(FSStoreOptions *)storeOptions sessionSettings:(NSDictionary *)sessionSettings completionHandler:(void (^)(FSBlob *blob, NSError *error))completionHandler;
- (void)POST:(NSString *)postURL withData:(NSData *)data parameters:(NSDictionary *)parameters multipartOptions:(FSStoreOptions *)storeOptions completionHandler:(void (^)(FSBlob *blob, NSError *error))completionHandler;

@end
