//
//  FilestackTests.m
//  FilestackTests
//
//  Created by Łukasz Cichecki on 26/01/16.
//  Copyright © 2016 Filestack. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OHHTTPStubs/OHHTTPStubs.h>
#import "Filestack.h"

@interface FilestackTests : XCTestCase

@property (nonatomic, strong) Filestack *filestack;
@property (nonatomic, strong) NSString *apiKey;
@property (nonatomic, strong) FSBlob *sampleBlob;

@end

@implementation FilestackTests

- (void)setUp {
    [super setUp];
    _apiKey = @"APIKEY";
    _filestack = [[Filestack alloc] initWithApiKey:_apiKey];
    _sampleBlob = [[FSBlob alloc] initWithURL:@"https://cdn.filestackcontent.com/filehandler"];
}

- (void)tearDown {
    [OHHTTPStubs removeAllStubs];
    [super tearDown];
}

- (void)testPickValidURLQuery{
    XCTestExpectation* responseArrived = [self expectationWithDescription:@"Valid URL"];
    __block FSBlob *responseBlob;

    NSString *url = @"https://example.com/image.png";
    NSString *expectedURL = [self expectedURLWithKey:_apiKey url:url storeOptions:nil  andMethod:@"pick"];

    [self setupStubsWithExpectedURL:expectedURL respondWithError:NO andHTTPMethod:@"POST"];

    [_filestack pickURL:url completionHandler:^(FSBlob *blob, NSError *error) {
        responseBlob = blob;
        [responseArrived fulfill];
    }];
    [self waitForExpectationsWithTimeout:5 handler:^(NSError * _Nullable error) {
        XCTAssertNotNil(responseBlob);
    }];
}

- (void)testRemoveValidURLQuery {
    XCTestExpectation* responseArrived = [self expectationWithDescription:@"Valid URL"];
    NSString *expectedURL = [self expectedURLWithKey:_apiKey url:_sampleBlob.url storeOptions:nil  andMethod:@"remove"];

    [self setupStubsWithExpectedURL:expectedURL respondWithError:NO andHTTPMethod:@"DELETE"];

    [_filestack remove:_sampleBlob completionHandler:^(NSError *error) {
        [responseArrived fulfill];
    }];

    [self waitForExpectationsWithTimeout:5 handler:^(NSError * _Nullable error) {
    }];
}

- (void)testDownloadValidURLQuery {
    XCTestExpectation* responseArrived = [self expectationWithDescription:@"Valid URL"];
    __block NSData *responseData;

    NSString *expectedURL = [self expectedURLWithKey:_apiKey url:_sampleBlob.url storeOptions:nil andMethod:@"download"];

    [self setupStubsWithExpectedURL:expectedURL respondWithError:NO andHTTPMethod:@"GET"];

    [_filestack download:_sampleBlob completionHandler:^(NSData *data, NSError *error) {
        responseData = data;
        [responseArrived fulfill];
    }];

    [self waitForExpectationsWithTimeout:5 handler:^(NSError * _Nullable error) {
        XCTAssertNotNil(responseData);
    }];
}

- (void)testStoreURLValidURLQuery {
    XCTestExpectation* responseArrived = [self expectationWithDescription:@"Valid URL"];
    __block FSBlob *responseBlob;

    NSString *url = @"https://example.com/image.png";
    FSStoreOptions *storeOptions = [[FSStoreOptions alloc] initWithDictionary:@{@"location": FSStoreLocationDropbox}];
    NSString *expectedURL = [self expectedURLWithKey:_apiKey url:url storeOptions:storeOptions andMethod:@"storeURL"];

    [self setupStubsWithExpectedURL:expectedURL respondWithError:NO andHTTPMethod:@"POST"];

    [_filestack storeURL:url withOptions:storeOptions completionHandler:^(FSBlob *blob, NSError *error) {
        responseBlob = blob;
        [responseArrived fulfill];
    }];

    [self waitForExpectationsWithTimeout:5 handler:^(NSError * _Nullable error) {
        XCTAssertNotNil(responseBlob);
    }];
}

