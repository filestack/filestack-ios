//
//  TransformationsTests.m
//  Filestack
//
//  Created by Łukasz Cichecki on 16/02/16.
//  Copyright © 2016 Filestack. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "FSTransformation.h"
#import "FSTransform.h"
#import "FSTransform+Private.h"
#import "FSResize.h"
#import "FSCrop.h"
#import "FSRotate.h"
#import "FSFlip.h"
#import "FSFlop.h"
#import "FSWatermark.h"
#import "FSCropFaces.h"
#import "FSDetectFaces.h"
#import "FSPixelateFaces.h"
#import "FSBlurFaces.h"
#import "FSRoundedCorners.h"
#import "FSPolaroid.h"
#import "FSTornEdges.h"
#import "FSShadow.h"
#import "FSCircle.h"
#import "FSBorder.h"
#import "FSSharpen.h"
#import "FSBlur.h"
#import "FSMonochrome.h"
#import "FSSepia.h"
#import "FSPixelate.h"
#import "FSOilPaint.h"
#import "FSModulate.h"
#import "FSPartialBlur.h"
#import "FSPartialPixelate.h"
#import "FSCollage.h"
#import "FSURLScreenshot.h"
#import "FSASCII.h"
#import "FSOutput.h"
#import "FSSecurity.h"

@interface TransformationsTests : XCTestCase

@end

@implementation TransformationsTests

- (void)setUp {
    [super setUp];

}

- (void)tearDown {

    [super tearDown];
}

- (void)testFSResize {
    FSResize *resize = [[FSResize alloc] initWithWidth:@300 height:@300 fit:FSResizeFitMax align:FSResizeAlignBottomRight];
    NSString *resizeQuery = [resize toQuery];
    XCTAssertEqualObjects(resizeQuery, @"resize=width:300,height:300,fit:max,align:[bottom,right]");

    FSResize *resize2 = [[FSResize alloc] initWithWidth:@100 height:@100 fit:FSResizeFitScale];
    NSString *resizeQuery2 = [resize2 toQuery];
    XCTAssertEqualObjects(resizeQuery2, @"resize=width:100,height:100,fit:scale");

    FSResize *resize3 = [[FSResize alloc] initWithWidth:@100 height:@400];
    NSString *resizeQuery3 = [resize3 toQuery];
    XCTAssertEqualObjects(resizeQuery3, @"resize=width:100,height:400");

    FSResize *resize4 = [[FSResize alloc] initWithWidth:@100];
    NSString *resizeQuery4 = [resize4 toQuery];
    XCTAssertEqualObjects(resizeQuery4, @"resize=width:100");

    FSResize *resize5 = [[FSResize alloc] initWithHeight:@100];
    NSString *resizeQuery5 = [resize5 toQuery];
    XCTAssertEqualObjects(resizeQuery5, @"resize=height:100");

    FSResize *resize6 = [[FSResize alloc] initWithHeight:nil];
    NSString *resizeQuery6 = [resize6 toQuery];
    XCTAssertNil(resizeQuery6);

    resize.fit = nil;
    resizeQuery = [resize toQuery];
    XCTAssertEqualObjects(resizeQuery, @"resize=width:300,height:300,align:[bottom,right]");

    resize.height = nil;
    resize.width = nil;
    resizeQuery = [resize toQuery];
    XCTAssertNil(resizeQuery);

    resize.height = @200.5;
    resizeQuery = [resize toQuery];
    XCTAssertEqualObjects(resizeQuery, @"resize=height:200,align:[bottom,right]");

    resize.align = FSResizeAlignFaces;
    resizeQuery = [resize toQuery];
    XCTAssertEqualObjects(resizeQuery, @"resize=height:200,align:faces");
}

- (void)testFSRotate {
    FSRotate *rotate = [[FSRotate alloc] initWithDegrees:@150.9 background:@"red" rotateToEXIF:NO resetEXIF:NO];
    NSString *rotateQuery = [rotate toQuery];
    XCTAssertEqualObjects(rotateQuery, @"rotate=deg:150,background:red");

    rotate.toEXIF = YES;
    rotate.resetEXIF = YES;
    rotateQuery = [rotate toQuery];
    XCTAssertEqualObjects(rotateQuery, @"rotate=deg:exif,exif:false,background:red");
}

- (void)testFSFlip {
    FSFlip *flip = [[FSFlip alloc] init];
    NSString *flipQuery = [flip toQuery];
    XCTAssertEqualObjects(flipQuery, @"flip");
}

- (void)testFSFlop {
    FSFlop *flop = [[FSFlop alloc] init];
    NSString *flopQuery = [flop toQuery];
    XCTAssertEqualObjects(flopQuery, @"flop");
}

- (void)testFSWatermark {
    FSBlob *blob = [[FSBlob alloc] initWithURL:@"https://www.filestackapi.com/filehandler"];
    FSWatermark *watermark = [[FSWatermark alloc] initWithBlob:blob size:@50.12 position:FSWatermarkPositionTopRight];
    NSString *watermarkQuery = [watermark toQuery];
    XCTAssertEqualObjects(watermarkQuery, @"watermark=file:filehandler,size:50,position:[top,right]");

    FSBlob *blobNoURL = [[FSBlob alloc] initWithURL:nil];
    FSWatermark *watermark2 = [[FSWatermark alloc] initWithBlob:blobNoURL size:@50.98 position:FSWatermarkPositionTopRight];
    NSString *watermarkQuery2 = [watermark2 toQuery];
    XCTAssertNil(watermarkQuery2);

    watermark.size = nil;
    watermark.position = nil;
    watermarkQuery = [watermark toQuery];
    XCTAssertEqualObjects(watermarkQuery, @"watermark=file:filehandler");
}

- (void)testFSDetectFaces {
    FSDetectFaces *detectFaces = [[FSDetectFaces alloc] initWithMinSize:@100 maxSize:@100 color:@"teal" exportToJSON:NO];
    NSString *detectFacesQuery = [detectFaces toQuery];
    XCTAssertEqualObjects(detectFacesQuery, @"detect_faces=minsize:100.00,maxsize:100.00,color:teal");

    FSDetectFaces *detectFaces2 = [[FSDetectFaces alloc] initWithExportToJSON];
    NSString *detectFacesQuery2 = [detectFaces2 toQuery];
    XCTAssertEqualObjects(detectFacesQuery2, @"detect_faces=export:true");

    FSDetectFaces *detectFacesAllNil = [[FSDetectFaces alloc] initWithMinSize:nil maxSize:nil color:nil exportToJSON:NO];
    NSString *detectFacesQueryAllNil = [detectFacesAllNil toQuery];
    XCTAssertEqualObjects(detectFacesQueryAllNil, @"detect_faces");
}

@end
