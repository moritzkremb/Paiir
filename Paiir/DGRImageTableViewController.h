//
//  DGRImageTableViewController.h
//  Paiir
//
//  Created by Moritz Kremb on 27/11/14.
//  Copyright (c) 2014 Kremb. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DGRHomeViewController.h"
#import "DGRHighlightsViewController.h"

@interface DGRImageTableViewController : UITableViewController <UIActionSheetDelegate, UIAlertViewDelegate>

// photo Objects
@property (nonatomic, retain) NSMutableArray *photoObjects;

@property BOOL moreOptionsType1; // personal
@property BOOL moreOptionsType2; // highlights
@property BOOL moreOptionsType3; // other

@property NSInteger highlightRemovalCount;

@property DGRHomeViewController *homeDelegate;
@property DGRHighlightsViewController *highlightDelegate;

@end
