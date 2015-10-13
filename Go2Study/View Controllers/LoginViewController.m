//
//  LoginViewController.m
//  Go2Study
//
//  Created by Ashish Kumar on 07/10/15.
//  Copyright © 2015 Go2Study. All rights reserved.
//

#import "LoginViewController.h"
#import "FHICTOAuth.h"
@import SafariServices;

@interface LoginViewController () <SFSafariViewControllerDelegate>

@property (nonatomic, strong) FHICTOAuth *fhictOAuth;
@property (nonatomic, strong) SFSafariViewController *safariViewController;

@end


@implementation LoginViewController

- (FHICTOAuth *)fhictOAuth {
    if (!_fhictOAuth) {
        _fhictOAuth = [[FHICTOAuth alloc] init];
    }
    
    return _fhictOAuth;
}

- (SFSafariViewController *)safariViewController {
    if (!_safariViewController) {
        _safariViewController = [[SFSafariViewController alloc] initWithURL:[self.fhictOAuth oauthURL]];
        _safariViewController.delegate = self;
    }
    
    return _safariViewController;
}


#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(dismissSafariViewController) name:@"oauthDismissSafariViewController"
                                               object:nil];
}


#pragma mark - Actions

- (IBAction)buttonOAuthLoginPressed:(UIButton *)sender {
    [self presentViewController:self.safariViewController animated:YES completion:nil];
//    [[UIApplication sharedApplication] openURL:[self.fhictOAuth oauthURL]];
}

#pragma mark - Private

- (void)dismissSafariViewController {
    [self.safariViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - SFSafariViewControllerDelegate

- (void)safariViewControllerDidFinish:(SFSafariViewController *)controller {
    [self dismissSafariViewController];
}

@end
