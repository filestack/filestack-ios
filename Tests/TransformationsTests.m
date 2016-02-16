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

- (void)testFSCropFaces {
    FSCropFaces *cropFaces = [[FSCropFaces alloc] initWithMode:FSCropFacesModeFill width:@100.12 height:@98.1 buffer:@87];
    NSString *cropFacesQuery = [cropFaces toQuery];
    XCTAssertEqualObjects(cropFacesQuery, @"crop_faces=width:100,height:98,buffer:87,mode:fill");

    FSCropFaces *cropFacesAllNil = [[FSCropFaces alloc] initWithMode:nil width:nil height:nil buffer:nil faces:nil];
    NSString *cropFacesAllNilQuery = [cropFacesAllNil toQuery];
    XCTAssertEqualObjects(cropFacesAllNilQuery, @"crop_faces");

    FSCropFaces *cropFacesWithArray = [[FSCropFaces alloc] initWithMode:FSCropFacesModeFill width:@100.12 height:@98.1 buffer:@87 faces:@[@1.1, @2.3, @4]];
    NSString *cropFacesWithArrayQuery = [cropFacesWithArray toQuery];
    XCTAssertEqualObjects(cropFacesWithArrayQuery, @"crop_faces=width:100,height:98,buffer:87,mode:fill,faces:[1,2,4]");

    FSCropFaces *cropFacesWithArray2 = [[FSCropFaces alloc] initWithMode:FSCropFacesModeFill width:@100.12 height:@98.1 buffer:@87 faces:@[@1.1, @2.3, @4]];
    cropFacesWithArray2.face = @1;
    cropFacesWithArray2.allFaces = YES;
    NSString *cropFacesWithArrayQuery2 = [cropFacesWithArray2 toQuery];
    XCTAssertEqualObjects(cropFacesWithArrayQuery2, @"crop_faces=width:100,height:98,buffer:87,mode:fill,faces:all");

    FSCropFaces *cropFacesWithArray3 = [[FSCropFaces alloc] initWithMode:FSCropFacesModeFill width:@100.12 height:@98.1 buffer:@87 faces:@[@1.1, @2.3, @4]];
    cropFacesWithArray3.face = @5;
    NSString *cropFacesWithArrayQuery3 = [cropFacesWithArray3 toQuery];
    XCTAssertEqualObjects(cropFacesWithArrayQuery3, @"crop_faces=width:100,height:98,buffer:87,mode:fill,faces:[1,2,4]");

    FSCropFaces *cropFacesWithArray4 = [[FSCropFaces alloc] initWithMode:FSCropFacesModeFill width:@100.12 height:@98.1 buffer:@87 face:@4];
    cropFacesWithArray4.allFaces = YES;
    NSString *cropFacesWithArrayQuery4 = [cropFacesWithArray4 toQuery];
    XCTAssertEqualObjects(cropFacesWithArrayQuery4, @"crop_faces=width:100,height:98,buffer:87,mode:fill,faces:all");

    FSCropFaces *cropFacesWithArray5 = [[FSCropFaces alloc] initAllFacesWithMode:FSCropFacesModeFill width:@100.12 height:@98.1 buffer:@87];
    cropFacesWithArray5.faces = @[@1, @2, @3];
    NSString *cropFacesWithArrayQuery5 = [cropFacesWithArray5 toQuery];
    XCTAssertEqualObjects(cropFacesWithArrayQuery5, @"crop_faces=width:100,height:98,buffer:87,mode:fill,faces:all");

    FSCropFaces *cropFacesWithArray6 = [[FSCropFaces alloc] initWithMode:FSCropFacesModeFill width:@100.12 height:@98.1 buffer:@87 face:@1];
    NSString *cropFacesWithArrayQuery6 = [cropFacesWithArray6 toQuery];
    XCTAssertEqualObjects(cropFacesWithArrayQuery6, @"crop_faces=width:100,height:98,buffer:87,mode:fill,faces:1");
}

