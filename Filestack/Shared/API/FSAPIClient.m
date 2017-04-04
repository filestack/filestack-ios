//
//  FSAPIClient.m
//  Filestack
//
//  Created by Łukasz Cichecki on 28/01/16.
//  Copyright © 2016 Filestack. All rights reserved.
//

#import "FSAPIClient.h"
#import "FSAPIURL.h"
#import "FSMetadata+Private.h"
#import <AFNetworkActivityLogger/AFNetworkActivityLogger.h>
#import <AFNetworkActivityLogger/AFNetworkActivityConsoleLogger.h>


@implementation FSAPIClient

- (void) startLogging {
    AFNetworkActivityConsoleLogger *consoleLogger = [AFNetworkActivityConsoleLogger new];
    [consoleLogger setLevel:AFLoggerLevelDebug];
    [[AFNetworkActivityLogger sharedLogger] removeLogger:[[[AFNetworkActivityLogger sharedLogger] loggers] anyObject]];
    [[AFNetworkActivityLogger sharedLogger] addLogger:consoleLogger];
    //[[AFNetworkActivityLogger sharedLogger] startLogging];
}

- (NSURLSessionUploadTask*)PUT:(NSString *)postURL
    formdata:(NSDictionary *)form
        data:(NSData*)data
progress:(void (^)(NSProgress *uploadProgress))progress
completionHandler:(void (^)(NSDictionary *response, NSError *error))completionHandler {
    [self startLogging];

    AFURLSessionManager *manager = [[AFURLSessionManager alloc] init];
    AFHTTPRequestSerializer *serializer = [AFHTTPRequestSerializer serializer];
    NSMutableURLRequest *request = [serializer requestWithMethod:@"PUT" URLString:postURL parameters:nil error:nil];
    for (id key in form) {
        [request setValue:form[key] forHTTPHeaderField:key];
    }
    NSString *dataLength = [NSString stringWithFormat:@"%ld", [data length]];
    [request setValue:dataLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"*/*" forHTTPHeaderField:@"Accept"];
    [request setValue:nil forHTTPHeaderField:@"Content-Type"];
    
    NSURLSessionUploadTask *uploadTask = [manager uploadTaskWithRequest:request fromData:data progress:^(NSProgress * _Nonnull uploadProgress) {
        if (progress) {
            progress(uploadProgress);
        }
    } completionHandler:^(NSURLResponse *response, id  responseObject, NSError *error) {
        [manager invalidateSessionCancelingTasks:YES];
        if (error) {
            NSString* ErrorResponse = [[NSString alloc] initWithData:(NSData *)error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:NSUTF8StringEncoding];
            NSLog(@"%@",ErrorResponse);
            completionHandler(nil, error);
        } else {
            // NSLog(@"%@ %@", response, responseObject);
            NSHTTPURLResponse *response2 = (NSHTTPURLResponse *)response;
            NSDictionary *headers = [response2 allHeaderFields];
            // NSLog(@"HEADERS : %@",[headers description]);
            completionHandler(headers, nil);
        }
    }];
    [uploadTask resume];
    return uploadTask;
}

// This version returns an NSDictionary object
- (void)POST:(NSString *)postURL
    formdata:(NSDictionary *)form
        data:(NSData*)data
     options:(FSStoreOptions *)storeOptions
sessionSettings:(FSSessionSettings *)sessionSettings
completionHandler:(void (^)(NSDictionary *response, NSError *error))completionHandler {
    [self startLogging];
    AFHTTPSessionManager *httpManager = [self httpSessionManagerWithBaseURL:sessionSettings.baseURL
                                                       andPOSTURIParameters:sessionSettings.paramsInURI];
    
    [httpManager POST:postURL
           parameters:nil
constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
    if(data) {
        [formData appendPartWithFileData:data
                                    name:@"files"
                                fileName:form[@"filename"]
                                mimeType:form[@"mimetype"]];
    }
    
    for (id key in form) {
        if (!(data && ([key isEqualToString:@"filename"] ||
                     [key isEqualToString:@"mimetype"]))) {
            [formData appendPartWithFormData:[[form objectForKey:key] dataUsingEncoding:NSUTF8StringEncoding]
                                    name:key];
        }
    }
}
             progress:nil
              success:^(NSURLSessionDataTask *task, id responseObject) {
                  [httpManager invalidateSessionCancelingTasks:YES];
                  NSDictionary *response = [[NSDictionary alloc]
                                            initWithDictionary:(NSDictionary *)responseObject];
                  completionHandler(response, nil);
              }
              failure:^(NSURLSessionDataTask *task, NSError *error) {
                  NSString* ErrorResponse = [[NSString alloc] initWithData:(NSData *)error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:NSUTF8StringEncoding];
                  NSLog(@"%@",ErrorResponse);
                  
                  [httpManager invalidateSessionCancelingTasks:YES];
                  completionHandler(nil, error);
              }];
}

