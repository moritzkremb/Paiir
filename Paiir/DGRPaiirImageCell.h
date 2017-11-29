//
//  DGRPaiirImageCell.h
//  Paiir
//
//  Created by Moritz Kremb on 27/11/14.
//  Copyright (c) 2014 Kremb. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface DGRPaiirImageCell : UITableViewCell

@property (weak, nonatomic) IBOutlet PFImageView *topImage;
@property (weak, nonatomic) IBOutlet PFImageView *bottomImage;
@property (weak, nonatomic) IBOutlet UILabel *topUser;
@property (weak, nonatomic) IBOutlet UILabel *bottomUser;


@end
