//
//  FSBlob.h
//  Filestack
//
//  Created by Łukasz Cichecki on 20/01/16.
//  Copyright © 2016 Filestack. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FSBlob : NSObject

/*! The most critical part of the file, the url points to where the file is stored and acts as a sort of "file path". */
@property (nonatomic, strong) NSString *url;
/*! The name of the file, if available */
@property (nonatomic, strong) NSString *fileName;
/*! The mimetype of the file, if available. */
@property (nonatomic, strong) NSString *mimeType;
/*! he size of the file in bytes */
@property (nonatomic, assign) NSInteger size;
/*! If the file was stored in one of the file stores you specified or configured (S3, Rackspace, Azure, etc.), this parameter will tell you where in the file store this file was put. */
@property (nonatomic, strong) NSString *key;
/*! If the file was stored in one of the file stores you specified or configured (S3, Rackspace, Azure, etc.), this parameter will tell you in which container this file was put */
@property (nonatomic, strong) NSString *container;
/*! The path of the Blob indicates its position in the hierarchy of files uploaded. */
@property (nonatomic, strong) NSString *path;
/*! This flag specifies whether the underlying file is writeable. */
@property (nonatomic, assign) BOOL writeable;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;
- (instancetype)initWithURL:(NSString *)url;

@end
