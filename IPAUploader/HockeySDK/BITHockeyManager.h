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

// Init & Utility
+ (BITHockeyManager *)sharedHockeyManager;
- (void)configureWithAppIdentifier;
- (void)startManager;
- (void)testIdentifier;
- (NSString*)getAppIdentifier;

// HockeyApp requests
+ (NSURLSessionDataTask *)getAllAppsWithBlock:(void (^)(id response, NSError *error))block;
+ (NSURLSessionDataTask *)uploadApp:(NSString*)ipaPath releaseNotes:(NSString*)releaseNotes withBlock:(void (^)(id response, NSError *error))block;

// Generic requests
+ (NSURLSessionDataTask *)get:(NSString*)url headers:(NSDictionary*)headers parameters:(NSDictionary*)parameters withBlock:(void (^)(id response, NSError *error))block;
+ (NSURLSessionDataTask *)post:(NSString*)url headers:(NSDictionary*)headers parameters:(NSDictionary*)parameters constructingBodyWithBlock:(void (^)(id <AFMultipartFormData> formData))block success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;



@end
