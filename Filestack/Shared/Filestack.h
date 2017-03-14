//
//  Filestack.h
//  Filestack
//
//  Created by Łukasz Cichecki on 20/01/16.
//  Copyright © 2016 Filestack. All rights reserved.
//

#ifdef DEBUG
#   define NSLog(...) NSLog(__VA_ARGS__)
#else
#   define NSLog(...) (void)0
#endif

@import Foundation;
#import "FSBlob.h"
#import "FSMetadata.h"
#import "FSStatOptions.h"
#import "FSStoreOptions.h"
#import "FSTransformation.h"
#import "FSUploadOptions.h"

@protocol FSFilestackDelegate <NSObject>
@optional
- (void)filestackTransformSuccess:(NSData *)data;
- (void)filestackTransformSuccessJSON:(NSDictionary *)JSON;
- (void)filestackStatSuccess:(FSMetadata *)metadata;
- (void)filestackDownloadSuccess:(NSData *)data;
- (void)filestackRequestError:(NSError *)error;
- (void)filestackPickURLSuccess:(FSBlob *)blob;
- (void)filestackStoreSuccess:(FSBlob *)blob;
- (void)filestackRemoveSuccess;
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
- (instancetype)initWithApiKey:(NSString *)apiKey delegate:(id <FSFilestackDelegate>)delegate NS_DESIGNATED_INITIALIZER;

/*!
 @brief Creates a symlink of the provided url.
 @param url Url string linking to the file.
 @param security FSSecurity object or nil.
 @param completionHandler A block object taking two arguments: blob and error, returned from pick request.
 */
- (void)pickURL:(NSString *)url security:(FSSecurity *)security completionHandler:(void (^)(FSBlob *blob, NSError *error))completionHandler;

/*!
 @brief Removes the blob from the storage or removes the symlink.
 @param blob Filestack blob with valid url.
 @param security FSSecurity object or nil.
 @param completionHandler A block object taking one argument: error, returned from remove request.
 */
- (void)remove:(FSBlob *)blob security:(FSSecurity *)security completionHandler:(void (^)(NSError *error))completionHandler;

/*!
 @brief Returns metadata of the provided blob.
 @param blob Filestack blob with valid url.
 @param statOptions FSStatOptions object or nil.
 @param completionHandler A block object taking two arguments: metadata and error, returned from stat request.
 */
- (void)stat:(FSBlob *)blob withOptions:(FSStatOptions *)statOptions completionHandler:(void (^)(FSMetadata *metadata, NSError *error))completionHandler;

/*!
 @brief Downloads provided blob to NSData object.
 @param blob Filestack blob with valid url.
 @param security FSSecurity object or nil.
 @param completionHandler A block object taking two arguments: data and error, returned from download request.
 */
- (void)download:(FSBlob *)blob security:(FSSecurity *)security completionHandler:(void (^)(NSData *data, NSError *error))completionHandler;

/*!
 @brief Stores file behind provided url to one of a few storage locations.
 @param url Url string linking to the file.
 @param storeOptions FSStoreOptions object or nil.
 @param completionHandler A block object taking two arguments: blob and error, returned from store request.
 */
- (void)storeURL:(NSString *)url withOptions:(FSStoreOptions *)storeOptions completionHandler:(void (^)(FSBlob *blob, NSError *error))completionHandler;

/*!
 @brief Stores provided data to one of a few storage locations.
 @param data NSData object to be stored.
 @param storeOptions FSStoreOptions object or nil.
 @param progress A block object taking one argument: upload progress.
 @param completionHandler A block object taking two arguments: blob and error, returned from store request.
 */
- (void)store:(NSData *)data withOptions:(FSStoreOptions *)storeOptions progress:(void (^)(NSProgress *uploadProgress))progress completionHandler:(void (^)(FSBlob *blob, NSError *error))completionHandler;

/*!
 @brief Uploads provided data to one of a few storage locations using multi-part upload feature.
 @param data NSData object to be stored.
 @param storeOptions FSStoreOptions object or nil.
 @param progress A block object taking one argument: upload progress.
 @param completionHandler A block object taking two arguments: blob and error, returned from store request.
 */
- (void)upload:(NSData *)data
   withOptions:(FSUploadOptions *)uploadOptions
   withStoreOptions:(FSStoreOptions *)storeOptions
       onStart:(void (^)())onStart
      progress:(void (^)(NSProgress *uploadProgress))progress
completionHandler:(void (^)(NSDictionary *result, NSError *error))completionHandler;


/*!
 @brief Transforms provided url using Filestack's transformation engine.
 @param url Url string linking to the file.
 @param transformation FSTransformation object or nil.
 @param security FSSecurity object or nil.
 @param completionHandler A block object taking three arguments: data, dictionary and error, returned from transform request.
 */
- (void)transformURL:(NSString *)url transformation:(FSTransformation *)transformation security:(FSSecurity *)security completionHandler:(void (^)(NSData *data, NSDictionary *JSON, NSError *error))completionHandler;

@end
