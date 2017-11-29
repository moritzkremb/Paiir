//
//  DGRHighlightsViewController.h
//  Paiir
//
//  Created by Moritz Kremb on 09/10/14.
//  Copyright (c) 2014 Kremb. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "DGRHomeViewController.h"

@interface DGRHighlightsViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate, UIActionSheetDelegate, UIAlertViewDelegate>

@property DGRHomeViewController *delegate;

@property (nonatomic, strong) NSMutableArray *photoObjects;
@property (nonatomic, strong) NSMutableArray *singlePhotoObjects;

@property PFUser *user;

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property BOOL highlightsType1; // personal -> delete
@property BOOL highlightsType2; // following -> complete
@property BOOL highlightsType3; // not following -> alertview

@end
