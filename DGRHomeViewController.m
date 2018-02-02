//
//  DGRHomeViewController.m
//  Paiir
//
//  Created by Moritz Kremb on 1/3/14.
//  Copyright (c) 2014 Kremb. All rights reserved.
//

#import "DGRHomeViewController.h"
#import "DGRCompleteViewController.h"
#import "DGRConstants.h"
#import "DGRCameraViewController.h"
#import "DGRCompleteCameraViewController.h"
#import "DGRNoStatusBarImagePickerControllerViewController.h"
#import "DGRHorizontalShiftRightAnimator.h"
#import "DGRHorizontalShiftLeftAnimator.h"
#import "DGRZoomAnimator.h"
#import "DGRFindFriendsViewController.h"
#import "DGRHighlightsViewController.h"
#import "DGRMyFollowersTableViewController.h"
#import <FacebookSDK/FacebookSDK.h>
#import <AudioToolbox/AudioToolbox.h>
#import "DGRImageTableViewController.h"

@interface DGRHomeViewController ()

// Data
@property (nonatomic, retain) NSMutableDictionary *sections;
@property (nonatomic, retain) NSMutableDictionary *sectionToAlphabetMap;

@property (nonatomic, retain) NSArray *sortedArray; //all following people in here
@property (nonatomic, retain) NSMutableArray *recentArray; //photos in recent

@property (nonatomic, retain) NSMutableDictionary *userToPaiirScore;
@property int myFollowersCount;

@property (nonatomic, retain) NSMutableDictionary *userToHighlightCount;

@property (nonatomic, retain) NSMutableArray *staffpickObjects;

// VCs
@property DGRCameraViewController *cameraVC;

@property DGRCompleteCameraViewController *completeCameraVC;

// Additional Views, Buttons
@property UIButton *additionalViewsButton;
@property UIView *darkCoverView;
@property UIButton *settingsButton;
@property UIButton *findFriendsButton;
@property UIButton *notificationsButton;

//
@property BOOL newUserSignedUpFlag;
@property UIImageView *tutorialOverlay;

// Outlets
- (IBAction)startCamera:(id)sender;
- (IBAction)startCompleteCamera:(id)sender;

@end

@implementation DGRHomeViewController

#pragma mark - Initializers

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        
        // The className to query on
        self.parseClassName = @"Activity";
        
        // The key of the PFObject to display in the label of the default cell style
        self.textKey = @"user1";
        
        // Uncomment the following line to specify the key of a PFFile on the PFObject to display in the imageView of the default cell style
        self.imageKey = @"image";
        
        // Whether the built-in pull-to-refresh is enabled
        self.pullToRefreshEnabled = YES;
        
        // Whether the built-in pagination is enabled
        self.paginationEnabled = NO;
        
        // The number of objects to show per page
        self.objectsPerPage = 1000;
        
        self.sections = [NSMutableDictionary dictionary];
        self.sectionToAlphabetMap = [NSMutableDictionary dictionary];
        self.sortedArray = [[NSArray alloc] init];
        
        self.userToPaiirScore = [NSMutableDictionary dictionary];
        self.userToTodayPhotos = [NSMutableDictionary dictionary];
        self.userToHighlightCount = [NSMutableDictionary dictionary];


    }
    return self;
    
}

- (id)initWithCoder:(NSCoder *)aCoder {
    self = [super initWithCoder:aCoder];
    if (self) {
        
        // The className to query on
        self.parseClassName = @"Activity";
        
        // The key of the PFObject to display in the label of the default cell style
        self.textKey = @"user1";
        
        // Uncomment the following line to specify the key of a PFFile on the PFObject to display in the imageView of the default cell style
        self.imageKey = @"image";
        
        // Whether the built-in pull-to-refresh is enabled
        self.pullToRefreshEnabled = YES;
        
        // Whether the built-in pagination is enabled
        self.paginationEnabled = NO;
        
        // The number of objects to show per page
        self.objectsPerPage = 1000;
        
        self.sections = [NSMutableDictionary dictionary];
        self.sectionToAlphabetMap = [NSMutableDictionary dictionary];
        self.sortedArray = [[NSArray alloc] init];
        
        self.userToPaiirScore = [NSMutableDictionary dictionary];
        self.userToTodayPhotos = [NSMutableDictionary dictionary];
        self.userToHighlightCount = [NSMutableDictionary dictionary];



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
    
    NSLog(@"Home VC viewDidLoad");
    
    NSString *completeVcIdentifier;
    NSString *cameraVcIdentifier;

    if (IS_WIDESCREEN) {
        cameraVcIdentifier = @"cameraViewController5";
        completeVcIdentifier = @"completeCameraViewController5";
    } else {
        cameraVcIdentifier = @"cameraViewController4";
        completeVcIdentifier = @"completeCameraViewController4";
    }
    
    // init Camera VCs
    DGRCameraViewController *cameraVC = [self.storyboard instantiateViewControllerWithIdentifier:cameraVcIdentifier];
    self.cameraVC = cameraVC;
    
    // init Complete Camera VCs
    DGRCompleteCameraViewController *completeCameraVC = [self.storyboard instantiateViewControllerWithIdentifier:completeVcIdentifier];
    completeCameraVC.type1 = YES;
    self.completeCameraVC = completeCameraVC;
    
    // register notif
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadParseObjects) name:@"DGRHomeViewControllerLoadParseObjects" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dismissAllPresentedViewControllersAnimated) name:@"DGRHomeViewControllerDismissAllPresentedViewControllersAnimated" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newUserSignedUp) name:@"DGRHomeViewControllerNewUserSignedUp" object:nil];


    
    //set background color
    //UIView *backgroundView = [[UIView alloc] initWithFrame:self.view.bounds];
    //[backgroundView setBackgroundColor:UIColorFromRGB(0x34aadc)];
    //self.tableView.backgroundView = backgroundView;
    
    // Nav bar style
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"HomePageNavBar.png"] forBarMetrics:UIBarMetricsDefault];
    //[self.navigationController.navigationBar setShadowImage:[[UIImage alloc] init]];
    [self.navigationController.navigationBar setTranslucent:NO];
    //[self.navigationController.navigationBar setBarTintColor:UIColorFromRGB(0x007aff)];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    
    // Additional View button
    UIButton *additionalViews = [UIButton buttonWithType:UIButtonTypeCustom];
    [additionalViews setImage:[UIImage imageNamed:@"AdditionalViews.png"] forState:UIControlStateNormal];
    [additionalViews addTarget:self action:@selector(additionalViews:) forControlEvents:UIControlEventTouchUpInside];
    additionalViews.adjustsImageWhenHighlighted = NO;
    additionalViews.selected = NO;
    if (IS_WIDESCREEN) {
        additionalViews.frame = CGRectMake(240, 510, 50, 50);
    }
    else {
        additionalViews.frame = CGRectMake(240, 422, 50, 50);
    }
    self.additionalViewsButton = additionalViews;
    [self.navigationController.view addSubview:additionalViews];
    
    
    // section index
    if ([self.tableView respondsToSelector:@selector(setSectionIndexColor:)]) {
        self.tableView.sectionIndexColor = [UIColor grayColor];
        //self.tableView.sectionIndexTrackingBackgroundColor
    }
    
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    // Flurry
    [Flurry logEvent:@"Home_ViewDidAppear"];
    
    NSLog(@"Home VC viewDidAppear");

    if (![PFUser currentUser]) { // No user logged in
        
        [self.sections removeAllObjects];
        [self.sectionToAlphabetMap removeAllObjects];
        [self.tableView reloadData];
        
        UIViewController *launchPage = [self.storyboard instantiateViewControllerWithIdentifier:@"LaunchPage"];
        [self presentViewController:launchPage animated:YES completion:NULL];

    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - UITableViewDelegate


- (PFObject *)objectAtIndexPath:(NSIndexPath *)indexPath {
    NSString *sectionTitle = [self letterForSection:indexPath.section];
    
    if ([sectionTitle isEqualToString:@"Me"]) {
        PFObject *userObject = (PFObject *)[PFUser currentUser];
        return userObject;
    }
    
    if ([sectionTitle isEqualToString:@"Recents"]) {
        // return any object it doesn't matter
        PFObject *userObject = (PFObject *)[PFUser currentUser];
        return userObject;
    }
    
    if ([sectionTitle isEqualToString:@"Placeholder"]) {
        // return any object it doesn't matter
        PFObject *userObject = (PFObject *)[PFUser currentUser];
        return userObject;
    }
    
    NSArray *rowIndecesInSection = [self.sections objectForKey:sectionTitle];

    NSNumber *rowIndex = [rowIndecesInSection objectAtIndex:indexPath.row];
    PFObject *object = [self.sortedArray objectAtIndex:[rowIndex intValue]];
    return object;
    
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.sections.allKeys.count == 3) {
        UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
        messageLabel.frame = CGRectMake(40, self.view.bounds.size.height/4, 240, self.view.bounds.size.height);

        messageLabel.text = @"Follow some people to fill this sad empty space.";
        messageLabel.textColor = [UIColor blackColor];
        messageLabel.numberOfLines = 2;
        messageLabel.textAlignment = NSTextAlignmentCenter;
        messageLabel.font = [UIFont fontWithName:@"Avenir Next" size:16];
        
        UIView *background = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
        [background addSubview:messageLabel];
        
        self.tableView.backgroundView = background;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
    }
    else self.tableView.backgroundView = nil;
    
    NSLog(@"number of sections %ld", (long)self.sections.allKeys.count);
    return self.sections.allKeys.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    NSString *sectionTitle = [self letterForSection:section];
    NSArray *rowIndecesInSection = [self.sections objectForKey:sectionTitle];

    return rowIndecesInSection.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *sectionTitle = [self letterForSection:section];
    
    if ([sectionTitle isEqualToString:@"Me"] || [sectionTitle isEqualToString:@"Placeholder"]) {
        return nil;
    }
    
    if ([sectionTitle isEqualToString:@"Recents"]) {
        return nil;
    }
    
    return sectionTitle;
}

