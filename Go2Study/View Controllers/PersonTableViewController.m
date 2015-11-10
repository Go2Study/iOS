//
//  PersonTableViewController.m
//  Go2Study
//
//  Created by Ashish Kumar on 30/10/15.
//  Copyright © 2015 Go2Study. All rights reserved.
//

#import "PersonTableViewController.h"
#import "User.h"

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
    
    self.title = [NSString stringWithFormat:@"%@ %@", self.user.firstName, self.user.lastName];
    
    self.labelName.text       = self.user.displayName;
    self.labelTitle.text      = self.user.title;
    self.labelDepartment.text = self.user.department;
    
    self.labelOffice.text     = self.user.office;
    self.labelEmail.text      = self.user.mail;
    self.labelTelephone.text  = self.user.phone;
}


#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
