//
//  DGRCameraNewViewController.h
//  Duogram1
//
//  Created by Kira Hentschel on 26/3/14.
//  Copyright (c) 2014 Kremb. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DGRCameraViewController.h"
#import <AviarySDK/AviarySDK.h>

@interface DGRPhotoEditViewController : UIViewController <AVYPhotoEditorControllerDelegate>

-(void)setPhoto:(UIImage *)image orientation:(UIImageOrientation)photoOrientation;
@property (nonatomic) BOOL isFromCrop;
@property DGRCameraViewController *delegate;

@end
