//
//  FSCircle.h
//  Filestack
//
//  Created by Łukasz Cichecki on 08/02/16.
//  Copyright © 2016 Filestack. All rights reserved.
//

#import "FSTransform.h"

@interface FSCircle : FSTransform

@property (nonatomic, strong) NSString *background;

- (instancetype)initWithBackground:(NSString *)background;

@end
