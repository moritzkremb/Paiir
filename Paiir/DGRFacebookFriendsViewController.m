//
//  DGRFacebookFriendsViewController.m
//  Paiir
//
//  Created by Moritz Kremb on 16/10/14.
//  Copyright (c) 2014 Kremb. All rights reserved.
//

#import "DGRFacebookFriendsViewController.h"
#import "DGRHighlightsViewController.h"
#import "DGRConstants.h"
#import "MBProgressHUD.h"

@interface DGRFacebookFriendsViewController ()

@property (nonatomic, retain) NSMutableArray *dataSourceArray;
@property (nonatomic, retain) NSMutableDictionary *facebookUserToHighlightPhotos;

@property BOOL isLoading;

@end

@implementation DGRFacebookFriendsViewController

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        
        self.parseClassName = @"User";
        self.textKey = @"username";
        self.imageKey = @"image";
        self.pullToRefreshEnabled = YES;
        self.paginationEnabled = NO;
        self.objectsPerPage = 50;
        
        self.facebookUserToHighlightPhotos = [NSMutableDictionary dictionary];

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
        self.objectsPerPage = 50;
        
        self.facebookUserToHighlightPhotos = [NSMutableDictionary dictionary];

    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.isLoading = YES;
    
    [self.tableView registerClass:[DGRFindFriendsCell class] forCellReuseIdentifier:@"FacebookFriendsCell"];
    
    if (![[PFUser currentUser] objectForKey:@"facebookId"]) {
        // set up facebook
        
        MBProgressHUD *loadingHUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        loadingHUD.mode = MBProgressHUDModeIndeterminate;
        loadingHUD.labelText = @"Loading...";
        [loadingHUD show:YES];
        
        [PFFacebookUtils linkUser:[PFUser currentUser] permissions:@[@"email"] block:^(BOOL succeeded, NSError *error){
            if (!error) {
                // load facebook data
                //get profile info
                FBRequest *request = [FBRequest requestForMe];
                [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                    // handle response
                    if (!error) {
                        
                        // Parse the data received
                        NSDictionary *userData = (NSDictionary *)result;
                        NSString *facebookID = userData[@"id"];
                        
                        NSMutableDictionary *userProfile = [NSMutableDictionary dictionaryWithCapacity:8];
                        
                        if (facebookID) {
                            userProfile[@"facebookId"] = facebookID;
                        }
                        
                        NSString *name = userData[@"name"];
                        if (name) {
                            userProfile[@"name"] = name;
                        }
                        
                        NSString *location = userData[@"location"][@"name"];
                        if (location) {
                            userProfile[@"location"] = location;
                        }
                        
                        NSString *gender = userData[@"gender"];
                        if (gender) {
                            userProfile[@"gender"] = gender;
                        }
                        
                        NSString *birthday = userData[@"birthday"];
                        if (birthday) {
                            userProfile[@"birthday"] = birthday;
                        }
                        
                        NSString *email = userData[@"email"];
                        if (email) {
                            userProfile[@"email"] = email;
                        }
                        
                        NSString *hardware = userData[@"devices"][@"hardware"];
                        if (hardware) {
                            userProfile[@"hardware"] = hardware;
                        }
                        
                        NSString *oS = userData[@"devices"][@"os"];
                        if (oS) {
                            userProfile[@"oS"] = oS;
                        }
                        
                        
                        [[PFUser currentUser] setObject:userProfile forKey:@"facebookProfileInfo"];
                        [[PFUser currentUser] setObject:facebookID forKey:@"facebookId"]; // set id separately for better comparison later
                        [[PFUser currentUser] saveInBackground];
                        NSLog(@"Facebook Profile Data loaded");
                        
                    }
                    else if ([[[[error userInfo] objectForKey:@"error"] objectForKey:@"type"]
                              isEqualToString: @"OAuthException"]) { // Since the request failed, we can check if it was due to an invalid session
                        NSLog(@"The facebook session was invalidated");

                        [PFUser logOut];
                    } else {

                        NSLog(@"Some other error: %@", error);
                    }
                }];
                
                // get friends
                [FBRequestConnection startForMyFriendsWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                    [loadingHUD hide:YES];

                    if (!error) {
                        // result will contain an array with your user's friends in the "data" key
                        NSArray *friendObjects = [result objectForKey:@"data"];
                        NSMutableArray *friendIds = [NSMutableArray arrayWithCapacity:friendObjects.count];
                        // Create a list of friends' Facebook IDs
                        for (NSDictionary *friendObject in friendObjects) {
                            [friendIds addObject:[friendObject objectForKey:@"id"]];
                        }
                        
                        [[PFUser currentUser] setObject:friendIds forKey:@"facebookFriends"];
                        [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeed, NSError *error){
                            //hud. success!
                            [self loadObjects];
                            if (error) {
                                NSLog(@"error during facebook data save occured.");
                            }
                        }];
                        
                        NSLog(@"Facebook Friends Data loaded");
                        
                        
                    }
                    else {
                        NSLog(@"Error for facebook friend graph request");

                    }
                }];

            }
            else {
                [loadingHUD hide:YES];
                [self okAlertWithTitle:@"Error" message:[error description]];
                NSLog(@"error.");

            }
        }];
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableView

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object{
    DGRFindFriendsCell *cell = (DGRFindFriendsCell *)[tableView dequeueReusableCellWithIdentifier:@"FacebookFriendsCell" forIndexPath:indexPath];
    
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
    
    // Highlight Button
    [cell highlightHighlightButton];

    // Facebook Name
    NSDictionary *facebookProfile = [object objectForKey:@"facebookProfileInfo"];
    NSString *facebookName = [facebookProfile objectForKey:@"name"];
    cell.paiirScoreLabel.text = facebookName;
    
    return cell;

}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (!self.isLoading && self.dataSourceArray.count == 0) {
        UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
        messageLabel.frame = CGRectMake(40, 0, 240, self.view.bounds.size.height);
        
        messageLabel.text = @"No new Facebook friends. Invite some!";
        messageLabel.textColor = [UIColor darkGrayColor];
        messageLabel.numberOfLines = 2;
        messageLabel.textAlignment = NSTextAlignmentCenter;
        messageLabel.font = [UIFont fontWithName:@"Avenir Next" size:16];
        
        UIView *background = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
        [background addSubview:messageLabel];
        
        self.tableView.backgroundView = background;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    else {
        self.tableView.backgroundView = nil;
    }
    
    return 1;

}

