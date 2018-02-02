//
//  DGRFindFriendsViewController.m
//  Paiir
//
//  Created by Moritz Kremb on 19/09/14.
//  Copyright (c) 2014 Kremb. All rights reserved.
//

#import "DGRFindFriendsViewController.h"
#import "MBProgressHUD.h"
#import "DGRConstants.h"
#import "DGRHighlightsViewController.h"
#import "DGRHomeViewController.h"


@interface DGRFindFriendsViewController () <UISearchDisplayDelegate, UISearchBarDelegate>

@property (nonatomic, retain) NSMutableArray *searchResults;
@property (nonatomic, retain) NSMutableArray *dataSourceArray;

@property (nonatomic, retain) NSMutableDictionary *suggestedUserToPhotos;
@property (nonatomic, retain) NSMutableDictionary *suggestedUserToHighlightPhotos;
@property (nonatomic, retain) NSMutableDictionary *suggestedUsersToPaiirScore;

@property (nonatomic, retain) NSMutableDictionary *searchedUserToPhotos;
@property (nonatomic, retain) NSMutableDictionary *searchedUserToHighlightPhotos;
@property (nonatomic, retain) NSMutableDictionary *searchedUsersToPaiirScore;

@property BOOL somethingChanged;

- (IBAction)doneButtonAction:(id)sender;

@end

#pragma mark - init

@implementation DGRFindFriendsViewController

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        
        self.parseClassName = @"User";
        self.textKey = @"username";
        self.imageKey = @"image";
        self.pullToRefreshEnabled = YES;
        self.paginationEnabled = NO;
        self.objectsPerPage = 30;
        
        self.searchResults = [NSMutableArray array];
        
        self.suggestedUserToPhotos = [NSMutableDictionary dictionary];
        self.suggestedUserToHighlightPhotos = [NSMutableDictionary dictionary];
        self.suggestedUsersToPaiirScore = [NSMutableDictionary dictionary];

        self.searchedUserToPhotos = [NSMutableDictionary dictionary];
        self.searchedUserToHighlightPhotos = [NSMutableDictionary dictionary];
        self.searchedUsersToPaiirScore = [NSMutableDictionary dictionary];


    }
    return self;
    
}

