//
//  DGRImageTableViewController.m
//  Paiir
//
//  Created by Moritz Kremb on 27/11/14.
//  Copyright (c) 2014 Kremb. All rights reserved.
//

#import "DGRImageTableViewController.h"
#import "DGRPaiirImageCell.h"
#import <Parse/Parse.h>
#import "DGRConstants.h"
#import <AudioToolbox/AudioToolbox.h>
#include "MBProgressHUD.h"

@interface DGRImageTableViewController ()

@property UIButton *cancelButton;
@property UIButton *moreOptionsButton;

- (IBAction)doubleTapAction:(id)sender;

@end

@implementation DGRImageTableViewController

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (UIViewController *)childViewControllerForStatusBarHidden {
    return nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (!IS_WIDESCREEN) {
        self.tableView.rowHeight = 480;
    }
    
    // Cancel button
    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancelButton setImage:[UIImage imageNamed:@"Cancel_border.png"] forState:UIControlStateNormal];
    [cancelButton addTarget:self action:@selector(cancelButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    if (!IS_WIDESCREEN) {
        cancelButton.frame = CGRectMake(30, 5, 35, 35);
    }
    else {
        cancelButton.frame = CGRectMake(10, 10, 40, 40);
    }
    self.cancelButton = cancelButton;
    [self.view addSubview:cancelButton];
    
    // more option button
    UIButton *moreOptionsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [moreOptionsButton setImage:[UIImage imageNamed:@"MoreOptionsButton.png"] forState:UIControlStateNormal];
    [moreOptionsButton addTarget:self action:@selector(moreOptionsButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    if (!IS_WIDESCREEN) {
        moreOptionsButton.frame = CGRectMake(255, 440, 35, 35);
    }
    else {
        moreOptionsButton.frame = CGRectMake(270, 518, 40, 40);
    }
    self.moreOptionsButton = moreOptionsButton;
    [self.view addSubview:moreOptionsButton];

    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return self.photoObjects.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (!IS_WIDESCREEN) {
        return 480;
    }
    else return 568;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    // keep button on top
    NSInteger cancelYOffset = 0;
    NSInteger moreOptionsYOffset = 0;
    if (!IS_WIDESCREEN) {
        cancelYOffset = 5;
        moreOptionsYOffset = 5;
    }
    else {
        cancelYOffset = 10;
        moreOptionsYOffset = 10;
    }
    
    // cancel button
    CGRect frame = self.cancelButton.frame;
    frame.origin.y = scrollView.contentOffset.y + cancelYOffset;
    self.cancelButton.frame = frame;
    [self.view bringSubviewToFront:self.cancelButton];
    
    // more options button
    frame = self.moreOptionsButton.frame;
    frame.origin.y = scrollView.contentOffset.y + self.tableView.frame.size.height - self.moreOptionsButton.frame.size.height - moreOptionsYOffset;
    self.moreOptionsButton.frame = frame;
    [self.view bringSubviewToFront:self.moreOptionsButton];
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DGRPaiirImageCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PaiirImageCell" forIndexPath:indexPath];
    
    PFObject *cPhotoObject = [self.photoObjects objectAtIndex:indexPath.row];
    
    // adjust imageViews and labels
    if (!IS_WIDESCREEN) {
        cell.topImage.frame = CGRectMake(25, 0, 270, 240);
        cell.bottomImage.frame = CGRectMake(25, 240, 270, 240);
        cell.topUser.frame = CGRectMake(30, 5, 260, 20);
        cell.bottomUser.frame = CGRectMake(30, 455, 260, 20);
    }
    
    // usernames
    PFUser *owner = [cPhotoObject objectForKey:@"owner"];
    cell.topUser.text = owner.username;
    
    PFUser *completor = [cPhotoObject objectForKey:@"completor"];
    cell.bottomUser.text = completor.username;
    
    // images
    PFObject *topImage = [cPhotoObject objectForKey:@"imageToComplete"];
    PFFile *image1 = [topImage objectForKey:@"image"];
    PFFile *image2 = [cPhotoObject objectForKey:@"image"];
    
    cell.topImage.image = [UIImage imageNamed:@"CompletePlaceholder.png"];
    cell.bottomImage.image = [UIImage imageNamed:@"CompletePlaceholder.png"];
    
    cell.topImage.file = image1;
    cell.bottomImage.file = image2;

    [cell.topImage loadInBackground];
    [cell.bottomImage loadInBackground];

    return cell;
}


#pragma mark - Action

-(void)cancelButtonAction:(id)sender {
    
    BOOL dismissAnimation = YES;
    if (self.moreOptionsType1) {
        [self.homeDelegate.tableView reloadData];
    }
    
    if (self.highlightDelegate) {
        dismissAnimation = NO;
    }
    
    [self dismissViewControllerAnimated:dismissAnimation completion:NULL];
    
}

- (IBAction)doubleTapAction:(id)sender {
    if (self.moreOptionsType1) {
        [self highlightImage];
    }
}

#pragma mark - Parse Operations

-(UIImage*)cropToSmallScreenSize:(UIImage*)imageToCrop {
    //crop image, hard coded to iphone 5s
    CGRect cropRect = CGRectMake(50, 0, 540, 960);
    CGImageRef croppedImage = CGImageCreateWithImageInRect(imageToCrop.CGImage, cropRect);
    return [UIImage imageWithCGImage:croppedImage];
}

-(void)saveImageToLibrary {
    
    UIImage *fullScreenshot = [self takeScreenshotOfImageWithWatermark];
    
    // save to library
    UIImageWriteToSavedPhotosAlbum(fullScreenshot, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
    
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    if (!error) {
        
        [self showSuccessHUDWithText:@"Saved to Library"];
        
        NSLog(@"image saved to lib");
    }
}

-(UIImage *)takeScreenshotOfImage{
    // hide buttons
    [self.moreOptionsButton removeFromSuperview];
    [self.cancelButton removeFromSuperview];
    
    // take screenshot
    UIGraphicsBeginImageContextWithOptions(self.tableView.frame.size, NO, 0.0);
    
    [self.tableView.superview.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage *fullScreenshot = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    if (!IS_WIDESCREEN) {
        fullScreenshot = [self cropToSmallScreenSize:fullScreenshot];
    }
    
    // show buttons
    [self.view addSubview:self.cancelButton];
    [self.view addSubview:self.moreOptionsButton];
    
    return fullScreenshot;
}

-(UIImage *)takeScreenshotOfImageWithWatermark{
    // hide buttons
    [self.moreOptionsButton removeFromSuperview];
    [self.cancelButton removeFromSuperview];
    
    // set watermark
    UIImageView *watermark = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Watermark.png"]];
    
    CGFloat contentOffset = self.tableView.contentOffset.y;
    CGFloat divideBy;
    if (IS_WIDESCREEN) {
        divideBy = 568.0f;
    } else divideBy = 480.0f;
    CGFloat objectIndex = (contentOffset / divideBy);
    NSLog(@"objectIndex: %f", objectIndex);
    
    if (IS_WIDESCREEN) {
        watermark.frame = CGRectMake(220, 518+(568*objectIndex), 100, 50);
    } else watermark.frame = CGRectMake(200, 430+(480*objectIndex), 100, 50); //test

    [self.view addSubview:watermark];
    
    
    // take screenshot
    UIGraphicsBeginImageContextWithOptions(self.tableView.frame.size, NO, 0.0);
    
    [self.tableView.superview.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage *fullScreenshot = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    if (!IS_WIDESCREEN) {
        fullScreenshot = [self cropToSmallScreenSize:fullScreenshot];
    }
    
    // remove watermark
    [watermark removeFromSuperview];
    
    // show buttons
    [self.view addSubview:self.cancelButton];
    [self.view addSubview:self.moreOptionsButton];
    
    return fullScreenshot;
}



-(void)highlightImage {
    
    [self playSound];
    [self showHighlightedHUD];
    
    NSArray *visible = [self.tableView indexPathsForVisibleRows];
    NSIndexPath *indexpath = (NSIndexPath*)[visible objectAtIndex:0];
    
    /*
    // add object to highlight array if doesnt exist - this only happens when called from HOME
    PFObject *object = [self.photoObjects objectAtIndex:indexpath.row];
    NSMutableArray *highlightPhotos = [self.homeDelegate.userToHighlightPhotos objectForKey:[PFUser currentUser].username];
    if (!highlightPhotos) {
        highlightPhotos = [NSMutableArray array];
    }
    
    BOOL matchFound = NO;
    for (PFObject *photoObject in highlightPhotos) {
        if ([photoObject.objectId isEqualToString:object.objectId]) {
            matchFound = YES;
            break;
        }
    }
    if (!matchFound) {
        NSMutableArray *newHighlightPhotos = [NSMutableArray arrayWithObject:object];
        [newHighlightPhotos addObjectsFromArray:highlightPhotos];
        [self.homeDelegate.userToHighlightPhotos setObject:newHighlightPhotos forKey:[PFUser currentUser].username];
    }
    */
    
    PFObject *object = [self.photoObjects objectAtIndex:indexpath.row];
    PFUser *owner = [object objectForKey:@"owner"];
    PFUser *otherUser;
    if ([owner.username isEqualToString:[PFUser currentUser].username]) {
        // current user is creator
        otherUser = [object objectForKey:@"completor"];
    }
    else {
        // current user is completor
        otherUser = owner;
    }
    
    
    PFQuery *checkIfObjectExists = [PFQuery queryWithClassName:@"Activity"];
    [checkIfObjectExists whereKey:@"type" equalTo:@"highlight"];
    [checkIfObjectExists whereKey:@"fromUser" equalTo:[PFUser currentUser]];
    [checkIfObjectExists whereKey:@"photoPointer" equalTo:object];
    
    [checkIfObjectExists getFirstObjectInBackgroundWithBlock:^(PFObject *queryObject, NSError *error) {
        if (!queryObject) {
            PFObject *highlightPhoto = [PFObject objectWithClassName:@"Activity"];
            highlightPhoto[@"type"] = @"highlight";
            highlightPhoto[@"fromUser"] = [PFUser currentUser];
            highlightPhoto[@"fromUserObjectId"] = [PFUser currentUser].objectId;
            highlightPhoto[@"toUser"] = otherUser;
            highlightPhoto[@"toUserObjectId"] = otherUser.objectId;
            highlightPhoto[@"photoPointer"] = object;
            highlightPhoto[@"photoPointerObjectId"] = object.objectId;
            [highlightPhoto saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
                if (succeeded) {
                    // create push
                    NSString *message = [NSString stringWithFormat:@"%@ highlighted your Paiir.", [PFUser currentUser].username];
                    [self sendPushToUser:otherUser withMessage:message objectId:object.objectId];
                }
            }];
            
            // increment Highlight count
            PFQuery *highlightCount = [PFQuery queryWithClassName:@"HighlightCount"];
            [highlightCount whereKey:@"user" equalTo:[PFUser currentUser]];
            PFObject *highlightCountObject = [highlightCount getFirstObject];
            [highlightCountObject incrementKey:@"highlightCount"];
            [highlightCountObject saveInBackground];
            
        }
    }];
    
}

-(void)deleteImage {
    
    MBProgressHUD *deletingHUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    deletingHUD.mode = MBProgressHUDModeIndeterminate;
    deletingHUD.labelText = @"Deleting...";
    [deletingHUD show:YES];
    
    NSArray *visible = [self.tableView indexPathsForVisibleRows];
    NSIndexPath *indexpath = (NSIndexPath*)[visible objectAtIndex:0];
    
    PFObject *object = [self.photoObjects objectAtIndex:indexpath.row];
    
    // network stuff
    PFQuery *checkIfObjectExists = [PFQuery queryWithClassName:@"CPhoto"];
    [checkIfObjectExists whereKey:@"objectId" equalTo:object.objectId];
    
    [checkIfObjectExists getFirstObjectInBackgroundWithBlock:^(PFObject *queryObject, NSError *error) {
        if (queryObject) {
            
            [deletingHUD hide:YES];
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                // check if the photo was highlighted and remove if it was
                PFQuery *checkIfObjectExists = [PFQuery queryWithClassName:@"Activity"];
                [checkIfObjectExists whereKey:@"type" equalTo:@"highlight"];
                [checkIfObjectExists whereKey:@"photoPointerObjectId" equalTo:object.objectId];
                
                [checkIfObjectExists findObjectsInBackgroundWithBlock:^(NSArray *highlightObjects, NSError *error) {
                    if (highlightObjects) {
                        for (PFObject *highlightObject in highlightObjects) {
                            [highlightObject deleteInBackground];
                            
                            // decrement Highlight count

                            PFUser *user = [highlightObject objectForKey:@"fromUser"];
                            PFQuery *highlightCount = [PFQuery queryWithClassName:@"HighlightCount"];
                            [highlightCount whereKey:@"user" equalTo:user];
                            PFObject *highlightCountObject = [highlightCount getFirstObject];
                            int count = [[highlightCountObject objectForKey:@"highlightCount"] intValue];
                            if (count == 0) {
                                count = 0;
                            } else count = count - 1;
                            NSNumber *number = [NSNumber numberWithInt:count];
                            [highlightCountObject setObject:number forKey:@"highlightCount"];
                            [highlightCountObject saveInBackground];

                        }
                    }
                    else NSLog(@"Object is not highlighted.");
                    
                }];
                
                // get paiir activity object and delete
                PFQuery *checkIfPaiirObjectExists = [PFQuery queryWithClassName:@"Activity"];
                [checkIfPaiirObjectExists whereKey:@"type" equalTo:@"paiir"];
                [checkIfPaiirObjectExists whereKey:@"photoPointerObjectId" equalTo:object.objectId];
                [checkIfPaiirObjectExists getFirstObjectInBackgroundWithBlock:^(PFObject *paiirObject, NSError *error) {
                    if (paiirObject) {
                        [paiirObject deleteInBackground];
                        
                    }
                    else NSLog(@"Object doesnt exist.");
                    
                }];
                
            });
            
            [queryObject deleteInBackground];
            
            // remove in tableview
            [self.photoObjects removeObjectAtIndex:indexpath.row];
            [self.tableView reloadData];
            
            // update on homedelegate
            NSMutableArray *myPhotos = [self.homeDelegate.userToTodayPhotos objectForKey:[PFUser currentUser].username];
            myPhotos = self.photoObjects;
            [self.homeDelegate.userToTodayPhotos setObject:myPhotos forKey:[PFUser currentUser].username];
            

        } else {
            [deletingHUD hide:YES];
            NSLog(@"Error. The object doesnt exist.");
            [self okAlertWithTitle:@"Sorry, there was an error. Please try again." message:nil];
        }
    }];
    
}


-(void)removeImageFromHighlights {
    
    NSArray *visible = [self.tableView indexPathsForVisibleRows];
    NSIndexPath *indexpath = (NSIndexPath*)[visible objectAtIndex:0];
    
    PFObject *object = [self.photoObjects objectAtIndex:indexpath.row];
    
    // do local stuff
    [self.photoObjects removeObjectAtIndex:indexpath.row];
    [self.tableView reloadData];
    
    // remove object on highlight page
    [self.highlightDelegate.photoObjects removeObjectAtIndex:indexpath.row];
    [self.highlightDelegate.collectionView reloadData];
    
    PFQuery *checkIfObjectExists = [PFQuery queryWithClassName:@"Activity"];
    [checkIfObjectExists whereKey:@"type" equalTo:@"highlight"];
    [checkIfObjectExists whereKey:@"fromUser" equalTo:[PFUser currentUser]];
    [checkIfObjectExists whereKey:@"photoPointer" equalTo:object];
    
    [checkIfObjectExists getFirstObjectInBackgroundWithBlock:^(PFObject *queryObject, NSError *error) {
        
        if (queryObject) {
            [queryObject deleteInBackground];
            
            // decrement Highlight count
            PFQuery *highlightCount = [PFQuery queryWithClassName:@"HighlightCount"];
            [highlightCount whereKey:@"user" equalTo:[PFUser currentUser]];
            PFObject *highlightCountObject = [highlightCount getFirstObject];
            int count = [[highlightCountObject objectForKey:@"highlightCount"] intValue];
            if (count == 0) {
                count = 0;
            } else count = count - 1;
            NSNumber *number = [NSNumber numberWithInt:count];
            [highlightCountObject setObject:number forKey:@"highlightCount"];
            [highlightCountObject saveInBackground];

            
        } else {
            NSLog(@"The object doesnt exist.");
        }
    }];
    
}


-(void)reportImage {
    
    MBProgressHUD *reportingHUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    reportingHUD.mode = MBProgressHUDModeIndeterminate;
    reportingHUD.labelText = @"Reporting...";
    [reportingHUD show:YES];
        
        NSArray *visible = [self.tableView indexPathsForVisibleRows];
        NSIndexPath *indexpath = (NSIndexPath*)[visible objectAtIndex:0];
        
        PFObject *object = [self.photoObjects objectAtIndex:indexpath.row];
        
        PFQuery *checkIfObjectExists = [PFQuery queryWithClassName:@"Activity"];
        [checkIfObjectExists whereKey:@"type" equalTo:@"report"];
        [checkIfObjectExists whereKey:@"fromUser" equalTo:[PFUser currentUser]];
        [checkIfObjectExists whereKey:@"photoPointer" equalTo:object];
        
        [checkIfObjectExists getFirstObjectInBackgroundWithBlock:^(PFObject *queryObject, NSError *error) {
            [reportingHUD hide:YES];
            
            if (!queryObject) {
                [self showSuccessHUDWithText:@"Reported."];
                
                PFObject *reportPhoto = [PFObject objectWithClassName:@"Activity"];
                reportPhoto[@"type"] = @"report";
                reportPhoto[@"fromUser"] = [PFUser currentUser];
                reportPhoto[@"photoPointer"] = object;
                [reportPhoto saveInBackground];
            } else {
                NSLog(@"The object already exists.");
                [self okAlertWithTitle:@"Sorry, there was an error. Please try again." message:nil];
            }
        }];
    
}

-(void)shareImage {
    UIImage *image = [self takeScreenshotOfImageWithWatermark];
    NSArray *activityItems = @[image, @"www.paiir-app.com"];
    UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
    [self presentViewController:activityController animated:YES completion:nil];
}


-(void)sendPushToUser: (PFUser *)user withMessage: (NSString *)message objectId:(NSString *)objectId{
    // Create our Installation query
    PFQuery *pushQuery = [PFInstallation query];
    [pushQuery whereKey:@"user" equalTo:user];
    
    NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
                          message, @"alert",
                          @"Tink.caf", @"sound",
                          @"Increment", @"badge",
                          @"2", @"t",
                          objectId, @"p",
                          nil];
    
    // Send push notification to query
    PFPush *push = [[PFPush alloc] init];
    [push setQuery:pushQuery];
    [push setData:data];
    [push sendPushInBackground];
    
}

#pragma mark - Action Sheets

// more options on today view

- (void)moreOptionsButtonAction:(id)sender {
    
    if (_moreOptionsType1) {
        if ([UIAlertController class]) {
            
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
            
            UIAlertAction* highlight = [UIAlertAction actionWithTitle:@"Highlight (or double tap)" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
                [self highlightImage];
                
            }];
            
            UIAlertAction* save = [UIAlertAction actionWithTitle:@"Save to Library" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
                [self saveImageToLibrary];
            }];
            
            UIAlertAction* share = [UIAlertAction actionWithTitle:@"Share" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
                [alertController dismissViewControllerAnimated:YES completion:NULL];
                [self shareImage];
            }];
            
            UIAlertAction* report = [UIAlertAction actionWithTitle:@"Report" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * action){
                [self yesNoAlertWithTitle:@"Do you want to report this photo for inappropriate content?" message:nil];
            }];
            
            UIAlertAction* delete = [UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * action){
                [self yesNoAlertWithTitle:@"Are you sure you want to delete this Paiir?" message:nil];
            }];
            
            UIAlertAction* cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * action){
                [alertController dismissViewControllerAnimated:YES completion:nil];
            }];
            
            [alertController addAction:highlight];
            [alertController addAction:share];
            [alertController addAction:save];
            [alertController addAction:report];
            [alertController addAction:delete];
            [alertController addAction:cancel];
            
            [self presentViewController:alertController animated:YES completion:nil];
            
        } else {
            UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:@"Highlight (or double tap)", @"Share", @"Save to Library", @"Report", @"Delete", @"Cancel", nil];
            actionSheet.destructiveButtonIndex = 4;
            actionSheet.cancelButtonIndex = 5;
            actionSheet.tag = 10; // todayView action sheet
            [actionSheet showInView:self.view];
        }

    }
    
    else if (_moreOptionsType2) {
        if ([UIAlertController class]) {
            
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
            
            UIAlertAction* save = [UIAlertAction actionWithTitle:@"Save to Library" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
                [self saveImageToLibrary];
            }];
            
            UIAlertAction* share = [UIAlertAction actionWithTitle:@"Share" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
                [alertController dismissViewControllerAnimated:YES completion:NULL];
                [self shareImage];
            }];
            
            UIAlertAction* remove = [UIAlertAction actionWithTitle:@"Remove from Highlights" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * action){
                [self yesNoAlertWithTitle:@"Are you sure you want to remove this Paiir from your Highlights?" message:nil];
            }];
            
            UIAlertAction* cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * action){
                [alertController dismissViewControllerAnimated:YES completion:nil];
            }];
            
            [alertController addAction:share];
            [alertController addAction:save];
            [alertController addAction:remove];
            [alertController addAction:cancel];
            
            [self presentViewController:alertController animated:YES completion:nil];
            
        } else {
            UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles: @"Share", @"Save to Library", @"Remove from Highlights", @"Cancel", nil];
            actionSheet.destructiveButtonIndex = 2;
            actionSheet.cancelButtonIndex = 3;
            actionSheet.tag = 20; // highlight action sheet
            [actionSheet showInView:self.view];
        }

    }
    
    else if (self.moreOptionsType3){
        if ([UIAlertController class]) {
            
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
            
            UIAlertAction* save = [UIAlertAction actionWithTitle:@"Save to Library" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
                [self saveImageToLibrary];
            }];
            
            UIAlertAction* share = [UIAlertAction actionWithTitle:@"Share" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
                [alertController dismissViewControllerAnimated:YES completion:NULL];
                [self shareImage];
            }];
            
            UIAlertAction* cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * action){
                [alertController dismissViewControllerAnimated:YES completion:nil];
            }];
            
            [alertController addAction:share];
            [alertController addAction:save];
            [alertController addAction:cancel];
            
            [self presentViewController:alertController animated:YES completion:nil];
            
        } else {
            UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles: @"Share", @"Save to Library", @"Cancel", nil];
            actionSheet.cancelButtonIndex = 2;
            actionSheet.tag = 30; // highlight action sheet
            [actionSheet showInView:self.view];
        }

    }
    
}


