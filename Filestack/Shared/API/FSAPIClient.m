//
//  FSAPIClient.m
//  Filestack
//
//  Created by Łukasz Cichecki on 28/01/16.
//  Copyright © 2016 Filestack. All rights reserved.
//

#import "FSAPIClient.h"
#import "FSAPIURL.h"
#import "FSSessionSettings.h"
#import "FSMetadata+Private.h"
#import <AFNetworking/AFNetworking.h>

@interface FSAPIClient ()

@property (nonatomic, strong) NSString *apiKey;

@end

@implementation FSAPIClient

- (instancetype)initWithApiKey:(NSString *)apiKey {
    if (self = [super init]) {
        self.apiKey = apiKey;
    }
    return self;
}

- (void)POST:(NSString *)postURL parameters:(NSDictionary *)parameters options:(FSStoreOptions *)storeOptions sessionSettings:(NSDictionary *)sessionSettings completionHandler:(void (^)(FSBlob *blob, NSError *error))completionHandler {
    AFHTTPSessionManager *httpManager = [self httpSessionManagerWithBaseURL:sessionSettings[FSSessionSettingsBaseURL] andPOSTURIParameters:[sessionSettings[FSSessionSettingsURIParams] boolValue]];

    [httpManager POST:postURL parameters:parameters progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        FSBlob *blob = [[FSBlob alloc] initWithDictionary:(NSDictionary *)responseObject];
        completionHandler(blob, nil);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        completionHandler(nil, error);
    }];
}

- (void)POST:(NSString *)postURL withData:(NSData *)data parameters:(NSDictionary *)parameters multipartOptions:(FSStoreOptions *)storeOptions completionHandler:(void (^)(FSBlob *blob, NSError *error))completionHandler {
    NSString *mimeType = [self mimeTypeForStoreOptions:storeOptions];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST" URLString:postURL parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFormData:data name:@"fileUpload"];
    } error:nil];

    [self addHeadersToRequest:request withMimeType:mimeType andFileName:storeOptions.fileName];

    NSURLSessionUploadTask *uploadTask;
    uploadTask = [manager uploadTaskWithStreamedRequest:request progress:nil completionHandler:^(NSURLResponse * response, id responseObject, NSError * error) {
        if (error) {
            completionHandler(nil, error);
        } else {
            FSBlob *blob = [[FSBlob alloc] initWithDictionary:(NSDictionary *)responseObject];
            completionHandler(blob, nil);
        }
    }];
    [uploadTask resume];
}

- (void)GET:(NSString *)getURL parameters:(NSDictionary *)parameters completionHandler:(void (^)(NSData *data, NSError *error))completionHandler {
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFHTTPSessionManager *httpManager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:configuration];
    httpManager.responseSerializer = [AFHTTPResponseSerializer serializer];

    [httpManager GET:getURL parameters:nil progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        NSData *responseData = [NSData dataWithData:responseObject];
        completionHandler(responseData, nil);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        completionHandler(nil, error);
    }];
}

- (void)GET:(NSString *)getURL parameters:(NSDictionary *)parameters options:(FSStatOptions *)statOptions sessionSettings:(NSDictionary *)sessionSettings completionHandler:(void (^)(FSMetadata *metadata, NSError *error))completionHandler {
    AFHTTPSessionManager *httpManager = [self httpSessionManagerWithBaseURL:sessionSettings[FSSessionSettingsBaseURL] andPOSTURIParameters:[sessionSettings[FSSessionSettingsURIParams] boolValue]];
    [httpManager GET:getURL parameters:parameters progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        FSMetadata *metadata = [[FSMetadata alloc] initWithDictionary:(NSDictionary *)responseObject];
        completionHandler(metadata, nil);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        completionHandler(nil, error);
    }];
}

- (void)DELETE:(NSString *)deleteURL parameters:(NSDictionary *)parameters completionHandler:(void (^)(NSError *error))completionHandler {
    AFHTTPSessionManager *httpManager = [self httpSessionManagerWithBaseURL:nil andPOSTURIParameters:NO];
    // Filestack API returns a simple "success" string for successful delete request.
    // We need responseSerializer to be AFHTTPResponseSerializer to parse this properly instead of
    // returning false error.
    httpManager.responseSerializer = [AFHTTPResponseSerializer serializer];

    [httpManager DELETE:deleteURL parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        completionHandler(nil);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        completionHandler(error);
    }];
}

- (void)addHeadersToRequest:(NSMutableURLRequest *)request withMimeType:(NSString *)mimeType andFileName:(NSString *)fileName {
    [request setValue:mimeType forHTTPHeaderField:@"Content-Type"];

    if (fileName) {
        [request setValue:fileName forHTTPHeaderField:@"X-File-Name"];
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
        managerBaseURL = [NSURL URLWithString:FSURLBaseURL];
    }
    AFHTTPSessionManager *httpManager = [[AFHTTPSessionManager alloc] initWithBaseURL:managerBaseURL sessionConfiguration:configuration];
    httpManager.requestSerializer = [AFHTTPRequestSerializer serializer];
    if (postUriParameters) {
        httpManager.requestSerializer.HTTPMethodsEncodingParametersInURI = [NSSet setWithArray:@[@"POST", @"GET", @"HEAD", @"DELETE"]];
    }
    return httpManager;
}

@end