- (id)initWithCoder:(NSCoder *)aCoder {
    self = [super initWithCoder:aCoder];
    if (self) {
        
        self.parseClassName = @"User";
        self.textKey = @"username";
        self.imageKey = @"image";
        self.pullToRefreshEnabled = YES;
        self.paginationEnabled = NO;
        self.objectsPerPage = 30;
        
        self.searchResults = [NSMutableArray array];
        
        self.suggestedUserToPhotos = [NSMutableDictionary dictionary];
        self.suggestedUserToHighlightPhotos = [NSMutableDictionary dictionary];
        self.suggestedUsersToPaiirScore = [NSMutableDictionary dictionary];
        
        self.searchedUserToPhotos = [NSMutableDictionary dictionary];
        self.searchedUserToHighlightPhotos = [NSMutableDictionary dictionary];
        self.searchedUsersToPaiirScore = [NSMutableDictionary dictionary];


    }
    return self;
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // nav bar
    //[self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"FindFriendsPageNavBar.png"] forBarMetrics:UIBarMetricsDefault];
    //[self.navigationController.navigationBar setTranslucent:NO];
    
    // row height in SDC
    [self.searchDisplayController.searchResultsTableView setRowHeight:self.tableView.rowHeight];
    [self.searchDisplayController.searchResultsTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    //[self loadObjects];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UISearchViewDelegate

- (void)filterResults:(NSString *)searchTerm {
    
    [self.searchResults removeAllObjects];
    
    PFQuery *allFollowing = [PFQuery queryWithClassName:@"Activity"];
    [allFollowing whereKey:@"fromUser" equalTo:[PFUser currentUser]];
    [allFollowing whereKey:@"type" equalTo:@"follow"];
    
    PFQuery *searchQuery = [PFUser query];
    [searchQuery whereKeyExists:@"username"];
    [searchQuery whereKey:@"username" notEqualTo:[PFUser currentUser].username];
    [searchQuery whereKey:@"objectId" doesNotMatchKey:@"toUserObjectId" inQuery:allFollowing];
    [searchQuery whereKey:@"username" matchesRegex:searchTerm modifiers:@"i"];
    searchQuery.cachePolicy = kPFCachePolicyNetworkOnly;
    
    MBProgressHUD *searchingHUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    searchingHUD.mode = MBProgressHUDModeIndeterminate;
    searchingHUD.labelText = @"Searching...";
    [searchingHUD show:YES];
    
    [searchQuery findObjectsInBackgroundWithBlock:^(NSArray *results, NSError *error){
        
        [searchingHUD hide:YES];

        NSLog(@"Search Results: %@", results);
        NSLog(@"Search Result count: %ld", (unsigned long)results.count);
        
        [self.searchResults addObjectsFromArray:results];
        [self.searchDisplayController.searchResultsTableView reloadData];
        
    }];
    /*
    // highlights Photos for searched users
    PFQuery *searchedUsersHighlightPhotos = [PFQuery queryWithClassName:@"Activity"];
    [searchedUsersHighlightPhotos whereKey:@"type" equalTo:@"highlight"];
    [searchedUsersHighlightPhotos whereKey:@"fromUserObjectId" matchesKey:@"objectId" inQuery:searchQuery];
    [searchedUsersHighlightPhotos includeKey:@"fromUser"];
    [searchedUsersHighlightPhotos includeKey:@"photoPointer.completor"];
    [searchedUsersHighlightPhotos includeKey:@"photoPointer.owner"];
    [searchedUsersHighlightPhotos includeKey:@"photoPointer.imageToComplete"];
    
    searchedUsersHighlightPhotos.cachePolicy = kPFCachePolicyNetworkOnly;
    [searchedUsersHighlightPhotos addDescendingOrder:@"createdAt"];
    [searchedUsersHighlightPhotos findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            // The find succeeded.
            NSLog(@"Retrieved %ld searched user Highlight Photo Objects.", (long)objects.count);
            [self.searchedUserToHighlightPhotos removeAllObjects];
            
            
            for (PFObject *object in objects) {
                PFUser *photoOwner = [object objectForKey:@"fromUser"];
                NSString *username = [photoOwner objectForKey:@"username"];
                
                NSMutableArray *objectsForUsername = [self.searchedUserToHighlightPhotos objectForKey:username];
                if (!objectsForUsername) {
                    objectsForUsername = [NSMutableArray array];
                    [objectsForUsername addObject:[object objectForKey:@"photoPointer"]];
                }
                else {
                    [objectsForUsername addObject:[object objectForKey:@"photoPointer"]];
                }
                
                [self.searchedUserToHighlightPhotos setObject:objectsForUsername forKey:username];
            }
            
            [self.searchDisplayController.searchResultsTableView reloadData];

            
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
    */
    
    // searched users paiir score
    PFQuery *searchedUsersPaiirScoreQuery = [PFQuery queryWithClassName:@"PaiirScore"];
    [searchedUsersPaiirScoreQuery whereKey:@"userObjectId" matchesKey:@"objectId" inQuery:searchQuery];
    [searchedUsersPaiirScoreQuery includeKey:@"user"];
    
    searchedUsersPaiirScoreQuery.cachePolicy = kPFCachePolicyNetworkOnly;
    [searchedUsersPaiirScoreQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            // The find succeeded.
            NSLog(@"Retrieved %ld suggested users Paiir Objects.", (long)objects.count);
            [self.searchedUsersToPaiirScore removeAllObjects];
            
            for (PFObject *object in objects) {
                PFUser *user = [object objectForKey:@"user"];
                NSString *username = [user objectForKey:@"username"];
                
                [self.searchedUsersToPaiirScore setObject:object forKey:username];
            }
            
            [self.searchDisplayController.searchResultsTableView reloadData];
            
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];



    
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self filterResults:searchBar.text];
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    //[self filterResults:searchString];
    return NO;
}

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {

    if ([tableView isEqual:self.searchDisplayController.searchResultsTableView]) {
        
        // create
        DGRFindFriendsCell *cell = (DGRFindFriendsCell *)[self.tableView dequeueReusableCellWithIdentifier:@"FindFriendsCell"]; // possibly unstable
        
        // fix content offset
        if (cell.scrollView.contentOffset.x != kCatchWidth) {
            [cell.scrollView setContentOffset:CGPointMake(kCatchWidth, 0) animated:NO];
        }
        
        // fix label position
        cell.highlightButton.frame = CGRectMake(320, 0, 60, 60);
        cell.instructionsLabel.frame = CGRectMake(75, 35, 200, 15);
        cell.paiirScoreLabel.frame = CGRectMake(75, 70, 125, 15);
        
        // set up        
        PFUser *user = [self.searchResults objectAtIndex:indexPath.row];
        NSString *username = [user objectForKey:@"username"];

        cell.delegate = self;
        cell.thisUser = user;
        cell.tableView = tableView;
        
        // Profile Picture
        cell.profilePictureView.image = [UIImage imageNamed:@"ProfilePicturePlaceholder.png"];
        cell.profilePictureView.file = [user objectForKey:@"profilePicture"];
        [cell.profilePictureView loadInBackground];
        
        // Username
        cell.followingUser.text = username;
        
        // Highlight Button
        [cell highlightHighlightButton];

        // Paiir score Label
        cell.paiirScoreLabel.text = [self setPaiirScoreForSearchedUser:username];
        
        return cell;
        
    }
    
    else {
        
        if (indexPath.section == 0) {
            
            if (indexPath.row == 0) {
                UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"Facebook" forIndexPath:indexPath];
                return cell;
                
            }
            
        }
        
        else {
            DGRFindFriendsCell *cell = (DGRFindFriendsCell *)[tableView dequeueReusableCellWithIdentifier:@"FindFriendsCell" forIndexPath:indexPath];
            
            // fix content offset
            if (cell.scrollView.contentOffset.x != kCatchWidth) {
                [cell.scrollView setContentOffset:CGPointMake(kCatchWidth, 0) animated:NO];
            }
            
            // fix label position
            cell.highlightButton.frame = CGRectMake(320, 0, 60, 60);
            cell.instructionsLabel.frame = CGRectMake(75, 35, 200, 15);
            cell.paiirScoreLabel.frame = CGRectMake(75, 70, 125, 15);
            
            // set up
            NSString *username = [object objectForKey:@"username"];
            cell.delegate = self;
            cell.thisUser = (PFUser *)object;
            cell.tableView = tableView;
            
            // Profile Picture
            cell.profilePictureView.image = [UIImage imageNamed:@"ProfilePicturePlaceholder.png"];
            cell.profilePictureView.file = [object objectForKey:@"profilePicture"];
            [cell.profilePictureView loadInBackground];

            // Username
            cell.followingUser.text = username;

            // Highlight Button
            [cell highlightHighlightButton];
            
            // Paiir score Label
            cell.paiirScoreLabel.text = [self setPaiirScoreForSuggestedUser:username];


            return cell;
            
        }
    }
    
    return nil;
}

