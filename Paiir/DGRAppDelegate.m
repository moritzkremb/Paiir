//
//  DGRAppDelegate.m
//  Paiir
//
//  Created by Moritz Kremb on 16/08/14.
//  Copyright (c) 2014 Kremb. All rights reserved.
//

#import "DGRAppDelegate.h"
#import "Parse/Parse.h"
#import <FacebookSDK/FacebookSDK.h>
#import "AGPushNoteView.h"
#import "DGRNotificationsViewController.h"
#import "DGRConstants.h"
#import <Crashlytics/Crashlytics.h>
#import "Flurry.h"


@implementation DGRAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSLog(@"Application didFinishLaunching");

    // Parse & Facebook Set up
    [Parse setApplicationId:@"DvcJe224MDKTT2VIOGFNUqH8R6WabuCotsrTneoZ"
                  clientKey:@"TncnCjsjhRw1tokASwcD72RmRdxgz5PYXsccQGex"];
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    [PFFacebookUtils initializeFacebook];
    
    // Flurry
    [Flurry startSession:@"T2XMFWC9S5WCC5VWZP43"];
    
    // Crashlytics
    [Crashlytics startWithAPIKey:@"1a3fd0c3f3133217b30fd65352aa9d217480ea5b"];
    
    // Tracking push notifications
    if (application.applicationState != UIApplicationStateBackground) {
        // Track an app open here if we launch with a push, unless
        // "content_available" was used to trigger a background push (introduced
        // in iOS 7). In that case, we skip tracking here to avoid double
        // counting the app-open.
        BOOL preBackgroundPush = ![application respondsToSelector:@selector(backgroundRefreshStatus)];
        BOOL oldPushHandlerOnly = ![self respondsToSelector:@selector(application:didReceiveRemoteNotification:fetchCompletionHandler:)];
        BOOL noPushPayload = ![launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
        if (preBackgroundPush || oldPushHandlerOnly || noPushPayload) {
            [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
        }
    }

    // Register for Push Notitications, if running iOS 8
    if ([application respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert |
                                                        UIUserNotificationTypeBadge |
                                                        UIUserNotificationTypeSound);
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes
                                                                                 categories:nil];
        [application registerUserNotificationSettings:settings];
        [application registerForRemoteNotifications];
    } else {
        // Register for Push Notifications before iOS 8
        [application registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
                                                         UIRemoteNotificationTypeAlert |
                                                         UIRemoteNotificationTypeSound)];
    }
    
    // Handle push notifications
    
    NSDictionary *notificationPayload = launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey];
    NSLog(@"Notificationspayload: %@", notificationPayload);
    
    if (notificationPayload && [PFUser currentUser]) {
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
        DGRNotificationsViewController *notifsVC = [storyboard instantiateViewControllerWithIdentifier:@"NotificationsViewController"];
        
        [[DGRAppDelegate topMostController] presentViewController:notifsVC animated:YES completion:nil];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"DGRNotificationsViewControllerLoadParseObjects" object:self];
        
    }
    
    return YES;
    
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [FBAppCall handleDidBecomeActiveWithSession:[PFFacebookUtils session]];
    
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    if (currentInstallation.badge != 0) {
        currentInstallation.badge = 0;
        [currentInstallation saveEventually];
    }
    /*
    UIViewController *topVC = [DGRAppDelegate topMostController];
    if ([topVC.childViewControllers[0] isKindOfClass:[DGRHomeViewController class]]) {
        NSLog(@"Application did become active with home VC as top VC.");
        [[NSNotificationCenter defaultCenter] postNotificationName:@"DGRHomeViewControllerLoadParseObjects" object:self];
    }
    */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [[PFFacebookUtils session] close];

}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    return [FBAppCall handleOpenURL:url
                  sourceApplication:sourceApplication
                        withSession:[PFFacebookUtils session]];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    // Store the deviceToken in the current installation and save it to Parse.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    if ([PFUser currentUser]) {
        [currentInstallation setObject:[PFUser currentUser] forKey:@"user"];
    }
    [currentInstallation saveInBackground];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    
    // Push Tracking
    if (application.applicationState == UIApplicationStateInactive) {
        // The application was just brought from the background to the foreground,
        // so we consider the app as having been "opened by a push notification."
        [PFAnalytics trackAppOpenedWithRemoteNotificationPayload:userInfo];
    }
    
    // Handle Push
    if (application.applicationState == UIApplicationStateActive) {
        // active state
        NSDictionary *aps = [userInfo objectForKey:@"aps"];

        if ([PFUser currentUser]) {
            [AGPushNoteView showWithNotificationMessage:[aps objectForKey:@"alert"]];
            [AGPushNoteView setMessageAction:^(NSString *message){
                                
                if ([DGRAppDelegate topMostController].childViewControllers.count != 0) {
                    
                    if ([[DGRAppDelegate topMostController].childViewControllers[0] isKindOfClass:[DGRNotificationsViewController class]]) {
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"DGRNotificationsViewControllerLoadParseObjects" object:self];

                    }
                    
                    else {
                        
                        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
                        DGRNotificationsViewController *notifsVC = [storyboard instantiateViewControllerWithIdentifier:@"NotificationsViewController"];
                        
                        [[DGRAppDelegate topMostController] presentViewController:notifsVC animated:YES completion:nil];
                        
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"DGRNotificationsViewControllerLoadParseObjects" object:self];
                    }
                    
                }
                
                else {
                    // if its imagetableVC or HighlightsVC it will jump here
                    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
                    DGRNotificationsViewController *notifsVC = [storyboard instantiateViewControllerWithIdentifier:@"NotificationsViewController"];
                    
                    [[DGRAppDelegate topMostController] presentViewController:notifsVC animated:YES completion:nil];
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"DGRNotificationsViewControllerLoadParseObjects" object:self];
                }
                
            }];
        }

    }
    else {
        // inactive or background state
        NSLog(@"applicationstate: Inactive");

        if ([PFUser currentUser]) {
            
            if ([DGRAppDelegate topMostController].childViewControllers.count != 0) {
                
                if ([[DGRAppDelegate topMostController].childViewControllers[0] isKindOfClass:[DGRNotificationsViewController class]]) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"DGRNotificationsViewControllerLoadParseObjects" object:self];
                    
                }
                
                else {
                    
                    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
                    DGRNotificationsViewController *notifsVC = [storyboard instantiateViewControllerWithIdentifier:@"NotificationsViewController"];
                    
                    [[DGRAppDelegate topMostController] presentViewController:notifsVC animated:YES completion:nil];
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"DGRNotificationsViewControllerLoadParseObjects" object:self];
                }
                
            }
            
            else {
                // if its imagetableVC or HighlightsVC it will jump here
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
                DGRNotificationsViewController *notifsVC = [storyboard instantiateViewControllerWithIdentifier:@"NotificationsViewController"];
                
                [[DGRAppDelegate topMostController] presentViewController:notifsVC animated:YES completion:nil];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:@"DGRNotificationsViewControllerLoadParseObjects" object:self];
            }

            
        }

    }
    
}

+ (UIViewController*) topMostController
{
    UIViewController *topController = [UIApplication sharedApplication].keyWindow.rootViewController;
    
    while (topController.presentedViewController) {
        topController = topController.presentedViewController;
    }
    
    return topController;
}

@end
