//
//  PeopleTableViewController.m
//  Go2Study
//
//  Created by Ashish Kumar on 08/10/15.
//  Copyright © 2015 Go2Study. All rights reserved.
//

#import "PeopleTableViewController.h"
#import "PersonTableViewCell.h"
#import "PersonTableViewController.h"
#import "G2SApi.h"
#import "FHICTOAuth.h"
#import "AFNetworking.h"
#import "UIImageView+AFNetworking.h"

@interface PeopleTableViewController ()

@property (nonatomic, strong) NSArray *people;
@property (nonatomic, strong) G2SApi *g2sAPI;
@property (nonatomic, strong) FHICTOAuth *fhictOAuth;

@end


@implementation PeopleTableViewController

- (G2SApi *)g2sAPI {
    if (!_g2sAPI) {
        _g2sAPI = [[G2SApi alloc] init];
    }
    
    return _g2sAPI;
}

- (FHICTOAuth *)fhictOAuth {
    if (!_fhictOAuth) {
        _fhictOAuth = [[FHICTOAuth alloc] init];
    }
    
    return _fhictOAuth;
}


#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self getStaff];
    self.tableView.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


#pragma mark - Actions

- (IBAction)segmentedControlValueChanged:(UISegmentedControl *)sender {
    self.people = nil;
    
    if (sender.selectedSegmentIndex == 0) {             // GET students
//        [self getStudents];
    } else if (sender.selectedSegmentIndex == 1) {      // GET staff
        [self getStaff];
    } else if (sender.selectedSegmentIndex == 2) {      // GET groups
        
    }
    
    [self.tableView reloadData];
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
    
    [self setStaffPhotoForCell:cell pcn:[person objectForKey:@"id"]];
    
    cell.name.text     = [person objectForKey:@"displayName"];
    cell.subtitle.text = [person objectForKey:@"office"];
    
    return cell;
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showPerson"]) {
        PersonTableViewController *personTableViewController = [segue destinationViewController];
        personTableViewController.person = [self.people objectAtIndex:[[self.tableView indexPathForCell:sender] row]];
    }
    
}


#pragma mark - API Operations

- (void)getStudents {
    NSURL *url = [[NSURL alloc] initWithString:@"users" relativeToURL:self.g2sAPI.apiBaseURL];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        self.people = (NSArray *)responseObject;
        [self.tableView reloadData];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
    
    [operation start];
}

- (void)getStaff {
    NSURL *url = [[NSURL alloc] initWithString:@"people" relativeToURL:self.fhictOAuth.apiBaseURL];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request addValue:[NSString stringWithFormat:@"Bearer %@", self.fhictOAuth.accessToken] forHTTPHeaderField:@"Authorization"];

    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];

    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        self.people = (NSArray *)responseObject;
        [self.tableView reloadData];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
    
    [operation start];
}

- (void)setStaffPhotoForCell:(PersonTableViewCell *)personCell pcn:(NSString *)pcn {
    NSString *endpoint = [NSString stringWithFormat:@"pictures/%@/large", pcn];
    NSURL *url = [[NSURL alloc] initWithString:endpoint relativeToURL:self.fhictOAuth.apiBaseURL];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request addValue:[NSString stringWithFormat:@"Bearer %@", self.fhictOAuth.accessToken] forHTTPHeaderField:@"Authorization"];
    
    [personCell.photo setImageWithURLRequest:request
                      placeholderImage:nil
                               success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                   personCell.photo.image = image;
                                   [personCell setNeedsLayout];
                               }
                               failure:nil];
}

@end
