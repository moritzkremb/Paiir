//
//  DGRPersonalCell.h
//  Paiir
//
//  Created by Moritz Kremb on 01/10/14.
//  Copyright (c) 2014 Kremb. All rights reserved.
//

#import <Parse/Parse.h>

@class DGRPersonalCell;

@protocol DGRPersonalCellProtocol

- (void)didTapPersonalTodayButton:(id)sender;
- (void)didTapPersonalHighlightButton:(id)sender;

@end

@interface DGRPersonalCell : PFTableViewCell


@property (weak, nonatomic) IBOutlet PFImageView *profilePicture;
@property (weak, nonatomic) IBOutlet UILabel *username;
@property (weak, nonatomic) IBOutlet UILabel *followersLabel;
@property (weak, nonatomic) IBOutlet UILabel *paiirScoreLabel;
@property (strong, nonatomic) IBOutlet UIButton *todayButton;
@property (weak, nonatomic) IBOutlet UILabel *todayLabel;
@property (strong, nonatomic) IBOutlet UIButton *highlightButton;

// other
@property (nonatomic, strong) id<DGRPersonalCellProtocol> delegate;

// methods
- (void)highlightRecentButton:(UIImage*)thumbnail;
- (void)disableRecentButton;
- (void)highlightHighlightButton;
- (void)disableHighlightButton;

@end