- (PFObject *)objectAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        // facebook and search
        return nil;
        
    }
    
    PFObject *object = [self.dataSourceArray objectAtIndex:indexPath.row];
    return object;
    
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        NSLog(@"search section");

        return 1;
    }
    
    else {
        return 2;
    }
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        NSLog(@"pass search numberrows");

        return self.searchResults.count;
    }
    
    else {
        if (section == 0) {
            return 1;
        }
        else {
            return self.dataSourceArray.count;
        }
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    if (section == 0) {
        return nil;
    }
    
    else {
        return @"Suggested Users";
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UILabel *myLabel = [[UILabel alloc] init];
    myLabel.frame = CGRectMake(10, 5, 320, 17);
    myLabel.font = [UIFont fontWithName:@"Avenir Next" size:15];
    myLabel.text = [self tableView:tableView titleForHeaderInSection:section];
    
    UIImageView *background = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SectionHeader.png"]];
    background.frame = CGRectMake(0, 0, 320, 23);

    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 25)];
    [headerView addSubview:background];
    [headerView addSubview:myLabel];
    
    return headerView;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    if (section == 0) {
        return 0;
    }
    else return 25;
}


- (void)objectsDidLoad:(NSError *)error {
    
    [super objectsDidLoad:error];
    
    self.dataSourceArray = [NSMutableArray arrayWithArray:self.objects];
    
    [self.tableView reloadData];
    
}

