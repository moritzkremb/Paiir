//
//  DGRCompleteCameraViewController.h
//  Duogram
//
//  Created by Moritz Kremb on 26/04/14.
//  Copyright (c) 2014 Kremb. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Parse/Parse.h"
#import "DGRCompleteViewController.h"

@interface DGRCompleteCameraViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (nonatomic) UIImagePickerController *imagePickerController;

@property (strong, nonatomic) PFObject *pfObject;

@property UIImageView *shutterTransitionView;
@property DGRCompleteViewController *completeViewController;

@property BOOL type1; // complete slide
@property BOOL type2; // complete one

-(void)setFirstImage;

@end
