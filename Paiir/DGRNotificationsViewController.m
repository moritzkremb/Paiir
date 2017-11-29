//
//  DGRNotificationsViewController.m
//  Paiir
//
//  Created by Moritz Kremb on 10/11/14.
//  Copyright (c) 2014 Kremb. All rights reserved.
//

#import "DGRNotificationsViewController.h"
#import "TTTTimeIntervalFormatter.h"
#import "DGRConstants.h"
#import "DGRImageTableViewController.h"

@interface DGRNotificationsViewController ()

@property BOOL noMoreObjects;
@property NSArray *objectNumberControl;

-(IBAction)doneButtonAction:(id)sender;

@end

static TTTTimeIntervalFormatter *timeFormatter;

@implementation DGRNotificationsViewController

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        
        self.parseClassName = @"User";
        self.textKey = @"username";
        self.imageKey = @"image";
        self.pullToRefreshEnabled = YES;
        self.paginationEnabled = NO;
        self.objectsPerPage = 10;
        
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
        self.objectsPerPage = 10;
        
        
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    timeFormatter = [[TTTTimeIntervalFormatter alloc] init];
    
    // register notif
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadParseObjects) name:@"DGRNotificationsViewControllerLoadParseObjects" object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    // infinite scrolling
    if (scrollView.contentSize.height - scrollView.contentOffset.y < (self.view.bounds.size.height)) {
        if (![self isLoading]) {
            if (!self.noMoreObjects) {
                [self loadNextPage];
                
            }
        }
    }
}


#pragma mark - UITableView

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object{
    DGRNotificationsCell *cell = (DGRNotificationsCell *)[tableView dequeueReusableCellWithIdentifier:@"NotificationsCell" forIndexPath:indexPath];
    
    cell.delegate = self;
    cell.indexPath = indexPath;
    
    NSString *type = [object objectForKey:@"type"];
    PFUser *fromUser = [object objectForKey:@"fromUser"];
    NSString *fromUserUsername = [fromUser objectForKey:@"username"];
    
    // set profile picture
    cell.profilePictureView.layer.cornerRadius = 25.0f;
    cell.profilePictureView.clipsToBounds = YES;
    cell.profilePictureView.image = [UIImage imageNamed:@"ProfilePicturePlaceholder.png"];
    cell.profilePictureView.file = [fromUser objectForKey:@"profilePicture"];
    [cell.profilePictureView loadInBackground];
    
    
    if ([type isEqualToString:@"follow"]) {
        cell.notificationsLabel.text = [NSString stringWithFormat:@"%@ started following you.", fromUserUsername];
        cell.timeLabel.text = [timeFormatter stringForTimeIntervalFromDate:[NSDate date] toDate:[object createdAt]];
        [cell.thumbnailButton setEnabled:NO];

    }
    else if ([type isEqualToString:@"paiir"]) {
        cell.notificationsLabel.text = [NSString stringWithFormat:@"%@ paiired your photo.", fromUserUsername];
        cell.timeLabel.text = [timeFormatter stringForTimeIntervalFromDate:[NSDate date] toDate:[object createdAt]];
        
        PFObject *cPhotoObject = [object objectForKey:@"photoPointer"];
        [cPhotoObject fetchIfNeeded];
        PFFile *thumbnail = [cPhotoObject objectForKey:@"thumbnail"];
        if ([thumbnail isKindOfClass:[NSNull class]]) {
            [cell.thumbnailButton setEnabled:NO];
        }
        [thumbnail getDataInBackgroundWithBlock:^(NSData *data, NSError *error){
            [cell.thumbnailButton setImage:[UIImage imageWithData:data] forState:UIControlStateNormal];
            cell.thumbnailButton.imageView.layer.cornerRadius = 5.0f;
            cell.thumbnailButton.imageView.clipsToBounds = YES;
            [cell.thumbnailButton setEnabled:YES];
        }];

    }
    else if ([type isEqualToString:@"highlight"]) {
        cell.notificationsLabel.text = [NSString stringWithFormat:@"%@ highlighted your Paiir.", fromUserUsername];
        cell.timeLabel.text = [timeFormatter stringForTimeIntervalFromDate:[NSDate date] toDate:[object createdAt]];
        
        PFObject *cPhotoObject = [object objectForKey:@"photoPointer"];
        [cPhotoObject fetchIfNeeded];
        PFFile *thumbnail = [cPhotoObject objectForKey:@"thumbnail"];
        if ([thumbnail isKindOfClass:[NSNull class]]) {
            [cell.thumbnailButton setEnabled:NO];
        }
        [thumbnail getDataInBackgroundWithBlock:^(NSData *data, NSError *error){
            [cell.thumbnailButton setImage:[UIImage imageWithData:data] forState:UIControlStateNormal];
            cell.thumbnailButton.imageView.layer.cornerRadius = 5.0f;
            cell.thumbnailButton.imageView.clipsToBounds = YES;
            [cell.thumbnailButton setEnabled:YES];
        }];

    }
    
    return cell;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (!self.isLoading && self.objects.count == 0) {
        UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
        messageLabel.frame = CGRectMake(40, 0, 240, self.view.bounds.size.height);
        
        messageLabel.text = @"No Notifications";
        messageLabel.textColor = [UIColor blackColor];
        messageLabel.numberOfLines = 2;
        messageLabel.textAlignment = NSTextAlignmentCenter;
        messageLabel.font = [UIFont fontWithName:@"AvenirNext" size:18];
        
        UIView *background = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
        [background addSubview:messageLabel];
        
        self.tableView.backgroundView = background;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        return 0;
    }
    else {
        self.tableView.backgroundView = nil;
    }
    
    return 1;
    
}

