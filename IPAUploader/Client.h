//
//  Client.h
//  IPAUploader
//
//  Created by Francesca Corsini on 22/05/15.
//  Copyright (c) 2015 Francesca Corsini. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"

@interface Client : NSObject

+ (NSURLSessionDataTask *)getWithBlock:(void (^)(id response, NSError *error))block;
+ (NSURLSessionDataTask *)postWithBlock:(void (^)(id response, NSError *error))block;

@end
