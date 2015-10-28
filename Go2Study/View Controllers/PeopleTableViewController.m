//
//  PeopleTableViewController.m
//  Go2Study
//
//  Created by Ashish Kumar on 08/10/15.
//  Copyright © 2015 Go2Study. All rights reserved.
//

#import "PeopleTableViewController.h"
#import "PersonTableViewCell.h"
#import "PersonViewController.h"
#import "FHICTOAuth.h"

@interface PeopleTableViewController () <UITableViewDelegate>

@property (nonatomic, strong) NSArray *people;
@property (nonatomic, strong) FHICTOAuth *fhictOAuth;
@property (nonatomic, weak) IBOutlet UISearchBar *searchBar;

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
    self.tableView.delegate = self;
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
    PersonTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"personCell"];
    
    NSDictionary *person = [self.people objectAtIndex:[indexPath row]];
    NSURL *imageURL      = [NSURL URLWithString:[person objectForKey:@"photo"]];
    
    cell.photo.image   = [UIImage imageWithData:[NSData dataWithContentsOfURL:imageURL]];
    cell.name.text     = [person objectForKey:@"displayName"];
    cell.subtitle.text = [person objectForKey:@"office"];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"showPerson" sender:indexPath];
}


#pragma mark - UITableVeiwDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.searchBar resignFirstResponder];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([[segue identifier] isEqualToString:@"showPerson"]) {
        PersonViewController *personViewController = [segue destinationViewController];
        personViewController.person = [self.people objectAtIndex:[(NSIndexPath *)sender row]];
    }
    
}

#pragma mark - Private

- (void)getPeople {
    self.people = [self.fhictOAuth getJSONFrom:@"people"];
    [self.tableView reloadData];
}

@end
