//
//  FontysClient.m
//  Go2Study
//
//  Created by Ashish Kumar on 10/11/15.
//  Copyright © 2015 Go2Study. All rights reserved.
//

#import "FontysClient.h"

@interface FontysClient()

@property (nonatomic, strong) NSURL *oauthURL;
@property (nonatomic, strong) NSURL *apiBaseURL;
@property (nonatomic, strong) NSString *accessToken;

@end

@implementation FontysClient

#pragma mark - Constants

const NSString *ClientID    = @"i271628-go2study-implicit";
const NSString *Scopes      = @"fhict+fhict_personal+fhict_location";
const NSString *CallbackURL = @"go2study://oauth/authorize";

static NSString * const apiBaseURLString = @"https://tas.fhict.nl:443/api/v1/";

#pragma mark - Initializers

@synthesize accessToken = _accessToken;


- (NSURL *)oauthURL {
    if (!_oauthURL) {
        _oauthURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://tas.fhict.nl/identity/connect/authorize?client_id=%@&scope=%@&response_type=token&redirect_uri=%@", ClientID, Scopes, CallbackURL]];
    }
    return _oauthURL;
}

- (NSURL *)apiBaseURL {
    if (!_apiBaseURL) {
        _apiBaseURL = [[NSURL alloc] initWithString:apiBaseURLString];
    }
    return _apiBaseURL;
}

- (NSString *)accessToken {
    if (!_accessToken) {
        _accessToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"fhictAccessToken"];
    }
    return _accessToken;
}

- (void)setAccessToken:(NSString *)accessToken {
    _accessToken = accessToken;
    [[NSUserDefaults standardUserDefaults] setObject:accessToken forKey:@"fhictAccessToken"];
}


#pragma mark - FontysClient

+ (FontysClient *)sharedClient {
    static FontysClient *_sharedClient = nil;
    NSString *accessToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"fhictAccessToken"];
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSURL *url = [NSURL URLWithString:apiBaseURLString];
        
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        NSDictionary *headers = [NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"Bearer %@", accessToken] forKey:@"Authorization"];
        configuration.HTTPAdditionalHeaders = headers;
        
        _sharedClient = [[self alloc] initWithBaseURL:url sessionConfiguration:configuration];
    });
    
    return _sharedClient;
}

- (instancetype)initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];
    
    if (self) {
        self.responseSerializer = [AFJSONResponseSerializer serializer];
        self.requestSerializer  = [AFJSONRequestSerializer serializer];
    }
    
    return self;
}


#pragma mark - Access Token

- (void)saveAccessToken:(NSURL *)url {
    NSArray *URLComponents = [[url fragment] componentsSeparatedByString:@"&"];
    NSMutableDictionary *URLParameters = [[NSMutableDictionary alloc] init];
    
    for (NSString *keyValuePair in URLComponents) {
        NSArray *pairComponents = [keyValuePair componentsSeparatedByString:@"="];
        NSString *key = [[pairComponents firstObject] stringByRemovingPercentEncoding];
        NSString *value = [[pairComponents lastObject] stringByRemovingPercentEncoding];
        
        [URLParameters setObject:value forKey:key];
    }
    
    // !TODO: This needs to be stored in the keychain for security
    self.accessToken = [URLParameters objectForKey:@"access_token"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"oauthDismissSafariViewController" object:nil];
}

- (BOOL)accessTokenExists {
    return self.accessToken ? YES : NO;
}


#pragma mark - Users

- (void)getUsers {
    [self GET:@"people"
   parameters:nil
      success:^(NSURLSessionDataTask *task, id responseObject) {
          if ([self.delegate respondsToSelector:@selector(fontysClient:didGetUsersData:)]) {
              [self.delegate fontysClient:self didGetUsersData:responseObject];
          }
      } failure:^(NSURLSessionDataTask *task, NSError *error) {
          if ([self.delegate respondsToSelector:@selector(fontysClient:didFailWithError:)]) {
              [self.delegate fontysClient:self didFailWithError:error];
          }
      }];
}

- (void)getUserForPCN:(NSString *)pcn {
    [self GET:[NSString stringWithFormat:@"people/%@", pcn]
   parameters:nil
      success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
          if ([self.delegate respondsToSelector:@selector(fontysClient:didGetUserData:forPCN:)]) {
              [self.delegate fontysClient:self didGetUserData:responseObject forPCN:pcn];
          }
      } failure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
          if ([self.delegate respondsToSelector:@selector(fontysClient:didFailWithError:)]) {
              [self.delegate fontysClient:self didFailWithError:error];
          }
      }];
}


@end
