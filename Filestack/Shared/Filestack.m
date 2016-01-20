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

@interface Filestack()

@property (nonatomic, strong) NSString *apiKey;
@property (nonatomic, strong) NSString *fsBaseURL;
@property (nonatomic, weak) id<FSFilestackDelegate> delegate;

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

- (void)pickWithURL:(NSString *)url completionHandler:(void (^)(FSBlob *blob, NSError *error))completionHandler {
    AFHTTPSessionManager *httpManager = [self httpSessionManagerWithBaseURL:nil];
    NSDictionary *parameters = @{@"key": @"A2sIbglHtSdG3DlVpozOKz", @"url": url};

    [httpManager POST:FSURLPickPath parameters:parameters progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        NSLog(@"pick response: %@", responseObject);
        FSBlob *blob = [[FSBlob alloc] initWithDictionary:(NSDictionary *)responseObject];
        completionHandler(blob, nil);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"pick error: %@", error);
        completionHandler(nil, error);
    }];
}

- (void)stat:(FSBlob *)blob withOptions:(FSStatOptions *)statOptions completionHandler:(void (^)(FSMetadata *metadata, NSError *error))completionHandler {
    AFHTTPSessionManager *httpManager = [self httpSessionManagerWithBaseURL:blob.url];
    NSString *blobHandle = [[NSURL URLWithString:blob.url] lastPathComponent];
    NSString *combinedPath = [NSString stringWithFormat:@"/%@%@", blobHandle, FSURLMetadataPath];
    NSDictionary *parameters = [statOptions toQueryParameters];

    [httpManager GET:combinedPath parameters:parameters progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        NSLog(@"metadata response: %@", responseObject);
        FSMetadata *metadata = [[FSMetadata alloc] initWithDictionary:(NSDictionary *)responseObject];
        completionHandler(metadata, nil);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"metadata error: %@", error);
        completionHandler(nil, error);
    }];
}

- (AFHTTPSessionManager *)httpSessionManagerWithBaseURL:(NSString *)baseURL {
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURL *managerBaseURL;
    if (baseURL) {
        managerBaseURL = [NSURL URLWithString:baseURL];
    } else {
        managerBaseURL = [NSURL URLWithString:_fsBaseURL];
    }
    AFHTTPSessionManager *httpManager = [[AFHTTPSessionManager alloc] initWithBaseURL:managerBaseURL sessionConfiguration:configuration];
    httpManager.requestSerializer = [AFHTTPRequestSerializer serializer];
    httpManager.requestSerializer.HTTPMethodsEncodingParametersInURI = [NSSet setWithArray:@[@"POST", @"GET", @"HEAD", @"DELETE"]];

    return httpManager;
}

@end
