//
//  Filestack.m
//  Filestack
//
//  Created by Łukasz Cichecki on 20/01/16.
//  Copyright © 2016 Filestack. All rights reserved.
//

#import "Filestack.h"
#import "FSBlobSerializer.h"
#import "FSMetadata+Private.h"
#import <AFNetworking/AFNetworking.h>

typedef NSString * FSURL;
#define FSURLPickPath @"api/pick"
#define FSURLMetadataPath @"/metadata"
#define FSURLFilePath @"api/file"
#define FSURLStorePath @"api/store"

@interface Filestack()

@property (nonatomic, strong) NSString *apiKey;
@property (nonatomic, strong) NSString *fsBaseURL;

@end

@implementation Filestack

- (instancetype)initWithApiKey:(NSString *)apiKey andDelegate:(id <FSFilestackDelegate>)delegate {
    if (self = [super init]) {
        self.apiKey = apiKey;
        self.delegate = delegate;
        self.fsBaseURL = @"https://www.filestackapi.com/";
    }
    return self;
}

- (instancetype)initWithApiKey:(NSString *)apiKey {
    return [self initWithApiKey:apiKey andDelegate:nil];
}

- (void)pickURL:(NSString *)url completionHandler:(void (^)(FSBlob *blob, NSError *error))completionHandler {
    AFHTTPSessionManager *httpManager = [self httpSessionManagerWithBaseURL:nil andPOSTURIParameters:YES];
    NSDictionary *parameters = @{@"key": _apiKey, @"url": url};

    [httpManager POST:FSURLPickPath parameters:parameters progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        FSBlob *blob = [[FSBlob alloc] initWithDictionary:(NSDictionary *)responseObject];
        if ([_delegate respondsToSelector:@selector(filestackPickURLSuccess:)]) {
            [_delegate filestackPickURLSuccess:blob];
        }
        completionHandler(blob, nil);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if ([_delegate respondsToSelector:@selector(filestackRequestError:)]) {
            [_delegate filestackRequestError:error];
        }
        completionHandler(nil, error);
    }];
}

- (void)remove:(FSBlob *)blob completionHandler:(void (^)(NSError *error))completionHandler {
    AFHTTPSessionManager *httpManager = [self httpSessionManagerWithBaseURL:nil andPOSTURIParameters:NO];
    // Filestack API returns a simple "success" string for successful delete request.
    // We need responseSerializer to be AFHTTPResponseSerializer to parse this properly instead of
    // returning false error.
    httpManager.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSString *blobHandle = [[NSURL URLWithString:blob.url] lastPathComponent];
    NSString *fullURL = [NSString stringWithFormat:@"%@/%@", FSURLFilePath, blobHandle];
    NSDictionary *parameters = @{@"key": _apiKey};

    [httpManager DELETE:fullURL parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        if ([_delegate respondsToSelector:@selector(filestackRemoveSuccess)]) {
            [_delegate filestackRemoveSuccess];
        }
        completionHandler(nil);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if ([_delegate respondsToSelector:@selector(filestackRequestError:)]) {
            [_delegate filestackRequestError:error];
        }
        completionHandler(error);
    }];
}

- (void)stat:(FSBlob *)blob withOptions:(FSStatOptions *)statOptions completionHandler:(void (^)(FSMetadata *metadata, NSError *error))completionHandler {
    AFHTTPSessionManager *httpManager = [self httpSessionManagerWithBaseURL:blob.url andPOSTURIParameters:NO];
    NSString *blobHandle = [[NSURL URLWithString:blob.url] lastPathComponent];
    NSString *fullURL = [NSString stringWithFormat:@"/%@%@", blobHandle, FSURLMetadataPath];
    NSDictionary *parameters = [statOptions toQueryParameters];

    [httpManager GET:fullURL parameters:parameters progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        FSMetadata *metadata = [[FSMetadata alloc] initWithDictionary:(NSDictionary *)responseObject];
        if ([_delegate respondsToSelector:@selector(filestackStatSuccess:)]) {
            [_delegate filestackStatSuccess:metadata];
        }
        completionHandler(metadata, nil);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if ([_delegate respondsToSelector:@selector(filestackRequestError:)]) {
            [_delegate filestackRequestError:error];
        }
        completionHandler(nil, error);
    }];
}


- (void)download:(FSBlob *)blob completionHandler:(void (^)(NSData *data, NSError *error))completionHandler {
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFHTTPSessionManager *httpManager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:configuration];
    httpManager.responseSerializer = [AFHTTPResponseSerializer serializer];

    [httpManager GET:blob.url parameters:nil progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        NSData *responseData = [NSData dataWithData:responseObject];
        if ([_delegate respondsToSelector:@selector(filestackDownloadSuccess:)]) {
            [_delegate filestackDownloadSuccess:responseData];
        }
        completionHandler(responseData, nil);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if ([_delegate respondsToSelector:@selector(filestackRequestError:)]) {
            [_delegate filestackRequestError:error];
        }
        completionHandler(nil, error);
    }];
}

