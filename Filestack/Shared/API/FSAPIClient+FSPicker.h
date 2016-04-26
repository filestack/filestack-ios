//
//  FSAPIClient+FSPicker.h
//  Filestack
//
//  Created by Łukasz Cichecki on 14/03/16.
//  Copyright © 2016 Filestack. All rights reserved.
//

#import "FSAPIClient.h"

@interface FSAPIClient (FSPicker)

- (void)GETContent:(NSString *)getURL parameters:(NSDictionary *)parameters sessionSettings:(FSSessionSettings *)sessionSettings completionHandler:(void (^)(NSDictionary *responseJSON, NSError *error))completionHandler;
- (void)LOGOUT:(NSString *)logoutURL parameters:(NSDictionary *)parameters completionHandler:(void (^)(NSError *error))completionHandler;

@end
