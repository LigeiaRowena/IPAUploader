//
//  Client.m
//  IPAUploader
//
//  Created by Francesca Corsini on 22/05/15.
//  Copyright (c) 2015 Francesca Corsini. All rights reserved.
//

#import "BITHockeyManager.h"
#import "BITHockeyAppClient.h"

static char *alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

NSString *const kBITHockeySDKURL = @"https://sdk.hockeyapp.net/";

// app id taken from the App detail in hockeyapp (only for the ping)
// ex: Speedy W-BE
NSString *const kAppIdentifier = @"995ec078810124dae72fe0d117d1be36";


// token for the hockeyapp account
//NSString *const kAppToken = @"0fb12912ba344081b41495c0f60d66f1";

// token key for the HTTPHeaderField
NSString *const kAppTokenKey = @"X-HockeyAppToken";

// url to get infos about all the apps
NSString *const kAppsUrl = @"https://rink.hockeyapp.net/api/2/apps";

// url to make a POST request to upload an app
NSString *const kUploadAppUrl = @"https://rink.hockeyapp.net/api/2/apps/upload";

// url to make the auth and get the token
NSString *const kAuthUrl = @"https://rink.hockeyapp.net/api/2/auth_tokens";


#define BITHOCKEY_INTEGRATIONFLOW_TIMESTAMP @"BITIntegrationFlowStartTimestamp"
#define BITHOCKEY_NAME @"HockeySDK"
#define BITHOCKEY_VERSION @"HockeyVersion"

@implementation BITHockeyManager
{
    BITHockeyAppClient *hockeyAppClient;
    NSString *appIdentifier;
    BOOL validAppIdentifier;
    NSString *token;
}

#pragma mark - Init & Utility

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
        hockeyAppClient = nil;
    }
    return self;
}

- (void)configureWithAppIdentifier
{
    appIdentifier = [[self getAppIdentifier] copy];
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

- (void)setToken:(NSString*)_token
{
    token = _token;
}

- (NSString*)getToken
{
    return token;
}

#pragma mark - HockeyApp requests

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
+ (NSURLSessionDataTask *)getAllAppsWithToken:(NSString*)_token block:(void (^)(id response, NSError *error))block
{
    NSDictionary *headers = @{kAppTokenKey : _token};
    return [self get:kAppsUrl headers:headers parameters:nil withBlock:^(id response, NSError *error) {
        if (block)
            block(response, error);
    }];
}

// login with email and password in order to get a token
+ (NSURLSessionDataTask *)loginWithEmail:(NSString*)email password:(NSString*)password block:(void (^)(id response, NSError *error))block
{
    // encoding credentials
    NSString *loginString = [@"" stringByAppendingFormat:@"%@:%@", email, password];
    NSString *encodedLoginData = [BITHockeyManager encode:[loginString dataUsingEncoding:NSUTF8StringEncoding]];
    NSString *authHeader = [@"Basic " stringByAppendingFormat:@"%@", encodedLoginData];
    NSDictionary *headers = @{@"Authorization" : authHeader};

    return [self get:kAuthUrl headers:headers parameters:nil withBlock:^(id response, NSError *error) {
        if (block)
            block(response, error);
    }];
}

+ (NSString *)encode:(NSData *)plainText {
    int encodedLength = (4 * (([plainText length] / 3) + (1 - (3 - ([plainText length] % 3)) / 3))) + 1;
    unsigned char *outputBuffer = malloc(encodedLength);
    unsigned char *inputBuffer = (unsigned char *)[plainText bytes];
    
    NSInteger i;
    NSInteger j = 0;
    int remain;
    
    for(i = 0; i < [plainText length]; i += 3) {
        remain = [plainText length] - i;
        
        outputBuffer[j++] = alphabet[(inputBuffer[i] & 0xFC) >> 2];
        outputBuffer[j++] = alphabet[((inputBuffer[i] & 0x03) << 4) |
                                     ((remain > 1) ? ((inputBuffer[i + 1] & 0xF0) >> 4): 0)];
        
        if(remain > 1)
            outputBuffer[j++] = alphabet[((inputBuffer[i + 1] & 0x0F) << 2)
                                         | ((remain > 2) ? ((inputBuffer[i + 2] & 0xC0) >> 6) : 0)];
        else
            outputBuffer[j++] = '=';
        
        if(remain > 2)
            outputBuffer[j++] = alphabet[inputBuffer[i + 2] & 0x3F];
        else
            outputBuffer[j++] = '=';
    }
    
    outputBuffer[j] = 0;
    
    NSString *result = [NSString stringWithCString:outputBuffer length:strlen(outputBuffer)];
    free(outputBuffer);
    
    return result;
}

// upload an app to an existing one or a new app
+ (NSURLSessionDataTask *)uploadApp:(NSString*)ipaPath releaseNotes:(NSString*)releaseNotes token:(NSString*)_token withBlock:(void (^)(id response, NSError *error))block progressBlock:(void (^)(NSProgress *pr))progressBlock
{
    // create multipart IPA data
    NSRange range = [ipaPath rangeOfString:@"/" options:NSBackwardsSearch];
    NSString *fileName = [ipaPath substringFromIndex:range.location+1];
    NSData *data = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:ipaPath]];
    NSDictionary *headers = @{kAppTokenKey : _token};
    
    NSProgress *progress = [NSProgress progressWithTotalUnitCount:data.length];
    return [self post:kUploadAppUrl headers:headers parameters:nil progress:progress constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
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

+ (NSURLSessionDataTask *)get:(NSString*)url headers:(NSDictionary*)headers parameters:(NSDictionary*)parameters withBlock:(void (^)(id response, NSError *error))block
{
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

+ (NSURLSessionDataTask *)post:(NSString*)url headers:(NSDictionary*)headers parameters:(NSDictionary*)parameters progress:(NSProgress*)progress constructingBodyWithBlock:(void (^)(id <AFMultipartFormData> formData))block success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure progressBlock:(void (^)(NSProgress* pr))progressBlock
{
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


+ (NSURLSessionDataTask *)post:(NSString*)url headers:(NSDictionary*)headers parameters:(NSDictionary*)parameters constructingBodyWithBlock:(void (^)(id <AFMultipartFormData> formData))block success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure
{
    AFHTTPSessionManager *session = [[AFHTTPSessionManager alloc] init];
    NSURLSessionDataTask *datatask = [session POST:url headers:headers parameters:parameters progress:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        if (block)
            block(formData);
        
    } success:^(NSURLSessionDataTask *task, id responseObject) {
        if (success)
            success(task, responseObject);
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (failure)
            failure(task, error);
        
    } progressBlock:^(NSProgress *pr) {
    }];
    
    return datatask;
}




@end
