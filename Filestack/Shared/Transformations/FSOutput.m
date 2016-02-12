//
//  FSOutput.m
//  Filestack
//
//  Created by Łukasz Cichecki on 10/02/16.
//  Copyright © 2016 Filestack. All rights reserved.
//

#import "FSOutput.h"

@implementation FSOutput

- (instancetype)initWithFormat:(FSOutputFormat)format colorspace:(FSOutputColorspace)colorspace page:(NSNumber *)page density:(NSNumber *)density compress:(BOOL)compress quality:(NSNumber *)quality secure:(BOOL)secure {
    if (self = [super init]) {
        self.format = format;
        self.colorspace = colorspace;
        self.page = page;
        self.density = density;
        self.compress = compress;
        self.quality = quality;
        self.secure = secure;
    }
    return self;
}

- (instancetype)initWithFormat:(FSOutputFormat)format {
    return [self initWithFormat:format colorspace:nil page:nil density:nil compress:NO quality:nil secure:NO];
}

- (instancetype)initWithDocInfo:(BOOL)docInfo {
    if (self = [self initWithFormat:nil colorspace:nil page:nil density:nil compress:NO quality:nil secure:NO]) {
        self.docInfo = docInfo;
    }
    return self;
}

@end