- (void)storeURL:(NSString *)url withOptions:(FSStoreOptions *)storeOptions completionHandler:(void (^)(FSBlob *blob, NSError *error))completionHandler {
    AFHTTPSessionManager *httpManager = [self httpSessionManagerWithBaseURL:nil andPOSTURIParameters:YES];
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] initWithDictionary:[storeOptions toQueryParameters]];
    [parameters removeObjectForKey:@"mimetype"];
    parameters[@"url"] = url;

    NSString *fullURL = [self fullURLForStoreOptions:storeOptions andStoringURL:YES];

    [httpManager POST:fullURL parameters:parameters progress:nil success:^(NSURLSessionDataTask * task, id responseObject) {
        FSBlob *blob = [[FSBlob alloc] initWithDictionary:(NSDictionary *)responseObject];
        if ([_delegate respondsToSelector:@selector(filestackStoreURLSuccess:)]) {
            [_delegate filestackStoreURLSuccess:blob];
        }
        completionHandler(blob, nil);
    } failure:^(NSURLSessionDataTask * task, NSError * error) {
        if ([_delegate respondsToSelector:@selector(filestackRequestError:)]) {
            [_delegate filestackRequestError:error];
        }
        completionHandler(nil, error);
    }];
}

- (void)store:(NSData *)data withOptions:(FSStoreOptions *)storeOptions completionHandler:(void (^)(FSBlob *blob, NSError *error))completionHandler {
    NSDictionary *parameters = [storeOptions toQueryParameters];
    NSString *fullURL = [self fullURLForStoreOptions:storeOptions andStoringURL:NO];
    NSString *mimeType = [self mimeTypeForStoreOptions:storeOptions];

    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST" URLString:fullURL parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFormData:data name:@"fileUpload"];
    } error:nil];

    [self addHeadersToRequest:request withMimeType:mimeType andFileName:storeOptions.fileName];

    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];

    NSURLSessionUploadTask *uploadTask;
    uploadTask = [manager uploadTaskWithStreamedRequest:request progress:nil completionHandler:^(NSURLResponse * response, id responseObject, NSError * error) {
                      if (error) {
                          if ([_delegate respondsToSelector:@selector(filestackRequestError:)]) {
                              [_delegate filestackRequestError:error];
                          }
                          completionHandler(nil, error);
                      } else {
                          NSLog(@"%@", responseObject);
                          FSBlob *blob = [[FSBlob alloc] initWithDictionary:(NSDictionary *)responseObject];
                          if ([_delegate respondsToSelector:@selector(filestackStoreSuccess:)]) {
                              [_delegate filestackStoreSuccess:blob];
                          }
                          completionHandler(blob, nil);
                      }
                  }];
    [uploadTask resume];
}

- (void)addHeadersToRequest:(NSMutableURLRequest *)request withMimeType:(NSString *)mimeType andFileName:(NSString *)fileName {
    [request setValue:mimeType forHTTPHeaderField:@"Content-Type"];

    if (fileName) {
        [request setValue:fileName forHTTPHeaderField:@"X-File-Name"];
    }
}

- (NSString *)fullURLForStoreOptions:(FSStoreOptions *)storeOptions andStoringURL:(BOOL)isStoreURL {
    if (isStoreURL) {
        if (storeOptions) {
            return [NSString stringWithFormat:@"%@/%@?key=%@", FSURLStorePath, storeOptions.storeLocation, _apiKey];
        }
        return [NSString stringWithFormat:@"%@/%@?key=%@", FSURLStorePath, @"S3", _apiKey];
    } else {
        if (storeOptions) {
            return [NSString stringWithFormat:@"%@%@/%@?key=%@", _fsBaseURL, FSURLStorePath, storeOptions.storeLocation, _apiKey];
        }
        return [NSString stringWithFormat:@"%@%@/%@?key=%@", _fsBaseURL, FSURLStorePath, @"S3", _apiKey];
    }
}

- (NSString *)mimeTypeForStoreOptions:(FSStoreOptions *)storeOptions {
    if (storeOptions.mimeType) {
        return storeOptions.mimeType;
    }
    return @"application/octet-stream";
}

- (AFHTTPSessionManager *)httpSessionManagerWithBaseURL:(NSString *)baseURL andPOSTURIParameters:(BOOL)postUriParameters {
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURL *managerBaseURL;
    if (baseURL) {
        managerBaseURL = [NSURL URLWithString:baseURL];
    } else {
        managerBaseURL = [NSURL URLWithString:_fsBaseURL];
    }
    AFHTTPSessionManager *httpManager = [[AFHTTPSessionManager alloc] initWithBaseURL:managerBaseURL sessionConfiguration:configuration];
    httpManager.requestSerializer = [AFHTTPRequestSerializer serializer];
    if (postUriParameters) {
        httpManager.requestSerializer.HTTPMethodsEncodingParametersInURI = [NSSet setWithArray:@[@"POST", @"GET", @"HEAD", @"DELETE"]];
    }
    return httpManager;
}

@end
