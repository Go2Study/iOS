//
//  FHICTAPI.m
//  Go2Study
//
//  Created by Ashish Kumar on 10/11/15.
//  Copyright © 2015 Go2Study. All rights reserved.
//

#import "FHICTAPI.h"

@interface FHICTAPI()

@property (nonatomic, strong) NSURL *oauthURL;
@property (nonatomic, strong) NSURL *apiBaseURL;
@property (nonatomic, strong) NSString *accessToken;

@end


@implementation FHICTAPI

#pragma mark - Constants

const NSString *ClientID    = @"i271628-go2study-implicit";
const NSString *Scopes      = @"fhict+fhict_personal+fhict_location";
const NSString *CallbackURL = @"go2study://oauth/authorize";


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
        _apiBaseURL = [[NSURL alloc] initWithString:@"https://tas.fhict.nl:443/api/v1/"];
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


#pragma mark - Public API: Users

- (void)getUsers {
    
}


- (void)getUserPCN:(NSString *)pcn {
    
}

@end
