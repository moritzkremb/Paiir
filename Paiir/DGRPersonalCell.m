//
//  DGRPersonalCell.m
//  Paiir
//
//  Created by Moritz Kremb on 01/10/14.
//  Copyright (c) 2014 Kremb. All rights reserved.
//

#import "DGRPersonalCell.h"

@implementation DGRPersonalCell

-(id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        //UITapGestureRecognizer *changeButtonTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(changeButton)];
        //[self.contentView addGestureRecognizer:changeButtonTap];

    }
    return self;
}
-(void)awakeFromNib {
    UITapGestureRecognizer *changeButtonTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(changeButton)];
    [self.username addGestureRecognizer:changeButtonTap];
}

- (IBAction)todayButtonAction:(id)sender {
    [self.delegate didTapPersonalTodayButton:sender];
}

- (IBAction)highlightButtonAction:(id)sender {
    [self.delegate didTapPersonalHighlightButton:sender];
}


-(void)highlightRecentButton:(UIImage*)thumbnail{
    
    [self.todayButton setImage:thumbnail forState:UIControlStateNormal];
    self.todayButton.imageView.layer.cornerRadius = 5.0f;
    self.todayButton.imageView.clipsToBounds = YES;

    [self.todayButton setEnabled:YES];
    
}

-(void)disableRecentButton {
    
    [self.todayButton setEnabled:NO];
    
}

-(void)highlightHighlightButton {
    
    [self.highlightButton setEnabled:YES];
}

-(void)disableHighlightButton {
    
    [self.highlightButton setEnabled:NO];
}

-(void)changeButton {
    NSLog(@"Cell selected");
    
    self.username.userInteractionEnabled = NO;
    
    [UIView animateWithDuration:0.2f
                     animations:^{
                         self.todayButton.frame = CGRectMake(320, 10, 30, 50);
                         self.followersLabel.frame = CGRectMake(75, 70, 160, 15);
                     }
                     completion:^(BOOL finished){
                         
                         [UIView animateWithDuration:0.2f
                                          animations:^{
                                              self.highlightButton.frame = CGRectMake(235, 5, 60, 60);
                                              self.paiirScoreLabel.frame = CGRectMake(75, 50, 160, 15);
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
    if (self.username.userInteractionEnabled == NO) {
        [UIView animateWithDuration:0.2f
                         animations:^{
                             self.highlightButton.frame = CGRectMake(320, 0, 60, 60);
                             self.paiirScoreLabel.frame = CGRectMake(75, 70, 160, 15);
                             
                         }
                         completion:^(BOOL finished){
                             [UIView animateWithDuration:0.2f
                                              animations:^{
                                                  self.todayButton.frame = CGRectMake(250, 10, 30, 50);
                                                  self.followersLabel.frame = CGRectMake(75, 50, 160, 15);
                                                  
                                              }
                                              completion:^(BOOL finished){
                                                  self.username.userInteractionEnabled = YES;

                                              }];
                         }];

    }
    
}


@end