- (NSString *)letterForSection:(NSInteger)section {
    return [self.sectionToAlphabetMap objectForKey:[NSNumber numberWithLong:section]];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UILabel *myLabel = [[UILabel alloc] init];
    myLabel.frame = CGRectMake(10, 5, 320, 15);
    myLabel.font = [UIFont fontWithName:@"Avenir Next" size:15];
    myLabel.text = [self tableView:tableView titleForHeaderInSection:section];
    
    UIImageView *background = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SectionHeader.png"]];
    background.frame = CGRectMake(0, 0, 320, 20);
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 22)];
    [headerView addSubview:background];
    [headerView addSubview:myLabel];
    
    return headerView;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    NSString *sectionTitle = [self letterForSection:section];
    
    if ([sectionTitle isEqualToString:@"Me"]) {
        return 0;
    }
    
    else if ([sectionTitle isEqualToString:@"Placeholder"]) {
        return 0;
    }
    
    else return 22;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return 70;
    }
    
    return 60;
}

// Index Methods

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    NSArray *alphabetArray = [[NSArray alloc] initWithObjects: @"#", @"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H", @"I", @"J", @"K", @"L", @"M", @"N", @"O", @"P", @"Q", @"R", @"S", @"T", @"U", @"V", @"W", @"X", @"Y", @"Z", nil];
    return alphabetArray;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    
    // for numbers
    if ([title isEqualToString:@"#"]) {
        return 2;
    }
    
    else if ([self.sectionToAlphabetMap allKeysForObject:title].count > 0) {
    
    // for letters
    NSArray *keysArray = [self.sectionToAlphabetMap allKeysForObject:title];
    NSNumber *key = keysArray[0];
    NSInteger returnIndex = [key longValue];
    return returnIndex;
        
    }
    
    return NSNotFound;
    
}

// Query
 
