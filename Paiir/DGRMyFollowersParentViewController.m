//
//  DGRSinglesAndFollowersViewController.m
//  Paiir
//
//  Created by Moritz Kremb on 11/11/14.
//  Copyright (c) 2014 Kremb. All rights reserved.
//

#import "DGRMyFollowersParentViewController.h"
#import "DGRMyFollowersTableViewController.h"
#import "DGRConstants.h"

@interface DGRMyFollowersParentViewController ()

// Child VCs
@property (nonatomic) DGRMyFollowersTableViewController *myFollowersVC;

// outlet
@property IBOutlet UIView *toggleView;

// actions
-(IBAction)doneButtonAction:(id)sender;

@end

@implementation DGRMyFollowersParentViewController

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (UIViewController *)childViewControllerForStatusBarHidden {
    return nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGRect frame = self.toggleView.frame;
    frame.origin.y = frame.origin.y - 44.0f;
    
    // VCs
    
    DGRMyFollowersTableViewController *myFollowersVC = (DGRMyFollowersTableViewController*)[self.storyboard instantiateViewControllerWithIdentifier:@"MyFollowersViewController"];
    myFollowersVC.view.frame = frame;
    self.myFollowersVC = myFollowersVC;
    
    // set followers first
    [self addChildViewController:myFollowersVC];
    [self.toggleView addSubview:myFollowersVC.view];
    [myFollowersVC didMoveToParentViewController:self];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)doneButtonAction:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:NULL];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DGRHomeViewControllerLoadParseObjects" object:self];
    
}
/*
- (IBAction)segmentsChangedAction:(id)sender {
    
    // my singles selected
    if (self.segmentOutlet.selectedSegmentIndex == 0) {
        [UIView animateWithDuration:0.3f animations:^{
            
            [self.myFollowersVC.view setAlpha:0.0f];
            
        } completion:^(BOOL finished) {
            
            [self.mySinglesVC.view setAlpha:0.0f];
            
            [self.myFollowersVC.view removeFromSuperview];
            [self.myFollowersVC removeFromParentViewController];
            
            [self addChildViewController:self.mySinglesVC];
            [self.toggleView addSubview:self.mySinglesVC.view];
            [self.mySinglesVC didMoveToParentViewController:self];
            
            //fade in
            [UIView animateWithDuration:0.3f animations:^{
                
                [self.mySinglesVC.view setAlpha:1.0f];
                
            } completion:nil];
            
        }];
        
    }
    
    else {
        [UIView animateWithDuration:0.3f animations:^{
            
            [self.mySinglesVC.view setAlpha:0.0f];
            
        } completion:^(BOOL finished) {
            
            [self.myFollowersVC.view setAlpha:0.0f];
            
            [self.mySinglesVC.view removeFromSuperview];
            [self.mySinglesVC removeFromParentViewController];
            
            [self addChildViewController:self.myFollowersVC];
            [self.toggleView addSubview:self.myFollowersVC.view];
            [self.myFollowersVC didMoveToParentViewController:self];
            
            //fade in
            [UIView animateWithDuration:0.3f animations:^{
                
                [self.myFollowersVC.view setAlpha:1.0f];
                
            } completion:nil];
            
        }];
        
    }

}
*/

@end
