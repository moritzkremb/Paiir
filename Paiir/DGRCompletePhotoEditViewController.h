//
//  DGRCompletePhotoEditViewController.h
//  Duogram
//
//  Created by Moritz Kremb on 26/04/14.
//  Copyright (c) 2014 Kremb. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Parse/Parse.h"
#import "DGRCompleteCameraViewController.h"
#import <AviarySDK/AviarySDK.h>

@interface DGRCompletePhotoEditViewController : UIViewController <AVYPhotoEditorControllerDelegate>

-(void)setPhoto:(UIImage *)unfilteredImage orientation:(UIImageOrientation)imageOrientation;

@property (strong, nonatomic) IBOutlet UILabel *completeUser;

@property (strong, nonatomic) PFObject *pfObject;

@property (nonatomic) BOOL isFromCrop;

@property DGRCompleteCameraViewController *delegate;


@end
