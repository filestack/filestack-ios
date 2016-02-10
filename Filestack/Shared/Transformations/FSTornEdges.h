//
//  FSTornEdges.h
//  Filestack
//
//  Created by Łukasz Cichecki on 08/02/16.
//  Copyright © 2016 Filestack. All rights reserved.
//

#import "FSTransform.h"

@interface FSTornEdges : FSTransform

@property (nonatomic, strong) NSArray<NSNumber *> *spread;
@property (nonatomic, strong) NSString *background;

- (instancetype)initWithSpread:(NSArray<NSNumber *> *)spread background:(NSString *)background;

@end
