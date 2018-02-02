//
//  DGRConnectCell.m
//  Duogram1
//
//  Created by Moritz Kremb on 3/3/14.
//  Copyright (c) 2014 Kremb. All rights reserved.
//

#import "DGRCompleteCell.h"

@implementation DGRCompleteCell

-(id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        
    }
    return self;
}

-(void)awakeFromNib {
    
    // causes ui to be slow
    /*
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        self.time.hidden = YES;
        self.paiirCount.hidden = YES;
        
        UITapGestureRecognizer *showLabelsTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showLabels)];
        [self.customImage addGestureRecognizer:showLabelsTap];
        self.customImage.userInteractionEnabled = YES;
        
    });
    */
}
/*
-(void)showLabels {
    NSLog(@"Cell selected");
    
    self.customImage.userInteractionEnabled = NO;
    self.time.alpha = 0.0;
    self.paiirCount.alpha = 0.0;
    self.time.hidden = NO;
    self.paiirCount.hidden = NO;
    
    [UIView animateWithDuration:0.2f
                     animations:^{
                         self.time.alpha = 1.0;
                         self.paiirCount.alpha = 1.0;
                     }
                     completion:^(BOOL finished){
                         
                         [NSTimer scheduledTimerWithTimeInterval:2
                                                          target:self
                                                        selector:@selector(hideLabels)
                                                        userInfo:nil
                                                         repeats:NO];
                         
                     }];

}
 */

-(void)hideLabels {
    
        [UIView animateWithDuration:0.2f
                         animations:^{
                             self.time.alpha = 0.0;
                             self.paiirCount.alpha = 0.0;
                         }
                         completion:^(BOOL finished){
                             self.time.hidden = YES;
                             self.paiirCount.hidden = YES;
                        }];
        
    

}

@end
