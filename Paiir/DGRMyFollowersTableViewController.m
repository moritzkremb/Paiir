//
//  DGRMyFollowersTableViewController.m
//  Paiir
//
//  Created by Moritz Kremb on 25/10/14.
//  Copyright (c) 2014 Kremb. All rights reserved.
//

#import "DGRMyFollowersTableViewController.h"
#import "DGRConstants.h"
#import "DGRHighlightsViewController.h"

@interface DGRMyFollowersTableViewController ()

@property (nonatomic, retain) NSMutableArray *following;
@property (nonatomic, retain) NSMutableArray *notFollowing;

@property (nonatomic, retain) NSMutableArray *myFollowers;
@property (nonatomic, retain) NSMutableArray *followingPeople;

@property (nonatomic, retain) NSMutableDictionary *followerToPaiirScore;

@property (nonatomic, retain) NSArray *singlePhotoObjects;

@end

@implementation DGRMyFollowersTableViewController

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (UIViewController *)childViewControllerForStatusBarHidden {
    return nil;
}

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        self.parseClassName = @"Activity";
        
        self.textKey = @"user1";
        
        self.imageKey = @"image";
        
        self.pullToRefreshEnabled = YES;
        
        self.paginationEnabled = NO;
        
        self.objectsPerPage = 1000;
        
        self.followerToPaiirScore = [NSMutableDictionary dictionary];
        
    }
    return self;
    
}

