//
//  FSTransformationTests.m
//  Filestack
//
//  Created by Łukasz Cichecki on 18/02/16.
//  Copyright © 2016 Filestack. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "FSTransformation.h"
#import "FSTransform+Private.h"
#import "FSSecurity+Private.h"

@interface FSTransformationTests : XCTestCase

@property (nonatomic, copy) NSString *apiKey;
@property (nonatomic, copy) NSString *testURL;
@property (nonatomic, copy) NSString *processURL;
@property (nonatomic, strong) FSSecurity *security;

@end

@implementation FSTransformationTests

- (void)setUp {
    [super setUp];
    _apiKey = @"APIKEY";
    _testURL = @"https://example.com/example.png";
    _security = [[FSSecurity alloc] initWithPolicy:@"testpolicy" signature:@"testsignature"];
    _processURL = @"https://process.filestackapi.com";
}

- (void)tearDown {

    [super tearDown];
}

- (void)testInitWithQueryString {
    FSResize *resize = [[FSResize alloc] initWithWidth:@100 height:@100 fit:FSResizeFitScale];
    NSString *resizeQuery = [resize toQuery];
    FSTransformation *transformation = [[FSTransformation alloc] initWithQueryString:resizeQuery];

    NSString *expectedURL = [NSString stringWithFormat:@"%@/%@/%@/%@/%@", _processURL, _apiKey, [resize toQuery], [_security toQuery], _testURL];
    XCTAssertEqualObjects([transformation transformationURLWithApiKey:_apiKey security:_security URLToTransform:_testURL], expectedURL);
}

- (void)testAddMethod {
    FSResize *resize = [[FSResize alloc] initWithWidth:@100 height:@100 fit:FSResizeFitScale];
    FSTransformation *transformation = [[FSTransformation alloc] init];
    [transformation add:resize];

    NSString *expectedURL = [NSString stringWithFormat:@"%@/%@/%@/%@/%@", _processURL, _apiKey, [resize toQuery], [_security toQuery], _testURL];
    XCTAssertEqualObjects([transformation transformationURLWithApiKey:_apiKey security:_security URLToTransform:_testURL], expectedURL);

    FSCrop *crop = [[FSCrop alloc] initWithX:@1 y:@1 width:@1 height:@1];
    [transformation add:crop];

    expectedURL = [NSString stringWithFormat:@"%@/%@/%@/%@/%@/%@", _processURL, _apiKey, [resize toQuery], [_security toQuery], [crop toQuery], _testURL];
    XCTAssertEqualObjects([transformation transformationURLWithApiKey:_apiKey security:_security URLToTransform:_testURL], expectedURL);
}

- (void)testWillReturnJSONDetectFaces {
    FSDetectFaces *detectFaces = [[FSDetectFaces alloc] initWithExportToJSON];
    FSTransformation *transformation = [[FSTransformation alloc] init];
    [transformation add:detectFaces];
    XCTAssertTrue([transformation willReturnJSON]);
}

- (void)testWillReturnJSONOutput {
    FSOutput *output = [[FSOutput alloc] initWithDocInfo];
    FSTransformation *transformation = [[FSTransformation alloc] init];
    [transformation add:output];
    XCTAssertTrue([transformation willReturnJSON]);
}

- (void)testWillReturnJSONDebug {
    FSTransformation *transformation = [[FSTransformation alloc] init];
    transformation.debug = YES;
    XCTAssertTrue([transformation willReturnJSON]);
}

- (void)testNilTranformationQuery {
    FSBlob *blob = [[FSBlob alloc] init];
    FSWatermark *watermark = [[FSWatermark alloc] initWithBlob:blob size:nil position:nil];
    FSTransformation *transformation = [[FSTransformation alloc] init];
    [transformation add:watermark];
    NSString *expectedURL = [NSString stringWithFormat:@"%@/%@//%@", _processURL, _apiKey, _testURL];
    XCTAssertEqualObjects([transformation transformationURLWithApiKey:_apiKey security:nil URLToTransform:_testURL], expectedURL);
}

- (void)testDebug {
    FSResize *resize = [[FSResize alloc] initWithWidth:@100 height:@100 fit:FSResizeFitScale];
    FSTransformation *transformation = [[FSTransformation alloc] init];
    [transformation add:resize];

    transformation.debug = YES;

    FSCrop *crop = [[FSCrop alloc] initWithX:@1 y:@1 width:@1 height:@1];
    [transformation add:crop];

    NSString *expectedURL = [NSString stringWithFormat:@"%@/%@/%@/%@/%@/%@/%@", _processURL, _apiKey, @"debug", [resize toQuery], [crop toQuery], [_security toQuery], _testURL];
    XCTAssertEqualObjects([transformation transformationURLWithApiKey:_apiKey security:_security URLToTransform:_testURL], expectedURL);
}

@end
