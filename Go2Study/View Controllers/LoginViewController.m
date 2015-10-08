//
//  LoginViewController.m
//  Go2Study
//
//  Created by Ashish Kumar on 07/10/15.
//  Copyright © 2015 Go2Study. All rights reserved.
//

#import "LoginViewController.h"
@import SafariServices;

@interface LoginViewController ()

@property (weak, nonatomic) IBOutlet UIButton *buttonOAuthLogin;
@property (strong, nonatomic) SFSafariViewController *safariViewController;

@end


@implementation LoginViewController

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}


#pragma mark - Actions

- (IBAction)buttonOAuthLoginPressed:(UIButton *)sender {
    NSString *clientID = @"i271628-go2study-implicit";
    NSString *requestedScopes = @"fhict_personal+fhict+fhict_location";
    NSString *redirectURI = @"go2study://oauth/authorize";
    
    NSString *oauthURLString = [NSString stringWithFormat:@"https://tas.fhict.nl/identity/connect/authorize?client_id=%@&scope=%@&response_type=token&redirect_uri=%@", clientID, requestedScopes, redirectURI];
    
    [self openURLinSafariViewController:[NSURL URLWithString:oauthURLString]];
    
//    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:oauthURLString]];
}

#pragma mark - Private

- (void)openURLinSafariViewController:(NSURL *)url {
    self.safariViewController = [[SFSafariViewController alloc] initWithURL:url];
    [self presentViewController:self.safariViewController animated:YES completion:nil];
}

- (void)dismissSafariViewController {
    [self.safariViewController dismissViewControllerAnimated:YES completion:nil];
}


@end
