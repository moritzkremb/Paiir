//
//  DGRPageViewContentViewController.m
//  Paiir
//
//  Created by Moritz Kremb on 05/10/14.
//  Copyright (c) 2014 Kremb. All rights reserved.
//

#import "DGRPageViewContentViewController.h"

@interface DGRPageViewContentViewController ()

@end

@implementation DGRPageViewContentViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.backgroundImageView.image = [UIImage imageNamed:self.imageFile];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
