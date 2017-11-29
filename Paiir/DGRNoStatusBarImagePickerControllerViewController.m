//
//  DGRNoStatusBarImagePickerControllerViewController.m
//  Duogram1
//
//  Created by Kira Hentschel on 1/4/14.
//  Copyright (c) 2014 Kremb. All rights reserved.
//

#import "DGRNoStatusBarImagePickerControllerViewController.h"

@interface DGRNoStatusBarImagePickerControllerViewController ()

@end

@implementation DGRNoStatusBarImagePickerControllerViewController

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
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
