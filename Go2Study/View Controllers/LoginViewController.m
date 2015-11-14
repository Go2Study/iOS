//
//  LoginViewController.m
//  Go2Study
//
//  Created by Ashish Kumar on 07/10/15.
//  Copyright © 2015 Go2Study. All rights reserved.
//

#import "LoginViewController.h"
#import "FontysClient.h"
#import "G2SClient.h"
@import SafariServices;

@interface LoginViewController () <FontysClientDelegate, G2SClientDelegate, SFSafariViewControllerDelegate>

@property (nonatomic, weak) FontysClient *fontysClient;
@property (nonatomic, weak) G2SClient *g2sClient;
@property (nonatomic, strong) SFSafariViewController *safariViewController;

@end


@implementation LoginViewController

- (FontysClient *)fontysClient {
    if (!_fontysClient) {
        _fontysClient = [FontysClient sharedClient];
        _fontysClient.delegate = self;
    }
    return _fontysClient;
}

- (G2SClient *)g2sClient {
    if (!_g2sClient) {
        _g2sClient = [G2SClient sharedClient];
        _g2sClient.delegate = self;
    }
    return _g2sClient;
}

- (SFSafariViewController *)safariViewController {
    if (!_safariViewController) {
        _safariViewController = [[SFSafariViewController alloc] initWithURL:self.fontysClient.oauthURL];
        _safariViewController.delegate = self;
    }
    return _safariViewController;
}


#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}


#pragma mark - Actions

- (IBAction)buttonOAuthLoginPressed:(UIButton *)sender {
    [self presentViewController:self.safariViewController animated:YES completion:nil];
}


#pragma mark - Public

- (void)oauthSuccessfulWithURL:(NSURL *)url {
    [self dismissSafariViewController];
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"fhictAccessToken"] == nil) {
        [self saveAccessTokenForURL:url];
    }
    
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"fhictAccessToken"] != nil) {
        [self.fontysClient getUserForPCN:@"me"];
//        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"authenticated"];
    } else {
        NSLog(@"no access token");
    }
}


#pragma mark - Private

- (void)saveAccessTokenForURL:(NSURL *)url {
    NSArray *URLComponents = [[url fragment] componentsSeparatedByString:@"&"];
    NSMutableDictionary *URLParameters = [[NSMutableDictionary alloc] init];
    
    for (NSString *keyValuePair in URLComponents) {
        NSArray *pairComponents = [keyValuePair componentsSeparatedByString:@"="];
        NSString *key = [[pairComponents firstObject] stringByRemovingPercentEncoding];
        NSString *value = [[pairComponents lastObject] stringByRemovingPercentEncoding];
        
        [URLParameters setObject:value forKey:key];
    }
    
    self.fontysClient = nil; // reset the object so we can store access token
    self.fontysClient.accessToken = [URLParameters objectForKey:@"access_token"];
}

- (void)dismissSafariViewController {
    [self.safariViewController dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - SFSafariViewControllerDelegate

- (void)safariViewControllerDidFinish:(SFSafariViewController *)controller {
    [self dismissSafariViewController];
}


#pragma mark - FontysClientDelegate

- (void)fontysClient:(FontysClient *)client didGetUserData:(id)data forPCN:(NSString *)pcn {
    NSString *personalPCN = [(NSDictionary *)data objectForKey:@"id"];
    [[NSUserDefaults standardUserDefaults] setObject:personalPCN forKey:@"personalPCN"];
    [self.g2sClient getUserForPCN:personalPCN];
}

- (void)fontysClient:(FontysClient *)client didFailWithError:(NSError *)error {
    NSLog(@"\n\n\n### LoginViewController::FontysClientDelegate ### \n%@", error);
}


#pragma mark - G2SClientDelegate

- (void)g2sClient:(G2SClient *)client didGetUserData:(id)data forPCN:(NSString *)pcn {
    // If we get data, just proceed for now :)
    NSDictionary *responseData = data;
    if ([responseData objectForKey:@"error"] != nil && [[[responseData objectForKey:@"error"] objectForKey:@"code"] isEqualToNumber:[NSNumber numberWithInt:404]]) {
//        self.g2sClient post
    } else if (data != nil) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"authenticated"];
    }
}

- (void)g2sClient:(G2SClient *)client didPostUserWithResponse:(id)response {
    
}

- (void)g2sClient:(G2SClient *)client didFailWithError:(NSError *)error {
    
}

@end
