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
#import "AFNetworking.h"
#import "UIImageView+AFNetworking.h"
#import "AppDelegate.h"
#import "User.h"
#import "FontysClient.h"

@interface PeopleTableViewController () <FontysClientDelegate>

@property (nonatomic, strong) G2SApi *g2sAPI;
@property (nonatomic, strong) NSFetchedResultsController *staffFetchedResultsController;
@property (nonatomic, strong) NSFetchedResultsController *studentsFetchedResultsController;
@property (nonatomic, strong) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, strong) FontysClient *fontysClient;

@end


@implementation PeopleTableViewController

NSString *currentDisplay = @"staff";

- (G2SApi *)g2sAPI {
    if (!_g2sAPI) {
        _g2sAPI = [[G2SApi alloc] init];
    }
    
    return _g2sAPI;
}

- (NSManagedObjectContext *)managedObjectContext {
    if (!_managedObjectContext) {
        AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        _managedObjectContext = appDelegate.managedObjectContext;
    }
    
    return _managedObjectContext;
}

- (NSFetchedResultsController *)staffFetchedResultsController {
    if (!_staffFetchedResultsController) {
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"User"];
        
        NSSortDescriptor *nameSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"displayName" ascending:YES];
        NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:nameSortDescriptor, nil];
        [fetchRequest setSortDescriptors:sortDescriptors];
        
        NSPredicate *staffPredicate = [NSPredicate predicateWithFormat:@"type == %@", @"staff"];
        [fetchRequest setPredicate:staffPredicate];
        
        _staffFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                              managedObjectContext:self.managedObjectContext
                                                                                sectionNameKeyPath:nil
                                                                                         cacheName:nil];
    }
    return _staffFetchedResultsController;
}

- (NSFetchedResultsController *)studentsFetchedResultsController {
    if (!_studentsFetchedResultsController) {
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"User"];
        
        NSSortDescriptor *nameSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"displayName" ascending:YES];
        NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:nameSortDescriptor, nil];
        [fetchRequest setSortDescriptors:sortDescriptors];
        
        NSPredicate *staffPredicate = [NSPredicate predicateWithFormat:@"type == %@", @"student"];
        [fetchRequest setPredicate:staffPredicate];
        
        _studentsFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                             managedObjectContext:self.managedObjectContext
                                                                               sectionNameKeyPath:nil
                                                                                        cacheName:nil];
    }
    return _studentsFetchedResultsController;
}

- (FontysClient *)fontysClient {
    if (!_fontysClient) {
        _fontysClient = [FontysClient sharedClient];
        _fontysClient.delegate = self;
    }
    return _fontysClient;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    if (!_persistentStoreCoordinator) {
        AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        _persistentStoreCoordinator = appDelegate.persistentStoreCoordinator;
    }
    
    return _persistentStoreCoordinator;
}


#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"hasDownloadedStaff"]) {
        [self.fontysClient getUsers];
    }
    
    self.tableView.delegate = self;
    [self reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


#pragma mark - Actions

- (IBAction)segmentedControlValueChanged:(UISegmentedControl *)sender {
//    self.people = nil;
    
    if (sender.selectedSegmentIndex == 0) {             // GET students
        currentDisplay = @"students";
//        [self getStudents];
    } else if (sender.selectedSegmentIndex == 1) {      // GET staff
        currentDisplay = @"staff";
        if (![[NSUserDefaults standardUserDefaults] boolForKey:@"hasDownloadedStaff"]) {
            [self.fontysClient getUsers];
        }
    } else if (sender.selectedSegmentIndex == 2) {      // GET groups
        currentDisplay = @"groups";
    }
    
    [self reloadData];
}

#pragma mark - Private

- (void)reloadData {
    NSError *error;
    
    if ([currentDisplay isEqualToString:@"students"]) {
        if (![self.studentsFetchedResultsController performFetch:&error]) {
            NSLog(@"Perform Fetch Error: %@", [error localizedDescription]);
        }
    } else if ([currentDisplay isEqualToString:@"staff"]) {
        if (![self.staffFetchedResultsController performFetch:&error]) {
            NSLog(@"Perform Fetch Error: %@", [error localizedDescription]);
        }
    } else if ([currentDisplay isEqualToString:@"groups"]) {
        
    }
    
    [self.tableView reloadData];
}

- (void)deleteUserData {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"User"];
    NSBatchDeleteRequest *deleteRequest = [[NSBatchDeleteRequest alloc] initWithFetchRequest:fetchRequest];
    [self.persistentStoreCoordinator executeRequest:deleteRequest withContext:self.managedObjectContext error:nil];
}

