//
//  FHICTOAuth.m
//  Go2Study
//
//  Created by Ashish Kumar on 13/10/15.
//  Copyright © 2015 Go2Study. All rights reserved.
//

#import "FHICTOAuth.h"
#import "AFNetworking.h"
@import UIKit;

@interface FHICTOAuth ()

@property (nonatomic, strong) NSString *clientID;
@property (nonatomic, strong) NSString *scopes;
@property (nonatomic, strong) NSString *callbackURL;

@end


@implementation FHICTOAuth

@synthesize accessToken = _accessToken;

- (NSURL *)oauthURL {
    if (!_oauthURL) {
        _oauthURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://tas.fhict.nl/identity/connect/authorize?client_id=%@&scope=%@&response_type=token&redirect_uri=%@", self.clientID, self.scopes, self.callbackURL]];
    }
    
    return _oauthURL;
}

- (NSString *)clientID {
    if (!_clientID) {
        _clientID = @"i271628-go2study-implicit";
    }
    
    return _clientID;
}

- (NSString *)scopes {
    if (!_scopes) {
        _scopes = @"fhict+fhict_personal+fhict_location";
    }
    
    return _scopes;
}

- (NSString *)callbackURL {
    if (!_callbackURL) {
        _callbackURL = @"go2study://oauth/authorize";
    }
    
    return _callbackURL;
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

#pragma mark - Public API

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

- (BOOL)confirmAuthStatus {
    return self.accessToken ? YES : NO;
}

@end