- (PFQuery *)queryForTable {
    
    NSLog(@"Query started.");
    
    if ([PFUser currentUser]) { //User logged in.
        
        NSTimeInterval aDayAgo = -86400.00;
        
        // all followees
        
        PFQuery *allFollowees = [PFQuery queryWithClassName:@"Activity"];
        [allFollowees whereKey:@"fromUser" equalTo:[PFUser currentUser]];
        [allFollowees whereKey:@"type" equalTo:@"follow"];
        
        
        // ******** PHOTOS ***********
        // 1. Today Photos
        // 1. Followees today photos
        
        // Followee is owner
        PFQuery *followeeTodayOwner = [PFQuery queryWithClassName:@"CPhoto"];
        [followeeTodayOwner whereKey:@"createdAt" greaterThanOrEqualTo:[NSDate dateWithTimeIntervalSinceNow:aDayAgo]];
        [followeeTodayOwner whereKey:@"owner" matchesKey:@"toUser" inQuery:allFollowees];
        // Followee completed
        PFQuery *followeeTodayCompletor = [PFQuery queryWithClassName:@"CPhoto"];
        [followeeTodayCompletor whereKey:@"createdAt" greaterThanOrEqualTo:[NSDate dateWithTimeIntervalSinceNow:aDayAgo]];
        [followeeTodayCompletor whereKey:@"completor" matchesKey:@"toUser" inQuery:allFollowees];
        
        // 2. Your Today photos
        
        // I am owner
        PFQuery *myTodayOwner = [PFQuery queryWithClassName:@"CPhoto"];
        [myTodayOwner whereKey:@"createdAt" greaterThanOrEqualTo:[NSDate dateWithTimeIntervalSinceNow:aDayAgo]];
        [myTodayOwner whereKey:@"owner" equalTo:[PFUser currentUser]];
        [myTodayOwner whereKey:@"objectId" doesNotMatchKey:@"objectId" inQuery:followeeTodayCompletor]; // to avoid duplicates
        // I am completor
        PFQuery *myTodayCompletor = [PFQuery queryWithClassName:@"CPhoto"];
        [myTodayCompletor whereKey:@"createdAt" greaterThanOrEqualTo:[NSDate dateWithTimeIntervalSinceNow:aDayAgo]];
        [myTodayCompletor whereKey:@"completor" equalTo:[PFUser currentUser]];
        [myTodayCompletor whereKey:@"objectId" doesNotMatchKey:@"objectId" inQuery:followeeTodayOwner]; // to avoid duplicates
        
        // all photos combined
        
        PFQuery *allTodayPhotos = [PFQuery orQueryWithSubqueries:@[followeeTodayOwner, followeeTodayCompletor, myTodayOwner, myTodayCompletor]];
        
        // includes for CPhoto
        [allTodayPhotos includeKey:@"owner"];
        [allTodayPhotos includeKey:@"completor"];
        [allTodayPhotos includeKey:@"imageToComplete"];
        
        allTodayPhotos.cachePolicy = kPFCachePolicyNetworkOnly;
        allTodayPhotos.limit = 1000;
        [allTodayPhotos addDescendingOrder:@"createdAt"];
        
        [allTodayPhotos findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            
            if (!error) {
                // The find succeeded.
                NSLog(@"Retrieved %ld Today Photo Objects.", (long)objects.count);
                self.recentArray = [NSMutableArray arrayWithArray:objects];
                
                [self.userToTodayPhotos removeAllObjects];
                
                
                for (PFObject *object in objects) {
                    // sort object into owner
                    PFUser *owner = [object objectForKey:@"owner"];
                    NSString *ownerUsername = [owner objectForKey:@"username"];
                    
                    NSMutableArray *ownerObjectsForUsername = [self.userToTodayPhotos objectForKey:ownerUsername];
                    if (!ownerObjectsForUsername) {
                        ownerObjectsForUsername = [NSMutableArray array];
                    }
                    [ownerObjectsForUsername addObject:object];
                    [self.userToTodayPhotos setObject:ownerObjectsForUsername forKey:ownerUsername];
                    
                    // sort object into completor
                    PFUser *completor = [object objectForKey:@"completor"];
                    NSString *completorUsername = [completor objectForKey:@"username"];
                    
                    NSMutableArray *completorObjectsForUsername = [self.userToTodayPhotos objectForKey:completorUsername];
                    if (!completorObjectsForUsername) {
                        completorObjectsForUsername = [NSMutableArray array];
                    }
                    [completorObjectsForUsername addObject:object];
                    [self.userToTodayPhotos setObject:completorObjectsForUsername forKey:completorUsername];
                }
                
                /*
                // add intro photos
                if (self.newUserSignedUp) {
                    NSLog(@"setting intro photos ");

                    PFUser *teamPaiir = [self.teamPaiirIntroPhotos[0] objectForKey:@"owner"];
                    NSLog(@"%@", teamPaiir.username);

                    [self.userToTodayPhotos setObject:self.teamPaiirIntroPhotos forKey:teamPaiir.username];
                    
                    NSLog(@"%@", self.userToTodayPhotos);
                    self.newUserSignedUp = NO;
                }
                */
                
                [self.tableView reloadData];
                
                
                if (self.userToTodayPhotos.count > 0) {
                    [self preloadFollowerToPhotos:self.userToTodayPhotos];
                }
                
            } else {
                // Log details of the failure
                NSLog(@"Error: %@ %@", error, [error userInfo]);
            }

        }];
        /*
        // 2. Highlight Photos

        // 1. Followee highlight photos
        
        PFQuery *followeeHighlight = [PFQuery queryWithClassName:@"Activity"];
        [followeeHighlight whereKey:@"fromUser" matchesKey:@"toUser" inQuery:allFollowees];
        [followeeHighlight whereKey:@"type" equalTo:@"highlight"];
        
        // 2. My Highlight photos
        
        PFQuery *myHighlight = [PFQuery queryWithClassName:@"Activity"];
        [myHighlight whereKey:@"fromUser" equalTo:[PFUser currentUser]];
        [myHighlight whereKey:@"type" equalTo:@"highlight"];
        
        PFQuery *allHighlightPhotos = [PFQuery orQueryWithSubqueries:@[followeeHighlight, myHighlight]];

        // includes for highlight
        [allHighlightPhotos includeKey:@"fromUser"];
        [allHighlightPhotos includeKey:@"photoPointer.owner"];
        [allHighlightPhotos includeKey:@"photoPointer.completor"];
        [allHighlightPhotos includeKey:@"photoPointer.imageToComplete"];

        allHighlightPhotos.cachePolicy = kPFCachePolicyNetworkOnly;
        allHighlightPhotos.limit = 1000;
        [allHighlightPhotos addDescendingOrder:@"createdAt"];

        [allHighlightPhotos findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            NSLog(@"Objects in allHighlightPhotos Query: %lu", (unsigned long)objects.count);
            
            if (!error) {
                // The find succeeded.
                NSLog(@"Retrieved %ld Highlight Photo Objects.", (long)objects.count);
                [self.userToHighlightPhotos removeAllObjects];
                
                for (PFObject *object in objects) {
                    PFUser *highlightor = [object objectForKey:@"fromUser"];
                    
                    NSString *username = [highlightor objectForKey:@"username"];
                    
                    NSMutableArray *objectsForUsername = [self.userToHighlightPhotos objectForKey:username];
                    if (!objectsForUsername) {
                        objectsForUsername = [NSMutableArray array];
                    }
                    
                    [objectsForUsername addObject:[object objectForKey:@"photoPointer"]];
                    [self.userToHighlightPhotos setObject:objectsForUsername forKey:username];
                }
                
                [self.tableView reloadData];
                
            } else {
                // Log details of the failure
                NSLog(@"Error: %@ %@", error, [error userInfo]);
            }
            
        }];
        */
        // **** END OF PHOTOS ****
        
        // My followers count
        PFQuery *myFollowersCount = [PFQuery queryWithClassName:@"Activity"];
        [myFollowersCount whereKey:@"toUser" equalTo:[PFUser currentUser]];
        [myFollowersCount whereKey:@"type" equalTo:@"follow"];
        
        myFollowersCount.cachePolicy = kPFCachePolicyNetworkOnly;
        [myFollowersCount countObjectsInBackgroundWithBlock:^(int count, NSError *error) {
            if (!error) {
                // The find succeeded.
                NSLog(@"Retrieved %i myFollowers.", (int)count);
                
                self.myFollowersCount = count;
                
                [self.tableView reloadData];
                
            } else {
                // Log details of the failure
                NSLog(@"Error: %@ %@", error, [error userInfo]);
            }
        }];
        
        // Paiir score
        PFQuery *followeePaiirScoreQuery = [PFQuery queryWithClassName:@"PaiirScore"];
        [followeePaiirScoreQuery whereKey:@"user" matchesKey:@"toUser" inQuery:allFollowees];
        
        PFQuery *personalPaiirScoreQuery = [PFQuery queryWithClassName:@"PaiirScore"];
        [personalPaiirScoreQuery whereKey:@"user" equalTo:[PFUser currentUser]];
        
        PFQuery *paiirScoreQuery = [PFQuery orQueryWithSubqueries:@[followeePaiirScoreQuery, personalPaiirScoreQuery]];
        
        [paiirScoreQuery includeKey:@"user"];
        
        paiirScoreQuery.cachePolicy = kPFCachePolicyNetworkOnly;
        [paiirScoreQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                // The find succeeded.
                NSLog(@"Retrieved %ld PaiirScore Objects.", (long)objects.count);
                [self.userToPaiirScore removeAllObjects];
                
                for (PFObject *object in objects) {
                    PFUser *user = [object objectForKey:@"user"];
                    NSString *username = [user objectForKey:@"username"];
                    
                    [self.userToPaiirScore setObject:object forKey:username];
                }
                
                [self.tableView reloadData];

                
            } else {
                // Log details of the failure
                NSLog(@"Error: %@ %@", error, [error userInfo]);
            }
        }];
        
        // Highlight count
        PFQuery *followeeHighlightCount = [PFQuery queryWithClassName:@"HighlightCount"];
        [followeeHighlightCount whereKey:@"user" matchesKey:@"toUser" inQuery:allFollowees];
        
        PFQuery *personalHighlightCount = [PFQuery queryWithClassName:@"HighlightCount"];
        [personalHighlightCount whereKey:@"user" equalTo:[PFUser currentUser]];
        
        PFQuery *highlightCount = [PFQuery orQueryWithSubqueries:@[personalHighlightCount, followeeHighlightCount]];
        
        [highlightCount includeKey:@"user"];
        
        highlightCount.cachePolicy = kPFCachePolicyNetworkOnly;
        [highlightCount findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                // The find succeeded.
                NSLog(@"Retrieved %ld PaiirScore Objects.", (long)objects.count);
                [self.userToHighlightCount removeAllObjects];
                
                for (PFObject *object in objects) {
                    PFUser *user = [object objectForKey:@"user"];
                    NSString *username = [user objectForKey:@"username"];
                    
                    [self.userToHighlightCount setObject:object forKey:username];
                }
                
                [self.tableView reloadData];
                
                
            } else {
                // Log details of the failure
                NSLog(@"Error: %@ %@", error, [error userInfo]);
            }
        }];
        
        // Staffpicks
        PFQuery *staffpickQuery = [PFQuery queryWithClassName:@"CPhoto"];
        [staffpickQuery whereKey:@"staffpicked" equalTo:@"Y"];
        
        [staffpickQuery includeKey:@"owner"];
        [staffpickQuery includeKey:@"completor"];
        [staffpickQuery includeKey:@"imageToComplete"];
        
        staffpickQuery.cachePolicy = kPFCachePolicyNetworkElseCache;
        [staffpickQuery orderByDescending:@"createdAt"];
        
        [staffpickQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                // The find succeeded.
                NSLog(@"Retrieved %ld Staffpick Objects.", (long)objects.count);
                self.staffpickObjects = [NSMutableArray arrayWithArray:objects];
                
            } else {
                // Log details of the failure
                NSLog(@"Error: %@ %@", error, [error userInfo]);
            }
        }];


        
        // Query for all following
        
        [allFollowees includeKey:@"toUser"];
        allFollowees.limit = 1000;
        allFollowees.cachePolicy = kPFCachePolicyNetworkOnly;
        
        NSLog(@"End of Query.");
        
        return allFollowees;
        
    }
    
    else {
        
        [super objectsDidLoad:[NSError errorWithDomain:@"" code:0 userInfo:nil]]; //Return failed to turn off spinner.
        
        return nil;
        
    }
    
}