- (id)initWithCoder:(NSCoder *)aCoder {
    self = [super initWithCoder:aCoder];
    if (self) {
        self.parseClassName = @"Activity";
        
        self.textKey = @"user1";
        
        self.imageKey = @"image";
        
        self.pullToRefreshEnabled = YES;
        
        self.paginationEnabled = NO;
        
        self.objectsPerPage = 1000;
        
        self.followerToPaiirScore = [NSMutableDictionary dictionary];
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.tableView registerClass:[DGRHomeCell class] forCellReuseIdentifier:@"FollowingCell"];
    [self.tableView registerClass:[DGRFindFriendsCell class] forCellReuseIdentifier:@"NotFollowingCell"];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Queries

-(void)objectsDidLoad:(NSError *)error {
    [super objectsDidLoad:error];
    
    // People Im following
    PFQuery *followingPeople = [PFQuery queryWithClassName:@"Activity"];
    [followingPeople whereKey:@"fromUser" equalTo:[PFUser currentUser]];
    [followingPeople whereKey:@"type" equalTo:@"follow"];
    
    [followingPeople includeKey:@"toUser"];
    followingPeople.cachePolicy = kPFCachePolicyNetworkOnly;
    self.followingPeople = [NSMutableArray arrayWithArray:[followingPeople findObjects]];
                            
    self.myFollowers = [NSMutableArray arrayWithArray:self.objects];
    
    NSLog(@"self.myfollowers: %lu", (unsigned long)self.myFollowers.count);
    NSLog(@"self.followingpeople: %lu", (unsigned long)self.followingPeople.count);
    
    // init
    _following = [NSMutableArray array];
    _notFollowing = [NSMutableArray array];
    
    
    // create
    BOOL matches = NO;
    for (PFObject *myFollowerObject in self.myFollowers) {
        for (PFObject *followingObject in self.followingPeople) {
            NSString *myFollowerId = [myFollowerObject objectForKey:@"fromUserObjectId"];
            NSString *followingUserId = [followingObject objectForKey:@"toUserObjectId"];
            if ([myFollowerId isEqualToString:followingUserId]) {
                matches = YES;
                break;
            }
        }
        if (matches) {
            [_following addObject:[myFollowerObject objectForKey:@"fromUser"]];
            
        } else {
            [_notFollowing addObject:[myFollowerObject objectForKey:@"fromUser"]];
        }
        matches = NO;
        
    }
    
    [self.tableView reloadData];
}

-(PFQuery*)queryForTable {
    if ([PFUser currentUser]) { //User logged in.
        
        //NSTimeInterval aDayAgo = -86400.00;
        
        // My followers
        PFQuery *myFollowersQuery = [PFQuery queryWithClassName:@"Activity"];
        [myFollowersQuery whereKey:@"toUser" equalTo:[PFUser currentUser]];
        [myFollowersQuery whereKey:@"type" equalTo:@"follow"];
        
        // People Im following
        PFQuery *followingPeople = [PFQuery queryWithClassName:@"Activity"];
        [followingPeople whereKey:@"fromUser" equalTo:[PFUser currentUser]];
        [followingPeople whereKey:@"type" equalTo:@"follow"];

        /*
        // Photos for followers highlights - excluding the ones Im already following
        PFQuery *followerHighlightPhotosQuery = [PFQuery queryWithClassName:@"Activity"];
        [followerHighlightPhotosQuery whereKey:@"fromUser" matchesKey:@"fromUser" inQuery:myFollowersQuery];
        [followerHighlightPhotosQuery whereKey:@"fromUser" doesNotMatchKey:@"toUser" inQuery:followingPeople];
        [followerHighlightPhotosQuery whereKey:@"type" equalTo:@"highlight"];
        [followerHighlightPhotosQuery includeKey:@"fromUser"];
        [followerHighlightPhotosQuery includeKey:@"photoPointer.owner"];
        [followerHighlightPhotosQuery includeKey:@"photoPointer.completor"];
        [followerHighlightPhotosQuery includeKey:@"photoPointer.imageToComplete"];
        
        followerHighlightPhotosQuery.cachePolicy = kPFCachePolicyNetworkOnly;
        [followerHighlightPhotosQuery addDescendingOrder:@"createdAt"];
        [followerHighlightPhotosQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                // The find succeeded.
                NSLog(@"Retrieved %ld follower Highlight Photo Objects.", (long)objects.count);
                [self.followerToHighlightPhotos removeAllObjects];
                
                
                for (PFObject *object in objects) {
                    PFUser *photoOwner = [object objectForKey:@"fromUser"];
                    NSString *username = [photoOwner objectForKey:@"username"];
                    
                    NSMutableArray *objectsForUsername = [self.followerToHighlightPhotos objectForKey:username];
                    if (!objectsForUsername) {
                        objectsForUsername = [NSMutableArray array];
                        [objectsForUsername addObject:[object objectForKey:@"photoPointer"]];
                    }
                    else {
                        [objectsForUsername addObject:[object objectForKey:@"photoPointer"]];
                    }
                    
                    [self.followerToHighlightPhotos setObject:objectsForUsername forKey:username];
                }
                
                [self.tableView reloadData];
                
            } else {
                // Log details of the failure
                NSLog(@"Error: %@ %@", error, [error userInfo]);
            }
        }];
         */
        
        // follower paiir score
        PFQuery *followerPaiirScoreQuery = [PFQuery queryWithClassName:@"PaiirScore"];
        [followerPaiirScoreQuery whereKey:@"user" matchesKey:@"fromUser" inQuery:myFollowersQuery];
        [followerPaiirScoreQuery includeKey:@"user"];
        
        followerPaiirScoreQuery.cachePolicy = kPFCachePolicyNetworkOnly;
        [followerPaiirScoreQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                // The find succeeded.
                NSLog(@"Retrieved %ld follower Paiir Objects.", (long)objects.count);
                [self.followerToPaiirScore removeAllObjects];
                
                for (PFObject *object in objects) {
                    PFUser *user = [object objectForKey:@"user"];
                    NSString *username = [user objectForKey:@"username"];
                    
                    [self.followerToPaiirScore setObject:object forKey:username];
                }
                
                [self.tableView reloadData];
                
            } else {
                // Log details of the failure
                NSLog(@"Error: %@ %@", error, [error userInfo]);
            }
        }];
        
        [myFollowersQuery includeKey:@"fromUser"];
        myFollowersQuery.cachePolicy = kPFCachePolicyNetworkOnly;
        
        return myFollowersQuery;
        
    }
    
    else {
        
        NSLog(@"Error. User not logged in.");
        [self dismissViewControllerAnimated:YES completion:NULL];
        
    }
    
    return nil;
    
}

#pragma mark - UITableViewDelegate

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (_following.count == 0 && _notFollowing.count == 0) {
        // set up background image
        if (!self.isLoading) {
            UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
            messageLabel.frame = CGRectMake(40, 0, 240, self.view.bounds.size.height);
            
            messageLabel.text = @"No followers.";
            messageLabel.textColor = [UIColor blackColor];
            messageLabel.numberOfLines = 2;
            messageLabel.textAlignment = NSTextAlignmentCenter;
            messageLabel.font = [UIFont fontWithName:@"Avenir Next" size:18];
            
            UIView *background = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
            [background addSubview:messageLabel];
            
            self.tableView.backgroundView = background;
            self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        }
        
        NSLog(@"numberofsections: 0");
        
        return 0;
    }
    else if ((_following.count == 0 && _notFollowing.count > 0) || (_following.count > 0 && _notFollowing.count == 0)){
        NSLog(@"numberofsections: 1");
        
        return 1;
    }
    else {
        NSLog(@"numberofsections: 2");
        return 2;
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if ([tableView numberOfSections] == 1) {
        if (_notFollowing.count == 0) {
            return _following.count;
        }
        else return _notFollowing.count;
    }
    
    if ([tableView numberOfSections] == 2) {
        if (section == 0) {
            return _following.count;
        }
        if (section == 1) {
            return _notFollowing.count;
        }
    }
    
    
    return 0;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    if ([tableView numberOfSections] == 1) {
        if (_notFollowing.count == 0) {
            return @"Following";
        }
        else return @"Not Following";
    }
    
    if ([tableView numberOfSections] == 2) {
        if (section == 0) {
            return @"Following";
        }
        if (section == 1) {
            return @"Not Following";
        }
    }
    
    return nil;
    
}

