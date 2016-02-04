//
//  FSTransformation.h
//  Filestack
//
//  Created by Łukasz Cichecki on 04/02/16.
//  Copyright © 2016 Filestack. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FSTransform.h"
#import "FSResize.h"
#import "FSCrop.h"
#import "FSRotate.h"
#import "FSFlip.h"
#import "FSFlop.h"

@interface FSTransformation : NSObject

- (void)add:(FSTransform *)transform;

@end
