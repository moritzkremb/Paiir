//
//  DGRHighlightsViewController.m
//  Paiir
//
//  Created by Moritz Kremb on 09/10/14.
//  Copyright (c) 2014 Kremb. All rights reserved.
//

#import "DGRHighlightsViewController.h"
#import "DGRHighlightsCell.h"
#import "MBProgressHUD.h"
#import "DGRImageTableViewController.h"
#import "DGRConstants.h"
#import "DGRNoStatusBarImagePickerControllerViewController.h"
#import <AudioToolbox/AudioToolbox.h>
#import "DGRCompleteCameraViewController.h"

@interface DGRHighlightsViewController ()

@property DGRCompleteCameraViewController *completeCameraVC;

@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
- (IBAction)segmentChanged:(id)sender;

- (IBAction)doneAction:(id)sender;

@property NSIndexPath *chosenObjectIndexPath;

@end

@implementation DGRHighlightsViewController

static NSString * const reuseIdentifier = @"HighlightCell";


- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (UIViewController *)childViewControllerForStatusBarHidden {
    return nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // collection view
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    
    // segment initialization
    self.segmentedControl.selectedSegmentIndex = 1;
    [[UISegmentedControl appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:@"Avenir Next" size:15.0], NSFontAttributeName, nil] forState:UIControlStateNormal];
    
    
    // load objects
    MBProgressHUD *loadingHUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    loadingHUD.mode = MBProgressHUDModeIndeterminate;
    [loadingHUD show:YES];
    
    PFQuery *highlightQuery = [PFQuery queryWithClassName:@"Activity"];
    [highlightQuery whereKey:@"fromUserObjectId" equalTo:self.user.objectId];
    [highlightQuery whereKey:@"type" equalTo:@"highlight"];
    
    // includes for highlight
    [highlightQuery includeKey:@"fromUser"];
    [highlightQuery includeKey:@"photoPointer.owner"];
    [highlightQuery includeKey:@"photoPointer.completor"];
    [highlightQuery includeKey:@"photoPointer.imageToComplete"];
    [highlightQuery orderByDescending:@"createdAt"];
    
    [highlightQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
        
        [loadingHUD hide:YES];
        
        self.photoObjects = [NSMutableArray array];

        if (!error) {
            for (PFObject *object in objects) {
                PFObject *cPhotoObject = [object objectForKey:@"photoPointer"];
                
                [self.photoObjects addObject:cPhotoObject];
            }
            
            [self.collectionView reloadData];
        }
        
        else {
            // alert
        }
        
        
    }];
    
    
    //[self preloadUserHighlightPhotos];
    
}

/*
-(void)preloadUserHighlightPhotos {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    
        // preload images
        for (int x=0; x<self.photoObjects.count; x++) {
            
            PFObject *object = [self.photoObjects objectAtIndex:x];
            PFObject *topImage = [object objectForKey:@"imageToComplete"];
            PFFile *image1 = [topImage objectForKey:@"image"];
            
            [image1 getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                NSLog(@"image %i.1 downloaded and cached", x);
            }];
            
            PFFile *image2 = [object objectForKey:@"image"];
            [image2 getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                if (x == self.photoObjects.count-1) {
                }
                NSLog(@"image %i.2 downloaded and cached", x);
                
            }];
        }
      });
    
    [self.collectionView reloadData];
    
    NSLog(@"Photos Preloaded");
    
}
 */


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    if (self.segmentedControl.selectedSegmentIndex == 1) {
        return self.photoObjects.count;
    }
    else if (self.segmentedControl.selectedSegmentIndex == 0) {
        return self.singlePhotoObjects.count;
    }
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    DGRHighlightsCell *cell = (DGRHighlightsCell *)[self.collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    if (self.segmentedControl.selectedSegmentIndex == 1) {
        PFObject *object = [self.photoObjects objectAtIndex:indexPath.row];
        
        PFObject *topImage = [object objectForKey:@"imageToComplete"];
        PFFile *image1 = [topImage objectForKey:@"image"];
        PFFile *image2 = [object objectForKey:@"image"];
        
        cell.image1.image = [UIImage imageNamed:@"CompletePlaceholder.png"];
        cell.image2.image = [UIImage imageNamed:@"CompletePlaceholder.png"];
        cell.image1.file = image1;
        cell.image2.file = image2;
        [cell.image1 loadInBackground];
        [cell.image2 loadInBackground];
    }
    
    else if (self.segmentedControl.selectedSegmentIndex == 0) {
        PFObject *object = [self.singlePhotoObjects objectAtIndex:indexPath.row];
        
        PFFile *image1 = [object objectForKey:@"image"];
        
        cell.image1.image = [UIImage imageNamed:@"CompletePlaceholder.png"];
        cell.image2.image = [UIImage imageNamed:@"SinglesFiller.png"];
        cell.image1.file = image1;
        [cell.image1 loadInBackground];

    }

    
    
    return cell;
}