- (PFObject *)objectAtIndexPath:(NSIndexPath *)indexPath {
    if ([[self tableView:self.tableView titleForHeaderInSection:indexPath.section] isEqualToString:@"Following"]) {
        return [_following objectAtIndex:indexPath.row];
    }
    if ([[self tableView:self.tableView titleForHeaderInSection:indexPath.section] isEqualToString:@"Not Following"]) {
        return [_notFollowing objectAtIndex:indexPath.row];
    }
    return nil;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UILabel *myLabel = [[UILabel alloc] init];
    myLabel.frame = CGRectMake(10, 5, 320, 17);
    myLabel.font = [UIFont fontWithName:@"Avenir Next" size:16];
    myLabel.text = [self tableView:tableView titleForHeaderInSection:section];
    
    UIImageView *background = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SectionHeader.png"]];
    background.frame = CGRectMake(0, 0, 320, 23);

    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 25)];
    [headerView addSubview:background];
    [headerView addSubview:myLabel];
    
    return headerView;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 25;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {
    
    if ([[self tableView:tableView titleForHeaderInSection:indexPath.section] isEqualToString:@"Following"]) {
        // Following
        // create
        DGRHomeCell *cell = (DGRHomeCell *)[tableView dequeueReusableCellWithIdentifier:@"FollowingCell" forIndexPath:indexPath];
        
        // fix content offset
        if (cell.scrollView.contentOffset.x != kCatchWidth) {
            [cell.scrollView setContentOffset:CGPointMake(kCatchWidth, 0) animated:NO];
        }
        
        NSString *username = [object objectForKey:@"username"];
        cell.delegate = self;
        cell.thisUser = (PFUser*)object;
        
        // Profile Picture
        cell.profilePictureView.image = [UIImage imageNamed:@"ProfilePicturePlaceholder.png"];
        cell.profilePictureView.file = [object objectForKey:@"profilePicture"];
        [cell.profilePictureView loadInBackground];
        
        // Username
        cell.followingUser.text = username;
        
        // Paiirscore label
        cell.paiirScoreLabel.text = [self setPaiirScoreForUser:username];
        
        return cell;
    }
    
    else {
        // Not Following
        // create
        DGRFindFriendsCell *cell = (DGRFindFriendsCell *)[tableView dequeueReusableCellWithIdentifier:@"NotFollowingCell" forIndexPath:indexPath];
        
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
        cell.thisUser = (PFUser*)object;
        
        // Profile Picture
        cell.profilePictureView.image = [UIImage imageNamed:@"ProfilePicturePlaceholder.png"];
        cell.profilePictureView.file = [object objectForKey:@"profilePicture"];
        [cell.profilePictureView loadInBackground];
        
        // Username
        cell.followingUser.text = username;
        
        // Paiirscore label
        cell.paiirScoreLabel.text = [self setPaiirScoreForUser:username];
        
        // highlight Button
        [cell highlightHighlightButton];
        
        return cell;
        
    }
    
    return nil;
    
}

#pragma mark - Other Methods

-(NSString*)setPaiirScoreForUser:(NSString*)username {
    PFObject *paiirScoreObject = [self.followerToPaiirScore objectForKey:username];
    NSNumber *scoreCount = [paiirScoreObject objectForKey:@"scoreCount"];
    NSString *paiirScoreText = [NSString stringWithFormat:@"PaiirScore: %i", [scoreCount intValue]];
    return paiirScoreText;
}

#pragma mark - Navigation



#pragma mark - UIScrollView

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DGRFindFriendsCellEnclosingTableViewDidBeginScrollingNotification" object:scrollView];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DGRHomeCellEnclosingTableViewDidBeginScrollingNotification" object:scrollView];
}

#pragma mark - Find Friend Cell Protocols

