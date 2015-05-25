//
//  Client.m
//  IPAUploader
//
//  Created by Francesca Corsini on 22/05/15.
//  Copyright (c) 2015 Francesca Corsini. All rights reserved.
//

#import "Client.h"

@implementation Client

+ (NSURLSessionDataTask *)getWithBlock:(void (^)(id response, NSError *error))block
{
    AFHTTPSessionManager *session = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:@"rink.hockeyapp.net"]];
    NSURLSessionDataTask *datatask = [session GET:@"http://francescacorsini.altervista.org/RadioRai/dettaglio_programma.json" parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        if (block)
            block(responseObject, nil);
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (block)
            block(nil, error);
    }];
    
    return datatask;
}


+ (NSURLSessionDataTask *)postWithBlock:(void (^)(id response, NSError *error))block
{
    AFHTTPSessionManager *session = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:@"rink.hockeyapp.net"]];
    NSURLSessionDataTask *datatask = [session POST:@"" parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        //
    } success:^(NSURLSessionDataTask *task, id responseObject) {
        if (block)
            block(responseObject, nil);
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (block)
            block(nil, error);
    }];
    
    return datatask;
}
 


@end
