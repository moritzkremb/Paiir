//
//  DGRLaunchPageViewController.m
//  Paiir
//
//  Created by Moritz Kremb on 05/12/14.
//  Copyright (c) 2014 Kremb. All rights reserved.
//

#import "DGRLaunchPageViewController.h"
#import "DGRConstants.h"

@interface DGRLaunchPageViewController ()

@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIButton *registerButton;

@property UIPageControl *pageControl;
@property (weak, nonatomic) UIButton *getStartedButton;

- (IBAction)loginButtonAction:(id)sender;
- (IBAction)registerButtonAction:(id)sender;

- (void)getStartedButtonAction;

@end

@implementation DGRLaunchPageViewController

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (UIViewController *)childViewControllerForStatusBarHidden {
    return nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeTutorialView) name:@"DGRLaunchPageRemoveTutorialView" object:nil];

    //page customization
    NSString *background;
    if (IS_WIDESCREEN) {
        background = @"LogInBackground.png";
    } else {
        background = @"LogInBackgroundSmall.png";
    }
    
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:background]]];
    
    // make buttons round
    self.loginButton.backgroundColor = [UIColor colorWithRed:255 green:255 blue:255 alpha:0.4];
    self.loginButton.layer.cornerRadius = 5.0f;
    self.loginButton.clipsToBounds = YES;
    self.registerButton.backgroundColor = [UIColor colorWithRed:255 green:255 blue:255 alpha:0.4];
    self.registerButton.layer.cornerRadius = 5.0f;
    self.registerButton.clipsToBounds = YES;
    
    // move buttons up on small screen
    if (!IS_WIDESCREEN) {
        self.loginButton.frame = CGRectMake(10, 420, 145, 45);
        self.registerButton.frame = CGRectMake(165, 420, 145, 45);
    }

}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // Flurry
    [Flurry logEvent:@"LaunchPage_ViewDidAppear"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions

- (IBAction)loginButtonAction:(id)sender {
    
    // Flurry
    [Flurry logEvent:@"LaunchPage_LogInAction"];

    UIViewController *logInViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"LogInViewController"];
    [self presentViewController:logInViewController animated:YES completion:NULL];
}

- (IBAction)registerButtonAction:(id)sender {
    
    // Flurry
    [Flurry logEvent:@"LaunchPage_RegisterAction"];

    // PageView
    if (IS_WIDESCREEN) {
        _pageImages = [NSArray arrayWithObjects:@"TutorialPage1.png", @"TutorialPage2.png", @"TutorialPage3.png", @"TutorialPage4.png", nil];
        
    } else _pageImages = [NSArray arrayWithObjects:@"TutorialPage1Small.png", @"TutorialPage2Small.png", @"TutorialPage3Small.png", @"TutorialPage4Small.png", nil];
    
    self.pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    self.pageViewController.dataSource = self;
    self.pageViewController.delegate = self;
    self.pageViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height + 37);
    
    // Page Control
    UIPageControl *pageControl = [[UIPageControl alloc] init];
    pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
    pageControl.currentPageIndicatorTintColor = [UIColor whiteColor];
    pageControl.backgroundColor = [UIColor clearColor];
    pageControl.numberOfPages = 4;
    pageControl.frame = CGRectMake(0, self.view.frame.size.height - 30, self.view.frame.size.width, 20);
    _pageControl = pageControl;
    [self.pageViewController.view addSubview:_pageControl];
    
    UIViewController *startingViewController = [self viewControllerAtIndex:0];
    NSArray *viewControllers = @[startingViewController];
    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
    [self addChildViewController:_pageViewController];
    _pageViewController.view.frame = CGRectMake(0, -500, self.view.frame.size.width, self.view.frame.size.height + 37);
    [self.view addSubview:_pageViewController.view];
    
    [UIView animateKeyframesWithDuration:0.5f
                                   delay:0.0f
                                 options:UIViewKeyframeAnimationOptionCalculationModeLinear
                              animations:^{
                                  _pageViewController.view.frame = CGRectMake(0, 0, _pageViewController.view.frame.size.width, _pageViewController.view.frame.size.height + 37);
                              }
                              completion:^(BOOL finished){}];
    
    [self.pageViewController didMoveToParentViewController:self];

}

