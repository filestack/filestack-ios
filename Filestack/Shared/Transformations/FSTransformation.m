//
//  FSTransformation.m
//  Filestack
//
//  Created by Łukasz Cichecki on 04/02/16.
//  Copyright © 2016 Filestack. All rights reserved.
//

#import "FSTransformation.h"
#import "FSTransform+Private.h"
#import "FSAPIURL.h"

@interface FSTransformation ()

@property (nonatomic, strong) NSMutableArray *transformationsArray;
@property (nonatomic, assign) BOOL exportFacesToJSON;

@end

@implementation FSTransformation

- (instancetype)init {
    if (self = [super init]) {
        self.transformationsArray = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)add:(FSTransform *)transform {
    NSString *transformQuery = [transform toQuery];

    if (transformQuery) {
        if ([transformQuery isMemberOfClass:[FSDetectFaces class]]) {
            _exportFacesToJSON = ((FSDetectFaces *)transformQuery).exportToJSON;
        }
        [_transformationsArray addObject:transformQuery];
    }

    NSLog(@"%@", _transformationsArray);
}

- (NSString *)transformationURLWithApiKey:(NSString *)apiKey andURLToTransform:(NSString *)urlToTransform {
    NSString *transformationQuery = [_transformationsArray componentsJoinedByString:@"/"];
    return [NSString stringWithFormat:@"%@/%@/%@/%@", FSURLTransformationURL, apiKey, transformationQuery, urlToTransform];
}

@end
