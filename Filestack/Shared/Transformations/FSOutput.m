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
        _format = format;
        _colorspace = colorspace;
        _page = page;
        _density = density;
        _compress = compress;
        _quality = quality;
        _secure = secure;
    }
    return self;
}

- (instancetype)initWithFormat:(FSOutputFormat)format {
    return [self initWithFormat:format colorspace:nil page:nil density:nil compress:NO quality:nil secure:NO];
}

- (instancetype)initWithDocInfo {
    if (self = [self initWithFormat:nil colorspace:nil page:nil density:nil compress:NO quality:nil secure:NO]) {
        _docInfo = YES;
    }
    return self;
}

- (instancetype)init {
    return [self initWithFormat:nil colorspace:nil page:nil density:nil compress:NO quality:nil secure:NO];
}

@end
