//
//  DGRInviteFriendsCell.h
//  Paiir
//
//  Created by Moritz Kremb on 17/10/14.
//  Copyright (c) 2014 Kremb. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DGRInviteFriendsCell;

@protocol DGRInviteFriendsCellProtocol

-(void)didTapInviteFriends;

@end

@interface DGRInviteFriendsCell : UITableViewCell

@property (nonatomic, strong) id<DGRInviteFriendsCellProtocol> delegate;

@end
