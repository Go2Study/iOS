//
//  PersonTableViewController.m
//  Go2Study
//
//  Created by Ashish Kumar on 30/10/15.
//  Copyright © 2015 Go2Study. All rights reserved.
//

#import "PersonTableViewController.h"

@interface PersonTableViewController ()

@property (weak, nonatomic) IBOutlet UILabel *labelName;
@property (weak, nonatomic) IBOutlet UILabel *labelTitle;
@property (weak, nonatomic) IBOutlet UILabel *labelDepartment;

@property (weak, nonatomic) IBOutlet UILabel *labelOffice;
@property (weak, nonatomic) IBOutlet UILabel *labelEmail;
@property (weak, nonatomic) IBOutlet UILabel *labelTelephone;

@end


@implementation PersonTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = [NSString stringWithFormat:@"%@ %@", [self.person objectForKey:@"givenName"], [self.person objectForKey:@"surName"]];
    
    self.labelName.text       = [self.person objectForKey:@"displayName"];
    self.labelTitle.text      = [self.person objectForKey:@"title"];
    self.labelDepartment.text = [self.person objectForKey:@"department"];
    
    self.labelOffice.text = [self.person objectForKey:@"office"];
    self.labelEmail.text  = [self.person objectForKey:@"mail"];
    self.labelTelephone.text = [self.person objectForKey:@"telephoneNumber"];
}

@end
