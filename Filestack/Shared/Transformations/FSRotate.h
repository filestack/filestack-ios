//
//  FSRotate.h
//  Filestack
//
//  Created by Łukasz Cichecki on 04/02/16.
//  Copyright © 2016 Filestack. All rights reserved.
//

#import "FSTransform.h"

@interface FSRotate : FSTransform

@property (nonatomic, strong) NSNumber *degrees;
@property (nonatomic, strong) NSString *background;
@property (nonatomic, assign) BOOL toEXIF;
@property (nonatomic, assign) BOOL resetEXIF;

- (instancetype)initWithDegrees:(NSNumber *)degrees background:(NSString *)background rotateToEXIF:(BOOL)toEXIF resetEXIF:(BOOL)resetEXIF;

@end
