//
//  LoginViewController.m
//  Go2Study
//
//  Created by Ashish Kumar on 07/10/15.
//  Copyright © 2015 Go2Study. All rights reserved.
//

#import "LoginViewController.h"
#import "FontysClient.h"
@import SafariServices;

@interface LoginViewController () <SFSafariViewControllerDelegate, FontysClientDelegate>

@property (nonatomic, strong) FontysClient *fontysClient;
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
    [self saveAccessTokenForURL:url];
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"fhictAccessToken"] != nil) {
        [self setUserProfile];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"authenticated"];
    } else {
        NSLog(@"no access token");
    }
}


#pragma mark - Private

- (void)setUserProfile {
    // Get user's personal data
    [self.fontysClient getUserForPCN:@"me"];
    
    // GET /users/(:pcn) to check if exists in database
    
    // If does not exist, POST
    
    
    
}

- (void)saveAccessTokenForURL:(NSURL *)url {
    NSArray *URLComponents = [[url fragment] componentsSeparatedByString:@"&"];
    NSMutableDictionary *URLParameters = [[NSMutableDictionary alloc] init];
    
    for (NSString *keyValuePair in URLComponents) {
        NSArray *pairComponents = [keyValuePair componentsSeparatedByString:@"="];
        NSString *key = [[pairComponents firstObject] stringByRemovingPercentEncoding];
        NSString *value = [[pairComponents lastObject] stringByRemovingPercentEncoding];
        
        [URLParameters setObject:value forKey:key];
    }
    
    // !TODO: This needs to be stored in the keychain for security
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
    
}

- (void)fontysClient:(FontysClient *)client didFailWithError:(NSError *)error {
    NSLog(@"\n\n\n### LoginViewController::FontysClientDelegate ### \n%@", error);
}

@end
