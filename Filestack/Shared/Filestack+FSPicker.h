//
//  Filestack+FSPicker.h
//  Filestack
//
//  Created by Łukasz Cichecki on 09/03/16.
//  Copyright © 2016 Filestack. All rights reserved.
//

#import "Filestack.h"

@interface Filestack (FSPicker)

+ (void)pickFSURL:(NSString *)fsURL parameters:(NSDictionary *)parameters completionHandler:(void (^)(FSBlob *blob, NSError *error))completionHandler;
+ (void)getContentForPath:(NSString *)contentPath parameters:(NSDictionary *)parameters completionHandler:(void (^)(NSDictionary *responseJSON, NSError *error))completionHandler;
+ (void)logoutFromSource:(NSString *)sourceIdentifier externalDomains:(NSArray *)externalDomains parameters:(NSDictionary *)parameters completionHandler:(void (^)(NSError *error))completionHandler;

@end