- (void)testStoreValidURLQuery {
    XCTestExpectation* responseArrived = [self expectationWithDescription:@"Valid URL"];
    __block FSBlob *responseBlob;

    NSData *dataToStore = [NSData data];
    FSStoreOptions *storeOptions = [[FSStoreOptions alloc] initWithDictionary:@{@"location": FSStoreLocationDropbox, @"path": @"test/"}];
    NSString *expectedURL = [self expectedURLWithKey:_apiKey url:@"" storeOptions:storeOptions andMethod:@"store"];

    [self setupStubsWithExpectedURL:expectedURL respondWithError:NO andHTTPMethod:@"POST"];

    [_filestack store:dataToStore withOptions:storeOptions completionHandler:^(FSBlob *blob, NSError *error) {
        responseBlob = blob;
        [responseArrived fulfill];
    }];

    [self waitForExpectationsWithTimeout:5 handler:^(NSError * _Nullable error) {
        XCTAssertNotNil(responseBlob);
    }];
}

- (void)testStatValidURLQuery {
    XCTestExpectation* responseArrived = [self expectationWithDescription:@"Valid URL"];
    __block FSMetadata *responseMetadata;

    NSString *expectedURL = [self expectedURLWithKey:_apiKey url:_sampleBlob.url storeOptions:nil andMethod:@"stat"];

    [self setupStubsWithExpectedURL:expectedURL respondWithError:NO andHTTPMethod:@"GET"];

    [_filestack stat:_sampleBlob withOptions:nil completionHandler:^(FSMetadata *metadata, NSError *error) {
        responseMetadata = metadata;
        [responseArrived fulfill];
    }];

    [self waitForExpectationsWithTimeout:5 handler:^(NSError * _Nullable error) {
        XCTAssertNotNil(responseMetadata);
    }];
}

- (NSString *)expectedURLWithKey:(NSString *)key url:(NSString *)url storeOptions:(FSStoreOptions *)storeOptions andMethod:(NSString *)method {
    if ([method isEqualToString:@"stat"]) {
        NSString *fileHandler = [[NSURL URLWithString:url] lastPathComponent];
        return [NSString stringWithFormat:@"https://cdn.filestackcontent.com/%@/metadata", fileHandler];
    } else if ([method isEqualToString:@"store"]) {
        return [NSString stringWithFormat:@"https://www.filestackapi.com/api/store/dropbox?key=%@", _apiKey];
    } else if ([method isEqualToString:@"storeURL"]) {
        NSString *encodedURL = [self AFNetworkingEncodedURL:url];
        return [NSString stringWithFormat:@"https://www.filestackapi.com/api/store/%@?key=%@&url=%@", storeOptions.location, _apiKey, encodedURL];
    } else if ([method isEqualToString:@"remove"]) {
        NSString *fileHandler = [[NSURL URLWithString:url] lastPathComponent];
        return [NSString stringWithFormat:@"https://www.filestackapi.com/api/file/%@?key=%@", fileHandler, _apiKey];
    } else if ([method isEqualToString:@"download"]) {
        return url;
    } else {
        NSString *encodedURL = [self AFNetworkingEncodedURL:url];
        return [NSString stringWithFormat:@"https://www.filestackapi.com/api/%@?key=%@&url=%@", method, key, encodedURL];
    }
}

- (NSString *)AFNetworkingEncodedURL:(NSString *)urlToEncode {
    // AFNetworking encoding character set.
    NSCharacterSet *set = [[NSCharacterSet characterSetWithCharactersInString:@":#[]@"] invertedSet];
    NSString *encodedURL = [urlToEncode stringByAddingPercentEncodingWithAllowedCharacters:set];
    return encodedURL;
}

- (void)setupStubsWithExpectedURL:(NSString *)expectedURL respondWithError:(BOOL)respondWithError andHTTPMethod:(NSString *)httpMethod {
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest * _Nonnull request) {
        XCTAssertEqualObjects(request.HTTPMethod, httpMethod);
        XCTAssertEqualObjects([request.URL absoluteString], expectedURL);
        return YES;
    } withStubResponse:^OHHTTPStubsResponse * _Nonnull(NSURLRequest * _Nonnull request) {
        return [OHHTTPStubsResponse responseWithData:[NSData data] statusCode:200 headers:nil];
    }];
}

@end
