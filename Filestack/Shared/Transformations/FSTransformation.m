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
// Custom return value setting for FSDetectFaces.
@property (nonatomic, assign) BOOL exportFacesToJSON;
// Custom return value setting for FSOutput.
@property (nonatomic, assign) BOOL docInfoJSON;

@end

@implementation FSTransformation

- (instancetype)init {
    if (self = [super init]) {
        self.transformationsArray = [[NSMutableArray alloc] init];
    }
    return self;
}

- (instancetype)initWithQueryString:(NSString *)queryString {
    if (self = [self init]) {
        [self.transformationsArray addObject:queryString];
    }
    return self;
}

- (void)add:(FSTransform *)transform {
    NSString *transformQuery = [transform toQuery];

    if (transformQuery) {
        if ([transformQuery isMemberOfClass:[FSDetectFaces class]]) {
            _exportFacesToJSON = ((FSDetectFaces *)transformQuery).exportToJSON;
        } else if ([transformQuery isMemberOfClass:[FSOutput class]]) {
            _docInfoJSON = ((FSOutput *)transformQuery).docInfo;
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
