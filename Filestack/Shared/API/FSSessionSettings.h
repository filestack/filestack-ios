//
//  FSSessionSettings.h
//  Filestack
//
//  Created by Łukasz Cichecki on 01/02/16.
//  Copyright © 2016 Filestack. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FSSessionSettings : NSObject

@property (nonatomic, strong) NSString *baseURL;
@property (nonatomic, assign) BOOL paramsInURI;

@end