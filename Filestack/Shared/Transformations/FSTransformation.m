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
    if ((self = [super init])) {
        self.transformationsArray = [[NSMutableArray alloc] init];
    }
    return self;
}

- (instancetype)initWithQueryString:(NSString *)queryString {
    if ((self = [self init])) {
        [self.transformationsArray addObject:queryString];
    }
    return self;
}

- (void)add:(FSTransform *)transform {
    NSString *transformQuery = [transform toQuery];

    if (!transformQuery) {
        return;
    }

    if ([transform isMemberOfClass:[FSDetectFaces class]]) {
        self.exportFacesToJSON = ((FSDetectFaces *)transform).exportToJSON;
    } else if ([transform isMemberOfClass:[FSOutput class]]) {
        self.docInfoJSON = ((FSOutput *)transform).docInfo;
    }

    [self.transformationsArray addObject:transformQuery];
}

- (NSString *)transformationURLWithApiKey:(NSString *)apiKey security:(FSSecurity *)security URLToTransform:(NSString *)urlToTransform {
    if (security && !self.securitySet) {
        self.securitySet = YES;
        [self.transformationsArray addObject:[security toQuery]];
    }

    if (self.debug && !self.debugSet) {
        self.debugSet = YES;
        [self.transformationsArray insertObject:@"debug" atIndex:0];
    }

    NSString *transformationQuery = [self.transformationsArray componentsJoinedByString:@"/"];

    return [NSString stringWithFormat:@"%@/%@/%@/%@", FSURLTransformationURL, apiKey, transformationQuery, urlToTransform];
}

- (BOOL)willReturnJSON {
    return (self.exportFacesToJSON || self.debug || self.docInfoJSON);
}

@end
