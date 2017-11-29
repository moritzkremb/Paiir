//
//  DGRCompletePhotoEditViewController.m
//  Duogram
//
//  Created by Moritz Kremb on 26/04/14.
//  Copyright (c) 2014 Kremb. All rights reserved.
//

#import "DGRCompletePhotoEditViewController.h"
#import "DGRConstants.h"
#import "MBProgressHUD.h"

@interface DGRCompletePhotoEditViewController ()

// images
@property UIImage *image;
@property UIImage *firstImage;

// views
@property (strong, nonatomic) IBOutlet UILabel *userLabel;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIImageView *firstImageView;

// aviary
@property AVYPhotoEditorController *aviaryPhotoEditor;

// action methods
- (IBAction)retake:(id)sender;
- (IBAction)postImage:(id)sender;
- (IBAction)editPhoto:(id)sender;

// internal methods
- (void)uploadImage:(NSData *)imageData;

@end

@implementation DGRCompletePhotoEditViewController

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (UIViewController *)childViewControllerForStatusBarHidden {
    return nil;
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
    
    // assign top image components
    [[self.pfObject objectForKey:@"image"] getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        if (!error) {
            UIImage *convertedImage = [UIImage imageWithData:data];
            self.firstImageView.image = convertedImage;
        }
    }];
    [self setFirstUser];
    
    // phototaker username and caption
    self.userLabel.text = [PFUser currentUser].username;
    
    // remove shutter transition view
    [self.delegate.shutterTransitionView removeFromSuperview];
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setFirstUser {
    
    // Assign username
    PFUser *user = [self.pfObject objectForKey:@"creator"];
    self.completeUser.text = [user objectForKey:@"username"];
    
}

-(void)setPhoto:(UIImage *)unfilteredImage orientation:(UIImageOrientation)imageOrientation {
    
    self.image = [UIImage imageWithCGImage:unfilteredImage.CGImage scale:1.0 orientation:imageOrientation];
    
    [self.imageView setImage:self.image];
    
}

- (IBAction)retake:(id)sender {
        
    if (self.isFromCrop) {
        [self.presentingViewController.presentingViewController dismissViewControllerAnimated:NO completion:nil];
    }
    
    else [self dismissViewControllerAnimated:NO completion:nil];}


- (IBAction)editPhoto:(id)sender {
    
    // Aviary
    [self displayEditorForImage:self.imageView.image];
    
}

- (IBAction)postImage:(id)sender {
    
    NSData *imageData = UIImageJPEGRepresentation(self.imageView.image, 0.5f);
    [self uploadImage:imageData];
    
}

- (void)uploadImage:(NSData *)imageData {
    
    MBProgressHUD *uploadingHUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    uploadingHUD.mode = MBProgressHUDModeAnnularDeterminate;
    uploadingHUD.labelText = @"Posting...";
    [uploadingHUD show:YES];
    
    // thumbnail
    PFFile *thumbnail = [self createThumbnailImage];
    [thumbnail saveInBackground];
    
    // actual image
    PFFile *imageFile = [PFFile fileWithName:@"completeImage.jpg" data:imageData];
    
    // Save PFFile
    [imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            
            [uploadingHUD hide:YES];
            
            [self showUploadedHUD];
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                // Create a PFObject around a PFFile and associate it with the current user
                PFObject *completePhoto = [PFObject objectWithClassName:@"CPhoto"];
                [completePhoto setObject:imageFile forKey:@"image"];
                [completePhoto setObject:thumbnail forKey:@"thumbnail"];
                
                // Set users
                [completePhoto setObject:[PFUser currentUser] forKey:@"completor"];
                [completePhoto setObject:[PFUser currentUser].objectId forKey:@"completorObjectId"];
                
                PFUser *creator = [self.pfObject objectForKey:@"creator"];
                [completePhoto setObject:creator forKey:@"owner"];
                [completePhoto setObject:creator.objectId forKey:@"ownerObjectId"];
                
                // Set pointer and object id string to the image to complete
                [completePhoto setObject:self.pfObject forKey:@"imageToComplete"];
                [completePhoto setObject:self.pfObject.objectId forKey:@"imageToCompleteString"];
                
                [completePhoto saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if (error) {
                        [completePhoto saveEventually];

                        NSLog(@"Error: %@ %@", error, [error userInfo]);
                    }
                    if (succeeded) {
                        // make paiir objects in activity
                        PFObject *paiirObject = [PFObject objectWithClassName:@"Activity"];
                        paiirObject[@"type"] = @"paiir";
                        paiirObject[@"fromUser"] = [PFUser currentUser];
                        paiirObject[@"fromUserObjectId"] = [PFUser currentUser].objectId;
                        paiirObject[@"toUser"] = creator;
                        paiirObject[@"toUserObjectId"] = creator.objectId;
                        paiirObject[@"photoPointer"] = completePhoto;
                        paiirObject[@"photoPointerObjectId"] = completePhoto.objectId;
                        [paiirObject saveInBackground];
                        
                        // increment paiir scores
                        PFQuery *paiirScore1 = [PFQuery queryWithClassName:@"PaiirScore"];
                        [paiirScore1 whereKey:@"user" equalTo:[PFUser currentUser]];
                        PFObject *paiirScoreObject1 = [paiirScore1 getFirstObject];
                        [paiirScoreObject1 incrementKey:@"scoreCount"];
                        [paiirScoreObject1 saveInBackground];

                        PFQuery *paiirScore2 = [PFQuery queryWithClassName:@"PaiirScore"];
                        [paiirScore2 whereKey:@"user" equalTo:creator];
                        PFObject *paiirScoreObject2 = [paiirScore2 getFirstObject];
                        [paiirScoreObject2 incrementKey:@"scoreCount"];
                        [paiirScoreObject2 saveInBackground];

                        NSString *message = [NSString stringWithFormat:@"%@ paiired your photo.", [PFUser currentUser].username];
                        [self sendPushToUser:[self.pfObject objectForKey:@"creator"] withMessage:message objectId:completePhoto.objectId];
                    }
                }];


            });
        }
        else {
            [uploadingHUD hide:YES];
            [self errorAlert:@"Network Error" message:@"Please try the upload again once your connection is back."];

            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
        
    } progressBlock:^(int percentDone) {
        // Update your progress spinner here. percentDone will be between 0 and 100.
        uploadingHUD.progress = (float)percentDone/100;
    }];
    
}

