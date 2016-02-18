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

- (void)testFSBorder {
    FSBorder *border = [[FSBorder alloc] initWithWidth:@10.1 color:@"blue" background:@"black"];
    NSString *borderQuery = [border toQuery];
    XCTAssertEqualObjects(borderQuery, @"border=width:10,background:black,color:blue");

    border.width = nil;
    border.color = nil;
    border.background = nil;
    borderQuery = [border toQuery];
    XCTAssertEqualObjects(borderQuery, @"border");
}

- (void)testFSSharpen {
    FSSharpen *sharpen = [[FSSharpen alloc] initWithAmount:@11.4];
    NSString *sharpenQuery = [sharpen toQuery];
    XCTAssertEqualObjects(sharpenQuery, @"sharpen=amount:11");

    sharpen.amount = nil;
    sharpenQuery = [sharpen toQuery];
    XCTAssertEqualObjects(sharpenQuery, @"sharpen");
}

- (void)testFSBlur {
    FSBlur *blur = [[FSBlur alloc] initWithAmount:@11.4];
    NSString *blurQuery = [blur toQuery];
    XCTAssertEqualObjects(blurQuery, @"blur=amount:11");

    blur.amount = nil;
    blurQuery = [blur toQuery];
    XCTAssertEqualObjects(blurQuery, @"blur");
}

- (void)testFSMonochrome {
    FSMonochrome *monochrome = [[FSMonochrome alloc] init];
    NSString *monochromeQuery = [monochrome toQuery];
    XCTAssertEqualObjects(monochromeQuery, @"monochrome");
}

- (void)testFSSepia {
    FSSepia *sepia = [[FSSepia alloc] initWithTone:@11.4];
    NSString *sepiaQuery = [sepia toQuery];
    XCTAssertEqualObjects(sepiaQuery, @"sepia=tone:11");

    sepia.tone = nil;
    sepiaQuery = [sepia toQuery];
    XCTAssertEqualObjects(sepiaQuery, @"sepia");
}

- (void)testFSPixelate {
    FSPixelate *pixelate = [[FSPixelate alloc] initWithAmount:@11.4];
    NSString *pixelateQuery = [pixelate toQuery];
    XCTAssertEqualObjects(pixelateQuery, @"pixelate=amount:11");

    pixelate.amount = nil;
    pixelateQuery = [pixelate toQuery];
    XCTAssertEqualObjects(pixelateQuery, @"pixelate");
}

- (void)testFSOilPaint {
    FSOilPaint *oilPaint = [[FSOilPaint alloc] initWithAmount:@11.4];
    NSString *oilPaintQuery = [oilPaint toQuery];
    XCTAssertEqualObjects(oilPaintQuery, @"oil_paint=amount:11");

    oilPaint.amount = nil;
    oilPaintQuery = [oilPaint toQuery];
    XCTAssertEqualObjects(oilPaintQuery, @"oil_paint");
}

- (void)testFSModulate {
    FSModulate *modulate = [[FSModulate alloc] initWithBrightness:@193.0 hue:@100.8 saturation:@0.4];
    NSString *modulateQuery = [modulate toQuery];
    XCTAssertEqualObjects(modulateQuery, @"modulate=hue:100,brightness:193,saturation:0");

    modulate.hue = nil;
    modulate.brightness = nil;
    modulate.saturation = nil;
    modulateQuery = [modulate toQuery];
    XCTAssertEqualObjects(modulateQuery, @"modulate");

    modulate.saturation = @19.89;
    modulateQuery = [modulate toQuery];
    XCTAssertEqualObjects(modulateQuery, @"modulate=saturation:19");
}

- (void)testFSPartialPixelate {
    FSPartialPixelate *partialPixelate = [[FSPartialPixelate alloc] initWithObjects:@[@[@12, @89.2, @100, @95.34], @[@(-10.34), @90.2, @88, @23.9]] buffer:@10.1 amount:@90.2 blur:@13.56 type:FSPPartialPixelateTypeOval];
    NSString *partialPixelateQuery = [partialPixelate toQuery];
    XCTAssertEqualObjects(partialPixelateQuery, @"partial_pixelate=objects:[[12,89,100,95],[-10,90,88,23]],buffer:10,amount:90,blur:13.5600,type:oval");

    partialPixelate.objects = @[];
    partialPixelateQuery = [partialPixelate toQuery];
    XCTAssertNil(partialPixelateQuery);

    FSPartialPixelate *partialPixelate2 = [[FSPartialPixelate alloc] initWithObjects:@[@[@12, @89.2, @100, @95.34], @[@(-10.34), @90.2, @88, @23.9]]];
    NSString *partialPixelateQuery2 = [partialPixelate2 toQuery];
    XCTAssertEqualObjects(partialPixelateQuery2, @"partial_pixelate=objects:[[12,89,100,95],[-10,90,88,23]]");
}

- (void)testFSPartialBlur {
    FSPartialBlur *partialBlur = [[FSPartialBlur alloc] initWithObjects:@[@[@12, @89.2, @100, @95.34], @[@(-10.34), @90.2, @88, @23.9]] buffer:@10.1 amount:@90.12 blur:@13.56 type:FSPPartialBlurTypeOval];
    NSString *partialBlurQuery = [partialBlur toQuery];
    XCTAssertEqualObjects(partialBlurQuery, @"partial_pixelate=objects:[[12,89,100,95],[-10,90,88,23]],buffer:10,amount:90.1200,blur:13.5600,type:oval");

    partialBlur.objects = @[];
    partialBlurQuery = [partialBlur toQuery];
    XCTAssertNil(partialBlurQuery);

    FSPartialBlur *partialBlur2 = [[FSPartialBlur alloc] initWithObjects:@[@[@12, @89.2, @100, @95.34], @[@(-10.34), @90.2, @88, @23.9]]];
    NSString *partialBlurQuery2 = [partialBlur2 toQuery];
    XCTAssertEqualObjects(partialBlurQuery2, @"partial_pixelate=objects:[[12,89,100,95],[-10,90,88,23]]");
}

