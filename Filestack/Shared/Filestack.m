//
//  Filestack.m
//  Filestack
//
//  Created by Łukasz Cichecki on 20/01/16.
//  Copyright © 2016 Filestack. All rights reserved.
//

#import "Filestack.h"
#import "FSAPIURL.h"
#import "FSAPIClient.h"
#import "FSTransformErrorSerializer.h"

@interface Filestack ()

@property (nonatomic, copy) NSString *apiKey;

@end

@implementation Filestack

- (instancetype)initWithApiKey:(NSString *)apiKey delegate:(id <FSFilestackDelegate>)delegate {
    if (self = [super init]) {
        _apiKey = apiKey;
        _delegate = delegate;
    }
    return self;
}

- (instancetype)initWithApiKey:(NSString *)apiKey {
    return [self initWithApiKey:apiKey delegate:nil];
}

- (void)pickURL:(NSString *)url completionHandler:(void (^)(FSBlob *blob, NSError *error))completionHandler {
    NSDictionary *parameters = @{@"key": _apiKey, @"url": url};
    FSSessionSettings *sessionSettings = [[FSSessionSettings alloc] init];
    sessionSettings.paramsInURI = YES;
    FSAPIClient *apiClient = [[FSAPIClient alloc] init];

    [apiClient POST:FSURLPickPath parameters:parameters options:nil sessionSettings:sessionSettings completionHandler:^(FSBlob *blob, NSError *error) {
        if (error) {
            [self delegateRequestError:error];
        } else {
            [self delegatePickSuccess:blob];
        }

        if (completionHandler) {
            completionHandler(blob, error);
        }
    }];
}

- (void)remove:(FSBlob *)blob completionHandler:(void (^)(NSError *error))completionHandler {
    NSString *deleteURL = [FSAPIURL URLFilePathWithBlobURL:blob.url];
    NSDictionary *parameters = @{@"key": _apiKey};

    FSAPIClient *apiClient = [[FSAPIClient alloc] init];
    [apiClient DELETE:deleteURL parameters:parameters completionHandler:^(NSError *error) {
        if (error) {
            [self delegateRequestError:error];
        } else {
            [self delegateRemoveSuccess];
        }

        if (completionHandler) {
            completionHandler(error);
        }
    }];
}

- (void)stat:(FSBlob *)blob withOptions:(FSStatOptions *)statOptions completionHandler:(void (^)(FSMetadata *metadata, NSError *error))completionHandler {
    FSSessionSettings *sessionSettings = [[FSSessionSettings alloc] init];
    sessionSettings.baseURL = blob.url;
    NSDictionary *parameters = [statOptions toQueryParameters];
    NSString *statURL = [FSAPIURL URLMetadataPathWithBlobURL:blob.url];

    FSAPIClient *apiClient = [[FSAPIClient alloc] init];
    [apiClient GET:statURL parameters:parameters sessionSettings:sessionSettings completionHandler:^(FSMetadata *metadata, NSError *error) {
        if (error) {
            [self delegateRequestError:error];
        } else {
            [self delegateStatSuccess:metadata];
        }

        if (completionHandler) {
            completionHandler(metadata, error);
        }
    }];
}

- (void)download:(FSBlob *)blob completionHandler:(void (^)(NSData *data, NSError *error))completionHandler {
    FSAPIClient *apiClient = [[FSAPIClient alloc] init];
    [apiClient GET:blob.url parameters:nil completionHandler:^(NSData *data, NSError *error) {
        if (error) {
            [self delegateRequestError:error];
        } else {
            [self delegateDownloadSuccess:data];
        }

        if (completionHandler) {
            completionHandler(data, error);
        }
    }];
}

- (void)storeURL:(NSString *)url withOptions:(FSStoreOptions *)storeOptions completionHandler:(void (^)(FSBlob *blob, NSError *error))completionHandler {
    FSSessionSettings *sessionSettings = [[FSSessionSettings alloc] init];
    sessionSettings.paramsInURI = YES;
    NSString *storeURL = [FSAPIURL URLForStoreOptions:storeOptions storeURL:YES andApiKey:_apiKey];
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] initWithDictionary:[storeOptions toQueryParameters]];
    [parameters removeObjectForKey:@"mimetype"];
    parameters[@"url"] = url;

    FSAPIClient *apiClient = [[FSAPIClient alloc] init];
    [apiClient POST:storeURL parameters:parameters options:storeOptions sessionSettings:sessionSettings completionHandler:^(FSBlob *blob, NSError *error) {
        if (error) {
            [self delegateRequestError:error];
        } else {
            [self delegateStoreSuccess:blob];
        }

        if (completionHandler) {
            completionHandler(blob, error);
        }
    }];
}