-(PFFile*)createThumbnailImage {
    UIImageView *thumbnailView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 40.0f, 71.0f)];
    UIImageView *topImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 40.0f, 35.0f)];
    UIImageView *bottomImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 35.0f, 40.0f, 36.0f)];
    
    topImageView.contentMode = UIViewContentModeScaleAspectFill;
    topImageView.clipsToBounds = YES;
    topImageView.image = self.firstImageView.image;
    
    bottomImageView.contentMode = UIViewContentModeScaleAspectFill;
    bottomImageView.clipsToBounds = YES;
    bottomImageView.image = self.imageView.image;
    
    [thumbnailView addSubview:topImageView];
    [thumbnailView addSubview:bottomImageView];
    
    // create snapshot
    UIGraphicsBeginImageContextWithOptions(thumbnailView.frame.size, NO, 0.0);
    if ([thumbnailView respondsToSelector:@selector(drawViewHierarchyInRect:afterScreenUpdates:)]) {
        [thumbnailView drawViewHierarchyInRect:thumbnailView.bounds afterScreenUpdates:YES];
    } else {
        [thumbnailView.layer renderInContext:UIGraphicsGetCurrentContext()];
    }
    UIImage *thumbnail = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    NSData *imageData = UIImageJPEGRepresentation(thumbnail, 0.5f);
    PFFile *imageFile = [PFFile fileWithName:@"thumbnail.jpg" data:imageData];
    
    return imageFile;
}

#pragma mark - Aviary Delegate

- (void)displayEditorForImage:(UIImage *)imageToEdit
{
    // kAviaryAPIKey and kAviarySecret are developer defined
    // and contain your API key and secret respectively
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [AVYPhotoEditorController setAPIKey:kAviaryAPIKey secret:kAviarySecret];
    });
    
    AVYPhotoEditorController *editorController = [[AVYPhotoEditorController alloc] initWithImage:imageToEdit];
    [editorController setDelegate:self];
    self.aviaryPhotoEditor = editorController;
    
    [AVYPhotoEditorCustomization setToolOrder:@[kAVYText, kAVYEffects, kAVYDraw, kAVYOrientation, kAVYCrop, kAVYEnhance, kAVYStickers, kAVYVignette, kAVYFocus, kAVYColorAdjust,kAVYLightingAdjust, kAVYSharpness, kAVYSplash, kAVYRedeye, kAVYWhiten, kAVYBlur, kAVYBlemish, kAVYMeme]];
    [AVYPhotoEditorCustomization setCropToolCustomEnabled:NO];
    [AVYPhotoEditorCustomization setCropToolInvertEnabled:NO];
    [AVYPhotoEditorCustomization setCropToolOriginalEnabled:NO];
    [AVYPhotoEditorCustomization setCropToolPresets:@[@{kAVYCropPresetName:@"8:7", kAVYCropPresetWidth:@8, kAVYCropPresetHeight:@7.1}]];
    
    [self presentViewController:editorController animated:YES completion:nil];
}

- (void)photoEditor:(AVYPhotoEditorController *)editor finishedWithImage:(UIImage *)image
{
    self.imageView.image = image;
    [self.aviaryPhotoEditor dismissViewControllerAnimated:YES completion:NULL];
}

- (void)photoEditorCanceled:(AVYPhotoEditorController *)editor
{
    [self.aviaryPhotoEditor dismissViewControllerAnimated:YES completion:NULL];
}


#pragma mark - HUD

-(void)showUploadedHUD {
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SuccessHUD.png"]];
    hud.mode = MBProgressHUDModeCustomView;
    hud.labelText = @"Posted";
    [hud showWhileExecuting:@selector(waitThenDismissView)
                   onTarget:self withObject:nil animated:YES];
    
}

- (void)waitThenDismissView {
    sleep(1.5);
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DGRHomeViewControllerDismissAllPresentedViewControllersAnimated" object:self];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DGRHomeViewControllerLoadParseObjects" object:self];

}


-(void)errorAlert:(NSString*)title message:(NSString*)message {
    
    if ([UIAlertController class]) {
        UIAlertController *errorAlert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* ok = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
        }];
        [errorAlert addAction:ok];
        
        [self presentViewController:errorAlert animated:YES completion:nil];
    }
    
    else {
        UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
        [errorAlert show];
    }
    
}

-(void)sendPushToUser: (PFUser *)user withMessage: (NSString *)message objectId:(NSString *)objectId {
    // Create our Installation query
    PFQuery *pushQuery = [PFInstallation query];
    [pushQuery whereKey:@"user" equalTo:user];
    
    NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
                          message, @"alert",
                          @"Tink.caf", @"sound",
                          @"Increment", @"badge",
                          @"1", @"t",
                          objectId, @"p",
                          nil];
    
    // Send push notification to query
    PFPush *push = [[PFPush alloc] init];
    [push setQuery:pushQuery];
    [push setData:data];
    [push sendPushInBackground];

}

@end
