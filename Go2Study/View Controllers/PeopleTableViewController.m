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
#import "AFNetworking.h"
#import "UIImageView+AFNetworking.h"
#import "AppDelegate.h"
#import "User.h"
#import "FontysClient.h"
#import "G2SClient.h"

@interface PeopleTableViewController () <FontysClientDelegate, G2SClientDelegate>

@property (nonatomic, strong) NSFetchedResultsController *staffFetchedResultsController;
@property (nonatomic, strong) NSFetchedResultsController *studentsFetchedResultsController;
@property (nonatomic, strong) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, strong) FontysClient *fontysClient;
@property (nonatomic, strong) G2SClient *g2sClient;

@end


@implementation PeopleTableViewController

#pragma mark - Property Initializers

NSString *currentDisplay = @"staff";

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
        
        NSPredicate *staffPredicate = [NSPredicate predicateWithFormat:@"type == %@", @"students"];
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

- (G2SClient *)g2sClient {
    if (!_g2sClient) {
        _g2sClient = [G2SClient sharedClient];
        _g2sClient.delegate = self;
    }
    return _g2sClient;
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
    
//    [self.fontysClient getUsers];
    
    self.tableView.delegate = self;
    [self reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


#pragma mark - Actions

- (IBAction)segmentedControlValueChanged:(UISegmentedControl *)sender {
    if (sender.selectedSegmentIndex == 0) {             // GET students
        currentDisplay = @"students";
        [self.g2sClient getUsers];
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
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"type == %@", currentDisplay];
    [fetchRequest setPredicate:predicate];
    NSBatchDeleteRequest *deleteRequest = [[NSBatchDeleteRequest alloc] initWithFetchRequest:fetchRequest];
    [self.persistentStoreCoordinator executeRequest:deleteRequest withContext:self.managedObjectContext error:nil];
}

- (void)setStaffPhotoForCell:(PersonTableViewCell *)personCell user:(User *)user {
    NSString *endpoint = [NSString stringWithFormat:@"pictures/%@/large", user.pcn];
    NSURL *url = [[NSURL alloc] initWithString:endpoint relativeToURL:self.fontysClient.apiBaseURL];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request addValue:[NSString stringWithFormat:@"Bearer %@", self.fontysClient.accessToken] forHTTPHeaderField:@"Authorization"];
    
    [personCell.photo setImageWithURLRequest:request
                            placeholderImage:nil
                                     success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                         
                                         user.photo = UIImageJPEGRepresentation(image, 1);
                                         NSError *error;
                                         if (![self.managedObjectContext save:&error]) {
                                             NSLog(@"Save Error: %@", [error localizedDescription]);
                                         }
                                         
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
        cell.photo.image = nil;
    } else if ([currentDisplay isEqualToString:@"staff"]) {
        User *user = [self.staffFetchedResultsController objectAtIndexPath:indexPath];
        
        cell.name.text     = user.displayName;
        cell.subtitle.text = user.office;
        
        if (!user.photo) {
            [self setStaffPhotoForCell:cell user:user];
        } else {
            cell.photo.image = [UIImage imageWithData:user.photo];
        }
    } else if ([currentDisplay isEqualToString:@"groups"]) {
        
    }
    
    return cell;
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showPerson"]) {
        PersonTableViewController *personTableViewController = [segue destinationViewController];
        
        if ([currentDisplay isEqualToString:@"students"]) {
            personTableViewController.user = [self.studentsFetchedResultsController objectAtIndexPath:[self.tableView indexPathForCell:sender]];
        } else if ([currentDisplay isEqualToString:@"staff"]) {
            personTableViewController.user = [self.staffFetchedResultsController objectAtIndexPath:[self.tableView indexPathForCell:sender]];
        } else if ([currentDisplay isEqualToString:@"groups"]) {
            
        }
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

- (void)fontysClient:(FontysClient *)client didGetUserImage:(UIImage *)image forPCN:(NSString *)pcn {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"User"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"pcn == %@", pcn];
    [fetchRequest setPredicate:predicate];
    
    NSSortDescriptor *nameSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"displayName" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:nameSortDescriptor, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    NSFetchedResultsController *fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                                               managedObjectContext:self.managedObjectContext
                                                                                                 sectionNameKeyPath:nil
                                                                                                          cacheName:nil];
    [fetchedResultsController performFetch:nil];
    NSArray *fetchedObjects = [fetchedResultsController fetchedObjects];
    
    User *user = fetchedObjects.firstObject;
    user.photo = UIImageJPEGRepresentation(image, 1);
    
    NSError *error;
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"Save Error: %@", [error localizedDescription]);
    }
    
    [self reloadData];
}

- (void)fontysClient:(FontysClient *)client didFailWithError:(NSError *)error {
    NSLog(@"\n\n\n### PeopleTableViewController::FontysClientDelegate ### \n%@", error);
}


#pragma mark - G2SClientDelegate

- (void)g2sClient:(G2SClient *)client didGetUsersData:(id)data {
    NSArray *responseData = (NSArray *)data;
    
    if (responseData) {
        [self deleteUserData];
    }
    
    for (NSDictionary *userDictionary in responseData) {
        User *user = [NSEntityDescription insertNewObjectForEntityForName:@"User"
                                                   inManagedObjectContext:self.managedObjectContext];
        
        user.firstName   = [userDictionary valueForKey:@"first_name"];
        user.lastName    = [userDictionary valueForKey:@"last_name"];
        user.displayName = [userDictionary valueForKey:@"display_name"];
        user.initials    = [userDictionary valueForKey:@"initials"];
        user.mail        = [userDictionary valueForKey:@"mail"];
        user.office      = [userDictionary valueForKey:@"office"];
        user.phone       = [userDictionary valueForKey:@"phone"];
        user.pcn         = [userDictionary valueForKey:@"pcn"];
        user.department  = [userDictionary valueForKey:@"department"];
        user.type        = @"students";
        
        NSError *error;
        if (![self.managedObjectContext save:&error]) {
            NSLog(@"Save Error: %@", [error localizedDescription]);
        }
    }
    
    [self reloadData];
}

- (void)g2sClient:(G2SClient *)client didFailWithError:(NSError *)error {
    NSLog(@"\n\n\n### PeopleTableViewController::G2SClientDelegate ### \n%@", error);
}

@end
