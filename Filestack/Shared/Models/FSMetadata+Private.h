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
@property (nonatomic, copy) NSString *mimeType;
@property (nonatomic, copy) NSString *fileName;
@property (nonatomic, assign) NSInteger width;
@property (nonatomic, assign) NSInteger height;
@property (nonatomic, assign) NSInteger uploaded;
@property (nonatomic, strong) NSNumber *writeable;
@property (nonatomic, copy) NSString *md5;
@property (nonatomic, copy) NSString *location;
@property (nonatomic, copy) NSString *path;
@property (nonatomic, copy) NSString *container;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end
