//
//  FontysClient.m
//  Go2Study
//
//  Created by Ashish Kumar on 10/11/15.
//  Copyright © 2015 Go2Study. All rights reserved.
//

#import "FontysClient.h"
@import SafariServices;

@interface FontysClient () <SFSafariViewControllerDelegate>
@property (nonatomic, strong) SFSafariViewController *safariViewController;
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

- (SFSafariViewController *)safariViewController {
    if (!_safariViewController) {
        _safariViewController = [[SFSafariViewController alloc] initWithURL:self.oauthURL];
        _safariViewController.delegate = self;
    }
    return _safariViewController;
}


#pragma mark - FontysClient

+ (FontysClient *)sharedClient {
    static FontysClient *_sharedClient = nil;
    NSString *accessToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"fhictAccessToken"];
    
    static dispatch_once_t onceToken;
    
    // Don't create a singleton if we access token does not exist.
    if (accessToken) {
        dispatch_once(&onceToken, ^{
            NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
            NSDictionary *headers = [NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"Bearer %@", accessToken] forKey:@"Authorization"];
            configuration.HTTPAdditionalHeaders = headers;
            
            _sharedClient = [[self alloc] initWithBaseURL:[NSURL URLWithString:apiBaseURLString]
                                     sessionConfiguration:configuration];
        });
    } else {
        _sharedClient = [[self alloc] initWithBaseURL:[NSURL URLWithString:apiBaseURLString]];
    }
    
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


#pragma mark - OAuth

- (void)presentLoginPage {
    
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

#pragma mark - Images

- (void)getUserImageForPCN:(NSString *)pcn {
    NSString *endpoint = [NSString stringWithFormat:@"pictures/%@/large", pcn];
    NSURL *url = [[NSURL alloc] initWithString:endpoint relativeToURL:self.apiBaseURL];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request addValue:[NSString stringWithFormat:@"Bearer %@", self.accessToken] forHTTPHeaderField:@"Authorization"];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFImageResponseSerializer serializer];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([self.delegate respondsToSelector:@selector(fontysClient:didGetUserImage:forPCN:)]) {
            [self.delegate fontysClient:self didGetUserImage:responseObject forPCN:pcn];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if ([self.delegate respondsToSelector:@selector(fontysClient:didFailWithError:)]) {
            [self.delegate fontysClient:self didFailWithError:error];
        }
    }];
    
    [operation start];
}

@end