- (void)objectsDidLoad:(NSError *)error {
    [super objectsDidLoad:error];
    
    NSLog(@"objectsDidLoad");

    NSLog(@"Number of followee objects: %ld", (long)self.objects.count);
    
    // This method is called every time objects are loaded from Parse via the PFQuery
    
    [self.sections removeAllObjects];
    [self.sectionToAlphabetMap removeAllObjects];
    
    // Set first Section - User
    
    NSInteger section = 0;
    NSInteger userRow = 0;
    
    NSMutableArray *objectsInFirstSection = [NSMutableArray array];
    NSString *userObject = @"Me";
    [self.sectionToAlphabetMap setObject:userObject forKey:[NSNumber numberWithLong:section++]];
    [objectsInFirstSection addObject:[NSNumber numberWithLong:userRow]];
    [self.sections setObject:objectsInFirstSection forKey:userObject];
    
    // Set second Section
    NSInteger recentRow = 0;

    NSMutableArray *objectsInSecondSection = [NSMutableArray array];
    [self.sectionToAlphabetMap setObject:@"Recents" forKey:[NSNumber numberWithLong:section++]];
    [objectsInSecondSection addObject:[NSNumber numberWithLong:recentRow]];
    [self.sections setObject:objectsInSecondSection forKey:@"Recents"];
    
    // Creating usernameToObject dictionary and sorted PFObjects in self.sortedArray
    
    NSMutableDictionary *usernameToObject = [NSMutableDictionary dictionary];
    
    for (PFObject *object in self.objects) {
        
        // Set followers into dictionary for sorting
        
        PFUser *user = [object objectForKey:@"toUser"];
        NSString *username = [user objectForKey:@"username"];
        [usernameToObject setObject:object forKey:username];
    }
    
    NSArray *sortedKeys = [[usernameToObject allKeys] sortedArrayUsingSelector: @selector(localizedCaseInsensitiveCompare:)];
    NSMutableArray *sortedValues = [NSMutableArray array];
    for (NSString *key in sortedKeys) {
        [sortedValues addObject:[usernameToObject objectForKey:key]];
    }
    self.sortedArray = (NSArray *)sortedValues;
    
    
    // Set Alphabetic Sections
    
    NSInteger rowIndex = 0;
    
    for (PFObject *object in self.sortedArray) {
        
        PFUser *user = [object objectForKey:@"toUser"];
        NSString *username = [user objectForKey:@"username"];
        NSString *sectionTitle = [username substringToIndex:1];
        sectionTitle = [sectionTitle uppercaseString];
        
        NSMutableArray *objectsInSection = [self.sections objectForKey:sectionTitle];
        if (!objectsInSection) {
            objectsInSection = [NSMutableArray array];
            
            // this is the first time we see this letter - increment the section index
            [self.sectionToAlphabetMap setObject:sectionTitle forKey:[NSNumber numberWithLong:section++]];
        }
        
        [objectsInSection addObject:[NSNumber numberWithLong:rowIndex++]];
        [self.sections setObject:objectsInSection forKey:sectionTitle];
    }
    
    // Set Placeholder/Last Section
    
    [self.sectionToAlphabetMap setObject:@"Placeholder" forKey:[NSNumber numberWithLong:section++]];
    NSMutableArray *objectsInLastSection = [NSMutableArray array];
    [objectsInLastSection addObject:[NSNumber numberWithLong:0]];
    [self.sections setObject:objectsInLastSection forKey:@"Placeholder"];
    
    // Reload Data
    
    [self.tableView reloadData];
    
    // hometutorialoverlay
    if (self.newUserSignedUpFlag) {
        
        self.newUserSignedUpFlag = NO;

        [self showTutorialOverlay];
        
    }
    
    NSLog(@"End of objectsDidLoad");

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {
    // Personal Section
    
    if (indexPath.section == 0) {
        // create cell
        DGRPersonalCell *cell = (DGRPersonalCell *)[tableView dequeueReusableCellWithIdentifier:@"PersonalCell" forIndexPath:indexPath];
        cell.delegate = self;
        
        // Profile Picture
        cell.profilePicture.layer.cornerRadius = 25.0f;
        cell.profilePicture.clipsToBounds = YES;
        cell.profilePicture.image = [UIImage imageNamed:@"ProfilePicturePlaceholder.png"];
        cell.profilePicture.file = [[PFUser currentUser] objectForKey:@"profilePicture"];
        [cell.profilePicture loadInBackground];
        
        // Username
        cell.username.text = [PFUser currentUser].username;
        
        // Paiirscore
        cell.paiirScoreLabel.text = [self setPaiirScoreForUser:[PFUser currentUser].username];
        
        // Followers
        cell.followersLabel.text = [NSString stringWithFormat:@"%i followers", (int)self.myFollowersCount];
        cell.followersLabel.textColor = [UIColor blueColor];
        
        // Today button
        NSArray *myPhotos = [self.userToTodayPhotos objectForKey:[PFUser currentUser].username];
        if (myPhotos.count > 0) {
            PFObject *latestPhoto = myPhotos[0];
            [latestPhoto fetchIfNeeded];
            PFFile *thumbnail = [latestPhoto objectForKey:@"thumbnail"];
            if ([thumbnail isKindOfClass:[NSNull class]]) {
                [cell disableRecentButton];
            }
            [thumbnail getDataInBackgroundWithBlock:^(NSData *data, NSError *error){
                    [cell highlightRecentButton:[UIImage imageWithData:data]];
            }];
            
        }
        else {
            [cell disableRecentButton];
        }
        
        
        // Highlight Button
        [cell highlightHighlightButton];
        
        // Today & Highlights Label
        cell.todayLabel.text = [self setPhotosLabelWithTodayPhotos:(int)myPhotos.count highlightPhotos:[self setHighlightCountForUser:[PFUser currentUser].username]];
        
        return cell;
        
    }
    
    // Recent Section
    
    else if (indexPath.section == 1) {
        DGRRecentCell *cell = (DGRRecentCell *)[tableView dequeueReusableCellWithIdentifier:@"RecentCell" forIndexPath:indexPath];
        
        // Today button
        if (self.recentArray.count > 0) {
            [cell highlightTodayButton];
        }
        else {
            [cell disableTodayButton];
        }
        
        // make staffpick cell rounded
        cell.staffpickButton.layer.cornerRadius = 5.0f;
        cell.staffpickButton.clipsToBounds = YES;

        return cell;
    }

    
    // Placeholder Section
    
    else if ((int)indexPath.section == (int)self.sectionToAlphabetMap.count-1) {
        DGRInviteFriendsCell *cell = (DGRInviteFriendsCell *)[tableView dequeueReusableCellWithIdentifier:@"PlaceholderCell" forIndexPath:indexPath];
        cell.delegate = self;
        return cell;
    }
    
    else {
        // create cell
        DGRHomeCell *cell = (DGRHomeCell *)[tableView dequeueReusableCellWithIdentifier:@"HomeCell" forIndexPath:indexPath];
        
        // fix content offset
        if (cell.scrollView.contentOffset.x != kCatchWidth) {
            [cell.scrollView setContentOffset:CGPointMake(kCatchWidth, 0) animated:NO];
        }
        
        // fix initial frames
        cell.todayButton.frame = CGRectMake(250, 5, 30, 50);
        cell.highlightButton.frame = CGRectMake(320, 0, 60, 60);
        cell.paiirsAndHighlightsLabel.frame = CGRectMake(75, 35, 145, 15);
        cell.paiirScoreLabel.frame = CGRectMake(75, 70, 145, 15);
        
        // set up
        cell.delegate = self;
        PFUser *user = [object objectForKey:@"toUser"];
        NSString *username = [user objectForKey:@"username"];
        cell.thisUser = user;
        
        // Profile Picture
        cell.profilePictureView.image = [UIImage imageNamed:@"ProfilePicturePlaceholder.png"];
        cell.profilePictureView.file = [user objectForKey:@"profilePicture"];
        [cell.profilePictureView loadInBackground];
        
        // Username
        cell.followingUser.text = username;
        
        // Paiirscore label
        cell.paiirScoreLabel.text = [self setPaiirScoreForUser:username];
        
        // Today Button
        NSArray *followeePhotos = [self.userToTodayPhotos objectForKey:username];
        if (followeePhotos.count != 0) {
            
            PFObject *latestPhoto = followeePhotos[0];
            [latestPhoto fetchIfNeeded];
            PFFile *thumbnail = [latestPhoto objectForKey:@"thumbnail"];
            if ([thumbnail isKindOfClass:[NSNull class]]) {
                [cell disableRecentButton];
            }
            [thumbnail getDataInBackgroundWithBlock:^(NSData *data, NSError *error){
                [cell highlightRecentButton:[UIImage imageWithData:data]];
            }];

        }
        else {
            [cell disableRecentButton];
        }
        
        cell.isInRecent = NO;
        
        // Highlight Button
        [cell highlightHighlightButton];
        
        // Photos label
        cell.paiirsAndHighlightsLabel.text = [self setPhotosLabelWithTodayPhotos:(int)followeePhotos.count highlightPhotos:[self setHighlightCountForUser:username]];
        
        return cell;
        
    }
    
    return nil;
    
    /*
     // Follower Section
     // recents
     else if ([[self letterForSection:indexPath.section] isEqualToString:@"Recents"]) {
     
     // create cell
     DGRRecentCell *cell = (DGRRecentCell *)[tableView dequeueReusableCellWithIdentifier:@"RecentCell" forIndexPath:indexPath];
     
     cell.delegate = self;
     
     // do rest
     PFUser *user = [object objectForKey:@"toUser"];
     NSMutableArray *paiirScore = [self.followerToPaiirScoreFinal objectForKey:[user objectForKey:@"username"]];
     if (paiirScore.count == 1) {
     cell.paiirScoreLabel.text = @"1 paiir";
     }
     else {
     cell.paiirScoreLabel.text = [NSString stringWithFormat:@"%lu paiirs", (unsigned long)paiirScore.count];
     }
     
     cell.followingUser.text = [user objectForKey:@"username"];
     NSLog(@"%@", user.username);
     
     NSLog(@"Recent section");
     NSArray *photos = [self.followerToRecentPhotos objectForKey:user.username];
     
     if (photos.count > 0) {
     [cell highlightRecentButton:photos.count];
     }
     else {
     [cell disableRecentButton:self];
     }
     // pass user on
     cell.thisUser = user;
     
     return cell;
     
     }
     */
    
}

#pragma mark - UIScrollView

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DGRHomeCellEnclosingTableViewDidBeginScrollingNotification" object:scrollView];
}