-(PFObject *)objectAtIndexPath:(NSIndexPath *)indexPath {
    return [self.dataSourceArray objectAtIndex:indexPath.row];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSourceArray.count;
}

-(void)objectsDidLoad:(NSError *)error {
    [super objectsDidLoad:error];
    
    self.dataSourceArray = [NSMutableArray arrayWithArray:self.objects];
    
    [self.tableView reloadData];
}


-(PFQuery *)queryForTable {
    
    if ([[PFUser currentUser] objectForKey:@"facebookId"]) {
        
        // all people im following
        PFQuery *allFollowing = [PFQuery queryWithClassName:@"Activity"];
        [allFollowing whereKey:@"fromUser" equalTo:[PFUser currentUser]];
        [allFollowing whereKey:@"type" equalTo:@"follow"];

        
        // users facebook friends query
        NSArray *friendIds = [[PFUser currentUser] objectForKey:@"facebookFriends"];
        
        PFQuery *friendQuery = [PFUser query];
        [friendQuery whereKey:@"facebookId" containedIn:friendIds];
        [friendQuery whereKey:@"objectId" doesNotMatchKey:@"toUserObjectId" inQuery:allFollowing];
        
        /*
        // Photos for facebook users highlights
        PFQuery *allFacebookUsersHighlightPhotos = [PFQuery queryWithClassName:@"Activity"];
        [allFacebookUsersHighlightPhotos whereKey:@"type" equalTo:@"highlight"];
        [allFacebookUsersHighlightPhotos whereKey:@"fromUserObjectId" matchesKey:@"objectId" inQuery:friendQuery];
        [allFacebookUsersHighlightPhotos includeKey:@"fromUser"];
        [allFacebookUsersHighlightPhotos includeKey:@"photoPointer.completor"];
        [allFacebookUsersHighlightPhotos includeKey:@"photoPointer.owner"];
        [allFacebookUsersHighlightPhotos includeKey:@"photoPointer.imageToComplete"];
        
        allFacebookUsersHighlightPhotos.cachePolicy = kPFCachePolicyNetworkOnly;
        [allFacebookUsersHighlightPhotos addDescendingOrder:@"createdAt"];
        [allFacebookUsersHighlightPhotos findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                // The find succeeded.
                NSLog(@"Retrieved %ld suggested user Highlight Photo Objects.", (long)objects.count);
                [self.facebookUserToHighlightPhotos removeAllObjects];
                
                
                for (PFObject *object in objects) {
                    PFUser *photoOwner = [object objectForKey:@"fromUser"];
                    NSString *username = [photoOwner objectForKey:@"username"];
                    
                    NSMutableArray *objectsForUsername = [self.facebookUserToHighlightPhotos objectForKey:username];
                    if (!objectsForUsername) {
                        objectsForUsername = [NSMutableArray array];
                        [objectsForUsername addObject:[object objectForKey:@"photoPointer"]];
                    }
                    else {
                        [objectsForUsername addObject:[object objectForKey:@"photoPointer"]];
                    }
                    
                    [self.facebookUserToHighlightPhotos setObject:objectsForUsername forKey:username];
                }
                
                [self.tableView reloadData];
                
            } else {
                // Log details of the failure
                NSLog(@"Error: %@ %@", error, [error userInfo]);
            }
        }];
        */
        
        friendQuery.cachePolicy = kPFCachePolicyNetworkOnly;
        self.isLoading = NO;
        return friendQuery;

    }
    else {
        NSLog(@"No facebook id");
        [super objectsDidLoad:[NSError errorWithDomain:@"" code:0 userInfo:nil]]; //Return failed to turn off spinner.
        return nil;
    }
}

