//
//  DGRHomeCell.m
//  Duogram1
//
//  Created by Moritz Kremb on 3/3/14.
//  Copyright (c) 2014 Kremb. All rights reserved.
//

#import "DGRHomeCell.h"
#import "DGRConstants.h"
#import <QuartzCore/QuartzCore.h>

@implementation DGRHomeCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    }
    
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enclosingTableViewDidScroll) name:@"DGRHomeCellEnclosingTableViewDidBeginScrollingNotification" object:nil];
        
        UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds))];
        scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.bounds) + kCatchWidth, CGRectGetHeight(self.bounds));
        scrollView.contentOffset = CGPointMake(kCatchWidth, 0);
        scrollView.delegate = self;
        scrollView.showsHorizontalScrollIndicator = NO;
        
        [self.contentView addSubview:scrollView];
        self.scrollView = scrollView;
        
        UIView *scrollViewButtonView = [[UIView alloc] initWithFrame:CGRectMake(kCatchWidth, 0, kCatchWidth, CGRectGetHeight(self.bounds))];
        self.scrollViewButtonView = scrollViewButtonView;
        [self.scrollView addSubview:scrollViewButtonView];
        
        UIButton *unfollowButton = [UIButton buttonWithType:UIButtonTypeCustom];
        unfollowButton.backgroundColor = [UIColor colorWithRed:1.0f green:0.231f blue:0.188f alpha:1.0f];
        unfollowButton.frame = CGRectMake(0, 0, kCatchWidth, CGRectGetHeight(self.bounds));
        [unfollowButton setTitle:@"Unfollow" forState:UIControlStateNormal];
        unfollowButton.titleLabel.font = [UIFont fontWithName:@"Avenir Next" size:18];
        [unfollowButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [unfollowButton addTarget:self action:@selector(unfollowButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        self.unfollowButton = unfollowButton;
        [self.scrollViewButtonView addSubview:unfollowButton];
   
        
        UIView *scrollViewContentView = [[UIView alloc] initWithFrame:CGRectMake(kCatchWidth, 0, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds))];
        scrollViewContentView.backgroundColor = [UIColor whiteColor];
        [self.scrollView addSubview:scrollViewContentView];
        self.scrollViewContentView = scrollViewContentView;
        
        PFImageView *profileView = [[PFImageView alloc] initWithFrame:CGRectMake(15, 5, 50, 50)];
        [profileView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"ProfilePicturePlaceholder.png"]]];
        profileView.contentMode = UIViewContentModeScaleAspectFill;
        profileView.layer.cornerRadius = 25.0f;
        profileView.clipsToBounds = YES;
        self.profilePictureView = profileView;
        [self.scrollViewContentView addSubview:profileView];
        
        UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(75, 8, 145, 30)];
        [nameLabel setFont:[UIFont fontWithName:@"Avenir Next" size:18.0f]];
        nameLabel.userInteractionEnabled = YES;
        self.followingUser = nameLabel;
        [self.scrollViewContentView addSubview:nameLabel];
        
        UITapGestureRecognizer *changeButtonTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(changeButton)];
        [self.followingUser addGestureRecognizer:changeButtonTap];
        
        UILabel *paiirsAndHighlightsLabel = [[UILabel alloc] initWithFrame:CGRectMake(75, 35, 145, 15)];
        [paiirsAndHighlightsLabel setFont:[UIFont fontWithName:@"Avenir Next" size:12.0f]];
        [paiirsAndHighlightsLabel setTextColor:[UIColor grayColor]];
        self.paiirsAndHighlightsLabel = paiirsAndHighlightsLabel;
        [self.scrollViewContentView addSubview:paiirsAndHighlightsLabel];
        
        UILabel *paiirScoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(75, 70, 145, 15)];
        [paiirScoreLabel setFont:[UIFont fontWithName:@"Avenir Next" size:12.0f]];
        [paiirScoreLabel setTextColor:[UIColor grayColor]];
        self.paiirScoreLabel = paiirScoreLabel;
        [self.scrollViewContentView addSubview:paiirScoreLabel];
        
        UIButton *todayButton = [UIButton buttonWithType:UIButtonTypeCustom];
        todayButton.frame = CGRectMake(250, 5, 30, 50);
        [todayButton setImage:[UIImage imageNamed:@"MoreOptionsButtonEmpty.png"] forState:UIControlStateDisabled];
        //[todayButton setImage:[UIImage imageNamed:@"TodayButtonHighlighted.png"] forState:UIControlStateNormal];
        //[todayButton setImage:[UIImage imageNamed:@"TodayButton.png"] forState:UIControlStateDisabled];
        self.todayButton = todayButton;
        [self.scrollViewContentView addSubview:todayButton];
        
        UITapGestureRecognizer *todayTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTodayTap:)];
        [self.todayButton addGestureRecognizer:todayTap];

        UIButton *highlightButton = [UIButton buttonWithType:UIButtonTypeCustom];
        highlightButton.frame = CGRectMake(320, 0, CGRectGetHeight(self.bounds), CGRectGetHeight(self.bounds));
        [highlightButton setImage:[UIImage imageNamed:@"SavedButtonHighlighted.png"] forState:UIControlStateNormal];
        [highlightButton setImage:[UIImage imageNamed:@"SavedButton.png"] forState:UIControlStateDisabled];
        //[highlightButton setImage:[UIImage imageNamed:@"MoreOptionsButtonEmpty.png"] forState:UIControlStateDisabled];
        [highlightButton setEnabled:NO];
        self.highlightButton = highlightButton;
        [self.scrollViewContentView addSubview:highlightButton];
        
        UITapGestureRecognizer *highlightTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleHighlightTap:)];
        [self.highlightButton addGestureRecognizer:highlightTap];

    }
    
    return self;

}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];

    if (self) {
        
        // being used on myFollowers page
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enclosingTableViewDidScroll) name:@"DGRHomeCellEnclosingTableViewDidBeginScrollingNotification" object:nil];
        
        UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.bounds), 60)];
        scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.bounds) + kCatchWidth, 60);
        scrollView.contentOffset = CGPointMake(kCatchWidth, 0);
        scrollView.delegate = self;
        scrollView.showsHorizontalScrollIndicator = NO;
        
        [self.contentView addSubview:scrollView];
        self.scrollView = scrollView;
        
        UIView *scrollViewButtonView = [[UIView alloc] initWithFrame:CGRectMake(kCatchWidth, 0, kCatchWidth, 60)];
        self.scrollViewButtonView = scrollViewButtonView;
        [self.scrollView addSubview:scrollViewButtonView];
        
        UIButton *unfollowButton = [UIButton buttonWithType:UIButtonTypeCustom];
        unfollowButton.backgroundColor = [UIColor colorWithRed:1.0f green:0.231f blue:0.188f alpha:1.0f];
        unfollowButton.frame = CGRectMake(0, 0, kCatchWidth, 60);
        [unfollowButton setTitle:@"Unfollow" forState:UIControlStateNormal];
        unfollowButton.titleLabel.font = [UIFont fontWithName:@"Avenir Next" size:18];
        [unfollowButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [unfollowButton addTarget:self action:@selector(unfollowButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        self.unfollowButton = unfollowButton;
        [self.scrollViewButtonView addSubview:unfollowButton];
        
        UIView *scrollViewContentView = [[UIView alloc] initWithFrame:CGRectMake(kCatchWidth, 0, CGRectGetWidth(self.bounds), 60)];
        scrollViewContentView.backgroundColor = [UIColor whiteColor];
        [self.scrollView addSubview:scrollViewContentView];
        self.scrollViewContentView = scrollViewContentView;
        
        PFImageView *profileView = [[PFImageView alloc] initWithFrame:CGRectMake(15, 5, 50, 50)];
        [profileView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"ProfilePicturePlaceholder.png"]]];
        profileView.contentMode = UIViewContentModeScaleAspectFill;
        profileView.layer.cornerRadius = 25.0f;
        profileView.clipsToBounds = YES;
        self.profilePictureView = profileView;
        [self.scrollViewContentView addSubview:profileView];
        
        UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(75, 8, 145, 30)];
        [nameLabel setFont:[UIFont fontWithName:@"Avenir Next" size:18.0f]];
        self.followingUser = nameLabel;
        [self.scrollViewContentView addSubview:nameLabel];
        
        UILabel *paiirScoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(75, 35, 145, 15)];
        [paiirScoreLabel setFont:[UIFont fontWithName:@"Avenir Next" size:12.0f]];
        [paiirScoreLabel setTextColor:[UIColor grayColor]];
        self.paiirScoreLabel = paiirScoreLabel;
        [self.scrollViewContentView addSubview:paiirScoreLabel];
        
    }
    return self;
}
 

