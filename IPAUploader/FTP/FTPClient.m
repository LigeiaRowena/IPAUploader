//
//  FTPManager.m
//  IPAUploader
//
//  Created by Francesca Corsini on 29/05/15.
//  Copyright (c) 2015 Francesca Corsini. All rights reserved.
//

#import "FTPClient.h"

// url to make a POST request to upload an app via FTP
NSString *const kUploadFTPUrl = @"https://uploader.wuerth-phoenix.com/login.html";

// username for FTP access
NSString *const kFTPUsername = @"pr00156";

// password for FTP access
NSString *const kFTPPassword = @"Objectivec.23";

@implementation FTPClient

#pragma mark - Init & Utility

+ (FTPClient *)sharedHockeyManager {
    static FTPClient *sharedInstance = nil;
    static dispatch_once_t pred;
    
    dispatch_once(&pred, ^{
        sharedInstance = [FTPClient alloc];
        sharedInstance = [sharedInstance init];
    });
    
    return sharedInstance;
}

- (id) init {
    if ((self = [super init])) {
    }
    return self;
}

#pragma mark - FTP requests

+ (NSURLSessionDataTask *)uploadApp:(NSString*)ipaPath releaseNotes:(NSString*)releaseNotes withBlock:(void (^)(id response, NSError *error))block progressBlock:(void (^)(NSProgress *pr))progressBlock
{
    // create multipart IPA data
    NSRange range = [ipaPath rangeOfString:@"/" options:NSBackwardsSearch];
    NSString *fileName = [ipaPath substringFromIndex:range.location+1];
    NSData *data = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:ipaPath]];
   // NSDictionary *headers = @{kAppTokenKey : kAppToken};
    
    NSProgress *progress = [NSProgress progressWithTotalUnitCount:data.length];
    return [self post:kUploadFTPUrl headers:nil parameters:nil progress:progress constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData:data name:@"ipa" fileName:fileName mimeType:@"application/octet-stream ipa"];
        [formData appendPartWithFormData:[@"2" dataUsingEncoding:NSUTF8StringEncoding] name:@"status"];
        [formData appendPartWithFormData:[@"0" dataUsingEncoding:NSUTF8StringEncoding] name:@"notify"];
        [formData appendPartWithFormData:[@"0" dataUsingEncoding:NSUTF8StringEncoding] name:@"release_type"];
        if (releaseNotes)
        {
            [formData appendPartWithFormData:[@"0" dataUsingEncoding:NSUTF8StringEncoding] name:@"notes_type"];
            [formData appendPartWithFormData:[releaseNotes dataUsingEncoding:NSUTF8StringEncoding] name:@"notes"];
        }
        
    } success:^(NSURLSessionDataTask *task, id responseObject) {
        if (block)
            block(responseObject, nil);
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (block)
            block(nil, error);
        
    } progressBlock:^(NSProgress *pr) {
        if (progressBlock)
            progressBlock(pr);
    }];
}

#pragma mark - Generic requests

+ (NSURLSessionDataTask *)post:(NSString*)url headers:(NSDictionary*)headers parameters:(NSDictionary*)parameters progress:(NSProgress*)progress constructingBodyWithBlock:(void (^)(id <AFMultipartFormData> formData))block success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure progressBlock:(void (^)(NSProgress* pr))progressBlock
{
    //AFHTTPSessionManager *session = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:@"rink.hockeyapp.net"]];
    AFHTTPSessionManager *session = [[AFHTTPSessionManager alloc] init];
    NSURLSessionDataTask *datatask = [session POST:url headers:headers parameters:parameters progress:progress constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        if (block)
            block(formData);
        
    } success:^(NSURLSessionDataTask *task, id responseObject) {
        if (success)
            success(task, responseObject);
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (failure)
            failure(task, error);
        
    } progressBlock:^(NSProgress *pr) {
        if (progressBlock)
            progressBlock(pr);
    }];
    
    return datatask;
}



@end
