//
//  DGRHomeViewController.h
//  Paiir
//
//  Created by Moritz Kremb on 1/3/14.
//  Copyright (c) 2014 Kremb. All rights reserved.
//

#import "Parse/Parse.h"
#import <UIKit/UIKit.h>
#import "DGRHomeCell.h"
#import "DGRPersonalCell.h"
#import "DGRRecentCell.h"
#import "DGRInviteFriendsCell.h"


@interface DGRHomeViewController : PFQueryTableViewController <DGRHomeCellProtocol, DGRPersonalCellProtocol, DGRInviteFriendsCellProtocol, UIAlertViewDelegate, UIViewControllerTransitioningDelegate>

@property CGPoint touchOnScreen;

@property (nonatomic, retain) NSMutableDictionary *userToTodayPhotos;

@end
