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
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(oauthSuccessful)
                                                 name:@"oauthSuccessful"
                                               object:nil];
}


#pragma mark - Actions

- (IBAction)buttonOAuthLoginPressed:(UIButton *)sender {
    [self presentViewController:self.safariViewController animated:YES completion:nil];
}


#pragma mark - Public

- (void)setUserProfile {
    // Get user's personal data
    [self.fontysClient getUserForPCN:@"me"];
    
    // GET /users/(:pcn) to check if exists in database
    
    // If does not exist, POST
}


#pragma mark - Private

- (void)oauthSuccessful {
    [self dismissSafariViewController];
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
    NSLog(@"%@", data);
}

- (void)fontysClient:(FontysClient *)client didFailWithError:(NSError *)error {
    NSLog(@"%@", error);
}

@end
