//
//  PListHandler.h
//  IPAUploader
//
//  Created by Francesca Corsini on 05/06/15.
//  Copyright (c) 2015 Francesca Corsini. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SettingsHandler : NSObject

// Plist
+ (NSDictionary*)getSettings;

// Getters
+ (BOOL)rememberCredentials;
+ (NSString*)getToken;
+ (NSString*)getUsername;
+ (NSString*)getPassword;

// Setters
+ (BOOL)setRememberCredentials:(BOOL)rememberCredentials;
+ (BOOL)setToken:(NSString*)token;
+ (BOOL)setUsername:(NSString*)username;
+ (BOOL)setPassword:(NSString*)password;

@end