-(PFObject *)objectAtIndexPath:(NSIndexPath *)indexPath {
    return [self.objects objectAtIndex:indexPath.row];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.objects.count;
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
        
        PFQuery *userActivityObjects = [PFQuery queryWithClassName:@"Activity"];
        [userActivityObjects whereKey:@"toUser" equalTo:[PFUser currentUser]];
        
        [userActivityObjects includeKey:@"fromUser"];
        [userActivityObjects includeKey:@"photoPointer.owner"];
        [userActivityObjects includeKey:@"photoPointer.completor"];
        [userActivityObjects includeKey:@"photoPointer.imageToComplete"];

        [userActivityObjects orderByDescending:@"createdAt"];
        
        // If Pull To Refresh is enabled, query against the network by default.
        if (self.pullToRefreshEnabled) {
            userActivityObjects.cachePolicy = kPFCachePolicyNetworkOnly;
        }
        
        // If no objects are loaded in memory, we look to the cache first to fill the table
        // and then subsequently do a query against the network.
        if (self.objects.count == 0) {
            userActivityObjects.cachePolicy = kPFCachePolicyCacheThenNetwork;
        }
        
        //self.isLoading = NO;
        return userActivityObjects;
        
    }
    else {
        NSLog(@"not logged in. Error.");
        [super objectsDidLoad:[NSError errorWithDomain:@"" code:0 userInfo:nil]]; //Return failed to turn off spinner.
        return nil;
    }
}

#pragma mark - Preload

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

#pragma mark - Other Methods

-(UIImage *)getThumbnailWithCPhotoObject:(PFObject*)object {
    [object fetchIfNeeded];
    PFFile *thumbnail = [object objectForKey:@"thumbnail"];
    if ([thumbnail isKindOfClass:[NSNull class]]) {
        return nil;
    }
    NSData *imageData = [thumbnail getData];
    
    return [UIImage imageWithData:imageData];
}

-(void)loadParseObjects {
    [self loadObjects];
}

#pragma mark - Cell Protocols

-(void)didTapThumbnailButton:(NSIndexPath*)indexPath {
    
    DGRImageTableViewController *imageVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ImageTableViewController"];
    
    // set moreoptionstype
    imageVC.moreOptionsType1 = YES;
    
    // set photoobjects
    NSArray *photoObjects = [[NSArray alloc] init];
    
    PFObject *activityObject = [self.objects objectAtIndex:indexPath.row];
    
    photoObjects = [NSArray arrayWithObject:[activityObject objectForKey:@"photoPointer"]];
    
    if (photoObjects) {
        
        imageVC.photoObjects = [NSMutableArray arrayWithArray:photoObjects];
        
        [self presentViewController:imageVC animated:YES completion:nil];
    }
    else {
        NSLog(@"No Objects available to show. Something went wrong.");
    }

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

-(IBAction)doneButtonAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

@end
