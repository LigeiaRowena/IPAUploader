//
//  Client.h
//  IPAUploader
//
//  Created by Francesca Corsini on 22/05/15.
//  Copyright (c) 2015 Francesca Corsini. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"

@interface BITHockeyManager : NSObject

+ (BITHockeyManager *)sharedHockeyManager;
- (void)configureWithIdentifier:(NSString *)_appIdentifier;
- (void)startManager;
- (void)testIdentifier;
- (NSString*)getAppIdentifier;

+ (NSURLSessionDataTask *)get:(NSString*)url headers:(NSDictionary*)headers parameters:(NSDictionary*)parameters withBlock:(void (^)(id response, NSError *error))block;
+ (NSURLSessionDataTask *)postWithBlock:(void (^)(id response, NSError *error))block;

+ (NSURLSessionDataTask *)getAllAppsWithBlock:(void (^)(id response, NSError *error))block;

@end
