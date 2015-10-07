//
//  LoginViewController.m
//  Go2Study
//
//  Created by Ashish Kumar on 07/10/15.
//  Copyright © 2015 Go2Study. All rights reserved.
//

#import "LoginViewController.h"

@interface LoginViewController ()

@property (weak, nonatomic) IBOutlet UIButton *buttonOAuthLogin;

@end


@implementation LoginViewController

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}


#pragma mark - Actions

- (IBAction)buttonOAuthLoginPressed:(UIButton *)sender {
    NSString *clientID = @"i271628-go2study-implicit";
    NSString *requestedScopes = @"fhict_people+fhict_schedule+fhict_personal+fhict+fhict_location";
    NSString *redirectURI = @"go2study://oauth/authorize";
    
    NSString *oauthURLString = [NSString stringWithFormat:@"https://tas.fhict.nl/identity/connect/authorize?client_id=%@&scope=%@&response_type=token&redirect_uri=%@", clientID, requestedScopes, redirectURI];
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:oauthURLString]];
}


@end
