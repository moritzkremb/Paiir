//
//  DGRLaunchPageViewController.h
//  Paiir
//
//  Created by Moritz Kremb on 05/12/14.
//  Copyright (c) 2014 Kremb. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DGRPageViewContentViewController.h"

@interface DGRLaunchPageViewController : UIViewController <UIPageViewControllerDataSource, UIPageViewControllerDelegate>

@property (strong, nonatomic) UIPageViewController *pageViewController;
@property (strong, nonatomic) NSArray *pageImages;

@end
