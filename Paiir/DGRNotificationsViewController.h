//
//  DGRNotificationsViewController.h
//  Paiir
//
//  Created by Moritz Kremb on 10/11/14.
//  Copyright (c) 2014 Kremb. All rights reserved.
//

#import <Parse/Parse.h>
#import "DGRNotificationsCell.h"

@interface DGRNotificationsViewController : PFQueryTableViewController <DGRNotificationsCellProtocol>

@end
