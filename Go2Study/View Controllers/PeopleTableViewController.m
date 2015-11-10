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
#import "User.h"
#import "AppDelegate.h"

@interface PeopleTableViewController ()

@property (nonatomic, strong) G2SApi *g2sAPI;
@property (nonatomic, strong) FHICTOAuth *fhictOAuth;
@property (nonatomic, strong) AppDelegate *appDelegate;
@property (nonatomic, strong) NSFetchedResultsController *peopleFetchedResultsController;

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

- (NSManagedObjectContext *)managedObjectContext {
    if (!_managedObjectContext) {
        AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        _managedObjectContext = appDelegate.managedObjectContext;
    }
    
    return _managedObjectContext;
}

- (NSFetchedResultsController *)peopleFetchedResultsController {
    if (!_peopleFetchedResultsController) {
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"User"];
        
        NSSortDescriptor *nameSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"displayName" ascending:YES];
        NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:nameSortDescriptor, nil];
        [fetchRequest setSortDescriptors:sortDescriptors];
        
        _peopleFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                              managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    }
    
    return _peopleFetchedResultsController;
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
//    self.people = nil;
    
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
    if ([[self.peopleFetchedResultsController sections] count] > 0) {
        id <NSFetchedResultsSectionInfo> sectionInfo = [[self.peopleFetchedResultsController sections] objectAtIndex:section];
        return [sectionInfo numberOfObjects];
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PersonTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"personCell"];
    
    User *user = [self.peopleFetchedResultsController objectAtIndexPath:indexPath];
    
    cell.name.text     = user.displayName;
    cell.subtitle.text = user.office;
    cell.photo.image   = [UIImage imageWithData:user.photo];
    
    return cell;
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showPerson"]) {
//        PersonTableViewController *personTableViewController = [segue destinationViewController];
//        personTableViewController.person = [self.people objectAtIndex:[[self.tableView indexPathForCell:sender] row]];
    }
    
}


#pragma mark - API Operations

- (void)getStaff {
    NSURL *url = [[NSURL alloc] initWithString:@"people" relativeToURL:self.fhictOAuth.apiBaseURL];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request addValue:[NSString stringWithFormat:@"Bearer %@", self.fhictOAuth.accessToken] forHTTPHeaderField:@"Authorization"];

    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSArray *response = (NSArray *)responseObject;
        
        for (NSDictionary *userDictionary in response) {
            User *user = [NSEntityDescription insertNewObjectForEntityForName:@"User"
                                                       inManagedObjectContext:self.managedObjectContext];
            
            user.firstName   = [userDictionary valueForKey:@"givenName"];
            user.lastName    = [userDictionary valueForKey:@"surName"];
            user.displayName = [userDictionary valueForKey:@"displayName"];
            user.initials    = [userDictionary valueForKey:@"initials"];
            user.mail        = [userDictionary valueForKey:@"mail"];
            user.office      = [userDictionary valueForKey:@"office"];
            user.phone       = [userDictionary valueForKey:@"telephoneNumber"];
            user.pcn         = [userDictionary valueForKey:@"id"];
            user.title       = [userDictionary valueForKey:@"title"];
            
            // Download User Photo
//            NSString *endpoint = [NSString stringWithFormat:@"pictures/%@/large", user.pcn];
//            NSURL *url = [[NSURL alloc] initWithString:endpoint relativeToURL:self.fhictOAuth.apiBaseURL];
//            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
//            [request addValue:[NSString stringWithFormat:@"Bearer %@", self.fhictOAuth.accessToken] forHTTPHeaderField:@"Authorization"];
//            
//            AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
//            operation.responseSerializer = [AFJSONResponseSerializer serializer];
//            
//            [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
//                user.photo = responseObject;
//            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//                NSLog(@"Error: %@", error);
//            }];
            
//            [operation start];
            
            NSError *error;
            if (![self.managedObjectContext save:&error]) {
                NSLog(@"Save Error: %@", [error localizedDescription]);
            }
        }
        
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
