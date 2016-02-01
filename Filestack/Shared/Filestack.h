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

@protocol FSFilestackDelegate <NSObject>
@optional
- (void)filestackRequestError:(NSError *)error;
- (void)filestackPickURLSuccess:(FSBlob *)blob;
- (void)filestackRemoveSuccess;
- (void)filestackStatSuccess:(FSMetadata *)metadata;
- (void)filestackDownloadSuccess:(NSData *)data;
- (void)filestackStoreSuccess:(FSBlob *)blob;
@end

@interface Filestack : NSObject

@property (nonatomic, weak) id<FSFilestackDelegate> delegate;

/*!
 @brief Initializes Filestack library instance with api key.
 @param apiKey Found in Developer Portal.
 */
- (instancetype)initWithApiKey:(NSString *)apiKey;

/*!
 @brief Initializes Filestack library instance with api key and delegate.
 @param apiKey Found in Developer Portal.
 @param delegate Filestack library delegate.
 */
- (instancetype)initWithApiKey:(NSString *)apiKey andDelegate:(id <FSFilestackDelegate>)delegate;

/*!
 @brief Creates a symlink of the provided url.
 @param url Url string linking to the file.
 @param completionHandler Function accepting two arguments: FSBlob and NSError, returned from pick request.
 */
- (void)pickURL:(NSString *)url completionHandler:(void (^)(FSBlob *blob, NSError *error))completionHandler;

/*!
 @brief Removes the blob from the storage or removes the symlink.
 @param blob Filestack blob with valid url.
 @param completionHandler Function accepting one argument: NSError, returned from remove request.
 */
- (void)remove:(FSBlob *)blob completionHandler:(void (^)(NSError *error))completionHandler;

/*!
 @brief Returns metadata of the provided blob.
 @param blob Filestack blob with valid url.
 @param statOptions FSStatOptions object or nil.
 @param completionHandler Function accepting two arguments: FSMetadata and NSError, returned from stat request.
 */
- (void)stat:(FSBlob *)blob withOptions:(FSStatOptions *)statOptions completionHandler:(void (^)(FSMetadata *metadata, NSError *error))completionHandler;

/*!
 @brief Downloads provided blob to NSData object.
 @param blob Filestack blob with valid url.
 @param completionHandler Function accepting two arguments: NSData and NSError, returned from download request.
 */
- (void)download:(FSBlob *)blob completionHandler:(void (^)(NSData *data, NSError *error))completionHandler;

/*!
 @brief Stores file behind provided url to one of a few storage locations.
 @param url Url string linking to the file.
 @param storeOptions FSStoreOptions object or nil.
 @param completionHandler Function accepting two arguments: FSBlob and NSError, returned from store request.
 */
- (void)storeURL:(NSString *)url withOptions:(FSStoreOptions *)storeOptions completionHandler:(void (^)(FSBlob *blob, NSError *error))completionHandler;

/*!
 @brief Stores provided data to one of few a storage locations.
 @param data NSData object to be stored.
 @param storeOptions FSStoreOptions object or nil.
 @param completionHandler Function accepting two arguments: FSBlob and NSError, returned from store request.
 */
- (void)store:(NSData *)data withOptions:(FSStoreOptions *)storeOptions completionHandler:(void (^)(FSBlob *blob, NSError *error))completionHandler;

@end