#pragma mark - Single Camera

- (IBAction)startCamera:(id)sender {
    
    // Flurry
    [Flurry logEvent:@"Home_SingleCameraAction"];
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [self playSound];
        [self initiateCamera];
    }
    else {
        [self noCameraAlert];
    }
}

- (void)initiateCamera {
    
    if (IS_WIDESCREEN) {
        
        DGRNoStatusBarImagePickerControllerViewController *picker = [[DGRNoStatusBarImagePickerControllerViewController alloc] init];
        picker.delegate = self.cameraVC;
        picker.allowsEditing = NO;
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        picker.showsCameraControls = NO;
        picker.cameraFlashMode = UIImagePickerControllerCameraFlashModeOff;
        
        self.cameraVC.view.frame = picker.cameraOverlayView.frame;
        picker.cameraOverlayView = self.cameraVC.view;
        
        //Adjusting camera preview size
        //Camera is 426,67 * 320. Screen height is 568
        CGAffineTransform translate = CGAffineTransformMakeTranslation(0.0, -71.0);
        picker.cameraViewTransform = translate;
        //CGAffineTransform scale = CGAffineTransformScale(translate, 0.5322, 0.5322);
        //picker.cameraViewTransform = scale;
        
        self.cameraVC.imagePickerController = picker;
        
        picker.isComplete = NO;
        picker.transitioningDelegate = self;
        picker.modalPresentationStyle = UIModalPresentationCustom;
        picker.modalPresentationCapturesStatusBarAppearance = YES;
        
        [self presentViewController:picker animated:YES completion:^{
            [self shrinkAdditionalViews];
        }];
    }
    
    else {
        
        DGRNoStatusBarImagePickerControllerViewController *picker = [[DGRNoStatusBarImagePickerControllerViewController alloc] init];
        picker.delegate = self.cameraVC;
        picker.allowsEditing = NO;
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        picker.showsCameraControls = NO;
        picker.cameraFlashMode = UIImagePickerControllerCameraFlashModeOff;
        
        self.cameraVC.view.frame = picker.cameraOverlayView.frame;
        picker.cameraOverlayView = self.cameraVC.view;
        
        //Adjusting camera preview size
        //Camera is 480 * 320. Screen height is 480.
        CGAffineTransform translate = CGAffineTransformMakeTranslation(0.0, -120.0);
        //picker.cameraViewTransform = translate;
        CGAffineTransform scale = CGAffineTransformScale(translate, 0.845, 0.845);
        picker.cameraViewTransform = scale;
        
        self.cameraVC.imagePickerController = picker;
        
        picker.isComplete = NO;
        picker.transitioningDelegate = self;
        picker.modalPresentationStyle = UIModalPresentationCustom;
        picker.modalPresentationCapturesStatusBarAppearance = YES;
        
        [self presentViewController:picker animated:YES completion:^{
            [self shrinkAdditionalViews];
        }];
    }
       
}

-(void)initiatePhotoLibrary {
    if (IS_WIDESCREEN) {
        
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self.cameraVC;
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        
        self.cameraVC.imagePickerController = picker;
        
        [self presentViewController:picker animated:YES completion:NULL];
    }
    
    else {
        
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self.cameraVC;
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        
        self.cameraVC.imagePickerController = picker;
        
        [self presentViewController:picker animated:YES completion:NULL];
    }

}

