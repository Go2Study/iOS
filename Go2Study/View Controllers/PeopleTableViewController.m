//
//  PeopleTableViewController.m
//  Go2Study
//
//  Created by Ashish Kumar on 08/10/15.
//  Copyright © 2015 Go2Study. All rights reserved.
//

#import "PeopleTableViewController.h"
#import "PersonViewController.h"

@interface PeopleTableViewController ()

@property (nonatomic, strong) NSURL *baseURL;
@property (nonatomic, strong) NSArray *people;
@property (nonatomic, strong) NSString *accessToken;

@end


@implementation PeopleTableViewController

- (NSURL *)baseURL {
    if (!_baseURL) {
        _baseURL = [[NSURL alloc] initWithString:@"https://tas.fhict.nl:443/api/v1/"];
    }
    
    return _baseURL;
}

- (NSString *)accessToken {
    if (!_accessToken) {
        _accessToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"fhict-access-token"];
    }
    
    return _accessToken;
}


#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self getPeople];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Actions

- (IBAction)logOutButtonPressed:(UIBarButtonItem *)sender {
     
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

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    UIViewController *viewController = [segue destinationViewController];
    
    if ([viewController isKindOfClass:[PersonViewController class]]) {
//        NSInteger pcn = (UITableViewCell *)sender.
    }
}

#pragma mark - Private

- (void)getPeople {
    NSURL *url = [[NSURL alloc] initWithString:@"people" relativeToURL:self.baseURL];
    self.people = [self getJSONFrom:url];
    [self.tableView reloadData];
}

- (NSArray *)getJSONFrom:(NSURL *)url {
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request addValue:[NSString stringWithFormat:@"Bearer %@", self.accessToken] forHTTPHeaderField:@"Authorization"];
    
    NSError *requestError = [[NSError alloc] init];
    NSError *jsonError = [[NSError alloc] init];
    NSHTTPURLResponse *responseCode = nil;
    
    NSData *requestData = [NSURLConnection sendSynchronousRequest:request returningResponse:&responseCode error:&requestError];
    NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:requestData options:NSJSONReadingMutableContainers error:&jsonError];
    
    return jsonArray;
}

@end