- (PFQuery *)queryForTable {
    
    if ([PFUser currentUser]) { //User logged in.
            
        // get already following users
        PFQuery *alreadyFollowing = [PFQuery queryWithClassName:@"Activity"];
        [alreadyFollowing whereKey:@"fromUser" equalTo:[PFUser currentUser]];
        [alreadyFollowing whereKey:@"type" equalTo:@"follow"];
        
        /*
        // follower following
        PFQuery *followerFollowing = [PFQuery queryWithClassName:@"Activity"];
        [followerFollowing whereKey:@"type" equalTo:@"follow"];
        [followerFollowing whereKey:@"fromUser" matchesKey:@"toUser" inQuery:alreadyFollowing];
         */
        
        // get my following people's following people
        PFQuery *suggestedUsers = [PFUser query];
        [suggestedUsers whereKey:@"username" notEqualTo:[PFUser currentUser].username];
        [suggestedUsers whereKey:@"objectId" doesNotMatchKey:@"toUserObjectId" inQuery:alreadyFollowing];
        //[suggestedUsers whereKey:@"objectId" matchesKey:@"fromUserObjectId" inQuery:followerFollowing];
        
        /*
        // Photos for suggested users highlights
        PFQuery *allSuggestedUsersHighlightPhotos = [PFQuery queryWithClassName:@"Activity"];
        [allSuggestedUsersHighlightPhotos whereKey:@"type" equalTo:@"highlight"];
        [allSuggestedUsersHighlightPhotos whereKey:@"fromUserObjectId" matchesKey:@"objectId" inQuery:suggestedUsers];
        [allSuggestedUsersHighlightPhotos includeKey:@"fromUser"];
        [allSuggestedUsersHighlightPhotos includeKey:@"photoPointer.completor"];
        [allSuggestedUsersHighlightPhotos includeKey:@"photoPointer.owner"];
        [allSuggestedUsersHighlightPhotos includeKey:@"photoPointer.imageToComplete"];
        
        allSuggestedUsersHighlightPhotos.cachePolicy = kPFCachePolicyNetworkOnly;
        [allSuggestedUsersHighlightPhotos addDescendingOrder:@"createdAt"];
        [allSuggestedUsersHighlightPhotos findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                // The find succeeded.
                NSLog(@"Retrieved %ld suggested user Highlight Photo Objects.", (long)objects.count);
                [self.suggestedUserToHighlightPhotos removeAllObjects];
                
                
                for (PFObject *object in objects) {
                    PFUser *photoOwner = [object objectForKey:@"fromUser"];
                    NSString *username = [photoOwner objectForKey:@"username"];
                    
                    NSMutableArray *objectsForUsername = [self.suggestedUserToHighlightPhotos objectForKey:username];
                    if (!objectsForUsername) {
                        objectsForUsername = [NSMutableArray array];
                        [objectsForUsername addObject:[object objectForKey:@"photoPointer"]];
                    }
                    else {
                        [objectsForUsername addObject:[object objectForKey:@"photoPointer"]];
                    }
                    
                    [self.suggestedUserToHighlightPhotos setObject:objectsForUsername forKey:username];
                }
                
                [self.tableView reloadData];
                
                
            } else {
                // Log details of the failure
                NSLog(@"Error: %@ %@", error, [error userInfo]);
            }
        }];
        */
        
        // suggested users paiir score
        PFQuery *allSuggestedUsersPaiirScoreQuery = [PFQuery queryWithClassName:@"PaiirScore"];
        [allSuggestedUsersPaiirScoreQuery whereKey:@"userObjectId" matchesKey:@"objectId" inQuery:suggestedUsers];
        [allSuggestedUsersPaiirScoreQuery includeKey:@"user"];
        
        allSuggestedUsersPaiirScoreQuery.cachePolicy = kPFCachePolicyNetworkElseCache;
        [allSuggestedUsersPaiirScoreQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                // The find succeeded.
                NSLog(@"Retrieved %ld suggested users Paiir Objects.", (long)objects.count);
                [self.suggestedUsersToPaiirScore removeAllObjects];
                
                for (PFObject *object in objects) {
                    PFUser *user = [object objectForKey:@"user"];
                    NSString *username = [user objectForKey:@"username"];
                    
                    [self.suggestedUsersToPaiirScore setObject:object forKey:username];
                }
                
                [self.tableView reloadData];
                
            } else {
                // Log details of the failure
                NSLog(@"Error: %@ %@", error, [error userInfo]);
            }
        }];
        
        
        // all suggested users query
        suggestedUsers.cachePolicy = kPFCachePolicyNetworkOnly;
        [suggestedUsers addDescendingOrder:@"suggestedRanking"];
        suggestedUsers.limit = 30;
        
        return suggestedUsers;
        
    }
    
    else {
        
        [super objectsDidLoad:[NSError errorWithDomain:@"" code:0 userInfo:nil]]; //Return failed to turn off spinner.
        
        return nil;
        
    }

}

