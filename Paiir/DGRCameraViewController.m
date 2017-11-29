//
//  DGRCameraViewController.m
//  Paiir
//
//  Created by Moritz Kremb on 20/04/14.
//  Copyright (c) 2014 Kremb. All rights reserved.
//

#import "DGRHomeViewController.h"
#import "DGRCameraViewController.h"
#import "DGRPhotoEditViewController.h"
#import "DGRNoStatusBarImagePickerControllerViewController.h"
#import "DGRConstants.h"
#import "DGRLibraryCropViewController.h"
#import "DGRHorizontalShiftLeftAnimator.h"

@interface DGRCameraViewController ()

- (IBAction)cancel:(id)sender;
- (IBAction)takePhoto:(id)sender;
- (IBAction)photoFromLibrary:(id)sender;
- (IBAction)flash:(id)sender;
- (IBAction)reverseCamera:(id)sender;

@property UIImageOrientation orientation;
@property CGImageRef imageRef;

@property UIButton *shutterButton;

@end

@implementation DGRCameraViewController

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
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)cancel:(id)sender {
    
    [self.imagePickerController dismissViewControllerAnimated:YES completion:NULL];
    self.imagePickerController = nil;

}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    // called when pick from library is cancelled
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        self.imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
    }
    else [self.imagePickerController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)takePhoto:(id)sender {
    
    self.shutterButton = sender;
    [self.shutterButton setEnabled:NO];
    
    [self.imagePickerController takePicture];
    
    NSString *transitionIdentifier;
    if (IS_WIDESCREEN) {
        transitionIdentifier = @"ShutterTransitionView.png";
    } else transitionIdentifier = @"ShutterTransitionViewSmall.png";
    
    UIImageView *transitionView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:transitionIdentifier]];
    transitionView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height/2);
    self.shutterTransitionView = transitionView;
    
    [self.imagePickerController.cameraOverlayView addSubview:self.shutterTransitionView];
    
    
}

- (IBAction)photoFromLibrary:(id)sender {
    
    self.imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
}

- (IBAction)flash:(id)sender {
    
    UIButton *flashButton = sender;
    
    if (flashButton.selected == true) {
        self.imagePickerController.cameraFlashMode = UIImagePickerControllerCameraFlashModeOff;
    }
    else {
        self.imagePickerController.cameraFlashMode = UIImagePickerControllerCameraFlashModeOn;
    }
    
    flashButton.selected = !flashButton.selected;
    
}

