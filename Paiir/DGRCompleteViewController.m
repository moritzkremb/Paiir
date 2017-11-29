//
//  DGRCompleteViewController.m
//  Paiir
//
//  Created by Moritz Kremb on 3/3/14.
//  Copyright (c) 2014 Kremb. All rights reserved.
//

#import "DGRCompleteViewController.h"
#import "DGRCompleteCell.h"
#import "DGRConstants.h"
#import "DGRHomeViewController.h"
#import "DGRCompleteCameraViewController.h"
#import "DGRCameraViewController.h"
#import "DGRNoStatusBarImagePickerControllerViewController.h"
#import "TTTTimeIntervalFormatter.h"
#import <AudioToolbox/AudioToolbox.h>


@interface DGRCompleteViewController ()

//@property BOOL isLoading;
@property BOOL noMoreObjects;
@property NSArray *objectNumberControl;

@property (nonatomic, strong) NSMutableDictionary *halfieToPaiirCount;


@end

static TTTTimeIntervalFormatter *timeFormatter;

@implementation DGRCompleteViewController

#pragma mark - Init

- (BOOL)prefersStatusBarHidden{
    return YES;
}

- (UIViewController *)childViewControllerForStatusBarHidden {
    return nil;
}

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
       
        self.parseClassName = @"UPhoto";
        self.textKey = @"caption";
        self.imageKey = @"image";
        self.pullToRefreshEnabled = YES;
        self.paginationEnabled = NO;
        self.objectsPerPage = 10;
        self.halfieToPaiirCount = [NSMutableDictionary dictionary];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aCoder {
    self = [super initWithCoder:aCoder];
    if (self) {
        
        self.parseClassName = @"UPhoto";
        self.textKey = @"caption";
        self.imageKey = @"image";
        self.pullToRefreshEnabled = YES;
        self.paginationEnabled = NO;
        self.objectsPerPage = 10;
        self.halfieToPaiirCount = [NSMutableDictionary dictionary];

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
    
    self.isLoading = YES;
    
    // register notif
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadParseObjects) name:@"DGRCompleteViewControllerLoadParseObjects" object:nil];
    
    if (IS_WIDESCREEN) {
        self.tableView.transform = CGAffineTransformMakeRotation(-M_PI_2);
        self.tableView.frame = CGRectMake(0.0f, 0.0f, 320, 284);
    }
    
    [self stylePFLoadingViewTheHardWay];
    
    // Background
    //[self.tableView setBackgroundView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CompletePageBackground3.png"]]];
    [self.tableView setBackgroundColor:UIColorFromRGB(0xf7f7f7)];
    
}

-(void)viewDidLayoutSubviews {

    if (!IS_WIDESCREEN) {
        self.tableView.transform = CGAffineTransformMakeRotation(-M_PI_2);
        //self.tableView.transform = CGAffineTransformMakeScale(0.845f, 0.845f);
        self.tableView.frame = CGRectMake(25.0f, 0.0f, 270, 240);
        self.tableView.rowHeight = 270;
    }

}

- (void)loadParseObjects {
    
    [self loadObjects];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)stylePFLoadingViewTheHardWay
{
    // go through all of the subviews until you find a PFLoadingView subclass
    for (UIView *subview in self.view.subviews)
    {
        if ([subview class] == NSClassFromString(@"PFLoadingView"))
        {
            // find the loading label and loading activity indicator inside the PFLoadingView subviews
            for (UIView *loadingViewSubview in subview.subviews) {
                if ([loadingViewSubview isKindOfClass:[UILabel class]])
                {
                    UILabel *label = (UILabel *)loadingViewSubview;
                    {
                        [label removeFromSuperview];
                        //label.transform = CGAffineTransformMakeRotation(M_PI_2);
                        //label.textColor = labelTextColor;
                        //label.shadowColor = labelShadowColor;
                    }
                }
                
                if ([loadingViewSubview isKindOfClass:[UIActivityIndicatorView class]])
                {
                    //UIActivityIndicatorView *activityIndicatorView = (UIActivityIndicatorView *)loadingViewSubview;
                    //activityIndicatorView.activityIndicatorViewStyle = activityIndicatorViewStyle;
                }
            }
        }
    }
}


#pragma mark - UIScrollView

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
        
    if (scrollView.contentSize.height - scrollView.contentOffset.y < (self.view.bounds.size.height)) {
        if (![self isLoading]) {
            if (!self.noMoreObjects) {
                [self loadNextPage];

            }
        }
    }
    

}

#pragma mark - Page Navigation


#pragma mark - UITableViewDelegate


