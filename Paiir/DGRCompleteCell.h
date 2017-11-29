//
//  DGRConnectCell.h
//  Duogram1
//
//  Created by Moritz Kremb on 3/3/14.
//  Copyright (c) 2014 Kremb. All rights reserved.
//

#import <Parse/Parse.h>

@protocol DGRCompleteCellProtocol;

@interface DGRCompleteCell : PFTableViewCell

@property (weak, nonatomic) IBOutlet PFImageView *customImage;
@property (weak, nonatomic) IBOutlet UILabel *user1;
@property (weak, nonatomic) IBOutlet UILabel *time;
@property (weak, nonatomic) IBOutlet UILabel *paiirCount;

@property (nonatomic) PFObject *uPhotoObject;

@property (nonatomic, strong) id<DGRCompleteCellProtocol> delegate;

-(void)hideLabels;

@end

@protocol DGRCompleteCellProtocol

@end