#pragma mark - Complete Camera

- (IBAction)startCompleteCamera:(id)sender {
    
    // Flurry
    [Flurry logEvent:@"Home_CompleteCameraAction"];
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [self playSound];
        [self initiateCompleteCamera];
    }
    else {
        [self noCameraAlert];
    }
}


- (void)initiateCompleteCamera {
    
    // ImagePicker
    
    if (IS_WIDESCREEN) {
                
        // init camera
        DGRNoStatusBarImagePickerControllerViewController *picker = [[DGRNoStatusBarImagePickerControllerViewController alloc] init];
        picker.delegate = self.completeCameraVC;
        picker.allowsEditing = NO;
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        picker.showsCameraControls = NO;
        picker.cameraFlashMode = UIImagePickerControllerCameraFlashModeOff;
        
        picker.cameraOverlayView = self.completeCameraVC.view;
        
        //Adjusting camera preview size
        //Camera is 426,67 * 320. Screen height is 568.
        CGAffineTransform translate = CGAffineTransformMakeTranslation(0.0, 141.0); //shift preview
        picker.cameraViewTransform = translate;
        //CGAffineTransform scale = CGAffineTransformScale(translate, 0.5322, 0.5322);
        //picker.cameraViewTransform = scale;
        
        self.completeCameraVC.imagePickerController = picker;
        
        picker.isComplete = YES;
        picker.transitioningDelegate = self;
        picker.modalPresentationStyle = UIModalPresentationCustom;
        picker.modalPresentationCapturesStatusBarAppearance = YES;
        
        [self presentViewController:picker animated:YES completion:^{
            if (self.completeCameraVC.completeViewController) {
                [self shrinkAdditionalViews];
                [self.completeCameraVC.completeViewController.tableView setContentOffset:CGPointMake(0, 0) animated:YES];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"DGRCompleteViewControllerLoadParseObjects" object:self];

            }
        }];
    }
    
    else {
        
        DGRNoStatusBarImagePickerControllerViewController *picker = [[DGRNoStatusBarImagePickerControllerViewController alloc] init];
        picker.delegate = self.completeCameraVC;
        picker.allowsEditing = NO;
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        picker.showsCameraControls = NO;
        picker.cameraFlashMode = UIImagePickerControllerCameraFlashModeOff;
        
        picker.cameraOverlayView = self.completeCameraVC.view;
        
        //Adjusting camera preview size
        //Camera is 480 * 320. Screen height is 480
        CGAffineTransform translate = CGAffineTransformMakeTranslation(0.0, 120.0);
        //picker.cameraViewTransform = translate;
        CGAffineTransform scale = CGAffineTransformScale(translate, 0.845, 0.845);
        picker.cameraViewTransform = scale;
        
        self.completeCameraVC.imagePickerController = picker;
        
        picker.isComplete = YES;
        picker.transitioningDelegate = self;
        picker.modalPresentationStyle = UIModalPresentationCustom;
        picker.modalPresentationCapturesStatusBarAppearance = YES;
        
        [self presentViewController:picker animated:YES completion:^{
            if (self.completeCameraVC.completeViewController) {
                [self shrinkAdditionalViews];
                [self.completeCameraVC.completeViewController.tableView setContentOffset:CGPointMake(0, 0) animated:YES];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"DGRCompleteViewControllerLoadParseObjects" object:self];

            }
        }];
    }
}

-(void)initiateCompletePhotoLibrary:(PFObject*)object {
    if (IS_WIDESCREEN) {
        
        self.completeCameraVC.pfObject = object;
        
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self.completeCameraVC;
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        
        self.completeCameraVC.imagePickerController = picker;
        
        [self presentViewController:picker animated:YES completion:NULL];
    }
    
    else {
        
        self.completeCameraVC.pfObject = object;
        
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self.completeCameraVC;
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        
        self.completeCameraVC.imagePickerController = picker;
        
        [self presentViewController:picker animated:YES completion:NULL];
    }
    
}


#pragma mark - Page Navigation

-(void)additionalViews:(id)sender {
    
    float degrees = 135.0;
    float radians = (degrees/180.0) * M_PI;
    
    if (self.additionalViewsButton.selected == NO) {
        
        // settings button
        UIButton *settingsButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [settingsButton setImage:[UIImage imageNamed:@"Settings.png"] forState:UIControlStateNormal];
        [settingsButton addTarget:self action:@selector(goToSettings:) forControlEvents:UIControlEventTouchUpInside];
        settingsButton.frame = self.additionalViewsButton.frame;
        self.settingsButton = settingsButton;
        [self.navigationController.view insertSubview:settingsButton atIndex:1];
        
        // notifications button
        UIButton *notificationsButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [notificationsButton setImage:[UIImage imageNamed:@"Notifications.png"] forState:UIControlStateNormal];
        [notificationsButton addTarget:self action:@selector(goToNotifications:) forControlEvents:UIControlEventTouchUpInside];
        notificationsButton.frame = self.additionalViewsButton.frame;
        self.notificationsButton = notificationsButton;
        [self.navigationController.view insertSubview:notificationsButton atIndex:1];

        // find friends button
        UIButton *findFriendsButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [findFriendsButton setImage:[UIImage imageNamed:@"AddFriend.png"] forState:UIControlStateNormal];
        [findFriendsButton addTarget:self action:@selector(goToFindFriends:) forControlEvents:UIControlEventTouchUpInside];
        findFriendsButton.frame = self.additionalViewsButton.frame;
        self.findFriendsButton = findFriendsButton;
        [self.navigationController.view insertSubview:findFriendsButton atIndex:1];
        
        // add overlay
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        _darkCoverView = [[UIView alloc] initWithFrame:screenRect];
        _darkCoverView.backgroundColor = [UIColor blackColor];
        _darkCoverView.alpha = 0.0f;
        [self.navigationController.view insertSubview:_darkCoverView atIndex:1];
        
        [UIView animateWithDuration:0.2
                         animations:^{
                             CGRect frame = self.additionalViewsButton.frame;
                             
                             // rotate
                             self.additionalViewsButton.transform = CGAffineTransformMakeRotation(radians);
                             
                             // overlay
                             _darkCoverView.alpha = 0.6f;
                             
                             //settings
                             frame.origin.x = frame.origin.x - 100.0f;
                             self.settingsButton.frame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, frame.size.height);
                             frame.origin.x = frame.origin.x + 100.0f;
                             
                             //notifications
                             frame.origin.x = frame.origin.x - 70.7f;
                             frame.origin.y = frame.origin.y - 70.7f;
                             self.notificationsButton.frame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, frame.size.height);
                             frame.origin.y = frame.origin.y + 70.7f;
                             frame.origin.x = frame.origin.x + 70.7f;
                             
                             //find friends
                             frame.origin.y = frame.origin.y - 100.0f;
                             self.findFriendsButton.frame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, frame.size.height);
                             frame.origin.y = frame.origin.y + 100.0f;

                             
                         }
                         completion:^(BOOL finished){
                             self.additionalViewsButton.selected = YES;
                         }];
    }
    
    else {
        [self shrinkAdditionalViews];
    }
    
}

