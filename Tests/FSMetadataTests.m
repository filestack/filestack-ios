//
//  FSMetadataTests.m
//  Filestack
//
//  Created by Łukasz Cichecki on 18/02/16.
//  Copyright © 2016 Filestack. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "FSMetadata.h"
#import "FSMetadata+Private.h"

@interface FSMetadataTests : XCTestCase

@end

@implementation FSMetadataTests

- (void)setUp {
    [super setUp];

}

- (void)tearDown {

    [super tearDown];
}

- (void)testInitWithDictionary {
    NSDictionary *dictionary = @{@"size": @18000.23, @"filename": @"test.png", @"width": @100.15,
                                 @"height": @100.56, @"uploaded": @1234567890, @"writeable": @1,
                                 @"md5": @"123md5AbC", @"location": @"S3", @"path": @"testpath",
                                 @"container": @"testcontainer", @"mimetype": @"image/png"};
    FSMetadata *metadata = [[FSMetadata alloc] initWithDictionary:dictionary];
    NSString *s3url = [NSString stringWithFormat:@"https://%@.s3.amazonaws.com/%@", dictionary[@"container"], dictionary[@"path"]];

    XCTAssertEqual(metadata.size, [dictionary[@"size"] integerValue]);
    XCTAssertEqual(metadata.width, [dictionary[@"width"] integerValue]);
    XCTAssertEqual(metadata.height, [dictionary[@"height"] integerValue]);
    XCTAssertEqual(metadata.uploaded, [dictionary[@"uploaded"] integerValue]);
    XCTAssertEqualObjects(metadata.writeable, dictionary[@"writeable"]);
    XCTAssertEqualObjects(metadata.md5, dictionary[@"md5"]);
    XCTAssertEqualObjects(metadata.fileName, dictionary[@"filename"]);
    XCTAssertEqualObjects(metadata.location, dictionary[@"location"]);
    XCTAssertEqualObjects(metadata.path, dictionary[@"path"]);
    XCTAssertEqualObjects(metadata.container, dictionary[@"container"]);
    XCTAssertEqualObjects(metadata.mimeType, dictionary[@"mimetype"]);
    XCTAssertEqualObjects(metadata.s3url, s3url);

    NSString *metadataDescription = [NSString stringWithFormat:@"\nsize: %ld\nfilename: %@\nmimetype: %@\nwidth: %ld\nheight: %ld\nuploaded: %ld\nwriteable: %@\nmd5: %@\nlocation: %@\npath: %@\ncontainer: %@\ns3url: %@",
                                     (long)metadata.size, metadata.fileName, metadata.mimeType, (long)metadata.width, (long)metadata.height, (long)metadata.uploaded,
                                     metadata.writeable, metadata.md5, metadata.location, metadata.path, metadata.container, metadata.s3url];

    XCTAssertEqualObjects(metadata.description, metadataDescription);

    metadata.path = nil;
    XCTAssertNil(metadata.s3url);
}

@end
