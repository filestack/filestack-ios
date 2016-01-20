//
//  FSMetadata.h
//  Filestack
//
//  Created by Łukasz Cichecki on 20/01/16.
//  Copyright © 2016 Filestack. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FSMetadata : NSObject

@property (nonatomic, assign) NSInteger size;
@property (nonatomic, assign) NSString *mimeType;
@property (nonatomic, assign) NSString *fileName;
@property (nonatomic, assign) NSInteger width;
@property (nonatomic, assign) NSInteger height;
@property (nonatomic, assign) NSNumber *uploaded;
@property (nonatomic, assign) BOOL writeable;
@property (nonatomic, assign) NSString *md5;
@property (nonatomic, assign) NSString *location;
@property (nonatomic, assign) NSString *path;
@property (nonatomic, assign) NSString *container;

@end
