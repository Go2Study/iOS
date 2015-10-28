//
//  PeopleTableViewController.m
//  Go2Study
//
//  Created by Ashish Kumar on 08/10/15.
//  Copyright © 2015 Go2Study. All rights reserved.
//

#import "PeopleTableViewController.h"
#import "FHICTOAuth.h"

@interface PeopleTableViewController ()

@property (nonatomic, strong) NSArray *people;
@property (nonatomic, strong) FHICTOAuth *fhictOAuth;

@end


@implementation PeopleTableViewController

- (FHICTOAuth *)fhictOAuth {
    if (!_fhictOAuth) {
        _fhictOAuth = [[FHICTOAuth alloc] init];
    }
    
    return _fhictOAuth;
}

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self getPeople];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


#pragma mark - Actions

- (IBAction)peopleToggleValueChanged:(UISegmentedControl *)sender {
    NSLog(@"%@", sender);
}



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.people count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"personCell" forIndexPath:indexPath];
    
    NSDictionary *person = [self.people objectAtIndex:[indexPath row]];
    
    cell.textLabel.text = [person objectForKey:@"displayName"];
    cell.detailTextLabel.text = [person objectForKey:@"id"];
    
    return cell;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

#pragma mark - Private

- (void)getPeople {
    self.people = [self.fhictOAuth getJSONFrom:@"people"];
    [self.tableView reloadData];
}

@end
