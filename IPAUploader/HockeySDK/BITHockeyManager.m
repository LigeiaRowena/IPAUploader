//
//  Client.m
//  IPAUploader
//
//  Created by Francesca Corsini on 22/05/15.
//  Copyright (c) 2015 Francesca Corsini. All rights reserved.
//

#import "BITHockeyManager.h"
#import "BITHockeyAppClient.h"

NSString *const kBITHockeySDKURL = @"https://sdk.hockeyapp.net/";
NSString *const kAppIdentifier = @"88b71a2d4a9e637ba858d1636475a438";
NSString *const kAppToken = @"769d1e8f260e48b8a3972f803f14842f";
NSString *const kAppsUrl = @"https://rink.hockeyapp.net/api/2/apps";


#define BITHOCKEY_INTEGRATIONFLOW_TIMESTAMP @"BITIntegrationFlowStartTimestamp"
#define BITHOCKEY_NAME @"HockeySDK"
#define BITHOCKEY_VERSION @"HockeyVersion"

@implementation BITHockeyManager
{
    BITHockeyAppClient *hockeyAppClient;
    NSString *appIdentifier;
    BOOL validAppIdentifier;
}

#pragma mark - Init

+ (BITHockeyManager *)sharedHockeyManager {
    static BITHockeyManager *sharedInstance = nil;
    static dispatch_once_t pred;
    
    dispatch_once(&pred, ^{
        sharedInstance = [BITHockeyManager alloc];
        sharedInstance = [sharedInstance init];
    });
    
    return sharedInstance;
}

- (id) init {
    if ((self = [super init])) {
        //serverURL = nil;
        hockeyAppClient = nil;
    }
    return self;
}

- (void)configureWithIdentifier:(NSString *)_appIdentifier
{
    appIdentifier = [_appIdentifier copy];
    [self initializeModules];
}

- (void)initializeModules
{
    validAppIdentifier = [self checkValidityOfAppIdentifier:appIdentifier];
    if (![self isSetUpOnMainThread])
        return;
    
    if (!validAppIdentifier)
    {
        NSLog(@"[HockeySDK] ERROR: The app id is invalid! Please use the HockeyApp app identifier you find on the apps website on HockeyApp! The SDK is disabled!");
    }
}

- (BOOL)isSetUpOnMainThread {
    if (!NSThread.isMainThread) {
        NSAssert(NSThread.isMainThread, @"ERROR: This SDK has to be setup on the main thread!");
        
        return NO;
    }
    
    return YES;
}

- (BOOL)checkValidityOfAppIdentifier:(NSString *)identifier {
    BOOL result = NO;
    
    if (identifier) {
        NSCharacterSet *hexSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789abcdef"];
        NSCharacterSet *inStringSet = [NSCharacterSet characterSetWithCharactersInString:identifier];
        result = ([identifier length] == 32) && ([hexSet isSupersetOfSet:inStringSet]);
    }
    
    return result;
}

- (void)startManager
{
    if (!validAppIdentifier || ![self isSetUpOnMainThread]) {
        return;
    }
    
    NSString *integrationFlowTime = [self integrationFlowTimeString];
    if (integrationFlowTime && [self integrationFlowStartedWithTimeString:integrationFlowTime]) {
        [self pingServerForIntegrationStartWorkflowWithTimeString:integrationFlowTime];
    }
}

- (NSString *)integrationFlowTimeString {
    NSString *timeString = [[NSBundle mainBundle] objectForInfoDictionaryKey:BITHOCKEY_INTEGRATIONFLOW_TIMESTAMP];
    
    return timeString;
}

- (BOOL)integrationFlowStartedWithTimeString:(NSString *)timeString {
    if (timeString == nil) {
        return NO;
    }
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSLocale *enUSPOSIXLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    [dateFormatter setLocale:enUSPOSIXLocale];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
    NSDate *integrationFlowStartDate = [dateFormatter dateFromString:timeString];
    
    if (integrationFlowStartDate && [integrationFlowStartDate timeIntervalSince1970] > [[NSDate date] timeIntervalSince1970] - (60 * 10) ) {
        return YES;
    }
    
    return NO;
}

- (BITHockeyAppClient *)hockeyAppClient
{
    if (!hockeyAppClient)
        hockeyAppClient = [[BITHockeyAppClient alloc] initWithBaseURL:[NSURL URLWithString:kBITHockeySDKURL]];
    
    return hockeyAppClient;
}

- (void)testIdentifier {
    if (!appIdentifier) {
        return;
    }
    
    NSDate *now = [NSDate date];
    NSString *timeString = [NSString stringWithFormat:@"%.0f", [now timeIntervalSince1970]];
    [self pingServerForIntegrationStartWorkflowWithTimeString:timeString];
}

- (NSString*)getAppIdentifier
{
    return kAppIdentifier;
}

#pragma mark - Request

- (void)pingServerForIntegrationStartWorkflowWithTimeString:(NSString *)timeString
{
    if (!appIdentifier) {
        return;
    }
    
    NSString *integrationPath = [NSString stringWithFormat:@"api/3/apps/%@/integration", [appIdentifier stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSLog(@"INFO: Sending integration workflow ping to %@", integrationPath);
    
    [[self hockeyAppClient] postPath:integrationPath
                          parameters:@{@"timestamp": timeString,
                                       @"sdk": BITHOCKEY_NAME,
                                       @"sdk_version": BITHOCKEY_VERSION,
                                       @"bundle_version": [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"]
                                       }
                          completion:^(BITHTTPOperation *operation, NSData* responseData, NSError *error) {
                              switch (operation.response.statusCode) {
                                  case 400:
                                      NSLog(@"ERROR: App ID not found");
                                      break;
                                  case 201:
                                      NSLog(@"INFO: Ping accepted.");
                                      break;
                                  case 200:
                                      NSLog(@"INFO: Ping accepted. Server already knows.");
                                      break;
                                  default:
                                      NSLog(@"ERROR: Unknown error");
                                      break;
                              }
                          }];
}

// get a list of all the apps with the given token
+ (NSURLSessionDataTask *)getAllAppsWithBlock:(void (^)(id response, NSError *error))block
{
    NSDictionary *headers = @{@"X-HockeyAppToken" : kAppToken};
    return [self get:kAppsUrl headers:headers parameters:nil withBlock:^(id response, NSError *error) {
        if (block)
            block(response, error);
    }];
}

+ (NSURLSessionDataTask *)get:(NSString*)url headers:(NSDictionary*)headers parameters:(NSDictionary*)parameters withBlock:(void (^)(id response, NSError *error))block
{
    //AFHTTPSessionManager *session = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:@"rink.hockeyapp.net"]];
    AFHTTPSessionManager *session = [[AFHTTPSessionManager alloc] init];
    NSURLSessionDataTask *datatask = [session GET:url headers:headers parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
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
