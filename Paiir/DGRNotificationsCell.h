//
//  DGRNotificationsCell.h
//  Paiir
//
//  Created by Moritz Kremb on 10/11/14.
//  Copyright (c) 2014 Kremb. All rights reserved.
//

#import <Parse/Parse.h>

@class DGRNotificationsCell;

@protocol DGRNotificationsCellProtocol

- (void)didTapThumbnailButton:(NSIndexPath*)indexPath;

@end

@interface DGRNotificationsCell : PFTableViewCell

// view
@property (weak, nonatomic) IBOutlet PFImageView *profilePictureView;
@property (weak, nonatomic) IBOutlet UIButton *thumbnailButton;
@property (weak, nonatomic) IBOutlet UILabel *notificationsLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

// delegate
@property (nonatomic, strong) id<DGRNotificationsCellProtocol> delegate;
@property NSIndexPath *indexPath;

@end
