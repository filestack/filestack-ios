//
//  FSMultipartUpload.h
//  Filestack
//
//  Created by Kevin Minnick on 3/8/17.
//  Copyright © 2017 Filestack. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FSUploadoptions.h"
#import "FSStoreOptions.h"

@interface FSMultipartUpload : NSObject

- (instancetype) initWithOptions:(FSUploadOptions*)uploadOptions
                withStoreOptions:(FSStoreOptions*)storeOptions
                      withApiKey:(NSString*)apiKey
                         onStart:(void (^)())onStart
                         onRetry:(void (^)(double retryAttempt, double inSeconds))onRetry
                        progress:(void (^)(NSProgress *uploadProgress))progress
               completionHandler:(void (^)(NSDictionary *result, NSError *error))completionHandler;

- (void)upload:(NSData*)file;

@end
