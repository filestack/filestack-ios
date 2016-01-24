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
#import "FSStoreOptions.h"

typedef NSString * FSURL;
#define FSURLPickPath @"api/pick"
#define FSURLMetadataPath @"/metadata"
#define FSURLFilePath @"api/file"
#define FSURLStorePath @"api/store"

@protocol FSFilestackDelegate <NSObject>

@end

@interface Filestack : NSObject

/*!
 @brief It initializes Filestack library instance with api key.
 @param apiKey Found in Developer Portal.
 */
- (instancetype)initWithApiKey:(NSString *)apiKey;

/*!
 @brief It initializes Filestack library instance with api key and delegate.
 @param apiKey Found in Developer Portal.
 @param delegate Filestack library delegate.
 */
- (instancetype)initWithApiKey:(NSString *)apiKey andDelegate:(id <FSFilestackDelegate>)delegate;

/*!
 @brief It creates a symlink of the provided url.
 @param url Url string linking to the file.
 @param completionHandler Function accepting two arguments: FSBlob and NSError, returned from pick request.
 */
- (void)pickURL:(NSString *)url completionHandler:(void (^)(FSBlob *blob, NSError *error))completionHandler;

/*!
 @brief It removes the blob from the storage or removes the symlink.
 @param blob Filestack blob with valid url.
 @param completionHandler Function accepting one argument: NSError, returned from remove request.
 */
- (void)remove:(FSBlob *)blob completionHandler:(void (^)(NSError *error))completionHandler;

/*!
 @brief It returns metadata of the provided blob.
 @param blob Filestack blob with valid url.
 @param statOptions FSStatOptions object or nil.
 @param completionHandler Function accepting two arguments: FSMetadata and NSError, returned from stat request.
 */
- (void)stat:(FSBlob *)blob withOptions:(FSStatOptions *)statOptions completionHandler:(void (^)(FSMetadata *metadata, NSError *error))completionHandler;

/*!
 @brief It stores a file behind provided url to one of few storage locations.
 @param url Url string linking to the file.
 @param storeOptions FSStoreOptions object or nil.
 @param completionHandler Function accepting two arguments: FSBlob and NSError, returned from store request.
 */
- (void)storeURL:(NSString *)url withOptions:(FSStoreOptions *)storeOptions completionHandler:(void (^)(FSBlob *blob, NSError *error))completionHandler;

/*!
 @brief It stores a provided data to one of few storage locations.
 @param data NSData object to be stored.
 @param storeOptions FSStoreOptions object or nil.
 @param completionHandler Function accepting two arguments: FSBlob and NSError, returned from store request.
 */
- (void)store:(NSData *)data withOptions:(FSStoreOptions *)storeOptions completionHandler:(void (^)(FSBlob *blob, NSError *error))completionHandler;

@end
