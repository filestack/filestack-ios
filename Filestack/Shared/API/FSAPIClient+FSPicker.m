//
//  FSAPIClient+FSPicker.m
//  Filestack
//
//  Created by Łukasz Cichecki on 14/03/16.
//  Copyright © 2016 Filestack. All rights reserved.
//

#import "FSAPIClient+FSPicker.h"
#import "FSAPIURL.h"
#import <AFNetworking/AFNetworking.h>

@implementation FSAPIClient (FSPicker)

- (void)GETContent:(NSString *)getURL parameters:(NSDictionary *)parameters sessionSettings:(FSSessionSettings *)sessionSettings completionHandler:(void (^)(NSDictionary *responseJSON, NSError *error))completionHandler {
    AFHTTPSessionManager *httpManager = [self fsPickerHttpSessionManagerWithBaseURL:sessionSettings.baseURL andPOSTURIParameters:sessionSettings.paramsInURI];

    [httpManager GET:getURL parameters:parameters progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        NSDictionary *responseJSON = (NSDictionary *)responseObject;
        if (completionHandler) {
            completionHandler(responseJSON, nil);
        }
        [httpManager invalidateSessionCancelingTasks:YES];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (completionHandler) {
            completionHandler(nil, error);
        }
        [httpManager invalidateSessionCancelingTasks:YES];
    }];
}

- (void)LOGOUT:(NSString *)logoutURL parameters:(NSDictionary *)parameters completionHandler:(void (^)(NSError *error))completionHandler {
    AFHTTPSessionManager *httpManager = [[AFHTTPSessionManager alloc] init];

    [httpManager GET:logoutURL parameters:nil progress:nil success:^(NSURLSessionDataTask * task, id responseObject) {
        if (completionHandler) {
            completionHandler(nil);
        }
        [httpManager invalidateSessionCancelingTasks:YES];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (completionHandler) {
            completionHandler(error);
        }
        [httpManager invalidateSessionCancelingTasks:YES];
    }];
}

- (AFHTTPSessionManager *)fsPickerHttpSessionManagerWithBaseURL:(NSString *)baseURL andPOSTURIParameters:(BOOL)postUriParameters {
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