- (void)testFSPixelateFaces {
    FSPixelateFaces *pixelateFaces = [[FSPixelateFaces alloc] initWithMinSize:@0.35 maxSize:@1001 type:FSPixelateFacesTypeOval buffer:@100 blurAmount:@0.4 pixelateAmount:@4.2 faces:@[@1, @2]];
    NSString *pixelateFacesQuery = [pixelateFaces toQuery];
    XCTAssertEqualObjects(pixelateFacesQuery, @"pixelate_faces=minsize:0.35,maxsize:1001.00,buffer:100,amount:4,blur:0.400000,type:oval,faces:[1,2]");

    FSPixelateFaces *pixelateFaces2 = [[FSPixelateFaces alloc] initWithAllFacesAndMinSize:@100 maxSize:@100 type:FSPixelateFacesTypeRect buffer:@1 blurAmount:@1 pixelateAmount:@1];
    NSString *pixelateFacesQuery2 = [pixelateFaces2 toQuery];
    XCTAssertEqualObjects(pixelateFacesQuery2, @"pixelate_faces=minsize:100.00,maxsize:100.00,buffer:1,amount:1,blur:1.000000,type:rect,faces:all");

    FSPixelateFaces *pixelateFaces3 = [[FSPixelateFaces alloc] initWithMinSize:@100 maxSize:@100 type:FSPixelateFacesTypeRect buffer:@1 blurAmount:@1 pixelateAmount:@1];
    NSString *pixelateFacesQuery3 = [pixelateFaces3 toQuery];
    XCTAssertEqualObjects(pixelateFacesQuery3, @"pixelate_faces=minsize:100.00,maxsize:100.00,buffer:1,amount:1,blur:1.000000,type:rect");

    FSPixelateFaces *pixelateFaces4 = [[FSPixelateFaces alloc] initWithMinSize:@100 maxSize:@100 type:FSPixelateFacesTypeRect buffer:@1 blurAmount:@1 pixelateAmount:@1 face:@1];
    NSString *pixelateFacesQuery4 = [pixelateFaces4 toQuery];
    XCTAssertEqualObjects(pixelateFacesQuery4, @"pixelate_faces=minsize:100.00,maxsize:100.00,buffer:1,amount:1,blur:1.000000,type:rect,faces:1");

    FSPixelateFaces *pixelateFacesAllNil = [[FSPixelateFaces alloc] initWithMinSize:nil maxSize:nil type:nil buffer:nil blurAmount:nil pixelateAmount:nil face:nil];
    NSString *pixelateFacesQueryAllNil = [pixelateFacesAllNil toQuery];
    XCTAssertEqualObjects(pixelateFacesQueryAllNil, @"pixelate_faces");
}

- (void)testFSBlurFaces {
    FSBlurFaces *blurFaces = [[FSBlurFaces alloc] initWithMinSize:@0.35 maxSize:@1001 type:FSBlurFacesTypeOval buffer:@100 blurAmount:@0.4 obscureAmount:@4.2 faces:@[@1, @2]];
    NSString *blurFacesQuery = [blurFaces toQuery];
    XCTAssertEqualObjects(blurFacesQuery, @"blur_faces=minsize:0.35,maxsize:1001.00,buffer:100,amount:4.200000,blur:0.400000,type:oval,faces:[1,2]");

    FSBlurFaces *blurFaces2 = [[FSBlurFaces alloc] initWithAllFacesAndMinSize:@100 maxSize:@100 type:FSBlurFacesTypeRect buffer:@1 blurAmount:@1 obscureAmount:@1];
    NSString *blurFacesQuery2 = [blurFaces2 toQuery];
    XCTAssertEqualObjects(blurFacesQuery2, @"blur_faces=minsize:100.00,maxsize:100.00,buffer:1,amount:1.000000,blur:1.000000,type:rect,faces:all");

    FSBlurFaces *blurFaces3 = [[FSBlurFaces alloc] initWithMinSize:@100 maxSize:@100 type:FSBlurFacesTypeRect buffer:@1 blurAmount:@1 obscureAmount:@1];
    NSString *blurFacesQuery3 = [blurFaces3 toQuery];
    XCTAssertEqualObjects(blurFacesQuery3, @"blur_faces=minsize:100.00,maxsize:100.00,buffer:1,amount:1.000000,blur:1.000000,type:rect");

    FSBlurFaces *blurFaces4 = [[FSBlurFaces alloc] initWithMinSize:@100 maxSize:@100 type:FSBlurFacesTypeRect buffer:@1 blurAmount:@1 obscureAmount:@1 face:@1];
    NSString *blurFacesQuery4 = [blurFaces4 toQuery];
    XCTAssertEqualObjects(blurFacesQuery4, @"blur_faces=minsize:100.00,maxsize:100.00,buffer:1,amount:1.000000,blur:1.000000,type:rect,faces:1");

    FSBlurFaces *blurFacesAllNil = [[FSBlurFaces alloc] initWithMinSize:nil maxSize:nil type:nil buffer:nil blurAmount:nil obscureAmount:nil face:nil];
    NSString *blurFacesQueryAllNil = [blurFacesAllNil toQuery];
    XCTAssertEqualObjects(blurFacesQueryAllNil, @"blur_faces");
}

