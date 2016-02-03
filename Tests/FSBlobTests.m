//
//  FSBlobTests.m
//  Filestack
//
//  Created by Łukasz Cichecki on 03/02/16.
//  Copyright © 2016 Filestack. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "FSBlob.h"

@interface FSBlobTests : XCTestCase

@end

@implementation FSBlobTests

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testInitWithDictionary {
    NSDictionary *dict = @{@"url": @"http://example.com",
                           @"filename": @"test",
                           @"mimetype": @"image/png",
                           @"size": @12345678910,
                           @"key": @"test-key",
                           @"container": @"test-container",
                           @"path": @"test-path",
                           @"writeable": @1
                           };

    NSString *s3url = [NSString stringWithFormat:@"https://%@.s3.amazonaws.com/%@", dict[@"container"], dict[@"key"]];
    FSBlob *blob = [[FSBlob alloc] initWithDictionary:dict];
    XCTAssertEqualObjects(blob.url, dict[@"url"]);
    XCTAssertEqualObjects(blob.fileName, dict[@"filename"]);
    XCTAssertEqualObjects(blob.mimeType, dict[@"mimetype"]);
    XCTAssertEqual(blob.size, [dict[@"size"] integerValue]);
    XCTAssertEqualObjects(blob.key, dict[@"key"]);
    XCTAssertEqualObjects(blob.container, dict[@"container"]);
    XCTAssertEqualObjects(blob.path, dict[@"path"]);
    XCTAssertEqualObjects(blob.writeable, dict[@"writeable"]);
    XCTAssertEqualObjects(blob.s3url, s3url);
}

- (void)testInitWithURL {
    FSBlob *blob = [[FSBlob alloc] initWithURL:@"http://example.com"];
    XCTAssertEqualObjects(blob.url, @"http://example.com");
    XCTAssertNil(blob.fileName);
    XCTAssertNil(blob.mimeType);
    XCTAssertEqual(blob.size, 0);
    XCTAssertNil(blob.key);
    XCTAssertNil(blob.container);
    XCTAssertNil(blob.path);
    XCTAssertNil(blob.writeable);
}

- (void)testWriteableFalse {
    FSBlob *blob = [[FSBlob alloc] initWithDictionary:@{@"writeable": @0}];
    XCTAssertEqualObjects(blob.writeable, @0);
}

- (void)testWriteableTrue {
    FSBlob *blob = [[FSBlob alloc] initWithDictionary:@{@"writeable": @1}];
    XCTAssertEqualObjects(blob.writeable, @1);
}

- (void)testWriteableNil {
    FSBlob *blob = [[FSBlob alloc] initWithDictionary:@{}];
    XCTAssertNil(blob.writeable);
}

- (void)testS3UrlNilNoContainer {
    NSDictionary *dict = @{@"url": @"http://example.com",
                           @"filename": @"test",
                           @"mimetype": @"image/png",
                           @"size": @12345678910,
                           @"key": @"test-key",
                           @"path": @"test-path",
                           @"writeable": @1
                           };

    FSBlob *blob = [[FSBlob alloc] initWithDictionary:dict];
    XCTAssertNil(blob.s3url);
}

- (void)testS3UrlNilNoKey {
    NSDictionary *dict = @{@"url": @"http://example.com",
                           @"filename": @"test",
                           @"mimetype": @"image/png",
                           @"size": @12345678910,
                           @"container": @"test-container",
                           @"path": @"test-path",
                           @"writeable": @1
                           };

    FSBlob *blob = [[FSBlob alloc] initWithDictionary:dict];
    XCTAssertNil(blob.s3url);
}

@end
