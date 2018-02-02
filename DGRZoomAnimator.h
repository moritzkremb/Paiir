//
//  DGRZoomAnimator.h
//  Paiir
//
//  Created by Moritz Kremb on 09/10/14.
//  Copyright (c) 2014 Kremb. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DGRZoomAnimator : NSObject <UIViewControllerAnimatedTransitioning>

@property BOOL isPresenting;
@property CGPoint startingLocation;

@end
