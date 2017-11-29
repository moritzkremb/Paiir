//
//  DGRMyFollowersTableViewController.h
//  Paiir
//
//  Created by Moritz Kremb on 25/10/14.
//  Copyright (c) 2014 Kremb. All rights reserved.
//

#import <Parse/Parse.h>
#import "DGRHomeCell.h"
#import "DGRFindFriendsCell.h"

@interface DGRMyFollowersTableViewController : PFQueryTableViewController <DGRHomeCellProtocol, DGRFindFriendsCellProtocol>

@end
