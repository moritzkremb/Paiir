//
//  DGRHomeCell.h
//  Duogram1
//
//  Created by Moritz Kremb on 3/3/14.
//  Copyright (c) 2014 Kremb. All rights reserved.
//

#import <Parse/Parse.h>

@class DGRHomeCell;

@protocol DGRHomeCellProtocol

- (void)didTapTodayButton:(PFUser *)user withRecognizer:(UITapGestureRecognizer *)sender;
- (void)didTapHighlightButton:(PFUser *)user withRecognizer:(UITapGestureRecognizer *)sender;
- (void)didTapUnfollowButton:(DGRHomeCell *)cell;

@end

@interface DGRHomeCell : PFTableViewCell <UIScrollViewDelegate>

// scroll view and subviews
@property (weak, nonatomic) UIScrollView *scrollView;
@property (weak, nonatomic) UIView *scrollViewContentView;
@property (weak, nonatomic) UIView *scrollViewButtonView;

// standard view
@property (weak, nonatomic) UILabel *followingUser;
@property (weak, nonatomic) UILabel *paiirScoreLabel;
@property (weak, nonatomic) UILabel *paiirsAndHighlightsLabel;
@property (weak, nonatomic) PFImageView *profilePictureView;
@property (strong, nonatomic) UIButton *todayButton;
@property (strong, nonatomic) UIButton *highlightButton;

// button view
@property (strong, nonatomic) UIButton *unfollowButton;

// other
@property (nonatomic) PFUser *thisUser;
@property (nonatomic) BOOL isInRecent;
@property (nonatomic, strong) id<DGRHomeCellProtocol> delegate;

// methods
- (void)highlightRecentButton:(UIImage*)thumbnail;
- (void)disableRecentButton;
- (void)highlightHighlightButton;
- (void)disableHighlightButton;

@end