// action sheet actions for today and highlight view for ios 7

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (![UIAlertController class]) {
        if (actionSheet.tag == 10) {
            // todayView action sheet
            switch (buttonIndex) {
                case 0:
                    // highlight
                {
                    [self highlightImage];
                }
                    break;
                    
                case 1:
                {
                    [actionSheet dismissWithClickedButtonIndex:1 animated:YES];
                    [self shareImage];
                }
                    break;
                    
                case 2:
                {
                    [self saveImageToLibrary];
                    break;
                }
                case 3:
                    // report
                {
                    [self yesNoAlertWithTitle:@"Do you want to report this photo for inappropriate content?" message:nil];
                }
                    break;
                    
                case 4:
                    //delete
                {
                    [self yesNoAlertWithTitle:@"Are you sure you want to delete this Paiir?" message:nil];
                }
                    break;
                    
                case 5:
                    //cancel
                    break;
                    
                default:
                    break;
            }
            
        }
        
        else if (actionSheet.tag == 20) {
            // highlight sheet
            switch (buttonIndex) {
                case 0:
                {
                    [actionSheet dismissWithClickedButtonIndex:0 animated:YES];
                    [self shareImage];
                }
                    break;
                case 1:
                {
                    // save
                    [self saveImageToLibrary];
                    break;
                }
                case 2:
                    //remove from highlight
                {
                    [self yesNoAlertWithTitle:@"Are you sure you want to remove this Paiir from your Highlights?" message:nil];
                }
                case 3:
                    // cancel
                    break;
                    
                default:
                    break;
            }
        }
        
        else if (actionSheet.tag == 30) {
            // other sheet
            switch (buttonIndex) {
                case 0:
                {
                    [actionSheet dismissWithClickedButtonIndex:0 animated:YES];
                    [self shareImage];

                }
                    break;
                case 1:
                {
                    // save
                    [self saveImageToLibrary];
                    break;
                }
                case 2:
                    // cancel
                    break;
                    
                default:
                    break;
            }
        }

    }
}

