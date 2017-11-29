//
//  DGRLibraryCropViewController.h
//  Paiir
//
//  Created by Moritz Kremb on 25/09/14.
//  Copyright (c) 2014 Kremb. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "DGRCameraViewController.h"
#import "DGRCompleteCameraViewController.h"

@interface DGRLibraryCropViewController : UIViewController <UIScrollViewDelegate>

-(void)setPhoto:(UIImage *)imageToCrop;

@property (nonatomic) BOOL isFromComplete;
@property (nonatomic) PFObject *pfObject;

@property DGRCompleteCameraViewController *completeDelegate;
@property DGRCameraViewController *cameraDelegate;

@end