- (void)handleTodayTap:(UITapGestureRecognizer *)sender {
    [self.delegate didTapTodayButton:self.thisUser withRecognizer:sender];
}

-(void)handleHighlightTap:(UITapGestureRecognizer *)sender {
    [self.delegate didTapHighlightButton:self.thisUser withRecognizer:sender];
}

- (void)unfollowButtonAction:(id)sender {
    [self.delegate didTapUnfollowButton:self];
}

-(void)highlightRecentButton:(UIImage*)thumbnail {
    
    [self.todayButton setImage:thumbnail forState:UIControlStateNormal];
    self.todayButton.imageView.layer.cornerRadius = 5.0f;
    self.todayButton.imageView.clipsToBounds = YES;
    
    //self.todayButton.imageView.layer.borderWidth = 2.0f;
    //self.todayButton.imageView.layer.borderColor = [UIColor orangeColor].CGColor;
    
    /*
    if (photoNumber > 99) {
        [self.todayButton setTitle:@"+" forState:UIControlStateNormal];

    } else [self.todayButton setTitle:[NSString stringWithFormat:@"%ld", (long)photoNumber] forState:UIControlStateNormal];
    

    [self.todayButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    [self.todayButton setImageEdgeInsets:UIEdgeInsetsMake(0.0, 0.0, 0.0, -9.0)];
    [self.todayButton setTitleEdgeInsets:UIEdgeInsetsMake(0.0, -60.0, 0.0, 0.0)];
    */
    
    [self.todayButton setEnabled:YES];

    
}

