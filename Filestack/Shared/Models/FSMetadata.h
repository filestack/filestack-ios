//
//  FSMetadata.h
//  Filestack
//
//  Created by Łukasz Cichecki on 20/01/16.
//  Copyright © 2016 Filestack. All rights reserved.
//

@import Foundation;

@interface FSMetadata : NSObject

@property (nonatomic, readonly, assign) NSInteger size;
@property (nonatomic, readonly, copy) NSString *mimeType;
@property (nonatomic, readonly, copy) NSString *fileName;
@property (nonatomic, readonly, assign) NSInteger width;
@property (nonatomic, readonly, assign) NSInteger height;
@property (nonatomic, readonly, assign) NSInteger uploaded;
@property (nonatomic, readonly, strong) NSNumber *writeable;
@property (nonatomic, readonly, copy) NSString *md5;
@property (nonatomic, readonly, copy) NSString *location;
@property (nonatomic, readonly, copy) NSString *path;
@property (nonatomic, readonly, copy) NSString *container;
@property (nonatomic, readonly, copy) NSString *s3url;

@end
