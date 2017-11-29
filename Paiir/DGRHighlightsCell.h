//
//  DGRHighlightsCell.h
//  Paiir
//
//  Created by Moritz Kremb on 09/10/14.
//  Copyright (c) 2014 Kremb. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface DGRHighlightsCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet PFImageView *image1;
@property (weak, nonatomic) IBOutlet PFImageView *image2;

@end