// Set cell background color

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    [cell setBackgroundColor:[UIColor blackColor]];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (!IS_WIDESCREEN) {
        return 270;
    }
    else return 320;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {
    
    static NSString *CellIdentifier = @"CompleteCell";
    DGRCompleteCell *cell = (DGRCompleteCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    cell.delegate = self;
    cell.uPhotoObject = object;
    
    // image file
    cell.customImage.image = [UIImage imageNamed:@"CompletePlaceholder.png"];
    cell.customImage.file = [object objectForKey:@"image"];
    [cell.customImage setAlpha:0.0f];
    [UIView animateWithDuration:0.6f
                     animations:^{
                         [cell.customImage loadInBackground];
                         [cell.customImage setAlpha:1.0f];
                     }];
    
    
    // username label
    PFUser *user = [object objectForKey:@"creator"];
    cell.user1.text = [user objectForKey:@"username"];
    
    // time
    timeFormatter = [[TTTTimeIntervalFormatter alloc] init];
    [cell.time setText:[timeFormatter stringForTimeIntervalFromDate:[NSDate date] toDate:[object createdAt]]];
    cell.time.hidden = NO;
    cell.time.alpha = 1.0;
    
    // paiir count
    NSArray *objectArray = [self.halfieToPaiirCount objectForKey:object.objectId];
    if (objectArray.count == 0) {
        cell.paiirCount.text = nil;
    }
    else if (objectArray.count == 1) {
        cell.paiirCount.text = @"Paiired 1 time";
    }
    else {
        cell.paiirCount.text = [NSString stringWithFormat:@"Paiired %li times", (long)objectArray.count];
    }
    cell.paiirCount.hidden = NO;
    cell.paiirCount.alpha = 1.0;
    
    // flip cell
    cell.transform = CGAffineTransformMakeRotation(M_PI_2);
    
    // scale issues
    if (!IS_WIDESCREEN) {
        cell.customImage.frame = CGRectMake(0, 30, 270, 240);
        cell.user1.frame = CGRectMake(15, 35, 250, 20);
        cell.time.frame = CGRectMake(15, 55, 250, 20);
        cell.paiirCount.frame = CGRectMake(15, 75, 250, 20);

    }
    
    [cell performSelector:@selector(hideLabels) withObject:nil afterDelay:3.0];
    
    return cell;
    
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (!self.isLoading && self.objects.count == 0) {
        UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
        messageLabel.frame = CGRectMake(40, 0, 240, self.view.bounds.size.height);
        
        messageLabel.text = @"Follow some people to paiir their photos here.";
        messageLabel.textColor = [UIColor blackColor];
        messageLabel.numberOfLines = 2;
        messageLabel.textAlignment = NSTextAlignmentCenter;
        messageLabel.font = [UIFont fontWithName:@"Avenir Next" size:18];
        messageLabel.transform = CGAffineTransformMakeRotation(M_PI_2);
        
        UIView *background = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
        [background addSubview:messageLabel];
        
        self.tableView.backgroundView = background;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        return 0;
    }
    else {
        self.tableView.backgroundView = nil;
        return 1;
    }
}

-(void)objectsWillLoad {
    [super objectsWillLoad];
    
    self.objectNumberControl = self.objects;
}

-(void)objectsDidLoad:(NSError *)error {
    [super objectsDidLoad:error];
    
    if (self.objects.count == self.objectNumberControl.count) {
        self.noMoreObjects = YES;
    }
    
}

-(PFQuery *)queryForTable {
    
    if ([PFUser currentUser]) {
        
        
        // all people im following
        PFQuery *allFollowing = [PFQuery queryWithClassName:@"Activity"];
        [allFollowing whereKey:@"fromUser" equalTo:[PFUser currentUser]];
        [allFollowing whereKey:@"type" equalTo:@"follow"];
        
        // all incomplete photos by people im following
        PFQuery *incompletePhotos = [PFQuery queryWithClassName:@"UPhoto"];
        [incompletePhotos whereKey:@"creator" matchesKey:@"toUser" inQuery:allFollowing];
        
        // exclude the intro photos
        [incompletePhotos whereKey:@"objectId" notContainedIn:@[@"RDJNn7e3hA", @"MRMN8zyAjq"]];
         
        // paiir count - for all incomplete photos
        PFQuery *allCompletedIncompletePhotos = [PFQuery queryWithClassName:@"CPhoto"];
        [allCompletedIncompletePhotos whereKey:@"imageToCompleteString" matchesKey:@"objectId" inQuery:incompletePhotos];
        
        allCompletedIncompletePhotos.cachePolicy = kPFCachePolicyCacheThenNetwork;
        [allCompletedIncompletePhotos findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                // The find succeeded.
                NSLog(@"Retrieved %ld completed Photo Objects.", (long)objects.count);
                [self.halfieToPaiirCount removeAllObjects];
                
                for (PFObject *object in objects) {
                    NSString *halfieObjectId = [object objectForKey:@"imageToCompleteString"];
                    
                    NSMutableArray *objectsForId = [self.halfieToPaiirCount objectForKey:halfieObjectId];
                    if (!objectsForId) {
                        objectsForId = [NSMutableArray array];
                        [objectsForId addObject:object];
                    }
                    else {
                        [objectsForId addObject:object];
                    }
                    
                    [self.halfieToPaiirCount setObject:objectsForId forKey:halfieObjectId];
                }
                
                
            } else {
                // Log details of the failure
                NSLog(@"Error: %@ %@", error, [error userInfo]);
            }
        }];
        
        
        [incompletePhotos includeKey:@"creator"];
        [incompletePhotos orderByDescending:@"createdAt"];
        /*
        // If Pull To Refresh is enabled, query against the network by default.
        if (self.pullToRefreshEnabled) {
            incompletePhotos.cachePolicy = kPFCachePolicyNetworkOnly;
        }
        
        // If no objects are loaded in memory, we look to the cache first to fill the table
        // and then subsequently do a query against the network.
        if (self.objects.count == 0) {
            incompletePhotos.cachePolicy = kPFCachePolicyCacheThenNetwork;
        }
         */
        incompletePhotos.cachePolicy = kPFCachePolicyNetworkOnly;
        
        self.isLoading = NO;
        return incompletePhotos;

    }

    else {
    
        [super objectsDidLoad:[NSError errorWithDomain:@"" code:0 userInfo:nil]]; //Return failed to turn off spinner.
    
        return nil;
    
    }

}

#pragma mark - Alerts

-(void)noCameraAlert:(PFObject*)object {
    
    if ([UIAlertController class]) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"No Camera Available!" message:@"You can only choose images from your photo library." preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* ok = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
            //[self initiateCompletePhotoLibrary];
        }];
        [alert addAction:ok];
        
        [self presentViewController:alert animated:YES completion:NULL];
    }
    
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Camera Available!" message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
        
        [alert show];
    }
    
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        //[self initiatePhotoLibrary:nil];
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