- (void)store:(NSData *)data withOptions:(FSStoreOptions *)storeOptions progress:(void (^)(NSProgress *uploadProgress))progress completionHandler:(void (^)(FSBlob *blob, NSError *error))completionHandler {
    NSDictionary *parameters = [storeOptions toQueryParameters];
    NSString *postURL = [FSAPIURL URLForStoreOptions:storeOptions storeURL:NO andApiKey:_apiKey];
    FSAPIClient *apiClient = [[FSAPIClient alloc] init];
    [apiClient POST:postURL withData:data parameters:parameters multipartOptions:storeOptions progress:progress completionHandler:^(FSBlob *blob, NSError *error) {
        if (error) {
            [self delegateRequestError:error];
        } else {
            [self delegateStoreSuccess:blob];
        }

        if (completionHandler) {
            completionHandler(blob, error);
        }
    }];
}

- (void)transformURL:(NSString *)url transformation:(FSTransformation *)transformation security:(FSSecurity *)security completionHandler:(void (^)(NSData *data, NSDictionary *JSON, NSError *error))completionHandler {
    NSString *transformationURL = [transformation transformationURLWithApiKey:_apiKey security:security URLToTransform:url];
    FSAPIClient *apiClient = [[FSAPIClient alloc] init];
    [apiClient GET:transformationURL parameters:nil completionHandler:^(NSData *data, NSError *error) {
        NSDictionary *JSON;
        NSError *fsError;

        if (data && [transformation willReturnJSON]) {
            JSON = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
            [self filestackTransformSuccessJSON:JSON];
        } else if (data) {
            [self filestackTransformSuccess:data];
        }

        if (error) {
            fsError = [FSTransformErrorSerializer transformErrorWithError:error];
            [self delegateRequestError:fsError];
        }

        if (completionHandler) {
            if (JSON) {
                completionHandler(nil, JSON, fsError);
            } else {
                completionHandler(data, JSON, fsError);
            }
        }
    }];
}

- (void)filestackTransformSuccess:(NSData *)data {
    if ([_delegate respondsToSelector:@selector(filestackTransformSuccess:)]) {
        [_delegate filestackTransformSuccess:data];
    }
}

- (void)filestackTransformSuccessJSON:(NSDictionary *)JSON {
    if ([_delegate respondsToSelector:@selector(filestackTransformSuccessJSON:)]) {
        [_delegate filestackTransformSuccessJSON:JSON];
    }
}

- (void)delegateRequestError:(NSError *)error {
    if ([_delegate respondsToSelector:@selector(filestackRequestError:)]) {
        [_delegate filestackRequestError:error];
    }
}

- (void)delegateStatSuccess:(FSMetadata *)metadata {
    if ([_delegate respondsToSelector:@selector(filestackStatSuccess:)]) {
        [_delegate filestackStatSuccess:metadata];
    }
}

- (void)delegateStoreSuccess:(FSBlob *)blob {
    if ([_delegate respondsToSelector:@selector(filestackStoreSuccess:)]) {
        [_delegate filestackStoreSuccess:blob];
    }
}

- (void)delegateDownloadSuccess:(NSData *)data {
    if ([_delegate respondsToSelector:@selector(filestackDownloadSuccess:)]) {
        [_delegate filestackDownloadSuccess:data];
    }
}

- (void)delegatePickSuccess:(FSBlob *)blob {
    if ([_delegate respondsToSelector:@selector(filestackPickURLSuccess:)]) {
        [_delegate filestackPickURLSuccess:blob];
    }
}

- (void)delegateRemoveSuccess {
    if ([_delegate respondsToSelector:@selector(filestackRemoveSuccess)]) {
        [_delegate filestackRemoveSuccess];
    }
}

@end
