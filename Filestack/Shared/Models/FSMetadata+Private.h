//
//  FSBlob+Private.h
//  Filestack
//
//  Created by Łukasz Cichecki on 20/01/16.
//  Copyright © 2016 Filestack. All rights reserved.
//

#import "FSMetadata.h"

@interface FSMetadata (Private)

@property (nonatomic, assign) NSInteger size;
@property (nonatomic, strong) NSString *mimeType;
@property (nonatomic, strong) NSString *fileName;
@property (nonatomic, assign) NSInteger width;
@property (nonatomic, assign) NSInteger height;
@property (nonatomic, assign) NSInteger uploaded;
@property (nonatomic, strong) NSNumber *writeable;
@property (nonatomic, strong) NSString *md5;
@property (nonatomic, strong) NSString *location;
@property (nonatomic, strong) NSString *path;
@property (nonatomic, strong) NSString *container;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end
