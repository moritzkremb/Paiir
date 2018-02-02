//
//  DGRProfilePictureAtSignUpViewController.m
//  Paiir
//
//  Created by Moritz Kremb on 08/12/14.
//  Copyright (c) 2014 Kremb. All rights reserved.
//

#import "DGRProfilePictureAtSignUpViewController.h"
#import "DGRNoStatusBarImagePickerControllerViewController.h"
#import "MBProgressHUD.h"
#import <Parse/Parse.h>
#import "DGRConstants.h"

@interface DGRProfilePictureAtSignUpViewController ()

@property UIImagePickerController *imagePickerController;
@property UIImage *uploadReadyImage;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;

- (IBAction)didTapImage:(UITapGestureRecognizer *)sender;
- (IBAction)doneAction:(id)sender;
- (IBAction)skipAction:(id)sender;


@end

@implementation DGRProfilePictureAtSignUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // hide back button
    self.navigationItem.hidesBackButton = YES;
    
    // image
    [self.imageView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"ProfilePicturePlaceholderBig.png"]]];
    self.imageView.layer.cornerRadius = 100.0f;
    self.imageView.clipsToBounds = YES;
    self.imageView.layer.borderWidth = 1.0f;
    self.imageView.layer.borderColor = [UIColor blackColor].CGColor;
    
    // hide done button
    [self.doneButton setHidden:YES];
    self.doneButton.layer.cornerRadius = 5.0f;
    self.doneButton.clipsToBounds = YES;
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation
 


#pragma mark - Actions

- (IBAction)didTapImage:(UITapGestureRecognizer *)sender {
    [self manageImageTap];
}

- (IBAction)skipAction:(id)sender {
    
    // Flurry
    [Flurry logEvent:@"SetProfilePicture_Skipped"];

    [self showAllSetHUD];
}

- (IBAction)doneAction:(id)sender {
    
    // Flurry
    [Flurry logEvent:@"SetProfilePicture_Set"];

    
    MBProgressHUD *uploadingHUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    uploadingHUD.mode = MBProgressHUDModeIndeterminate;
    uploadingHUD.labelText = @"Saving...";
    [uploadingHUD show:YES];
    
    NSData *imageData = UIImageJPEGRepresentation(self.uploadReadyImage, 0.5f);
    PFFile *imageFile = [PFFile fileWithName:@"profilePicture.jpg" data:imageData];
    [imageFile saveInBackgroundWithBlock:^(BOOL succeded, NSError *error){
        [uploadingHUD hide:YES];
        if (succeded) {
            [self showAllSetHUD];
            
            PFUser *user = [PFUser currentUser];
            user[@"profilePicture"] = imageFile;
            [user saveInBackground];
            
        }
        if (error) {
            [self okAlertWithTitle:@"Sorry!" message:@"There was an error. Please try again."];
        }
    }];
}

- (void)manageImageTap {
    if ([UIAlertController class]) {
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        
        UIAlertAction *library = [UIAlertAction actionWithTitle:@"Choose From Library" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
            [self chooseImageFromLibrary];
        }];
        
        UIAlertAction *photo = [UIAlertAction actionWithTitle:@"Take Photo" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
            [self takePhoto];
        }];
        
        UIAlertAction* cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * action){
            [alertController dismissViewControllerAnimated:YES completion:nil];
        }];
        
        [alertController addAction:library];
        [alertController addAction:photo];
        [alertController addAction:cancel];
        
        [self presentViewController:alertController animated:YES completion:nil];
        
    } else {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:@"Choose From Library", @"Take Photo", @"Cancel", nil];
        actionSheet.cancelButtonIndex = 2;
        actionSheet.tag = 10;
        [actionSheet showInView:self.view];
    }
    
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (![UIAlertController class]) {
        if (actionSheet.tag == 10) {
            
            switch (buttonIndex) {
                case 0:
                    [self chooseImageFromLibrary];
                    break;
                    
                case 1:
                    [self takePhoto];
                    break;
                    
                default:
                    break;
                    
            }
        }
    }
}

-(void)chooseImageFromLibrary {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    self.imagePickerController = picker;
    
    [self presentViewController:picker animated:YES completion:NULL];
    
}

-(void)takePhoto {
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [self initiateCamera];
    }
    else {
        [self okAlertWithTitle:@"No camera available" message:nil];
    }
    
}

-(void)initiateCamera {
    DGRNoStatusBarImagePickerControllerViewController *picker = [[DGRNoStatusBarImagePickerControllerViewController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    picker.showsCameraControls = YES;
    self.imagePickerController = picker;
    
    [self presentViewController:picker animated:YES completion:NULL];
    
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    
    CGFloat imageWidth = image.size.width;
    CGFloat imageHeight = image.size.height;
    CGFloat aspectRatio = imageHeight/imageWidth;
    CGFloat imageFrameHeight = 200.0f * aspectRatio;
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(200.0f, imageFrameHeight), NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, 200.0f, imageFrameHeight)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    imageFrameHeight = 50.0f * aspectRatio;
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(50.0f, imageFrameHeight), NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, 50.0f, imageFrameHeight)];
    UIImage *readyImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    self.uploadReadyImage = readyImage;
    
    self.imageView.image = scaledImage;
    
    [self.doneButton setHidden:NO];
    
    [self.imagePickerController dismissViewControllerAnimated:YES completion:NULL];
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

-(void)showUploadedHUD {
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SuccessHUD.png"]];
    hud.mode = MBProgressHUDModeCustomView;
    hud.labelText = @"Saved";
    [hud showWhileExecuting:@selector(wait)
                   onTarget:self withObject:nil animated:YES];
    
}

-(void)wait {
    sleep(1.5);
}

-(void)showAllSetHUD {
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SuccessHUD.png"]];
    hud.mode = MBProgressHUDModeCustomView;
    hud.labelText = @"You're All Set!";
    [hud showWhileExecuting:@selector(finishUp)
                   onTarget:self withObject:nil animated:YES];
    
}

-(void)finishUp {
    sleep(2.0);
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DGRHomeViewControllerDismissAllPresentedViewControllersAnimated" object:self];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DGRHomeViewControllerNewUserSignedUp" object:self];

    [[NSNotificationCenter defaultCenter] postNotificationName:@"DGRHomeViewControllerLoadParseObjects" object:self];
}



@end