-(void)shrinkAdditionalViews {
    [UIView animateWithDuration:0.2
                     animations:^{
                         CGRect frame = self.additionalViewsButton.frame;
                         
                         // rotate back
                         self.additionalViewsButton.transform = CGAffineTransformIdentity;
                         
                         // overlay
                         _darkCoverView.alpha = 0.0f;
                         
                         //settings
                         self.settingsButton.frame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, frame.size.height);
                         
                         //notifications
                         self.notificationsButton.frame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, frame.size.height);
                         
                         //find friends
                         self.findFriendsButton.frame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, frame.size.height);
                     }
                     completion:^(BOOL finished){
                         [self.settingsButton removeFromSuperview];
                         [self.notificationsButton removeFromSuperview];
                         [self.findFriendsButton removeFromSuperview];
                         [_darkCoverView removeFromSuperview];
                         
                         self.additionalViewsButton.selected = NO;
                     }];

}

-(void)goToFindFriends:(id)sender {
    
    // Flurry
    [Flurry logEvent:@"Home_FindFriendsAction"];
    
    UIViewController *findFriendsVC = (UIViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"FindFriendsViewController"];
    
    [self presentViewController:findFriendsVC animated:YES completion:^{
        [self shrinkAdditionalViews];
    }];
}

-(void)goToSettings:(id)sender {
    
    // Flurry
    [Flurry logEvent:@"Home_SettingsAction"];
    
    UIViewController *settingsVC = (UIViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"SettingsViewController"];
    
    [self presentViewController:settingsVC animated:YES completion:^{
        [self shrinkAdditionalViews];
    }];
}

-(void)goToNotifications:(id)sender {
    
    // Flurry
    [Flurry logEvent:@"Home_NotificationsAction"];
    
    UIViewController *settingsVC = (UIViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"NotificationsViewController"];
    
    [self presentViewController:settingsVC animated:YES completion:^{
        [self shrinkAdditionalViews];
    }];

}


-(IBAction)didTapMyFollowers:(UITapGestureRecognizer*)sender {
    
    UIViewController *singlesAndFollowersVC = (UIViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"SinglesAndFollowersViewController"];
    
    [self presentViewController:singlesAndFollowersVC animated:YES completion:NULL];
    
}

-(IBAction)didTapRecents:(UITapGestureRecognizer*)sender {
    
    // set photoobjects
    NSArray *photoObjects = [[NSArray alloc] init];
    
    photoObjects = self.recentArray;
    
    if (photoObjects) {
        
        // Flurry
        [Flurry logEvent:@"Home_RecentsAction"];
        
        // set animation variable
        CGPoint pointOnScreen = [sender locationInView:nil];
        self.touchOnScreen = pointOnScreen;
        
        // init VC
        DGRImageTableViewController *imageVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ImageTableViewController"];
        
        imageVC.transitioningDelegate = self;
        imageVC.modalPresentationStyle = UIModalPresentationCustom;
        imageVC.modalPresentationCapturesStatusBarAppearance = YES;
        
        // set moreoptionstype
        imageVC.moreOptionsType3 = YES;
        
        imageVC.photoObjects = [NSMutableArray arrayWithArray:photoObjects];
        
        [self presentViewController:imageVC animated:YES completion:nil];
    }
    else {
        NSLog(@"Recent Section empty.");
    }
    
}

-(IBAction)didTapStaffpicks:(UITapGestureRecognizer*)sender {
    
    // Flurry
    [Flurry logEvent:@"Home_RecentsAction"];
    
    if (self.staffpickObjects.count != 0) {
        
        // Flurry
        [Flurry logEvent:@"Home_StaffpicksAction"];
        
        // set animation variable
        CGPoint pointOnScreen = [sender locationInView:nil];
        self.touchOnScreen = pointOnScreen;
        
        // init VC
        DGRImageTableViewController *imageVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ImageTableViewController"];
        
        imageVC.transitioningDelegate = self;
        imageVC.modalPresentationStyle = UIModalPresentationCustom;
        imageVC.modalPresentationCapturesStatusBarAppearance = YES;
        
        // set moreoptionstype
        imageVC.moreOptionsType3 = YES;
        
        imageVC.photoObjects = [NSMutableArray arrayWithArray:self.staffpickObjects];
        
        [self presentViewController:imageVC animated:YES completion:nil];
    }
    else {
        NSLog(@"Staffpick empty.");
    }

}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented
                                                                  presentingController:(UIViewController *)presenting
                                                                      sourceController:(UIViewController *)source {
    
    if ([presented isKindOfClass:[DGRNoStatusBarImagePickerControllerViewController class]]) {
        DGRNoStatusBarImagePickerControllerViewController *imagePicker = (DGRNoStatusBarImagePickerControllerViewController*)presented;
        if (imagePicker.isComplete) {
            DGRHorizontalShiftRightAnimator *animator = [DGRHorizontalShiftRightAnimator new];
            animator.isPresenting = YES;
            return animator;
        }
        else {
            DGRHorizontalShiftLeftAnimator *animator = [DGRHorizontalShiftLeftAnimator new];
            animator.isPresenting = YES;
            return animator;
        }
    }
    
    else if ([presented isKindOfClass:[DGRHighlightsViewController class]] || [presented isKindOfClass:[DGRImageTableViewController class]]) {
        DGRZoomAnimator *animator = [DGRZoomAnimator new];
        animator.isPresenting = YES;
        animator.startingLocation = self.touchOnScreen;
        return animator;
    }
    
    return nil;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
        
    if ([dismissed isKindOfClass:[DGRNoStatusBarImagePickerControllerViewController class]]) {
        DGRNoStatusBarImagePickerControllerViewController *imagePicker = (DGRNoStatusBarImagePickerControllerViewController*)dismissed;
        if (imagePicker.isComplete) {
            DGRHorizontalShiftRightAnimator *animator = [DGRHorizontalShiftRightAnimator new];
            animator.isPresenting = NO;
            return animator;
        }
        else {
            DGRHorizontalShiftLeftAnimator *animator = [DGRHorizontalShiftLeftAnimator new];
            animator.isPresenting = NO;
            return animator;
        }

    }
    
    else if ([dismissed isKindOfClass:[DGRHighlightsViewController class]] || [dismissed isKindOfClass:[DGRImageTableViewController class]]) {
        DGRZoomAnimator *animator = [DGRZoomAnimator new];
        animator.isPresenting = NO;
        animator.startingLocation = self.touchOnScreen;
        return animator;
    }
    
    return nil;

}

#pragma mark - Preload Methods

