//
//  DGRRecentCell.h
//  Paiir
//
//  Created by Moritz Kremb on 18/10/14.
//  Copyright (c) 2014 Kremb. All rights reserved.
//

#import <Parse/Parse.h>

@interface DGRRecentCell : PFTableViewCell

@property (strong, nonatomic) IBOutlet UIButton *recentButton;
@property (strong, nonatomic) IBOutlet UIButton *staffpickButton;

// methods
- (void)highlightTodayButton;
- (void)disableTodayButton;

@end

