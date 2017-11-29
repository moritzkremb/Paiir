//
//  DGRPageViewContentViewController.h
//  Paiir
//
//  Created by Moritz Kremb on 05/10/14.
//  Copyright (c) 2014 Kremb. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DGRPageViewContentViewController : UIViewController

@property (nonatomic, weak) IBOutlet UIImageView *backgroundImageView;
@property NSUInteger pageIndex;
@property NSString *imageFile;


@end
