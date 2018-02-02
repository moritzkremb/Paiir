//
//  DGRCameraViewController.h
//  Paiir
//
//  Created by Moritz Kremb on 20/04/14.
//  Copyright (c) 2014 Kremb. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DGRCameraViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIViewControllerTransitioningDelegate>

@property (nonatomic) UIImagePickerController *imagePickerController;
@property UIImageView *shutterTransitionView;

@end