- (IBAction)reverseCamera:(id)sender {
    
    if (self.imagePickerController.cameraDevice == UIImagePickerControllerCameraDeviceRear) {
        self.imagePickerController.cameraDevice = UIImagePickerControllerCameraDeviceFront;
    }
    
    else if (self.imagePickerController.cameraDevice == UIImagePickerControllerCameraDeviceFront) {

        self.imagePickerController.cameraDevice = UIImagePickerControllerCameraDeviceRear;
    }
    
}


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
    if (picker.sourceType == UIImagePickerControllerSourceTypePhotoLibrary) {
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
        NSString *vcIdentifier;
        if (IS_WIDESCREEN) {
            vcIdentifier = @"libraryCropViewController5";
        } else vcIdentifier = @"libraryCropViewController4";
        
        DGRLibraryCropViewController *libraryCropVC = (DGRLibraryCropViewController *)[storyboard instantiateViewControllerWithIdentifier:vcIdentifier];
        libraryCropVC.cameraDelegate = self;
        [libraryCropVC setPhoto:image];
            
        [self.imagePickerController presentViewController:libraryCropVC animated:NO completion:nil];
        
        
    }
    
    else {
        
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    
        //flip image
        if (picker.sourceType == UIImagePickerControllerSourceTypeCamera && picker.cameraDevice == UIImagePickerControllerCameraDeviceFront) {
            UIImage *flippedImage = [UIImage imageWithCGImage:image.CGImage scale:image.scale orientation:UIImageOrientationLeftMirrored];
        
            image = flippedImage;
        }
        
        if (IS_WIDESCREEN) {
            switch (image.imageOrientation) {
                case UIImageOrientationUp:
                {    NSLog(@"image orientation left");
                    
                    //scale image
                    UIGraphicsBeginImageContextWithOptions(CGSizeMake(427, 320), NO, 0.0);
                    [image drawInRect:CGRectMake(0, 0, 427, 320)];
                    UIImage *scaledImage1 = UIGraphicsGetImageFromCurrentImageContext();
                    UIGraphicsEndImageContext();
                    
                    //crop image, hard coded to iphone 5s
                    CGRect cropRect1 = CGRectMake(142, 0, 568, 640);
                    CGImageRef croppedImage1 = CGImageCreateWithImageInRect(scaledImage1.CGImage, cropRect1);
                    self.imageRef = croppedImage1;
                    self.orientation = UIImageOrientationRight;
                    
                    break;
                }
                case UIImageOrientationDown:
                {
                    NSLog(@"image orientation right");
                    
                    //scale image
                    UIGraphicsBeginImageContextWithOptions(CGSizeMake(427, 320), NO, 0.0);
                    [image drawInRect:CGRectMake(0, 0, 427, 320)];
                    UIImage *scaledImage2 = UIGraphicsGetImageFromCurrentImageContext();
                    UIGraphicsEndImageContext();
                    
                    //crop image, hard coded to iphone 5s
                    CGRect cropRect2 = CGRectMake(142, 0, 568, 640);
                    CGImageRef croppedImage2 = CGImageCreateWithImageInRect(scaledImage2.CGImage, cropRect2);
                    self.imageRef = croppedImage2;
                    self.orientation = UIImageOrientationLeft;
                    
                    break;
                }
                case UIImageOrientationLeft:
                {
                    NSLog(@"image orientation down");
                    
                    //scale image
                    UIGraphicsBeginImageContextWithOptions(CGSizeMake(320, 427), NO, 0.0);
                    [image drawInRect:CGRectMake(0, 0, 320, 427)];
                    UIImage *scaledImage3 = UIGraphicsGetImageFromCurrentImageContext();
                    UIGraphicsEndImageContext();
                    
                    //crop image, hard coded to iphone 5s
                    CGRect cropRect3 = CGRectMake(0, 142, 640, 568);
                    CGImageRef croppedImage3 = CGImageCreateWithImageInRect(scaledImage3.CGImage, cropRect3);
                    self.imageRef = croppedImage3;
                    self.orientation = UIImageOrientationDown;
                    
                    break;
                }
                default:
                {
                    NSLog(@"image orientation up");
                    
                    //scale image
                    UIGraphicsBeginImageContextWithOptions(CGSizeMake(320, 427), NO, 0.0);
                    [image drawInRect:CGRectMake(0, 0, 320, 427)];
                    UIImage *scaledImage4 = UIGraphicsGetImageFromCurrentImageContext();
                    UIGraphicsEndImageContext();
                    
                    //crop image, hard coded to iphone 5s
                    CGRect cropRect4 = CGRectMake(0, 142, 640, 568);
                    CGImageRef croppedImage4 = CGImageCreateWithImageInRect(scaledImage4.CGImage, cropRect4);
                    self.imageRef = croppedImage4;
                    self.orientation = UIImageOrientationUp;
                    
                    break;
                }
            }

        }
        
        else {
            switch (image.imageOrientation) {
                case UIImageOrientationUp:
                {    NSLog(@"image orientation left");
                    
                    //scale image
                    UIGraphicsBeginImageContextWithOptions(CGSizeMake(427, 320), NO, 0.0);
                    [image drawInRect:CGRectMake(0, 0, 427, 320)];
                    UIImage *scaledImage1 = UIGraphicsGetImageFromCurrentImageContext();
                    UIGraphicsEndImageContext();
                    
                    //crop image, hard coded to iphone 5s
                    CGRect cropRect1 = CGRectMake(171, 36, 504, 568);
                    CGImageRef croppedImage1 = CGImageCreateWithImageInRect(scaledImage1.CGImage, cropRect1);
                    self.imageRef = croppedImage1;
                    self.orientation = UIImageOrientationRight;
                    
                    break;
                }
                case UIImageOrientationDown:
                {
                    NSLog(@"image orientation right");
                    
                    //scale image
                    UIGraphicsBeginImageContextWithOptions(CGSizeMake(427, 320), NO, 0.0);
                    [image drawInRect:CGRectMake(0, 0, 427, 320)];
                    UIImage *scaledImage2 = UIGraphicsGetImageFromCurrentImageContext();
                    UIGraphicsEndImageContext();
                    
                    //crop image, hard coded to iphone 5s
                    CGRect cropRect2 = CGRectMake(171, 36, 504, 568);
                    CGImageRef croppedImage2 = CGImageCreateWithImageInRect(scaledImage2.CGImage, cropRect2);
                    self.imageRef = croppedImage2;
                    self.orientation = UIImageOrientationLeft;
                    
                    break;
                }
                case UIImageOrientationLeft:
                {
                    NSLog(@"image orientation down");
                    
                    //scale image
                    UIGraphicsBeginImageContextWithOptions(CGSizeMake(320, 427), NO, 0.0);
                    [image drawInRect:CGRectMake(0, 0, 320, 427)];
                    UIImage *scaledImage3 = UIGraphicsGetImageFromCurrentImageContext();
                    UIGraphicsEndImageContext();
                    
                    //crop image, hard coded to iphone 5s
                    CGRect cropRect3 = CGRectMake(36, 171, 568, 504);
                    CGImageRef croppedImage3 = CGImageCreateWithImageInRect(scaledImage3.CGImage, cropRect3);
                    self.imageRef = croppedImage3;
                    self.orientation = UIImageOrientationDown;
                    
                    break;
                }
                default:
                {
                    NSLog(@"image orientation up");
                    
                    //scale image
                    UIGraphicsBeginImageContextWithOptions(CGSizeMake(320, 427), NO, 0.0);
                    [image drawInRect:CGRectMake(0, 0, 320, 427)];
                    UIImage *scaledImage4 = UIGraphicsGetImageFromCurrentImageContext();
                    UIGraphicsEndImageContext();
                    
                    //crop image, hard coded to iphone 5s
                    CGRect cropRect4 = CGRectMake(36, 171, 568, 504);
                    CGImageRef croppedImage4 = CGImageCreateWithImageInRect(scaledImage4.CGImage, cropRect4);
                    self.imageRef = croppedImage4;
                    self.orientation = UIImageOrientationUp;
                    
                    break;
                }
            }

        }

        

        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
        
        NSString *vcIdentifier;
        
        if (IS_WIDESCREEN) {
            vcIdentifier = @"photoEditViewController5";
        }
        else vcIdentifier = @"photoEditViewController4";
        
        
        DGRPhotoEditViewController *photoEditPage = (DGRPhotoEditViewController *)[storyboard instantiateViewControllerWithIdentifier:vcIdentifier];
        photoEditPage.isFromCrop = NO;
        photoEditPage.delegate = self;
                
        [self.imagePickerController presentViewController:photoEditPage animated:NO completion:NULL];
        
        [photoEditPage setPhoto:[UIImage imageWithCGImage:self.imageRef] orientation:self.orientation]; // possibly not threadsafe but faster...
        [self.shutterButton setEnabled:YES];


    
    }
}


@end
