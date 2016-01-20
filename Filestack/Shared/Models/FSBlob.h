//
//  FSBlob.h
//  Filestack
//
//  Created by Łukasz Cichecki on 20/01/16.
//  Copyright © 2016 Filestack. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FSBlob : NSObject

@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSString *fileName;
@property (nonatomic, assign) NSInteger size;
@property (nonatomic, strong) NSString *key;
@property (nonatomic, strong) NSString *container;
@property (nonatomic, strong) NSString *path;
@property (nonatomic, assign) BOOL writeable;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end
