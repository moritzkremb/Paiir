//
//  DGRZoomAnimator.m
//  Paiir
//
//  Created by Moritz Kremb on 09/10/14.
//  Copyright (c) 2014 Kremb. All rights reserved.
//

#import "DGRZoomAnimator.h"

@implementation DGRZoomAnimator

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext {
    return 0.3f;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    // Grab the from and to view controllers from the context
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    // Set our ending frame. We'll modify this later if we have to
    
    if (self.isPresenting) {
        //fromViewController.view.userInteractionEnabled = NO;
        
        [transitionContext.containerView addSubview:toViewController.view];
        
        toViewController.view.transform = CGAffineTransformMakeScale(0.01, 0.01);
        CGPoint originalCenter = toViewController.view.center;
        
        toViewController.view.center = self.startingLocation;
        
        [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
            toViewController.view.transform = CGAffineTransformMakeScale(1.0, 1.0);
            toViewController.view.center = originalCenter;

        } completion:^(BOOL finished) {
            [transitionContext completeTransition:YES];
        }];
    }
    else {
        toViewController.view.userInteractionEnabled = YES;
        
        [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
            fromViewController.view.transform = CGAffineTransformMakeScale(0.01, 0.01);
            fromViewController.view.center = self.startingLocation;

        } completion:^(BOOL finished) {
            [transitionContext completeTransition:YES];
        }];
    }
}


@end
