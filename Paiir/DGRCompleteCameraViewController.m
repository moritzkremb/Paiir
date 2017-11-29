//
//  DGRCompleteCameraViewController.m
//  Duogram
//
//  Created by Moritz Kremb on 26/04/14.
//  Copyright (c) 2014 Kremb. All rights reserved.
//

#import "DGRCompleteCameraViewController.h"
#import "DGRCompletePhotoEditViewController.h"
#import "DGRConstants.h"
#import "DGRLibraryCropViewController.h"
#import "DGRCompleteViewController.h"

@interface DGRCompleteCameraViewController ()

// action methods
- (IBAction)cancel:(id)sender;
- (IBAction)takePhoto:(id)sender;
- (IBAction)photoFromLibrary:(id)sender;
- (IBAction)flash:(id)sender;
- (IBAction)reverseCamera:(id)sender;

// images
@property UIImageOrientation orientation;
@property CGImageRef imageRef;

// button
@property UIButton *shutterButton;

// views
@property (weak, nonatomic) IBOutlet UIView *completePageView;
@property (strong, nonatomic) UIImageView *imageToComplete;
@property (strong, nonatomic) UILabel *completeUser;

@end

@implementation DGRCompleteCameraViewController

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
    
    if (self.type1) {
        DGRCompleteViewController *completeViewController = (DGRCompleteViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"CompleteViewController"];
        self.completeViewController = completeViewController;
        [self.completePageView addSubview:completeViewController.view];
    }
    
    else if (self.type2) {
        [self setFirstImage];
    }
    
        
}


-(void)setFirstImage {
    
    // Assign image
    [[self.pfObject objectForKey:@"image"] getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        if (!error) {
            UIImage *convertedImage = [UIImage imageWithData:data];
            if (IS_WIDESCREEN) {
                self.imageToComplete = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 284)];
            } else self.imageToComplete = [[UIImageView alloc] initWithFrame:CGRectMake(25, 0, 270, 240)];
            self.imageToComplete.image = convertedImage;
            [self.completePageView addSubview:self.imageToComplete];
            
            // Assign username
            PFUser *user = [self.pfObject objectForKey:@"creator"];
            UILabel *label;
            if (IS_WIDESCREEN) {
                label = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, 300, 20)];
            }
            else {
                label = [[UILabel alloc] initWithFrame:CGRectMake(30, 5, 260, 20)];
            }
            label.text = [user objectForKey:@"username"];
            label.textColor = [UIColor whiteColor];
            label.textAlignment = NSTextAlignmentRight;
            label.font = [UIFont fontWithName:@"AvenirNext-Medium" size:18];
            label.shadowColor = [UIColor blackColor];
            label.shadowOffset = CGSizeMake(1, -1);
            label.minimumScaleFactor = 0.75;
            self.completeUser = label;
            [self.completePageView addSubview:label];
        }
    }];
    

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
    
    if (self.pfObject) {
        // complete directly from singles page
        
        // add shutter overlay
        self.shutterButton = sender;
        [self.shutterButton setEnabled:NO];
        
        [self.imagePickerController takePicture];
        
        NSString *transitionIdentifier;
        if (IS_WIDESCREEN) {
            transitionIdentifier = @"CompleteShutterTransitionView.png";
        } else transitionIdentifier = @"CompleteShutterTransitionViewSmall.png";
        
        UIImageView *transitionView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:transitionIdentifier]];
        transitionView.frame = CGRectMake(0, self.view.frame.size.height/2, self.view.frame.size.width, self.view.frame.size.height/2);
        self.shutterTransitionView = transitionView;
        
        [self.imagePickerController.cameraOverlayView addSubview:self.shutterTransitionView];

    }
    
    else {
        // complete from complete page
        if (self.completeViewController.objects.count == 0) {
            [self cannotTakePhotoAlert];
        }
        else {
            // add shutter overlay
            self.shutterButton = sender;
            [self.shutterButton setEnabled:NO];
            
            [self.imagePickerController takePicture];
            
            NSString *transitionIdentifier;
            if (IS_WIDESCREEN) {
                transitionIdentifier = @"CompleteShutterTransitionView.png";
            } else transitionIdentifier = @"CompleteShutterTransitionViewSmall.png";
            
            UIImageView *transitionView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:transitionIdentifier]];
            transitionView.frame = CGRectMake(0, self.view.frame.size.height/2, self.view.frame.size.width, self.view.frame.size.height/2);
            self.shutterTransitionView = transitionView;
            
            [self.imagePickerController.cameraOverlayView addSubview:self.shutterTransitionView];
        }
        
    }
    
}