#pragma mark <UICollectionViewDelegate>


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"did select item in collection view.");
    
    if (self.segmentedControl.selectedSegmentIndex == 1) {
        DGRImageTableViewController *todayVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ImageTableViewController"];
        
        if (self.user == [PFUser currentUser]) {
            todayVC.moreOptionsType2 = YES;
        }
        
        else todayVC.moreOptionsType3 = YES;
        
        if (self.photoObjects) {
            
            // Pass the arrays on
            todayVC.highlightDelegate = self;
            todayVC.highlightRemovalCount = 0;
            todayVC.photoObjects = [NSMutableArray arrayWithArray:self.photoObjects];
            
            NSInteger yOffset;
            if (IS_WIDESCREEN) {
                yOffset = 568;
            } else yOffset = 480;
            
            [todayVC.tableView setContentOffset:CGPointMake(0, indexPath.row * yOffset)];
            
            [self presentViewController:todayVC animated:NO completion:NULL];
        }
        
        else {
            NSLog(@"No Objects available to show. Something went wrong.");
        }

    }
    
    else if (self.segmentedControl.selectedSegmentIndex == 0) {
        if (self.highlightsType1) {
            self.chosenObjectIndexPath = indexPath;
            [self deleteActionSheet];
        }
        else if (self.highlightsType2) {
            // init Complete Camera VC
            NSString *vcIdentifier;
            if (IS_WIDESCREEN) {
                vcIdentifier = @"completeCameraViewController5";
            } else vcIdentifier = @"completeCameraViewController4";
            
            DGRCompleteCameraViewController *completeCameraVC = [self.storyboard instantiateViewControllerWithIdentifier:vcIdentifier];
            completeCameraVC.type2 = YES;
            self.completeCameraVC = completeCameraVC;
            
            self.completeCameraVC.pfObject = [self.singlePhotoObjects objectAtIndex:indexPath.row];
            [self startCompleteCamera];
        }
        else if (self.highlightsType3) {
            [self okAlertWithTitle:@"Follow this user to paiir his Singles." message:nil];
        }
    }
    
    
}

#pragma mark - Single photo Delete

- (void)deleteActionSheet {
    
    if ([UIAlertController class]) {
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        
        UIAlertAction *delete = [UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * action){
            [self yesNoAlertWithTitle:@"Are you sure you want to delete your Single?" message:nil];
        }];
        
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * action){
            
        }];
        
        [alertController addAction:delete];
        [alertController addAction:cancel];
        
        [self presentViewController:alertController animated:YES completion:nil];
        
    } else {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles: @"Delete", @"Cancel", nil];
        actionSheet.destructiveButtonIndex = 0;
        actionSheet.cancelButtonIndex = 1;
        [actionSheet showInView:self.view];
    }
    
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        [self yesNoAlertWithTitle:@"Are you sure you want to delete your Single?" message:nil];
    }
}