- (void)didTapHighlightButton:(PFUser *)user {
    
    DGRHighlightsViewController *highlightVC = (DGRHighlightsViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"HighlightsViewController"];
    
    highlightVC.highlightsType3 = YES;
    highlightVC.user = user;
    
    [self presentViewController:highlightVC animated:YES completion:NULL];
    
}

- (void)didTapFollowButton:(DGRFindFriendsCell *)cell {
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    PFObject *toBeMovedObject = [_notFollowing objectAtIndex:indexPath.row];
    
    [self.tableView beginUpdates];
    [_notFollowing removeObjectAtIndex:indexPath.row];
    if (_notFollowing.count == 0) {
        // remove section
        [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationRight];
    }
    else {
        // remove row
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationRight];
    }
    
    // add to following
    NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:_following.count inSection:0];
    [_following addObject:toBeMovedObject];
    if (_following.count == 1) { // was empty before
        // add section
        [self.tableView insertSections:[NSIndexSet indexSetWithIndex:newIndexPath.section] withRowAnimation:UITableViewRowAnimationRight];
    }
    else {
        // add row
        [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationRight];
    }
    
    [self.tableView endUpdates];

    
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
    
    
}

#pragma mark - Home Cell Protocols

- (void)didTapTodayButton:(PFUser*)user withRecognizer:(UITapGestureRecognizer *)sender {
    /*
    NSString *viewIdentifier;
    if (IS_WIDESCREEN) {
        viewIdentifier = @"imageViewController5";
    } else viewIdentifier = @"imageViewController4";
    
    DGRImageViewController *todayVC = [self.storyboard instantiateViewControllerWithIdentifier:viewIdentifier];
    
    NSArray *photoObjects = [[NSArray alloc] init];
    
    photoObjects = [self.followerToPhotos objectForKey:user.username];
        
    todayVC.moreOptionsButtonBool = NO;
    todayVC.moreOptionsButtonInHighlightBool = NO;
    
    if (photoObjects) {
        
        todayVC.counter = 0;
        todayVC.photoObjects = [NSMutableArray arrayWithArray:photoObjects];
        
        [self presentViewController:todayVC animated:YES completion:nil];
    }
    else {
        NSLog(@"No Objects available to show. Something went wrong.");
    }
     */
}

- (void)didTapHighlightButton:(PFUser *)user withRecognizer:(UITapGestureRecognizer*)sender {
    /*
    DGRHighlightsViewController *highlightVC = (DGRHighlightsViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"HighlightsViewController"];
    
    NSMutableArray *photoObjects = [NSMutableArray array];
    
    photoObjects = [self.followerToHighlightPhotos objectForKey:user.username];
    highlightVC.userIsMe = NO;
    
    highlightVC.photoObjects = photoObjects;
    
    [self presentViewController:highlightVC animated:YES completion:NULL];
     */
}


- (void)didTapUnfollowButton:(DGRHomeCell *)cell {
    //add method
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    PFObject *toBeMovedObject = [_following objectAtIndex:indexPath.row];
    
    [self.tableView beginUpdates];
    [_following removeObjectAtIndex:indexPath.row];
    if (_following.count == 0) {
        // remove section
        [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationRight];
        
        // add to not following
        NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:_notFollowing.count inSection:0];
        [_notFollowing addObject:toBeMovedObject];
        if (_notFollowing.count == 1) { // was empty before
            // add section
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:newIndexPath.section] withRowAnimation:UITableViewRowAnimationRight];
        }
        else {
            // add row
            [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationRight];
        }

    }
    else {
        // remove row
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationRight];
        
        // add to not following
        NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:_notFollowing.count inSection:1];
        [_notFollowing addObject:toBeMovedObject];
        if (_notFollowing.count == 1) { // was empty before
            // add section
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:newIndexPath.section] withRowAnimation:UITableViewRowAnimationRight];
        }
        else {
            // add row
            [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationRight];
        }

    }

    [self.tableView endUpdates];
    
    
    // remove Parse object
    
    PFQuery *checkIfObjectExists = [PFQuery queryWithClassName:@"Activity"];
    [checkIfObjectExists whereKey:@"type" equalTo:@"follow"];
    [checkIfObjectExists whereKey:@"fromUser" equalTo:[PFUser currentUser]];
    [checkIfObjectExists whereKey:@"toUser" equalTo:cell.thisUser];
    
    [checkIfObjectExists getFirstObjectInBackgroundWithBlock:^(PFObject *queryObject, NSError *error) {
        if (queryObject) {
            [queryObject deleteInBackground];
            
        } else {
            NSLog(@"The object does not exist.");
        }
    }];
    
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
