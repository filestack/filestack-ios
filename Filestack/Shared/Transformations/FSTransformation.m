//
//  FSTransformation.m
//  Filestack
//
//  Created by Łukasz Cichecki on 04/02/16.
//  Copyright © 2016 Filestack. All rights reserved.
//

#import "FSTransformation.h"
#import "FSTransform+Private.h"
#import "FSSecurity+Private.h"
#import "FSAPIURL.h"

@interface FSTransformation ()

@property (nonatomic, strong) NSMutableArray *transformationsArray;
// Custom return value setting for FSDetectFaces.
@property (nonatomic, assign) BOOL exportFacesToJSON;
// Custom return value setting for FSOutput.
@property (nonatomic, assign) BOOL docInfoJSON;
@property (nonatomic, assign) BOOL debugSet;
@property (nonatomic, assign) BOOL securitySet;

@end

@implementation FSTransformation

- (instancetype)init {
    if (self = [super init]) {
        _transformationsArray = [[NSMutableArray alloc] init];
    }
    return self;
}

- (instancetype)initWithQueryString:(NSString *)queryString {
    if (self = [self init]) {
        [_transformationsArray addObject:queryString];
    }
    return self;
}

- (void)add:(FSTransform *)transform {
    NSString *transformQuery = [transform toQuery];

    if (!transformQuery) {
        return;
    }

    if ([transform isMemberOfClass:[FSDetectFaces class]]) {
        _exportFacesToJSON = ((FSDetectFaces *)transform).exportToJSON;
    } else if ([transform isMemberOfClass:[FSOutput class]]) {
        _docInfoJSON = ((FSOutput *)transform).docInfo;
    }

    [_transformationsArray addObject:transformQuery];
}

- (NSString *)transformationURLWithApiKey:(NSString *)apiKey security:(FSSecurity *)security URLToTransform:(NSString *)urlToTransform {
    if (security && !_securitySet) {
        _securitySet = YES;
        [_transformationsArray addObject:[security toQuery]];
    }

    if (_debug && !_debugSet) {
        _debugSet = YES;
        [_transformationsArray insertObject:@"debug" atIndex:0];
    }

    NSString *transformationQuery = [_transformationsArray componentsJoinedByString:@"/"];

    return [NSString stringWithFormat:@"%@/%@/%@/%@", FSURLTransformationURL, apiKey, transformationQuery, urlToTransform];
}

- (BOOL)willReturnJSON {
    return (_exportFacesToJSON || _debug || _docInfoJSON);
}

@end
