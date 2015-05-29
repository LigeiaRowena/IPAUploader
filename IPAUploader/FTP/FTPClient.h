//
//  FTPManager.h
//  IPAUploader
//
//  Created by Francesca Corsini on 29/05/15.
//  Copyright (c) 2015 Francesca Corsini. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"

@interface FTPClient : NSObject

// Init & Utility
+ (FTPClient *)sharedHockeyManager;

// FTP requests
+ (NSURLSessionDataTask *)uploadApp:(NSString*)ipaPath releaseNotes:(NSString*)releaseNotes withBlock:(void (^)(id response, NSError *error))block progressBlock:(void (^)(NSProgress *pr))progressBlock;

@end
