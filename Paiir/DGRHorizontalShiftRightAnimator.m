//
//  DGRTransitioningAnimator.m
//  Paiir
//
//  Created by Moritz Kremb on 06/10/14.
//  Copyright (c) 2014 Kremb. All rights reserved.
//

#import "DGRHorizontalShiftRightAnimator.h"

@implementation DGRHorizontalShiftRightAnimator

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
        
        toViewController.view.frame = CGRectMake(toViewController.view.frame.size.width, 0, toViewController.view.frame.size.width, toViewController.view.frame.size.height);
        
        [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
            fromViewController.view.frame = CGRectMake(-fromViewController.view.frame.size.width, 0, fromViewController.view.frame.size.width, fromViewController.view.frame.size.height);
            toViewController.view.frame = CGRectMake(0, 0, toViewController.view.frame.size.width, toViewController.view.frame.size.height);
        } completion:^(BOOL finished) {
            [transitionContext completeTransition:YES];
        }];
    }
    else {
        toViewController.view.userInteractionEnabled = YES;
        
        toViewController.view.frame = CGRectMake(-toViewController.view.frame.size.width, 0, toViewController.view.frame.size.width, toViewController.view.frame.size.height);
        
        [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
            fromViewController.view.frame = CGRectMake(fromViewController.view.frame.size.width, 0, fromViewController.view.frame.size.width, fromViewController.view.frame.size.height);
            toViewController.view.frame = CGRectMake(0, 0, toViewController.view.frame.size.width, toViewController.view.frame.size.height);
        } completion:^(BOOL finished) {
            [transitionContext completeTransition:YES];
        }];
    }
}

@end