- (void)setStaffPhotoForCell:(PersonTableViewCell *)personCell pcn:(NSString *)pcn {
    NSString *endpoint = [NSString stringWithFormat:@"pictures/%@/large", pcn];
    NSURL *url = [[NSURL alloc] initWithString:endpoint relativeToURL:self.fontysClient.apiBaseURL];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request addValue:[NSString stringWithFormat:@"Bearer %@", self.fontysClient.accessToken] forHTTPHeaderField:@"Authorization"];
    
    [personCell.photo setImageWithURLRequest:request
                            placeholderImage:nil
                                     success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                         personCell.photo.image = image;
                                         [personCell setNeedsLayout];
                                     }
                                     failure:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([currentDisplay isEqualToString:@"students"]) {
        if ([[self.studentsFetchedResultsController sections] count] > 0) {
            id <NSFetchedResultsSectionInfo> sectionInfo = [[self.studentsFetchedResultsController sections] objectAtIndex:section];
            return [sectionInfo numberOfObjects];
        }
    } else if ([currentDisplay isEqualToString:@"staff"]) {
        if ([[self.staffFetchedResultsController sections] count] > 0) {
            id <NSFetchedResultsSectionInfo> sectionInfo = [[self.staffFetchedResultsController sections] objectAtIndex:section];
            return [sectionInfo numberOfObjects];
        }
    } else if ([currentDisplay isEqualToString:@"groups"]) {
        
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PersonTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"personCell"];
    
    if ([currentDisplay isEqualToString:@"students"]) {
        User *user = [self.studentsFetchedResultsController objectAtIndexPath:indexPath];
        
        cell.name.text = user.displayName;
        cell.subtitle.text = user.pcn;
    } else if ([currentDisplay isEqualToString:@"staff"]) {
        User *user = [self.staffFetchedResultsController objectAtIndexPath:indexPath];
        
        [self setStaffPhotoForCell:cell pcn:user.pcn];
        
        cell.name.text     = user.displayName;
        cell.subtitle.text = user.office;
    } else if ([currentDisplay isEqualToString:@"groups"]) {
        
    }
    
    return cell;
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showPerson"]) {
        PersonTableViewController *personTableViewController = [segue destinationViewController];
        personTableViewController.user = [self.staffFetchedResultsController objectAtIndexPath:[self.tableView indexPathForCell:sender]];
    }
    
}

#pragma mark - FontysClientDelegate

- (void)fontysClient:(FontysClient *)client didGetUsersData:(id)data {
    NSArray *responseData = (NSArray *)data;
    
    if (responseData) {
        [self deleteUserData];
    }
    
    for (NSDictionary *userDictionary in responseData) {
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
        user.department  = [userDictionary valueForKey:@"department"];
        user.type        = @"staff";
        
        NSError *error;
        if (![self.managedObjectContext save:&error]) {
            NSLog(@"Save Error: %@", [error localizedDescription]);
        }
    }
    
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"hasDownloadedStaff"];
    [self reloadData];
}

- (void)fontysClient:(FontysClient *)client didFailWithError:(NSError *)error {
    NSLog(@"%@", error);
}

@end