// This version returns a FSBlob object
- (void)POST:(NSString *)postURL parameters:(NSDictionary *)parameters
        options:(FSStoreOptions *)storeOptions
        sessionSettings:(FSSessionSettings *)sessionSettings
        completionHandler:(void (^)(FSBlob *blob, NSError *error))completionHandler {
    //[self startLogging];
    AFHTTPSessionManager *httpManager = [self httpSessionManagerWithBaseURL:sessionSettings.baseURL
                                                       andPOSTURIParameters:sessionSettings.paramsInURI];
    httpManager.requestSerializer = [AFJSONRequestSerializer serializer];
    [httpManager POST:postURL
           parameters:parameters
             progress:nil
              success:^(NSURLSessionDataTask *task, id responseObject) {
                  [httpManager invalidateSessionCancelingTasks:YES];
                  FSBlob *blob = [[FSBlob alloc] initWithDictionary:(NSDictionary *)responseObject];
                  completionHandler(blob, nil);
              }
              failure:^(NSURLSessionDataTask *task, NSError *error) {
                  [httpManager invalidateSessionCancelingTasks:YES];
                  completionHandler(nil, error);
              }];
}

- (void)POST:(NSString *)postURL
    withData:(NSData *)data parameters:(NSDictionary *)parameters
multipartOptions:(FSStoreOptions *)storeOptions
    progress:(void (^)(NSProgress *uploadProgress))progress
completionHandler:(void (^)(FSBlob *blob, NSError *error))completionHandler {
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] init];
    AFHTTPRequestSerializer *serializer = [AFHTTPRequestSerializer serializer];
    serializer.HTTPMethodsEncodingParametersInURI = [NSSet setWithArray:@[@"POST", @"GET", @"HEAD", @"DELETE"]];
    NSMutableURLRequest *request = [serializer requestWithMethod:@"POST" URLString:postURL parameters:parameters error:nil];
    NSString *mimeType = [self mimeTypeForStoreOptions:storeOptions];
    [self addHeadersToRequest:request withMimeType:mimeType andFileName:storeOptions.fileName];

    NSURLSessionUploadTask *uploadTask = [manager uploadTaskWithRequest:request fromData:data progress:^(NSProgress * _Nonnull uploadProgress) {
        if (progress) {
            progress(uploadProgress);
        }
    } completionHandler:^(NSURLResponse *response, id  responseObject, NSError *error) {
        [manager invalidateSessionCancelingTasks:YES];
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
    AFHTTPSessionManager *httpManager = [[AFHTTPSessionManager alloc] init];
    httpManager.responseSerializer = [AFHTTPResponseSerializer serializer];

    [httpManager GET:getURL parameters:parameters progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        NSData *responseData = [NSData dataWithData:responseObject];
        completionHandler(responseData, nil);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        completionHandler(nil, error);
    }];
}

- (void)GET:(NSString *)getURL parameters:(NSDictionary *)parameters sessionSettings:(FSSessionSettings *)sessionSettings completionHandler:(void (^)(FSMetadata *metadata, NSError *error))completionHandler {
    AFHTTPSessionManager *httpManager = [self httpSessionManagerWithBaseURL:sessionSettings.baseURL andPOSTURIParameters:sessionSettings.paramsInURI];
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

#pragma mark - Helper methods

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
    NSURL *managerBaseURL;
    if (baseURL) {
        managerBaseURL = [NSURL URLWithString:baseURL];
    } else {
        managerBaseURL = [NSURL URLWithString:FSURLBaseURL];
    }
    AFHTTPSessionManager *httpManager = [[AFHTTPSessionManager alloc] initWithBaseURL:managerBaseURL];
    httpManager.requestSerializer = [AFHTTPRequestSerializer serializer];
    if (postUriParameters) {
        httpManager.requestSerializer.HTTPMethodsEncodingParametersInURI = [NSSet setWithArray:@[@"POST", @"GET", @"HEAD", @"DELETE"]];
    }
    return httpManager;
}

@end
