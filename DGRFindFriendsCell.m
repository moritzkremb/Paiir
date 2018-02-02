//
//  DGRFindFriendsCell.m
//  Paiir
//
//  Created by Moritz Kremb on 01/10/14.
//  Copyright (c) 2014 Kremb. All rights reserved.
//

#import "DGRFindFriendsCell.h"
#import "DGRConstants.h"

@implementation DGRFindFriendsCell

-(id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enclosingTableViewDidScroll) name:@"DGRFindFriendsCellEnclosingTableViewDidBeginScrollingNotification" object:nil];
        
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
        
        UIButton *followButton = [UIButton buttonWithType:UIButtonTypeCustom];
        followButton.backgroundColor = [UIColor colorWithRed:0.2f green:1.0f blue:0.188f alpha:1.0f];
        followButton.frame = CGRectMake(0, 0, kCatchWidth, CGRectGetHeight(self.bounds));
        [followButton setTitle:@"Follow" forState:UIControlStateNormal];
        followButton.titleLabel.font = [UIFont fontWithName:@"Avenir Next" size:18];
        [followButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [followButton addTarget:self action:@selector(followButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        self.followButton = followButton;
        [self.scrollViewButtonView addSubview:followButton];
        
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
        
        UILabel *instructionsLabel = [[UILabel alloc] initWithFrame:CGRectMake(75, 35, 200, 15)];
        [instructionsLabel setFont:[UIFont fontWithName:@"Avenir Next" size:12.0f]];
        [instructionsLabel setTextColor:[UIColor grayColor]];
        [instructionsLabel setText:@"Swipe to follow, Tap for highlights"];
        self.instructionsLabel = instructionsLabel;
        [self.scrollViewContentView addSubview:instructionsLabel];
        
        UILabel *paiirScoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(75, 70, 145, 15)];
        [paiirScoreLabel setFont:[UIFont fontWithName:@"Avenir Next" size:12.0f]];
        [paiirScoreLabel setTextColor:[UIColor grayColor]];
        self.paiirScoreLabel = paiirScoreLabel;
        [self.scrollViewContentView addSubview:paiirScoreLabel];
        
        UIButton *highlightButton = [UIButton buttonWithType:UIButtonTypeCustom];
        highlightButton.frame = CGRectMake(320, 0, CGRectGetHeight(self.bounds), CGRectGetHeight(self.bounds));
        [highlightButton setImage:[UIImage imageNamed:@"SavedButtonHighlighted.png"] forState:UIControlStateNormal];
        [highlightButton setImage:[UIImage imageNamed:@"SavedButton.png"] forState:UIControlStateDisabled];
        [highlightButton addTarget:self action:@selector(highlightButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        self.highlightButton = highlightButton;
        [self.scrollViewContentView addSubview:highlightButton];
        
    }
    
    return self;
    
}

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enclosingTableViewDidScroll) name:@"DGRFindFriendsCellEnclosingTableViewDidBeginScrollingNotification" object:nil];
        
        UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 320, 60)];
        scrollView.contentSize = CGSizeMake(320 + kCatchWidth, 60);
        scrollView.contentOffset = CGPointMake(kCatchWidth, 0);
        scrollView.delegate = self;
        scrollView.showsHorizontalScrollIndicator = NO;
        
        [self.contentView addSubview:scrollView];
        self.scrollView = scrollView;
        
        UIView *scrollViewButtonView = [[UIView alloc] initWithFrame:CGRectMake(kCatchWidth, 0, kCatchWidth, 60)];
        self.scrollViewButtonView = scrollViewButtonView;
        [self.scrollView addSubview:scrollViewButtonView];
        
        UIButton *followButton = [UIButton buttonWithType:UIButtonTypeCustom];
        followButton.backgroundColor = [UIColor colorWithRed:0.2f green:1.0f blue:0.188f alpha:1.0f];
        followButton.frame = CGRectMake(0, 0, kCatchWidth, 60);
        [followButton setTitle:@"Follow" forState:UIControlStateNormal];
        followButton.titleLabel.font = [UIFont fontWithName:@"Avenir Next" size:18];
        [followButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [followButton addTarget:self action:@selector(followButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        self.followButton = followButton;
        [self.scrollViewButtonView addSubview:followButton];
        
        UIView *scrollViewContentView = [[UIView alloc] initWithFrame:CGRectMake(kCatchWidth, 0, 320, 60)];
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
        
        UILabel *instructionsLabel = [[UILabel alloc] initWithFrame:CGRectMake(75, 35, 200, 15)];
        [instructionsLabel setFont:[UIFont fontWithName:@"Avenir Next" size:12.0f]];
        [instructionsLabel setTextColor:[UIColor grayColor]];
        [instructionsLabel setText:@"Swipe to follow, Tap for highlights"];
        self.instructionsLabel = instructionsLabel;
        [self.scrollViewContentView addSubview:instructionsLabel];
        
        UILabel *paiirScoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(75, 70, 145, 15)];
        [paiirScoreLabel setFont:[UIFont fontWithName:@"Avenir Next" size:12.0f]];
        [paiirScoreLabel setTextColor:[UIColor grayColor]];
        self.paiirScoreLabel = paiirScoreLabel;
        [self.scrollViewContentView addSubview:paiirScoreLabel];
        
        UIButton *highlightButton = [UIButton buttonWithType:UIButtonTypeCustom];
        highlightButton.frame = CGRectMake(320, 0, 60, 60);
        [highlightButton setImage:[UIImage imageNamed:@"SavedButtonHighlighted.png"] forState:UIControlStateNormal];
        [highlightButton setImage:[UIImage imageNamed:@"SavedButton.png"] forState:UIControlStateDisabled];
        [highlightButton addTarget:self action:@selector(highlightButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        self.highlightButton = highlightButton;
        [self.scrollViewContentView addSubview:highlightButton];
        
    }
    
    return self;
    
}

- (void)highlightButtonAction:(id)sender {
    [self.delegate didTapHighlightButton:self.thisUser];
}

- (void)followButtonAction:(id)sender {
    [self.delegate didTapFollowButton:self];
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
                         self.instructionsLabel.frame = CGRectMake(75, 70, 200, 15);
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
                                                  self.instructionsLabel.frame = CGRectMake(75, 35, 200, 15);
                                                  
                                              }
                                              completion:^(BOOL finished){
                                                  self.followingUser.userInteractionEnabled = YES;
                                              }];
                         }];

    }
    
}


#pragma mark - scroll view

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.contentOffset.x > kCatchWidth) {
        scrollView.contentOffset = CGPointMake(kCatchWidth, 0);
    }
    if (scrollView.contentOffset.x < 0) {
        scrollView.contentOffset = CGPointMake(0, 0);
    }
    
    self.scrollViewButtonView.frame = CGRectMake(scrollView.contentOffset.x, 0.0f, kCatchWidth, CGRectGetHeight(self.bounds));
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    if (scrollView.contentOffset.x <= 0) {
        targetContentOffset->x = 0;
    }
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
