//
//  DGRFindFriendsCell.h
//  Paiir
//
//  Created by Moritz Kremb on 01/10/14.
//  Copyright (c) 2014 Kremb. All rights reserved.
//

#import <Parse/Parse.h>

@class DGRFindFriendsCell;

@protocol DGRFindFriendsCellProtocol

- (void)didTapHighlightButton:(PFUser *)user;
- (void)didTapFollowButton:(DGRFindFriendsCell *)cell;

@end

@interface DGRFindFriendsCell : PFTableViewCell <UIScrollViewDelegate>

// scroll view and subviews
@property (weak, nonatomic) UIScrollView *scrollView;
@property (weak, nonatomic) UIView *scrollViewContentView;
@property (weak, nonatomic) UIView *scrollViewButtonView;

// standard view
@property (weak, nonatomic) UILabel *followingUser;
@property (weak, nonatomic) UILabel *paiirScoreLabel;
@property (weak, nonatomic) UILabel *instructionsLabel;
@property (weak, nonatomic) PFImageView *profilePictureView;
@property (strong, nonatomic) UIButton *todayButton;
@property (strong, nonatomic) UIButton *highlightButton;

// button view
@property (strong, nonatomic) UIButton *followButton;

// other
@property (nonatomic) PFUser *thisUser;
@property (nonatomic) UITableView *tableView;
@property (nonatomic, strong) id<DGRFindFriendsCellProtocol> delegate;

// methods
- (void)highlightHighlightButton;
- (void)disableHighlightButton;



@end