- (void)testFSCollage {
    FSBlob *blob = [[FSBlob alloc] initWithURL:@"https://www.filestackapi.com/filehandler"];
    FSBlob *blob2 = [[FSBlob alloc] initWithURL:@"https://www.filestackapi.com/filehandler2"];
    FSCollage *collage = [[FSCollage alloc] initWithFiles:@[blob, blob2] width:@100.34 height:@98.2 margin:@100.89 color:@"white"];
    NSString *collageQuery = [collage toQuery];
    XCTAssertEqualObjects(collageQuery, @"collage=files:[filehandler,filehandler2],width:100,height:98,color:white,margin:100");

    collage.height = [[NSNumber alloc] init];
    collageQuery = [collage toQuery];
    XCTAssertNil(collageQuery);

    collage.width = [[NSNumber alloc] init];
    collage.height = @100;
    collageQuery = [collage toQuery];
    XCTAssertNil(collageQuery);

    collage.width = @100;
    collage.height = @100;
    collage.files = @[];
    collageQuery = [collage toQuery];
    XCTAssertNil(collageQuery);

    FSCollage *collage2 = [[FSCollage alloc] initWithFiles:@[blob, blob2] width:@99.12 height:@98.12];
    NSString *collageQuery2 = [collage2 toQuery];
    XCTAssertEqualObjects(collageQuery2, @"collage=files:[filehandler,filehandler2],width:99,height:98");
}

- (void)testFSURLScreenshot {
    FSURLScreenshot *urlScreenshot = [[FSURLScreenshot alloc] init];
    NSString *urlScreenshotQuery = [urlScreenshot toQuery];
    XCTAssertEqualObjects(urlScreenshotQuery, @"urlscreenshot");

    FSURLScreenshot *urlScreenshot2 = [[FSURLScreenshot alloc] initWithWidth:@100.1 height:@200.2 agent:FSURLScreenshotAgentMobile mode:FSURLScreenshotModeWindow];
    NSString *urlScreenshotQuery2 = [urlScreenshot2 toQuery];
    XCTAssertEqualObjects(urlScreenshotQuery2, @"urlscreenshot=width:100,height:200,agent:mobile,mode:window");
}

- (void)testFSASCII {
    FSASCII *ascii = [[FSASCII alloc] init];
    NSString *asciiQuery = [ascii toQuery];
    XCTAssertEqualObjects(asciiQuery, @"ascii");

    FSASCII *ascii2 = [[FSASCII alloc] initWithForeground:@"yellow" background:@"blue" size:@98.12 reverse:YES colored:YES];
    NSString *asciiQuery2 = [ascii2 toQuery];
    XCTAssertEqualObjects(asciiQuery2, @"ascii=background:blue,foreground:yellow,colored:true,reverse:true,size:98");
}

- (void)testFSCrop {
    FSCrop *crop = [[FSCrop alloc] initWithX:@10.12 y:@20.12 width:@90.56 height:@90.78];
    NSString *cropQuery = [crop toQuery];
    XCTAssertEqualObjects(cropQuery, @"crop=dim:[10,20,90,90]");

    crop.height = [[NSNumber alloc] init];
    cropQuery = [crop toQuery];
    XCTAssertNil(cropQuery);

    crop.x = [[NSNumber alloc] init];
    crop.height = @100;
    cropQuery = [crop toQuery];
    XCTAssertNil(cropQuery);

    crop.y = [[NSNumber alloc] init];
    crop.x = @100;
    crop.height = @100;
    cropQuery = [crop toQuery];
    XCTAssertNil(cropQuery);

    crop.width = [[NSNumber alloc] init];
    crop.x = @100;
    crop.y = @100;
    crop.height = @100;
    cropQuery = [crop toQuery];
    XCTAssertNil(cropQuery);
}

- (void)testFSOutput {
    FSOutput *output = [[FSOutput alloc] initWithFormat:FSOutputFormatBMP colorspace:FSOutputColorspaceCMYK page:@1.23 density:@10.1 compress:YES quality:@10.1 secure:YES];
    NSString *outputQuery = [output toQuery];
    XCTAssertEqualObjects(outputQuery, @"output=format:bmp,page:1,density:10,compress:true,quality:10,secure:true");

    output.docInfo = YES;
    outputQuery = [output toQuery];
    XCTAssertEqualObjects(outputQuery, @"output=format:bmp,page:1,density:10,compress:true,quality:10,secure:true,docinfo:true");

    FSOutput *output2 = [[FSOutput alloc] initWithFormat:FSOutputFormatPNG];
    NSString *outputQuery2 = [output2 toQuery];
    XCTAssertEqualObjects(outputQuery2, @"output=format:png");

    FSOutput *output3 = [[FSOutput alloc] initWithDocInfo];
    NSString *outputQuery3 = [output3 toQuery];
    XCTAssertEqualObjects(outputQuery3, @"output=docinfo:true");
}

@end