-(void)preloadFollowerToPhotos:(NSDictionary *) dictionary {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    
        NSDictionary *duplicateDictionary = [NSDictionary dictionaryWithDictionary:dictionary];
        for (NSString *key in duplicateDictionary) {
            NSArray *photoObjects = [[NSArray alloc] init];
            photoObjects = [duplicateDictionary objectForKey:key];
                        
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


#pragma mark - Cell Protocols

- (void)didTapTodayButton:(PFUser*)user withRecognizer:(UITapGestureRecognizer *)sender {
    
    // Flurry
    [Flurry logEvent:@"Home_UserTodayAction"];
    
    // set animation variable
    if (user == nil) {
        // recent cell
        self.touchOnScreen = CGPointMake(260, 170);
    }
    else if (sender == nil){
        // personal cell
        self.touchOnScreen = CGPointMake(260, 100);
    }
    else {
        CGPoint pointOnScreen = [sender locationInView:nil];
        NSLog(@"Touch Point - %f, %f", pointOnScreen.x, pointOnScreen.y);
        self.touchOnScreen = pointOnScreen;
    }
    
    DGRImageTableViewController *imageVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ImageTableViewController"];
    
    imageVC.transitioningDelegate = self;
    imageVC.modalPresentationStyle = UIModalPresentationCustom;
    imageVC.modalPresentationCapturesStatusBarAppearance = YES;
    
    // set moreoptionstype
    if (user == [PFUser currentUser]) {
        imageVC.moreOptionsType1 = YES;
    }
    else {
        imageVC.moreOptionsType3 = YES;
    }

    // set photoobjects
    NSArray *photoObjects = [[NSArray alloc] init];
    
    if (user == nil) {
        photoObjects = self.recentArray;
    }
    else {
        photoObjects = [self.userToTodayPhotos objectForKey:user.username];
    }
    
    if (photoObjects) {
        
        imageVC.photoObjects = [NSMutableArray arrayWithArray:photoObjects];
        imageVC.homeDelegate = self;
        
        [self presentViewController:imageVC animated:YES completion:nil];
    }
    else {
        NSLog(@"No Objects available to show. Something went wrong.");
    }

}

- (void)didTapHighlightButton:(PFUser *)user withRecognizer:(UITapGestureRecognizer*)sender {
    
    // Flurry
    [Flurry logEvent:@"Home_UserHighlightAction"];
    
    if (sender == nil) {
        self.touchOnScreen = CGPointMake(260, 100);
    }
    else {
        CGPoint pointOnScreen = [sender locationInView:nil];
        NSLog(@"Touch Point - %f, %f", pointOnScreen.x, pointOnScreen.y);
        self.touchOnScreen = pointOnScreen;
    }
    
    DGRHighlightsViewController *highlightVC = (DGRHighlightsViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"HighlightsViewController"];
    
    highlightVC.transitioningDelegate = self;
    highlightVC.modalPresentationStyle = UIModalPresentationCustom;
    highlightVC.modalPresentationCapturesStatusBarAppearance = YES;

    if (user == [PFUser currentUser]) {
        highlightVC.highlightsType1 = YES;
    } else highlightVC.highlightsType2 = YES;
    
    highlightVC.user = user;
    
    highlightVC.delegate = self;
    
    [self presentViewController:highlightVC animated:YES completion:NULL];

}

- (void)didTapUnfollowButton:(DGRHomeCell *)cell {
    
    // remove cell
    [self.tableView beginUpdates];
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    NSString *sectionName = [self letterForSection:indexPath.section];
    
    NSMutableArray *objectsInSection = [self.sections objectForKey:sectionName];
    [objectsInSection removeObjectAtIndex:indexPath.row];
    
    
    if (objectsInSection.count == 0) {
        NSLog(@"remove section");
        [self.sections removeObjectForKey:sectionName];
        
        // adjust sectionToAlphabetMap
        for (int x = (int)indexPath.section; x < (int)self.sectionToAlphabetMap.count-1; x++) {
            NSObject *object = [self.sectionToAlphabetMap objectForKey:[NSNumber numberWithInt:x+1]];
            [self.sectionToAlphabetMap setObject:object forKey:[NSNumber numberWithInt:x]];
        }
        [self.sectionToAlphabetMap removeObjectForKey:[NSNumber numberWithInt:(int)self.sectionToAlphabetMap.count-1]];
        
        [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationRight];

    }
    
    else {
        NSLog(@"remove row");

        [self.sections setObject:objectsInSection forKey:sectionName];
        
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationRight];
    }
    [self.tableView endUpdates];

    
    NSLog(@"Removed cell in table view");
    
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

-(void)didTapPersonalTodayButton:(id)sender {
    
    [self didTapTodayButton:[PFUser currentUser] withRecognizer:nil];
    
}

-(void)didTapPersonalHighlightButton:(id)sender {
    
    [self didTapHighlightButton:[PFUser currentUser] withRecognizer:nil];
    
}

-(void)didTapInviteFriends {
    
    // Flurry
    [Flurry logEvent:@"Home_InviteFriendsAction"];
    
    NSArray *activityItems = @[@"Check out Paiir! www.paiir-app.com"];
    UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
    
    [self presentViewController:activityController animated:YES completion:NULL];
}


#pragma mark - Additional Methods


-(NSString *)setPhotosLabelWithTodayPhotos:(int)todayPhotos highlightPhotos:(int)highlightPhotos{
    
    NSString *todayPhotosText;
    NSString *highlightPhotosText;
    
    todayPhotosText = [NSString stringWithFormat:@"%li today", (long)todayPhotos];
    
    if (highlightPhotos == 1) {
        highlightPhotosText = @"1 highlight";
    }
    else {
        highlightPhotosText = [NSString stringWithFormat:@"%li highlights", (long)highlightPhotos];
    }
    
    NSString *fullLabel = [NSString stringWithFormat:@"%@, %@", todayPhotosText, highlightPhotosText];
    /*
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:fullLabel];
    
    if (followerCount > 0) {
        NSRange followerCountTextRange = {paiirScoreText.length+2, followerCountText.length};
        [attributedText setAttributes:@{NSForegroundColorAttributeName:[UIColor blueColor]}
                                range:followerCountTextRange];
    }
    */
    
    return fullLabel;
}

-(NSString*)setPaiirScoreForUser:(NSString*)username {
    PFObject *paiirScoreObject = [self.userToPaiirScore objectForKey:username];
    NSNumber *scoreCount = [paiirScoreObject objectForKey:@"scoreCount"];
    NSString *paiirScoreText = [NSString stringWithFormat:@"PaiirScore: %i", [scoreCount intValue]];
    return paiirScoreText;
}

-(int)setHighlightCountForUser:(NSString*)username {
    PFObject *highlightCountObject = [self.userToHighlightCount objectForKey:username];
    NSNumber *count = [highlightCountObject objectForKey:@"highlightCount"];
    return [count intValue];
}



-(void)loadParseObjects {
    [self dismissViewControllerAnimated:YES completion:NULL];
    [self loadObjects];
}

-(void)dismissAllPresentedViewControllersAnimated {
    [self dismissViewControllerAnimated:YES completion:NULL];

}

-(void)newUserSignedUp {
    self.newUserSignedUpFlag = YES;
}

-(void)showTutorialOverlay {

    NSString *overlayImage;
    if (IS_WIDESCREEN) {
        overlayImage = @"HomeTutorialOverlay.png";
    } else overlayImage = @"HomeTutorialOverlaySmall.png";
    
    UIImageView *cover = [[UIImageView alloc] initWithImage:[UIImage imageNamed:overlayImage]];
    
    //UIImageView *cover = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 568)];
    //[cover setBackgroundColor:[UIColor blackColor]];
    [cover setAlpha:0.0];
    
    UITapGestureRecognizer *coverTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideTutorialOverlay)];
    [cover addGestureRecognizer:coverTap];
    cover.userInteractionEnabled = YES;
    self.tutorialOverlay = cover;
    [self.navigationController.view addSubview:self.tutorialOverlay];
    
    [UIView animateWithDuration:1.0f
                     animations:^{
                         self.tutorialOverlay.alpha = 1.0f;
                     }];
}

-(void)hideTutorialOverlay {
    [UIView animateWithDuration:0.3f
                     animations:^{
                         self.tutorialOverlay.alpha = 0.0f;
                     }
                     completion:^(BOOL finished){
                         [self.tutorialOverlay removeFromSuperview];
                     }];

}



#pragma mark - Alerts

-(void)noCameraAlert {
    
    if ([UIAlertController class]) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Camera not available on this device" message:nil preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* ok = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
        }];
        [alert addAction:ok];
        
        [self presentViewController:alert animated:YES completion:nil];
    }
    
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Camera not available on this device" message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
        alert.tag = 1;
        
        [alert show];
    }
    
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0 && alertView.tag == 1) {
        
    }
}

-(void)playSound {
    /*
     NSString *path = [[NSBundle bundleWithIdentifier:@"com.apple.UIKit"] pathForResource:@"Tock" ofType:@"aiff"];
     SystemSoundID soundID;
     AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:path], &soundID);
     */
    AudioServicesPlaySystemSound (1103);
}








@end
