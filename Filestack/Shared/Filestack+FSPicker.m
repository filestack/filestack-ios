//
//  Filestack+FSPicker.m
//  Filestack
//
//  Created by Łukasz Cichecki on 09/03/16.
//  Copyright © 2016 Filestack. All rights reserved.
//

#import "Filestack+FSPicker.h"
#import "FSAPIClient+FSPicker.h"
#import "FSSessionSettings.h"
#import "FSAPIURL.h"

@implementation Filestack (FSPicker)

+ (void)pickFSURL:(NSString *)fsURL parameters:(NSDictionary *)parameters completionHandler:(void (^)(FSBlob *blob, NSError *error))completionHandler {
    FSAPIClient *apiClient = [[FSAPIClient alloc] init];
    FSSessionSettings *sessionSettings = [[FSSessionSettings alloc] init];
    sessionSettings.paramsInURI = YES;
    NSString *pickURL = [NSString stringWithFormat:@"%@%@%@", FSURLBaseURL, FSURLContentPath, fsURL];

    [apiClient GETContent:pickURL parameters:parameters sessionSettings:sessionSettings completionHandler:^(NSDictionary *responseJSON, NSError *error) {
        if (completionHandler) {
            if (error) {
                completionHandler(nil, error);
            } else {
                FSBlob *blob = [[FSBlob alloc] initWithDictionary:responseJSON];
                completionHandler(blob, nil);
            }
        }
    }];
}

+ (void)getContentForPath:(NSString *)contentPath parameters:(NSDictionary *)parameters completionHandler:(void (^)(NSDictionary *responseJSON, NSError *error))completionHandler {
    FSAPIClient *apiClient = [[FSAPIClient alloc] init];
    NSString *contentUrl = [NSString stringWithFormat:@"%@%@%@", FSURLBaseURL, FSURLContentPath, contentPath];
    FSSessionSettings *sessionSettings = [[FSSessionSettings alloc] init];
    sessionSettings.paramsInURI = YES;

    [apiClient GETContent:contentUrl parameters:parameters sessionSettings:sessionSettings completionHandler:^(NSDictionary *responseJSON, NSError *error) {
        if (completionHandler) {
            if (!error) {
                completionHandler(responseJSON, error);
            } else {
                completionHandler(nil, error);
            }
        }
    }];
}

+ (void)logoutFromSource:(NSString *)sourceIdentifier externalDomains:(NSArray *)externalDomains parameters:(NSDictionary *)parameters completionHandler:(void (^)(NSError *error))completionHandler {
    FSAPIClient *apiClient = [[FSAPIClient alloc] init];
    NSString *logoutUrl = [NSString stringWithFormat:@"%@%@/%@/unauth", FSURLBaseURL, FSURLClientPath, sourceIdentifier];

    [apiClient LOGOUT:logoutUrl parameters:parameters completionHandler:^(NSError *error) {
        if (completionHandler) {
            if (!error) {
                [[self class] clearCookiesForDomains:externalDomains];
            }
            completionHandler(error);
        }
    }];
}

+ (void)clearCookiesForDomains:(NSArray *)domains {
    NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];

    for (NSString *urlString in domains) {
        NSURL *URL = [NSURL URLWithString:urlString];
        NSArray *siteCookies = [cookieStorage cookiesForURL:URL];

        for (NSHTTPCookie *cookie in siteCookies) {
            [cookieStorage deleteCookie:cookie];
        }
    }
}

@end
