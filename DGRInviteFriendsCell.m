//
//  DGRInviteFriendsCell.m
//  Paiir
//
//  Created by Moritz Kremb on 17/10/14.
//  Copyright (c) 2014 Kremb. All rights reserved.
//

#import "DGRInviteFriendsCell.h"

@implementation DGRInviteFriendsCell

- (IBAction)inviteFriendsButtonAction:(id)sender {
    [self.delegate didTapInviteFriends];
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