-(void)disableRecentButton {
    [self.todayButton setEnabled:NO];

    /*
    [self.todayButton setTitle:[NSString stringWithFormat:@""] forState:UIControlStateNormal];
    
    [self.todayButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    if ([self.todayButton isEnabled]) {
        [self.todayButton setImageEdgeInsets:UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)];
        [self.todayButton setTitleEdgeInsets:UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)];
    }
    */
}

-(void)highlightHighlightButton {

    [self.highlightButton setEnabled:YES];
}

-(void)disableHighlightButton {

    [self.highlightButton setEnabled:NO];
}

-(void)changeButton {
    NSLog(@"Cell selected");
    
    self.followingUser.userInteractionEnabled = NO;
    
    [UIView animateWithDuration:0.2f
                     animations:^{
                         self.todayButton.frame = CGRectMake(320, 5, 30, 50);
                         self.paiirsAndHighlightsLabel.frame = CGRectMake(75, 70, 145, 15);
                     }
                     completion:^(BOOL finished){
                         
                         [UIView animateWithDuration:0.2f
                                          animations:^{
                                              self.highlightButton.frame = CGRectMake(235, 0, 60, 60);
                                              self.paiirScoreLabel.frame = CGRectMake(75, 35, 145, 15);
                                          }
                                          completion:^(BOOL finished){
                                              
                                              [NSTimer scheduledTimerWithTimeInterval:2
                                                                               target:self
                                                                             selector:@selector(changeButtonBack)
                                                                             userInfo:nil
                                                                              repeats:NO];

                                              
                                          }];
                         
                     }];
    
}

-(void)changeButtonBack {
    if (self.followingUser.userInteractionEnabled == NO) {
        [UIView animateWithDuration:0.2f
                         animations:^{
                             self.highlightButton.frame = CGRectMake(320, 0, 60, 60);
                             self.paiirScoreLabel.frame = CGRectMake(75, 70, 145, 15);
                         }
                         completion:^(BOOL finished){
                             [UIView animateWithDuration:0.2f
                                              animations:^{
                                                  self.todayButton.frame = CGRectMake(250, 5, 30, 50);
                                                  self.paiirsAndHighlightsLabel.frame = CGRectMake(75, 35, 145, 15);
                                                  
                                              }
                                              completion:^(BOOL finished){
                                                  self.followingUser.userInteractionEnabled = YES;
                                                  
                                              }];
                         }];
        
    }
    
}

#pragma mark - scroll view

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    // left scroll border
    if (scrollView.contentOffset.x > kCatchWidth) {
        scrollView.contentOffset = CGPointMake(kCatchWidth, 0);
    }
    // right scroll border
    if (scrollView.contentOffset.x < 0) {
        scrollView.contentOffset = CGPointMake(0, 0);
    }
    
    // shift button out underneath while scrolling
    self.scrollViewButtonView.frame = CGRectMake(scrollView.contentOffset.x, 0.0f, kCatchWidth, CGRectGetHeight(self.bounds));
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    // make it stop at the end
    if (scrollView.contentOffset.x <= 0) {
        targetContentOffset->x = 0;
    }
    // make it jump back if its not scrolled all the way
    else {
        *targetContentOffset = CGPointMake(kCatchWidth, 0);
        
        // Need to call this subsequently to remove flickering.
        dispatch_async(dispatch_get_main_queue(), ^{
            [scrollView setContentOffset:CGPointMake(kCatchWidth, 0) animated:YES];
        });
    }
}

-(void)enclosingTableViewDidScroll {
    [self.scrollView setContentOffset:CGPointMake(kCatchWidth, 0) animated:YES];
}
@end