#pragma mark - UIScrollView

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DGRFindFriendsCellEnclosingTableViewDidBeginScrollingNotification" object:scrollView];
}

#pragma mark - Cell Protocols

- (void)didTapHighlightButton:(PFUser *)user {
    
    DGRHighlightsViewController *highlightVC = (DGRHighlightsViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"HighlightsViewController"];
    
    highlightVC.highlightsType3 = YES;
    highlightVC.user = user;
    
    [self presentViewController:highlightVC animated:YES completion:NULL];

    
}

- (void)didTapFollowButton:(DGRFindFriendsCell *)cell {
    
    // remove cell
    
    NSIndexPath *indexPath = [cell.tableView indexPathForCell:cell];
    
    if ([cell.tableView isEqual:self.searchDisplayController.searchResultsTableView]) {
        
        [cell.tableView beginUpdates];
        [self.searchResults removeObjectAtIndex:indexPath.row];
        [cell.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationRight];
        [cell.tableView endUpdates];
        
    }
    else {
    
        [cell.tableView beginUpdates];
        [self.dataSourceArray removeObjectAtIndex:indexPath.row];
        [cell.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationRight];
        [cell.tableView endUpdates];
        
    }
    
    [cell.tableView reloadData];
    
    NSLog(@"Removed cell in table view");
    
    // add Parse follow object
    
    PFQuery *checkIfObjectExists = [PFQuery queryWithClassName:@"Activity"];
    [checkIfObjectExists whereKey:@"type" equalTo:@"follow"];
    [checkIfObjectExists whereKey:@"fromUser" equalTo:[PFUser currentUser]];
    [checkIfObjectExists whereKey:@"toUser" equalTo:cell.thisUser];
    
    [checkIfObjectExists getFirstObjectInBackgroundWithBlock:^(PFObject *queryObject, NSError *error) {
        if (!queryObject) {
            PFObject *newFollow = [PFObject objectWithClassName:@"Activity"];
            newFollow[@"type"] = @"follow";
            newFollow[@"fromUser"] = [PFUser currentUser];
            newFollow[@"fromUserObjectId"] = [PFUser currentUser].objectId;
            newFollow[@"toUser"] = cell.thisUser;
            newFollow[@"toUserObjectId"] = cell.thisUser.objectId;
            [newFollow saveInBackgroundWithBlock:^(BOOL suceeded, NSError *error){
                if (suceeded) {
                    NSString *message = [NSString stringWithFormat:@"%@ started following you.", [PFUser currentUser].username];
                    [self sendPushToUser:cell.thisUser withMessage:message];
                }
            }];

        } else {
            NSLog(@"The object already exists.");
        }
    }];

    self.somethingChanged = YES;
    
}

#pragma mark - Other Methods


-(NSString*)setPaiirScoreForSuggestedUser:(NSString*)username {
    PFObject *paiirScoreObject = [self.suggestedUsersToPaiirScore objectForKey:username];
    NSNumber *scoreCount = [paiirScoreObject objectForKey:@"scoreCount"];
    NSString *paiirScoreText = [NSString stringWithFormat:@"PaiirScore: %i", [scoreCount intValue]];
    return paiirScoreText;
}

-(NSString*)setPaiirScoreForSearchedUser:(NSString*)username {
    PFObject *paiirScoreObject = [self.searchedUsersToPaiirScore objectForKey:username];
    NSNumber *scoreCount = [paiirScoreObject objectForKey:@"scoreCount"];
    NSString *paiirScoreText = [NSString stringWithFormat:@"PaiirScore: %i", [scoreCount intValue]];
    return paiirScoreText;
}



#pragma mark - PageNavigation

-(IBAction)doneButtonAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:NULL];
    
    if (self.somethingChanged) {
        self.somethingChanged = NO;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"DGRHomeViewControllerLoadParseObjects" object:self];
    }
    
}

#pragma mark - Alerts

-(void)sendPushToUser: (PFUser *)user withMessage: (NSString *)message {
    // Create our Installation query
    PFQuery *pushQuery = [PFInstallation query];
    [pushQuery whereKey:@"user" equalTo:user];
    
    NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
                          message, @"alert",
                          @"Tink.caf", @"sound",
                          @"Increment", @"badge",
                          @"3", @"t",
                          nil];
    
    // Send push notification to query
    PFPush *push = [[PFPush alloc] init];
    [push setQuery:pushQuery];
    [push setData:data];
    [push sendPushInBackground];
    
}


     
     


@end
