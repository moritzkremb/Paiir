//
//  DGRRecentCell.m
//  Paiir
//
//  Created by Moritz Kremb on 18/10/14.
//  Copyright (c) 2014 Kremb. All rights reserved.
//

#import "DGRRecentCell.h"

@implementation DGRRecentCell

-(id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
    }
    return self;
}
/*
-(void)awakeFromNib {
    UITapGestureRecognizer *recentTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(todayButtonAction:)];
    [self.recentButton addGestureRecognizer:recentTap];
    
    UITapGestureRecognizer *staffpickTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(staffpickButtonAction:)];
    [self.recentButton addGestureRecognizer:staffpickTap];
}

- (void)todayButtonAction:(UITapGestureRecognizer *)sender {
    [self.delegate didTapRecentTodayButtonwithRecognizer:sender];
}

-(void)staffpickButtonAction:(UITapGestureRecognizer *)sender {
    [self.delegate didTapRecentHighlightButtonwithRecognizer:sender];
}
 */

-(void)highlightTodayButton {
    
    [self.recentButton setImage:[UIImage imageNamed:@"RecentPaiirsButton.png"] forState:UIControlStateNormal];
    self.recentButton.layer.cornerRadius = 5.0f;
    self.recentButton.clipsToBounds = YES;
    
    [self.recentButton setEnabled:YES];
    
}

-(void)disableTodayButton {
    
    [self.recentButton setImage:[UIImage imageNamed:@"RecentPaiirsButton_grey.png"] forState:UIControlStateDisabled];
    self.recentButton.layer.cornerRadius = 5.0f;
    self.recentButton.clipsToBounds = YES;
    
    [self.recentButton setEnabled:NO];
    
}

@end
