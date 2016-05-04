//
//  FSOutput.h
//  Filestack
//
//  Created by Łukasz Cichecki on 10/02/16.
//  Copyright © 2016 Filestack. All rights reserved.
//

#import "FSTransform.h"

typedef NSString * FSOutputFormat;
#define FSOutputFormatPDF @"pdf"
#define FSOutputFormatDOC @"doc"
#define FSOutputFormatDOCX @"docx"
#define FSOutputFormatODT @"odt"
#define FSOutputFormatXLS @"xls"
#define FSOutputFormatXLSX @"xlsx"
#define FSOutputFormatODS @"ods"
#define FSOutputFormatPPT @"ppt"
#define FSOutputFormatPPTX @"pptx"
#define FSOutputFormatODP @"odp"
#define FSOutputFormatBMP @"bmp"
#define FSOutputFormatGIF @"gif"
#define FSOutputFormatJPG @"jpg"
#define FSOutputFormatPNG @"png"
#define FSOutputFormatTIFF @"tiff"
#define FSOutputFormatAI @"ai"
#define FSOutputFormatPSD @"psd"
#define FSOutputFormatSVG @"svg"
#define FSOutputFormatHTML @"html"
#define FSOutputFormatTXT @"txt"

typedef NSString * FSOutputColorspace;
#define FSOutputColorspaceRGB @"rgb"
#define FSOutputColorspaceCMYK @"cmyk"
#define FSOutputColorspaceInput @"input"

@interface FSOutput : FSTransform

/**
 The format to convert the file to.
 */
@property (nonatomic, strong) FSOutputFormat format;
/**
 The output file colorspace. Defaults to FSOutputColorspaceRGB.
 */
@property (nonatomic, strong) FSOutputColorspace colorspace;
/**
 Specifies the page to extract if converting a file that contains multiple pages. The value for the page parameter must be an integer between 1 and 10000, the default is 1.
 */
@property (nonatomic, strong) NSNumber *page;
/**
 Specifies the density when converting documents files to image formats. This can improve the resolution of the output image. The value for the density parameter must be an integer between 1 and 500.
 */
@property (nonatomic, strong) NSNumber *density;
/**
 You can change the quality (and reduce file size) of JPEG images by using the quality parameter. The value for this parameter must be an integer between 1 and 100. The quality is set to 100 by default.
 */
@property (nonatomic, strong) NSNumber *quality;
/**
 If `YES`, it will compress the image with JPEGtran or OptiPNG. Compression is set to `NO` by default.
 */
@property (nonatomic, assign) BOOL compress;
/**
 If `YES`, the HTML or SVG file will be stripped of any insecure tags.
 */
@property (nonatomic, assign) BOOL secure;
/**
 If `YES`, it will return information about a document, such as the number of pages and the dimensions of the file as a JSON object.
 */
@property (nonatomic, assign) BOOL docInfo;

- (instancetype)initWithFormat:(FSOutputFormat)format colorspace:(FSOutputColorspace)colorspace page:(NSNumber *)page density:(NSNumber *)density compress:(BOOL)compress quality:(NSNumber *)quality secure:(BOOL)secure NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithFormat:(FSOutputFormat)format;
- (instancetype)initWithDocInfo;

@end
