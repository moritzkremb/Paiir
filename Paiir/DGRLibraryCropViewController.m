//
//  DGRLibraryCropViewController.m
//  Paiir
//
//  Created by Moritz Kremb on 25/09/14.
//  Copyright (c) 2014 Kremb. All rights reserved.
//

#import "DGRLibraryCropViewController.h"
#import "DGRPhotoEditViewController.h"
#import "DGRCompletePhotoEditViewController.h"
#import "DGRConstants.h"

@interface DGRLibraryCropViewController ()

@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIView *myView;

@property (nonatomic) UIImage *imageToCrop;

@property (nonatomic, strong) IBOutlet UIImageView *iphone4CropFrameTop;
@property (nonatomic, strong) IBOutlet UIImageView *iphone4CropFrameBottom;


- (IBAction)goBack:(id)sender;
- (IBAction)crop:(id)sender;

@end

@implementation DGRLibraryCropViewController

@synthesize imageView = _imageView;

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (UIViewController *)childViewControllerForStatusBarHidden {
    return nil;
}

-(void)setPhoto:(UIImage *)imageToCrop {
    
    self.imageToCrop = imageToCrop;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGFloat imageWidth = self.imageToCrop.size.width;
    CGFloat imageHeight = self.imageToCrop.size.height;
    CGFloat aspectRatio = imageHeight/imageWidth;
    CGFloat imageFrameHeight = 320.0f * aspectRatio;
    
    CGFloat scrollViewHeight;
    if (IS_WIDESCREEN) {
        scrollViewHeight = imageFrameHeight + 240.0f;
    } else  scrollViewHeight = imageFrameHeight + 152.0f;

    CGFloat yDistance = (scrollViewHeight - imageFrameHeight) / 2.0f;
    
    
    // 1
    self.scrollView.contentSize = CGSizeMake(320.0f, scrollViewHeight);
    self.myView = [[UIView alloc] initWithFrame: CGRectMake(0, 0, 320.0f, scrollViewHeight)];
    
    
    //2
    UIImage *image = self.imageToCrop;
    self.imageView = [[UIImageView alloc] initWithImage:image];
    self.imageView.frame = CGRectMake(0.0f, yDistance, 320.0f, imageFrameHeight);
    
    [self.myView addSubview:self.imageView];
    [self.scrollView addSubview:self.myView];
    
    //3
    CGFloat initialOffset = (imageFrameHeight - 284.0f) / 2.0f;
    [self.scrollView setContentOffset:CGPointMake(0.0f, initialOffset) animated:NO];

    //4
    
    // Calc zoomscale
    CGFloat zoomScale;
    if (imageFrameHeight < 320) {
        zoomScale = 284.0/imageFrameHeight;
    } else {
        zoomScale = 1.0;
    }

    self.scrollView.minimumZoomScale = 1.0f;
    self.scrollView.maximumZoomScale = 2.0f;
    self.scrollView.zoomScale = zoomScale;
    
    
    
}


- (UIView*)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    // Return the view that you want to zoom
    return self.myView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    // The scroll view has zoomed, so you need to re-center the contents
    //[self centerScrollViewContents];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)goBack:(id)sender {
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (IBAction)crop:(id)sender {
    
    if (self.isFromComplete) {
        CGRect cropRect;
        NSString *vcIdentifier;
        if (IS_WIDESCREEN) {
            cropRect = CGRectMake(0, 240, 640, 568);
            vcIdentifier = @"completePhotoEditViewController5";
        } else {
            cropRect = CGRectMake(0, 152, 640, 568);
            vcIdentifier = @"completePhotoEditViewController4";
        }
        
        UIGraphicsBeginImageContextWithOptions(self.view.frame.size, NO, 0.0);
        
        if ([self.view respondsToSelector:@selector(drawViewHierarchyInRect:afterScreenUpdates:)]) {
            [self.view drawViewHierarchyInRect:self.view.bounds afterScreenUpdates:YES];
        } else {
            [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
        }
        
        UIImage *fullScreenshot = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();

        CGImageRef croppedImage = CGImageCreateWithImageInRect(fullScreenshot.CGImage, cropRect);
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
        
        DGRCompletePhotoEditViewController *photoEditPage = (DGRCompletePhotoEditViewController *)[storyboard instantiateViewControllerWithIdentifier:vcIdentifier];
        
        photoEditPage.pfObject = self.pfObject;
        photoEditPage.isFromCrop = YES;
        photoEditPage.delegate = self.completeDelegate;
        
        [self presentViewController:photoEditPage animated:NO completion:nil];
        
        [photoEditPage setPhoto:[UIImage imageWithCGImage:croppedImage] orientation:UIImageOrientationUp]; // could be thread unsafe but faster
        
    }
    
    else {
        
        CGRect cropRect;
        NSString *vcIdentifier;
        if (IS_WIDESCREEN) {
            cropRect = CGRectMake(0, 240, 640, 568);
            vcIdentifier = @"photoEditViewController5";
        } else {
            cropRect = CGRectMake(0, 152, 640, 568);
            vcIdentifier = @"photoEditViewController4";
        }
        
        UIGraphicsBeginImageContextWithOptions(self.view.frame.size, NO, 0.0);
        
        if ([self.view respondsToSelector:@selector(drawViewHierarchyInRect:afterScreenUpdates:)]) {
            [self.view drawViewHierarchyInRect:self.view.bounds afterScreenUpdates:YES];
        } else {
            [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
        }
        
        UIImage *fullScreenshot = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();

        
        CGImageRef croppedImage = CGImageCreateWithImageInRect(fullScreenshot.CGImage, cropRect);
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
        
        DGRPhotoEditViewController *photoEditPage = (DGRPhotoEditViewController *)[storyboard instantiateViewControllerWithIdentifier:vcIdentifier];
        photoEditPage.isFromCrop = YES;
        photoEditPage.delegate = self.cameraDelegate;

        [self presentViewController:photoEditPage animated:YES completion:nil];
        [photoEditPage setPhoto:[UIImage imageWithCGImage:croppedImage] orientation:UIImageOrientationUp];
    
    }
}
    
@end
