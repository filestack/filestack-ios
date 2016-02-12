//
//  FSTransformErrorSerializer.m
//  Filestack
//
//  Created by Łukasz Cichecki on 12/02/16.
//  Copyright © 2016 Filestack. All rights reserved.
//

#import "FSTransformErrorSerializer.h"
#import <AFNetworking/AFNetworking.h>

@implementation FSTransformErrorSerializer

+ (NSError *)transformErrorWithError:(NSError *)error {
    NSString *errorResponse = [[NSString alloc] initWithData:(NSData *)error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:NSUTF8StringEncoding];
    NSMutableDictionary *mutableUserInfo = [error.userInfo mutableCopy];

    if (errorResponse) {
        mutableUserInfo[@"com.filestack.serialization.response.error"] = errorResponse;
    }

    return [NSError errorWithDomain:error.domain code:error.code userInfo:mutableUserInfo];
}

@end
