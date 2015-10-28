//
//  PersonViewController.m
//  Go2Study
//
//  Created by Ashish Kumar on 12/10/15.
//  Copyright © 2015 Go2Study. All rights reserved.
//

#import "PersonViewController.h"

@interface PersonViewController ()


@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *personTitle;
@property (weak, nonatomic) IBOutlet UILabel *department;


@end

@implementation PersonViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.person) {
        self.name.text = [self.person objectForKey:@"displayName"];
        self.personTitle.text = [self.person objectForKey:@"title"];
        self.department.text = [self.person objectForKey:@"department"];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