- (IBAction)photoFromLibrary:(id)sender {
    
    if (self.pfObject) {
        self.imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    
    else {
    
        if (self.completeViewController.objects.count == 0) {
            [self cannotTakePhotoAlert];
        }
        
        else {
            self.imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        }
        
    }

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

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    //get the pfobject on display
    if (self.completeViewController) {
        CGFloat completeContentOffset = self.completeViewController.tableView.contentOffset.y;
        CGFloat divideBy;
        if (IS_WIDESCREEN) {
            divideBy = 320.0f;
        } else divideBy = 270.0f;
        CGFloat objectIndex = (completeContentOffset / divideBy);
        NSLog(@"objectIndex: %f", objectIndex);
        PFObject *completedObject = [self.completeViewController.objects objectAtIndex:objectIndex];
        NSLog(@"%@", completedObject);
        self.pfObject = completedObject;
    }
    
    if (picker.sourceType == UIImagePickerControllerSourceTypePhotoLibrary) {
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
        NSString *vcIdentifier;
        if (IS_WIDESCREEN) {
            vcIdentifier = @"libraryCropViewController5";
        } else vcIdentifier = @"libraryCropViewController4";
        
        DGRLibraryCropViewController *libraryCropVC = (DGRLibraryCropViewController *)[storyboard instantiateViewControllerWithIdentifier:vcIdentifier];
        [libraryCropVC setPhoto:image];
        libraryCropVC.isFromComplete = YES;
        libraryCropVC.pfObject = self.pfObject;
        libraryCropVC.completeDelegate = self;
        
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
                    CGRect cropRect1 = CGRectMake(284, 0, 568, 640);
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
                    CGRect cropRect2 = CGRectMake(0, 0, 568, 640);
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
                    CGRect cropRect3 = CGRectMake(0, 0, 640, 568);
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
                    CGRect cropRect4 = CGRectMake(0, 284, 640, 568);
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
        
        

        NSString *vcIdentifier;
        
        if (IS_WIDESCREEN) {
            vcIdentifier = @"completePhotoEditViewController5";
        } else {
            vcIdentifier = @"completePhotoEditViewController4"; }
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
        
        DGRCompletePhotoEditViewController *photoEditPage = (DGRCompletePhotoEditViewController *)[storyboard instantiateViewControllerWithIdentifier:vcIdentifier];
        
        photoEditPage.pfObject = self.pfObject;
        photoEditPage.isFromCrop = NO;
        photoEditPage.delegate = self;
        
        [self.imagePickerController presentViewController:photoEditPage animated:NO completion:NULL];
        
        [photoEditPage setPhoto:[UIImage imageWithCGImage:self.imageRef] orientation:self.orientation]; // could be thread unsafe but faster
        [self.shutterButton setEnabled:YES];
        
    }
        
}

-(void)cannotTakePhotoAlert {
    if ([UIAlertController class]) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Follow some people to paiir their photos" message:nil preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* ok = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
            [alert dismissViewControllerAnimated:YES completion:nil];
        }];
        [alert addAction:ok];
        
        [self.imagePickerController presentViewController:alert animated:YES completion:nil];
    }
    
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Follow some people to paiir their photos" message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
        
        [alert show];
    }

}


@end
