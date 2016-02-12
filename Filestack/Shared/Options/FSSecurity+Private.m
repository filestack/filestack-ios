//
//  FSSecurity+Private.m
//  Filestack
//
//  Created by Łukasz Cichecki on 11/02/16.
//  Copyright © 2016 Filestack. All rights reserved.
//

#import "FSSecurity+Private.h"

@implementation FSSecurity (Private)

- (NSString *)toQuery {
    if (!self.policy && !self.signature) {
        return nil;
    }

    return [NSString stringWithFormat:@"security=policy:%@,signature:%@", self.policy, self.signature];
}

@end
