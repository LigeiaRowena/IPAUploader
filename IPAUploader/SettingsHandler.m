//
//  PListHandler.m
//  IPAUploader
//
//  Created by Francesca Corsini on 05/06/15.
//  Copyright (c) 2015 Francesca Corsini. All rights reserved.
//

#import "SettingsHandler.h"

NSString *const kSettingsFileName = @"settings";
NSString *const kTokenKey = @"Token";
NSString *const kRememberKey = @"Remember";
NSString *const kUsernameKey = @"Username";
NSString *const kPasswordKey = @"Password";

@implementation SettingsHandler

#pragma mark - Plist


+ (NSDictionary*)getSettings
{
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:kSettingsFileName ofType:@"plist"];
    NSDictionary *settings = [NSDictionary dictionaryWithContentsOfFile:plistPath];
    return settings;
}

#pragma mark - Getters

+ (BOOL)rememberCredentials
{
    NSDictionary *settings = [self getSettings];
    if (settings != nil)
        return [settings[kRememberKey] boolValue];
    else
        return NO;
}

+ (NSString*)getToken
{
    NSDictionary *settings = [self getSettings];
    if (settings != nil && [self rememberCredentials])
        return settings[kTokenKey];
    else
        return @"";
}

+ (NSString*)getUsername
{
    NSDictionary *settings = [self getSettings];
    if (settings[kUsernameKey] != nil && [self rememberCredentials])
        return settings[kUsernameKey];
    else
        return @"";
}

+ (NSString*)getPassword
{
    NSDictionary *settings = [self getSettings];
    if (settings[kPasswordKey] != nil && [self rememberCredentials])
        return settings[kPasswordKey];
    else
        return @"";
}

#pragma mark - Setters

+ (BOOL)setRememberCredentials:(BOOL)rememberCredentials
{
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:kSettingsFileName ofType:@"plist"];
    NSMutableDictionary *settings = [self getSettings].mutableCopy;
    if (settings != nil)
    {
        [settings setObject:[NSNumber numberWithBool:rememberCredentials] forKey:kRememberKey];
        NSData *xmlData = [NSPropertyListSerialization dataWithPropertyList:settings format:NSPropertyListXMLFormat_v1_0 options:kCFPropertyListImmutable error:nil];
        return [xmlData writeToFile:plistPath atomically:YES];
    }
    else
        return NO;
}

+ (BOOL)setToken:(NSString*)token
{
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:kSettingsFileName ofType:@"plist"];
    NSMutableDictionary *settings = [self getSettings].mutableCopy;
    if (settings != nil)
    {
        [settings setObject:token forKey:kTokenKey];
        NSData *xmlData = [NSPropertyListSerialization dataWithPropertyList:settings format:NSPropertyListXMLFormat_v1_0 options:kCFPropertyListImmutable error:nil];
        return [xmlData writeToFile:plistPath atomically:YES];
    }
    else
        return NO;
}

+ (BOOL)setUsername:(NSString*)username
{
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:kSettingsFileName ofType:@"plist"];
    NSMutableDictionary *settings = [self getSettings].mutableCopy;
    if (settings != nil)
    {
        [settings setObject:username forKey:kUsernameKey];
        NSData *xmlData = [NSPropertyListSerialization dataWithPropertyList:settings format:NSPropertyListXMLFormat_v1_0 options:kCFPropertyListImmutable error:nil];
        return [xmlData writeToFile:plistPath atomically:YES];
    }
    else
        return NO;
}

+ (BOOL)setPassword:(NSString*)password
{
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:kSettingsFileName ofType:@"plist"];
    NSMutableDictionary *settings = [self getSettings].mutableCopy;
    if (settings != nil)
    {
        [settings setObject:password forKey:kPasswordKey];
        NSData *xmlData = [NSPropertyListSerialization dataWithPropertyList:settings format:NSPropertyListXMLFormat_v1_0 options:kCFPropertyListImmutable error:nil];
        return [xmlData writeToFile:plistPath atomically:YES];
    }
    else
        return NO;
}

@end
