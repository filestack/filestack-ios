//
//  FSMetadata.h
//  Filestack
//
//  Created by Łukasz Cichecki on 20/01/16.
//  Copyright © 2016 Filestack. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FSMetadata : NSObject

@property (nonatomic, readonly, assign) NSInteger size;
@property (nonatomic, readonly, strong) NSString *mimeType;
@property (nonatomic, readonly, strong) NSString *fileName;
@property (nonatomic, readonly, assign) NSInteger width;
@property (nonatomic, readonly, assign) NSInteger height;
@property (nonatomic, readonly, assign) NSInteger uploaded;
@property (nonatomic, readonly, strong) NSNumber *writeable;
@property (nonatomic, readonly, strong) NSString *md5;
@property (nonatomic, readonly, strong) NSString *location;
@property (nonatomic, readonly, strong) NSString *path;
@property (nonatomic, readonly, strong) NSString *container;
@property (nonatomic, readonly, strong) NSString *s3url;

@end