-(void)yesNoAlertWithTitle:(NSString*)title message:(NSString*)message {
    if ([UIAlertController class]) {
        UIAlertController *reportAlert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* no = [UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
            
        }];
        
        UIAlertAction* yes = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
            [self deleteChosenObject];
        }];
        
        [reportAlert addAction:no];
        [reportAlert addAction:yes];
        
        [self presentViewController:reportAlert animated:YES completion:nil];
        
    }
    
    else {
        UIAlertView *reportAlert = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:nil otherButtonTitles:@"No", @"Yes", nil];
        [reportAlert show];
    }
    
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    switch (buttonIndex) {
        case 1:
        {
            [self deleteChosenObject];
        }
            break;
            
        default:
            break;
    }
    
}


-(void)deleteChosenObject {
    
    MBProgressHUD *deletingHUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    deletingHUD.mode = MBProgressHUDModeIndeterminate;
    deletingHUD.labelText = @"Deleting...";
    [deletingHUD show:YES];
    
    PFObject *object = [self.singlePhotoObjects objectAtIndex:self.chosenObjectIndexPath.row];
    [self.singlePhotoObjects removeObjectAtIndex:self.chosenObjectIndexPath.row];
    
    PFQuery *checkIfObjectExists = [PFQuery queryWithClassName:@"UPhoto"];
    [checkIfObjectExists whereKey:@"objectId" equalTo:object.objectId];
    
    [checkIfObjectExists getFirstObjectInBackgroundWithBlock:^(PFObject *queryObject, NSError *error) {
        if (queryObject) {
            
            [deletingHUD hide:YES];
            
            queryObject[@"creator"] = [NSNull null];
            queryObject[@"creatorObjectId"] = [NSNull null];
            
            [queryObject saveInBackground];
            
            [self.collectionView reloadData];
            
        } else {
            [deletingHUD hide:YES];
            NSLog(@"Error. The object doesnt exist.");
        }
    }];
    
    
}

#pragma mark - Alert

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

#pragma mark - Complete Camera

- (void)startCompleteCamera {
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [self playSound];
        
        [self initiateCompleteCamera];
    }
    else {
        [self okAlertWithTitle:@"No camera available." message:nil];
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
        
        [self presentViewController:picker animated:YES completion:^{
            //[self.completeCameraVC setFirstImage];
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
        
        [self presentViewController:picker animated:YES completion:^{
            //[self.completeCameraVC setFirstImage];
        }];

    }
}


#pragma mark - Actions

- (IBAction)segmentChanged:(id)sender {
    if (!self.singlePhotoObjects && self.segmentedControl.selectedSegmentIndex == 0) {
        
        // load objects
        MBProgressHUD *loadingHUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        loadingHUD.mode = MBProgressHUDModeIndeterminate;
        [loadingHUD show:YES];

        // load user single photos in background
        PFQuery *userSinglePhotos = [PFQuery queryWithClassName:@"UPhoto"];
        [userSinglePhotos whereKey:@"creatorObjectId" equalTo:self.user.objectId];
        
        [userSinglePhotos includeKey:@"creator"];
        [userSinglePhotos orderByDescending:@"createdAt"];
        [userSinglePhotos findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
            
            [loadingHUD hide:YES];
            
            self.singlePhotoObjects = [NSMutableArray arrayWithArray:objects];
            [self.collectionView reloadData];
            
        }];
    }
    
    [UIView animateWithDuration:0.3f animations:^{
        
        [self.collectionView setAlpha:0.0f];
        
    } completion:^(BOOL finished) {
        
        [self.collectionView reloadData];
        
        //fade in
        [UIView animateWithDuration:0.3f animations:^{
            
            [self.collectionView setAlpha:1.0f];
            
        } completion:nil];
        
    }];

}

- (IBAction)doneAction:(id)sender {
    /*
    if (self.userIsMe) {
        NSMutableArray *myHighlightPhotos = [self.delegate.userToHighlightPhotos objectForKey:[PFUser currentUser].username];
        myHighlightPhotos = self.photoObjects;
        [self.delegate.userToHighlightPhotos setObject:myHighlightPhotos forKey:[PFUser currentUser].username];
        [self.delegate.tableView reloadData];
    }
    */
    [self.delegate.tableView reloadData];
    
    [self dismissViewControllerAnimated:YES completion:NULL];

}

-(void)playSound {

    AudioServicesPlaySystemSound (1103);
}

@end
