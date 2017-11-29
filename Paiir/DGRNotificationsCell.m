//
//  DGRNotificationsCell.m
//  Paiir
//
//  Created by Moritz Kremb on 10/11/14.
//  Copyright (c) 2014 Kremb. All rights reserved.
//

#import "DGRNotificationsCell.h"

@implementation DGRNotificationsCell

-(IBAction)thumbnailButtonAction:(id)sender {
    [self.delegate didTapThumbnailButton:self.indexPath];
}

@end