-(void)removeTutorialView {
    [_pageViewController.view removeFromSuperview];
    [_pageViewController removeFromParentViewController];
}

- (void)getStartedButtonAction {
    
    // Flurry
    [Flurry logEvent:@"LaunchPage_GetStartedAction"];
    
    UIViewController *signUpViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SignUpViewController"];
    [self presentViewController:signUpViewController animated:YES completion:NULL];
}


#pragma mark - Navigation


#pragma mark - Page View Controller Data Source

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    /*
    if ([viewController isKindOfClass:[UINavigationController class]]) {
        return [self viewControllerAtIndex:3];
    }
    */
    NSUInteger index = ((DGRPageViewContentViewController*) viewController).pageIndex;
    
    if ((index == 0) || (index == NSNotFound)) {
        return nil;
    }
    
    index--;
    
    return [self viewControllerAtIndex:index];
    
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    /*
    if ([viewController isKindOfClass:[UINavigationController class]]) {
        return nil;
    }
    */
    
    NSUInteger index = ((DGRPageViewContentViewController*) viewController).pageIndex;
    
    if (index == 3 || index == NSNotFound) {
        return nil;
    }
    
    index++;
    
    return [self viewControllerAtIndex:index];
    
}

- (UIViewController *)viewControllerAtIndex:(NSUInteger)index
{
    if ([self.pageImages count] == 0) {
        return nil;
    }
    /*
    if (index == 4) {
        UINavigationController *signUpViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SignUpViewController"];
        return signUpViewController;
    }
    */
    // Create a new view controller and pass suitable data.
    NSString *vcIdentifier;
    if (IS_WIDESCREEN) {
        vcIdentifier = @"PageViewContentViewController";
    } else vcIdentifier = @"PageViewContentViewController4";
    DGRPageViewContentViewController *pageContentViewController = [self.storyboard instantiateViewControllerWithIdentifier:vcIdentifier];
    pageContentViewController.imageFile = self.pageImages[index];
    pageContentViewController.pageIndex = index;
    
    if (index == 3 && !self.getStartedButton) {
        UIButton *getStartedButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [getStartedButton setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.4]];
        [getStartedButton addTarget:self action:@selector(getStartedButtonAction) forControlEvents:UIControlEventTouchUpInside];
        [getStartedButton setTitle:@"Get Started" forState:UIControlStateNormal];
        [getStartedButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        getStartedButton.titleLabel.font = [UIFont fontWithName:@"AvenirNext-Medium" size:17];
        getStartedButton.layer.cornerRadius = 5.0f;
        getStartedButton.clipsToBounds = YES;
        
        if (IS_WIDESCREEN) {
            getStartedButton.frame = CGRectMake(80, 498, 160, 40);
        }
        else {
            getStartedButton.frame = CGRectMake(80, 410, 160, 40);
        }
        self.getStartedButton = getStartedButton;
        [pageContentViewController.view insertSubview:getStartedButton atIndex:1];

        //[pageContentViewController.view addSubview:getStartedButton];
        //[self.getStartedButton bringSubviewToFront:pageContentViewController.view];

    }

    
    return pageContentViewController;
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController
{
    return [self.pageImages count];
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController
{
    return 0;
}

-(void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed {
    
    [_pageControl setCurrentPage:((DGRPageViewContentViewController*)[pageViewController.viewControllers lastObject]).pageIndex ];

    /*
    if ([[pageViewController.viewControllers lastObject] isKindOfClass:[UINavigationController class]]) {
        [_pageControl setCurrentPage:4];
    } else {
        [_pageControl setCurrentPage:((DGRPageViewContentViewController*)[pageViewController.viewControllers lastObject]).pageIndex ];
    }
    */
}


@end
