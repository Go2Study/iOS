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
#import "AppDelegate.h"
#import "User.h"
#import "FontysClient.h"

@interface PeopleTableViewController () <FontysClientDelegate>

@property (nonatomic, strong) G2SApi *g2sAPI;
@property (nonatomic, strong) FHICTOAuth *fhictOAuth;
@property (nonatomic, strong) NSFetchedResultsController *peopleFetchedResultsController;
@property (nonatomic, strong) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, strong) FontysClient *fontysClient;

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
                                                                              managedObjectContext:self.managedObjectContext
                                                                                sectionNameKeyPath:nil
                                                                                         cacheName:nil];
    }
    return _peopleFetchedResultsController;
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
    
    [self.fontysClient getUsers];
    
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
        [self.fontysClient getUsers];
    } else if (sender.selectedSegmentIndex == 2) {      // GET groups
        
    }
    
    [self reloadData];
}

#pragma mark - Private

- (void)reloadData {
    NSError *error;
    if (![self.peopleFetchedResultsController performFetch:&error]) {
        NSLog(@"Perform Fetch Error: %@", [error localizedDescription]);
    }
    
    [self.tableView reloadData];
}

- (void)deleteData {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"User"];
    NSBatchDeleteRequest *deleteRequest = [[NSBatchDeleteRequest alloc] initWithFetchRequest:fetchRequest];
    [self.persistentStoreCoordinator executeRequest:deleteRequest withContext:self.managedObjectContext error:nil];
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
//    cell.photo.image   = [UIImage imageWithData:user.photo];
    
    return cell;
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showPerson"]) {
        PersonTableViewController *personTableViewController = [segue destinationViewController];
        personTableViewController.user = [self.peopleFetchedResultsController objectAtIndexPath:[self.tableView indexPathForCell:sender]];
    }
    
}

#pragma mark - FontysClientDelegate

- (void)fontysClient:(FontysClient *)client didGetUsersData:(id)data {
    NSArray *responseData = (NSArray *)data;
    
    if (responseData) {
        [self deleteData];
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
    
    [self reloadData];
}

- (void)fontysClient:(FontysClient *)client didFailWithError:(NSError *)error {
    NSLog(@"%@", error);
}

@end
