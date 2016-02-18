//
//  FSStatOptionsTests.m
//  Filestack
//
//  Created by Łukasz Cichecki on 18/02/16.
//  Copyright © 2016 Filestack. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "FSStatOptions.h"

@interface FSStatOptionsTests : XCTestCase

@end

@implementation FSStatOptionsTests

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testInitWithDictionary {
    NSDictionary *dictionary = @{@"size": @YES, @"mimetype": @YES, @"filename": @YES, @"width": @YES,
                                 @"height": @YES, @"uploaded": @YES, @"writeable": @YES, @"md5": @YES,
                                 @"location": @YES, @"path": @YES, @"container": @YES};
    FSStatOptions *statOptions = [[FSStatOptions alloc] initWithDictionary:dictionary];

    XCTAssertTrue(statOptions.size);
    XCTAssertTrue(statOptions.mimeType);
    XCTAssertTrue(statOptions.fileName);
    XCTAssertTrue(statOptions.width);
    XCTAssertTrue(statOptions.height);
    XCTAssertTrue(statOptions.uploaded);
    XCTAssertTrue(statOptions.writeable);
    XCTAssertTrue(statOptions.md5);
    XCTAssertTrue(statOptions.location);
    XCTAssertTrue(statOptions.path);
    XCTAssertTrue(statOptions.container);
}

- (void)testToQueryParametersMethod {
    NSDictionary *dictionary = @{@"size": @YES, @"mimetype": @YES, @"filename": @YES, @"width": @YES,
                                 @"height": @YES, @"uploaded": @YES, @"writeable": @YES, @"md5": @YES,
                                 @"location": @YES, @"path": @YES, @"container": @YES};
    FSStatOptions *statOptions = [[FSStatOptions alloc] initWithDictionary:dictionary];
    NSDictionary *queryParameters = [statOptions toQueryParameters];

    XCTAssertEqualObjects(@"true", queryParameters[@"size"]);
    XCTAssertEqualObjects(@"true", queryParameters[@"mimetype"]);
    XCTAssertEqualObjects(@"true", queryParameters[@"filename"]);
    XCTAssertEqualObjects(@"true", queryParameters[@"width"]);
    XCTAssertEqualObjects(@"true", queryParameters[@"height"]);
    XCTAssertEqualObjects(@"true", queryParameters[@"uploaded"]);
    XCTAssertEqualObjects(@"true", queryParameters[@"writeable"]);
    XCTAssertEqualObjects(@"true", queryParameters[@"md5"]);
    XCTAssertEqualObjects(@"true", queryParameters[@"location"]);
    XCTAssertEqualObjects(@"true", queryParameters[@"path"]);
    XCTAssertEqualObjects(@"true", queryParameters[@"container"]);
}

@end