#pragma mark - Preload
/*
-(void)preloadFollowerToPhotos:(NSDictionary *) dictionary {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    
        for (NSString *key in dictionary) {
            NSLog(@"key: %@", key);
            NSArray *photoObjects = [[NSArray alloc] init];
            photoObjects = [dictionary objectForKey:key];
            
            NSLog(@"photoobject count: %ld", (long)photoObjects.count);
            
            // preload images
            for (int x=0; x<photoObjects.count; x++) {
                
                PFObject *object = [photoObjects objectAtIndex:x];
                PFObject *topImage = [object objectForKey:@"imageToComplete"];
                PFFile *image1 = [topImage objectForKey:@"image"];
                
                [image1 getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                    NSLog(@"%@ image %i.1 downloaded and cached", key, x);
                }];
                
                PFFile *image2 = [object objectForKey:@"image"];
                [image2 getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                    NSLog(@"%@ image %i.2 downloaded and cached", key, x);
                    
                }];
            }
        }
        
    });
    
    NSLog(@"FollowerToPhotos Preloaded");
}
*/

#pragma mark - Cell Protocols


- (void)didTapHighlightButton:(PFUser *)user {
    
    DGRHighlightsViewController *highlightVC = (DGRHighlightsViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"HighlightsViewController"];
    
    highlightVC.highlightsType3 = YES;
    highlightVC.user = user;
    
    [self presentViewController:highlightVC animated:YES completion:NULL];    
    
}

- (void)didTapFollowButton:(DGRFindFriendsCell *)cell {
    
    // remove cell
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    
    [self.tableView beginUpdates];
    [self.dataSourceArray removeObjectAtIndex:indexPath.row];
    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationRight];
    [self.tableView endUpdates];
    
    [self.tableView reloadData];
    
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
    
    
}

#pragma mark - Alerts

-(void)okAlertWithTitle:(NSString*)title message:(NSString*)message {
    
    if ([UIAlertController class]) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* ok = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
            [alert dismissViewControllerAnimated:YES completion:nil];
        }];
        [alert addAction:ok];
        
        [self presentViewController:alert animated:YES completion:nil];
    }
    
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
        
        [alert show];
    }
    
}

-(void)sendPushToUser: (PFUser *)user withMessage: (NSString *)message {
    // Create our Installation query
    PFQuery *pushQuery = [PFInstallation query];
    [pushQuery whereKey:@"user" equalTo:user];
    
    NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
                          message, @"alert",
                          @"Tink.caf", @"sound",
                          @"Increment", @"badge", nil];
    
    // Send push notification to query
    PFPush *push = [[PFPush alloc] init];
    [push setQuery:pushQuery];
    [push setData:data];
    [push sendPushInBackground];
    
}


#pragma mark - Navigation



@end
