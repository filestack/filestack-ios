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

@property (nonatomic, strong) FSOutputFormat format;
@property (nonatomic, strong) FSOutputColorspace colorspace;
@property (nonatomic, strong) NSNumber *page;
@property (nonatomic, strong) NSNumber *density;
@property (nonatomic, strong) NSNumber *quality;
@property (nonatomic, assign) BOOL compress;
@property (nonatomic, assign) BOOL secure;
@property (nonatomic, assign) BOOL docInfo;

- (instancetype)initWithFormat:(FSOutputFormat)format colorspace:(FSOutputColorspace)colorspace page:(NSNumber *)page density:(NSNumber *)density compress:(BOOL)compress quality:(NSNumber *)quality secure:(BOOL)secure;
- (instancetype)initWithFormat:(FSOutputFormat)format;
- (instancetype)initWithDocInfo:(BOOL)docInfo;

@end
