//
//  DGRCameraNewViewController.m
//  Duogram1
//
//  Created by Kira Hentschel on 26/3/14.
//  Copyright (c) 2014 Kremb. All rights reserved.
//

#import "DGRPhotoEditViewController.h"
#import "Parse/Parse.h"
#import "DGRConstants.h"
#import "MBProgressHUD.h"

@interface DGRPhotoEditViewController ()

// images
@property UIImage *image;

// imageview
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet UILabel *userLabel;

// aviary
@property AVYPhotoEditorController *aviaryPhotoEditor;

// action methods
- (IBAction)retake:(id)sender;
- (IBAction)postImage:(id)sender;
- (IBAction)saveImageToLibrary:(id)sender;
- (IBAction)editPhoto:(id)sender;

// internal methods
- (void)uploadImage:(NSData *)imageData;


@end

@implementation DGRPhotoEditViewController

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
    
    self.userLabel.text = [PFUser currentUser].username;
    //self.displayCaption.text = nil;
    //self.imageCounter = 1;
    
    // remove the added shutterview
    [self.delegate.shutterTransitionView removeFromSuperview];

    // Aviary start loading OpenGL entities
    [AFOpenGLManager beginOpenGLLoad];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



-(void)setPhoto:(UIImage *)originalImage orientation:(UIImageOrientation)imageOrientation {
    
    self.image = [UIImage imageWithCGImage:originalImage.CGImage scale:1.0 orientation:imageOrientation];
    
    [self.imageView setImage:self.image];
    
}

- (IBAction)editPhoto:(id)sender {
    
    // Aviary
    [self displayEditorForImage:self.imageView.image];
    
}

- (IBAction)retake:(id)sender {
    
    if (self.isFromCrop) {
        [self.presentingViewController.presentingViewController dismissViewControllerAnimated:NO completion:NULL];
    }
    
    else [self dismissViewControllerAnimated:NO completion:NULL];
    
}

- (IBAction)saveImageToLibrary:(id)sender {
    UIImageWriteToSavedPhotosAlbum(self.imageView.image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    if (!error) {
        NSLog(@"image saved to lib");
        
        [self showSavedToLibraryHUD];
    }
}

- (IBAction)postImage:(id)sender {
    
    NSData *imageData = UIImageJPEGRepresentation(self.imageView.image, 0.5f);
    [self uploadImage:imageData];
    
}



- (void)uploadImage:(NSData *)imageData {
    
    PFFile *imageFile = [PFFile fileWithName:@"incompleteImage.jpg" data:imageData];

    MBProgressHUD *uploadingHUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    uploadingHUD.mode = MBProgressHUDModeAnnularDeterminate;
    uploadingHUD.labelText = @"Posting...";
    [uploadingHUD show:YES];

    // Save PFFile
    [imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            [uploadingHUD hide:YES];
            
            [self showFinishedUploadHUD];
            
            // Create a PFObject around a PFFile and associate it with the current user. in background.

            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                PFObject *uncompletedPhoto = [PFObject objectWithClassName:@"UPhoto"];
                [uncompletedPhoto setObject:imageFile forKey:@"image"];
                
                // Set user
                [uncompletedPhoto setObject:[PFUser currentUser] forKey:@"creator"];
                [uncompletedPhoto setObject:[PFUser currentUser].objectId forKey:@"creatorObjectId"];
                
                [uncompletedPhoto saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if (succeeded) {
                        NSLog(@"Photo saved.");
                    }
                    else {
                        [uncompletedPhoto saveEventually];
                        NSLog(@"Error: %@ %@", error, [error userInfo]);
                    }
                }];

            });
        }
        else {
            [uploadingHUD hide:YES];
            // error hud
            NSLog(@"Error: %@ %@", error, [error userInfo]);
            [self errorAlert:@"Network Error" message:@"Please try the upload again once your connection is back."];
            
        }
    } progressBlock:^(int percentDone) {
        // Update your progress spinner here. percentDone will be between 0 and 100.
        uploadingHUD.progress = (float)percentDone/100;
    }];
  
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

-(void)showSavedToLibraryHUD {
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SuccessHUD.png"]];
    hud.mode = MBProgressHUDModeCustomView;
    hud.labelText = @"Saved To Library";
    [hud showWhileExecuting:@selector(waitForOneSecond)
                   onTarget:self withObject:nil animated:YES];
    
}

- (void)waitForOneSecond {
    sleep(1);
}

-(void)showFinishedUploadHUD {
    
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
            // close view
            if ([message isEqualToString:@"Don't worry, your photo will be uploaded automatically once your connection is back."]) {
                if (self.isFromCrop) {
                    [self.presentingViewController.presentingViewController.presentingViewController dismissViewControllerAnimated:NO completion:nil];
                }
                else [self.presentingViewController.presentingViewController dismissViewControllerAnimated:NO completion:nil];
            }
        }];
        [errorAlert addAction:ok];
        
        [self presentViewController:errorAlert animated:YES completion:nil];
    }
    
    else {
        UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
        if ([message isEqualToString:@"Don't worry, your photo will be uploaded automatically once your connection is back."]) {
            errorAlert.tag = 10;
        }
        [errorAlert show];
    }
    
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (![UIAlertController class]) {
        if (alertView.tag == 10) {
            switch (buttonIndex) {
                case 0:
                {
                    if (self.isFromCrop) {
                        [self.presentingViewController.presentingViewController.presentingViewController dismissViewControllerAnimated:NO completion:nil];
                    }
                    else [self.presentingViewController.presentingViewController dismissViewControllerAnimated:NO completion:nil];
                }
                    break;
                    
                default:
                    break;
            }
        }
    }
}




@end