// standard alert with title

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

-(void)yesNoAlertWithTitle:(NSString*)title message:(NSString*)message {
    if ([UIAlertController class]) {
        UIAlertController *reportAlert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* no = [UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
            [reportAlert dismissViewControllerAnimated:YES completion:nil];
            
        }];
        
        UIAlertAction* yes = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
            if ([title isEqualToString:@"Do you want to report this photo for inappropriate content?"]) {
                [self reportImage];
            }
            
            if ([title isEqualToString:@"Are you sure you want to delete this Paiir?"]) {
                [self deleteImage];
            }
            
            if ([title isEqualToString:@"Are you sure you want to remove this Paiir from your Highlights?"]) {
                [self removeImageFromHighlights];
            }
            
        }];
        
        [reportAlert addAction:no];
        [reportAlert addAction:yes];
        
        [self presentViewController:reportAlert animated:YES completion:nil];
        
    }
    
    else {
        UIAlertView *reportAlert = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:nil otherButtonTitles:@"No", @"Yes", nil];
        if ([title isEqualToString:@"Do you want to report this photo for inappropriate content?"]) {
            reportAlert.tag = 10;
        }
        if ([title isEqualToString:@"Are you sure you want to delete this Paiir?"]) {
            reportAlert.tag = 20;
        }
        if ([title isEqualToString:@"Are you sure you want to remove this Paiir from your Highlights?"]) {
            reportAlert.tag = 30;
        }
        [reportAlert show];
    }
    
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (![UIAlertController class]) {
        //report photo
        if (alertView.tag == 10) {
            switch (buttonIndex) {
                case 1:
                {
                    [self reportImage];
                }
                    break;
                    
                default:
                    
                    break;
            }
        }
        if (alertView.tag == 20) {
            switch (buttonIndex) {
                case 1:
                {
                    [self deleteImage];
                }
                    break;
                    
                default:
                    break;
            }
            
        }
        if (alertView.tag == 30) {
            switch (buttonIndex) {
                case 1:
                {
                    [self removeImageFromHighlights];
                }
                    break;
                    
                default:
                    break;
            }
            
        }

    }
}


#pragma mark - HUD

-(void)showSuccessHUDWithText: (NSString *)text {
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SuccessHUD.png"]];
    hud.mode = MBProgressHUDModeCustomView;
    hud.labelText = text;
    [hud showWhileExecuting:@selector(waitForOneSecond)
                   onTarget:self withObject:nil animated:YES];
    
}

- (void)waitForOneSecond {
    sleep(1);
}

-(void)showHighlightedHUD {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SavedButtonHighlighted.png"]];
    hud.mode = MBProgressHUDModeCustomView;
    hud.labelText = @"Highlighted";
    [hud showWhileExecuting:@selector(waitForOneSecond)
                   onTarget:self withObject:nil animated:YES];
}

-(void)playSound {
    AudioServicesPlaySystemSound (1103);
}



@end