- (void)testFSRoundedCorners {
    FSRoundedCorners *roundedCorners = [[FSRoundedCorners alloc] initWithMaxRadiusAndBlur:@1.34 background:@"red"];
    roundedCorners.radius = @12;
    NSString *roundedCornersQuery = [roundedCorners toQuery];
    XCTAssertEqualObjects(roundedCornersQuery, @"rounded_corners=radius:max,blur:1.340000,background:red");

    FSRoundedCorners *roundedCorners2 = [[FSRoundedCorners alloc] initWithRadius:@45.3 blur:@1.34 background:@"red"];
    NSString *roundedCornersQuery2 = [roundedCorners2 toQuery];
    XCTAssertEqualObjects(roundedCornersQuery2, @"rounded_corners=radius:45,blur:1.340000,background:red");

    FSRoundedCorners *roundedCorners3 = [[FSRoundedCorners alloc] initWithRadius:nil blur:nil background:nil];
    NSString *roundedCornersQuery3 = [roundedCorners3 toQuery];
    XCTAssertEqualObjects(roundedCornersQuery3, @"rounded_corners");
}

- (void)testFSPolaroid {
    FSPolaroid *polaroid = [[FSPolaroid alloc] initWithColor:@"yellow" background:@"pink" rotation:@300.12];
    NSString *polaroidQuery = [polaroid toQuery];
    XCTAssertEqualObjects(polaroidQuery, @"polaroid=rotate:300,background:pink,color:yellow");

    FSPolaroid *polaroid2 = [[FSPolaroid alloc] init];
    NSString *polaroidQuery2 = [polaroid2 toQuery];
    XCTAssertEqualObjects(polaroidQuery2, @"polaroid");

    polaroid2.background = @"blue";
    polaroidQuery2 = [polaroid2 toQuery];
    XCTAssertEqualObjects(polaroidQuery2, @"polaroid=background:blue");
}

- (void)testTornEdges {
    FSTornEdges *tornEdges = [[FSTornEdges alloc] initWithSpread:@[@1.34, @49.2] background:@"green"];
    NSString *tornEdgesQuery = [tornEdges toQuery];
    XCTAssertEqualObjects(tornEdgesQuery, @"torn_edges=spread:[1,49],background:green");

    FSTornEdges *tornEdgesAllNil = [[FSTornEdges alloc] init];
    NSString *tornEdgesAllNilQuery = [tornEdgesAllNil toQuery];
    XCTAssertEqualObjects(tornEdgesAllNilQuery, @"torn_edges");
}

- (void)testFSShadow {
    FSShadow *shadow = [[FSShadow alloc] initWithBlur:@4.3 opacity:@70.12 vector:@[@(-10.12), @90.13] color:@"blue" background:@"green"];
    NSString *shadowQuery = [shadow toQuery];
    XCTAssertEqualObjects(shadowQuery, @"shadow=blur:4,color:blue,opacity:70,vector:[-10,90],background:green");

    shadow.background = @"purple";
    shadowQuery = [shadow toQuery];
    XCTAssertEqualObjects(shadowQuery, @"shadow=blur:4,color:blue,opacity:70,vector:[-10,90],background:purple");

    shadow.opacity = nil;
    shadowQuery = [shadow toQuery];
    XCTAssertEqualObjects(shadowQuery, @"shadow=blur:4,color:blue,vector:[-10,90],background:purple");

    FSShadow *shadowAllNil = [[FSShadow alloc] init];
    NSString *shadowAllNilQuery = [shadowAllNil toQuery];
    XCTAssertEqualObjects(shadowAllNilQuery, @"shadow");
}

- (void)testFSCircle {
    FSCircle *circle = [[FSCircle alloc] initWithBackground:@"yellow"];
    NSString *circleQuery = [circle toQuery];
    XCTAssertEqualObjects(circleQuery, @"circle=background:yellow");

    circle.background = nil;
    circleQuery = [circle toQuery];
    XCTAssertEqualObjects(circleQuery, @"circle");
}

@end
