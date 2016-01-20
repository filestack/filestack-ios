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
@property (nonatomic, readonly, assign) NSString *mimeType;
@property (nonatomic, readonly, assign) NSString *fileName;
@property (nonatomic, readonly, assign) NSInteger width;
@property (nonatomic, readonly, assign) NSInteger height;
@property (nonatomic, readonly, assign) float *uploaded;
@property (nonatomic, readonly, assign) BOOL writeable;
@property (nonatomic, readonly, assign) NSString *md5;
@property (nonatomic, readonly, assign) NSString *location;
@property (nonatomic, readonly, assign) NSString *path;
@property (nonatomic, readonly, assign) NSString *container;

@end
