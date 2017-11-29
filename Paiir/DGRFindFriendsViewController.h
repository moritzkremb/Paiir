//
//  DGRFindFriendsViewController.h
//  Paiir
//
//  Created by Moritz Kremb on 19/09/14.
//  Copyright (c) 2014 Kremb. All rights reserved.
//

#import <Parse/Parse.h>
#import "DGRFindFriendsCell.h"

@interface DGRFindFriendsViewController : PFQueryTableViewController <DGRFindFriendsCellProtocol, UITableViewDelegate>

@end
