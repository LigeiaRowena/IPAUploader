//
//  Client.h
//  IPAUploader
//
//  Created by Francesca Corsini on 22/05/15.
//  Copyright (c) 2015 Francesca Corsini. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"
#import "BITHockeyAppModel.h"

@interface BITHockeyManager : NSObject 

// Init & Utility
+ (BITHockeyManager *)sharedHockeyManager;
- (void)configureWithAppIdentifier;
- (void)startManager;
- (void)testIdentifier;
- (NSString*)getAppIdentifier;
- (void)setToken:(NSString*)_token;
- (NSString*)getToken;

// HockeyApp requests
+ (NSURLSessionDataTask *)getAllAppsWithToken:(NSString*)_token block:(void (^)(id response, NSError *error))block;
+ (NSURLSessionDataTask *)loginWithEmail:(NSString*)email password:(NSString*)password block:(void (^)(id response, NSError *error))block;
+ (NSURLSessionDataTask *)uploadApp:(NSString*)ipaPath releaseNotes:(NSString*)releaseNotes token:(NSString*)_token withBlock:(void (^)(id response, NSError *error))block progressBlock:(void (^)(NSProgress *pr))progressBlock;


@end
