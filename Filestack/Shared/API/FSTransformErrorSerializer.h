//
//  FSTransformErrorSerializer.h
//  Filestack
//
//  Created by Łukasz Cichecki on 12/02/16.
//  Copyright © 2016 Filestack. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FSTransformErrorSerializer : NSObject

+ (NSError *)transformErrorWithError:(NSError *)error;

@end
