//
//  DGRSettingsTableViewController.m
//  Paiir
//
//  Created by Moritz Kremb on 08/10/14.
//  Copyright (c) 2014 Kremb. All rights reserved.
//

#import "DGRSettingsTableViewController.h"
#import "MBProgressHUD.h"

@interface DGRSettingsTableViewController ()

- (IBAction)logOutAction:(id)sender;
- (IBAction)clearCacheAction:(id)sender;
- (IBAction)doneButtonAction:(id)sender;

@end

@implementation DGRSettingsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //[self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // this UIViewController is about to re-appear, make sure we remove the current selection in our table view
    NSIndexPath *tableSelection = [self.tableView indexPathForSelectedRow];
    [self.tableView deselectRowAtIndexPath:tableSelection animated:NO];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableView

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        switch (indexPath.row) {
            case 3:
                [self manageFacebookAction];
                break;
                
            default:
                break;
        }

    }
    if (indexPath.section == 1) {
        switch (indexPath.row) {
            case 0:
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"itms-apps://itunes.apple.com/app/id952423007"]];
                break;
                
            case 1:
                [self didTapInviteFriends];
                break;
                
            case 2:
                [self sendBugReportEmail];
                break;
                
            case 3:
                [self sendContactUsEmail];
                break;
                
            default:
                break;
        }
        
    }
    
    // unhighlight selected cell
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];

}

#pragma mark - Actions

- (void)manageFacebookAction {
    if ([UIAlertController class]) {
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        
        UIAlertAction *connect = [UIAlertAction actionWithTitle:@"Connect to Facebook" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
            [self connectToFacebook];
        }];
        
        UIAlertAction *unlink = [UIAlertAction actionWithTitle:@"Unlink from Facebook" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
            [self unlinkFromFacebook];
        }];
        
        UIAlertAction* cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * action){
            [alertController dismissViewControllerAnimated:YES completion:nil];
        }];
        
        [alertController addAction:connect];
        [alertController addAction:unlink];
        [alertController addAction:cancel];
        
        [self presentViewController:alertController animated:YES completion:nil];
        
    } else {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:@"Connect To Facebook", @"Unlink From Facebook", @"Cancel", nil];
        actionSheet.cancelButtonIndex = 2;
        actionSheet.tag = 10; // todayView action sheet
        [actionSheet showInView:self.view];
    }

}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (![UIAlertController class]) {
        if (actionSheet.tag == 10) { // Facebook action
            // todayView action sheet
            switch (buttonIndex) {
                case 0:
                    // connect
                    [self connectToFacebook];
                    break;
                    
                case 1:
                    // unlink
                    [self unlinkFromFacebook];
                    break;
                    
                default:
                    break;
            
            }
        }
    }
}

-(void)didTapInviteFriends {
    
    NSArray *activityItems = @[@"Check out Paiir! www.paiirapp.com"];
    UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
    
    [self presentViewController:activityController animated:YES completion:NULL];
    
}

#pragma mark - MFMailDelegate

- (void)sendBugReportEmail {
    
    // Email Subject
    NSString *emailTitle = @"Bug Report";
    // To address
    NSArray *toRecipents = [NSArray arrayWithObject:@"info@paiir-app.com"];
    
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
        mc.mailComposeDelegate = self;
        [mc setSubject:emailTitle];
        [mc setToRecipients:toRecipents];
        
        // Present mail view controller on screen
        [self presentViewController:mc animated:YES completion:NULL];
    }
    else {
        [self okAlertWithTitle:@"Not available" message:@"Make sure you have an email account set up in Settings."];
    }
    
}

- (void)sendContactUsEmail {
    
    // To address
    NSArray *toRecipents = [NSArray arrayWithObject:@"info@paiir-app.com"];
    
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
        mc.mailComposeDelegate = self;
        [mc setToRecipients:toRecipents];
        
        // Present mail view controller on screen
        [self presentViewController:mc animated:YES completion:NULL];
    }
    else {
        [self okAlertWithTitle:@"Not available" message:@"Make sure you have an email account set up in Settings."];
    }

}


- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail sent");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail sent failure: %@", [error localizedDescription]);
            break;
        default:
            break;
    }
    
    // Close the Mail Interface
    [self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - Facebook Methods

-(void)connectToFacebook {
    
    if ([PFUser currentUser]) {
        
        MBProgressHUD *loadingHUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        loadingHUD.mode = MBProgressHUDModeIndeterminate;
        loadingHUD.labelText = @"Connecting...";
        [loadingHUD show:YES];
        
        [PFFacebookUtils linkUser:[PFUser currentUser] permissions:@[@"email"] block:^(BOOL succeeded, NSError *error){
            if (!error) {
                // load facebook data
                //get profile info
                FBRequest *request = [FBRequest requestForMe];
                [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                    // handle response
                    if (!error) {
                        
                        // Parse the data received
                        NSDictionary *userData = (NSDictionary *)result;
                        NSString *facebookID = userData[@"id"];
                        
                        NSMutableDictionary *userProfile = [NSMutableDictionary dictionaryWithCapacity:8];
                        
                        if (facebookID) {
                            userProfile[@"facebookId"] = facebookID;
                        }
                        
                        NSString *name = userData[@"name"];
                        if (name) {
                            userProfile[@"name"] = name;
                        }
                        
                        NSString *location = userData[@"location"][@"name"];
                        if (location) {
                            userProfile[@"location"] = location;
                        }
                        
                        NSString *gender = userData[@"gender"];
                        if (gender) {
                            userProfile[@"gender"] = gender;
                        }
                        
                        NSString *birthday = userData[@"birthday"];
                        if (birthday) {
                            userProfile[@"birthday"] = birthday;
                        }
                        
                        NSString *email = userData[@"email"];
                        if (email) {
                            userProfile[@"email"] = email;
                        }
                        
                        NSString *hardware = userData[@"devices"][@"hardware"];
                        if (hardware) {
                            userProfile[@"hardware"] = hardware;
                        }
                        
                        NSString *oS = userData[@"devices"][@"os"];
                        if (oS) {
                            userProfile[@"oS"] = oS;
                        }
                        
                        
                        [[PFUser currentUser] setObject:userProfile forKey:@"facebookProfileInfo"];
                        [[PFUser currentUser] setObject:facebookID forKey:@"facebookId"]; // set id separately for better comparison later
                        [[PFUser currentUser] saveInBackground];
                        NSLog(@"Facebook Profile Data loaded");
                        
                    }
                    else if ([[[[error userInfo] objectForKey:@"error"] objectForKey:@"type"]
                              isEqualToString: @"OAuthException"]) { // Since the request failed, we can check if it was due to an invalid session
                        NSLog(@"The facebook session was invalidated");
                        
                        [PFUser logOut];
                    } else {
                        
                        NSLog(@"Some other error: %@", error);
                    }
                }];
                
                // get friends
                [FBRequestConnection startForMyFriendsWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                    [loadingHUD hide:YES];
                    [self showSuccessHUDWithText:@"Linked"];
                    
                    if (!error) {
                        // result will contain an array with your user's friends in the "data" key
                        NSArray *friendObjects = [result objectForKey:@"data"];
                        NSMutableArray *friendIds = [NSMutableArray arrayWithCapacity:friendObjects.count];
                        // Create a list of friends' Facebook IDs
                        for (NSDictionary *friendObject in friendObjects) {
                            [friendIds addObject:[friendObject objectForKey:@"id"]];
                        }
                        
                        [[PFUser currentUser] setObject:friendIds forKey:@"facebookFriends"];
                        [[PFUser currentUser] saveInBackground];
                        
                        NSLog(@"Facebook Friends Data loaded");
                        
                    }
                    else {
                        NSLog(@"Error for facebook friend graph request");
                        
                    }
                }];
                
            }
            else {
                [loadingHUD hide:YES];
                [self okAlertWithTitle:@"Error" message:[error description]];
                NSLog(@"error.");
                
            }
        }];

    }
    
}

-(void)unlinkFromFacebook {
    MBProgressHUD *loadingHUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    loadingHUD.mode = MBProgressHUDModeIndeterminate;
    loadingHUD.labelText = @"Unlinking...";
    [loadingHUD show:YES];
    
    [PFFacebookUtils unlinkUserInBackground:[PFUser currentUser] block:^(BOOL succeed, NSError *error){
        [loadingHUD hide:YES];
        if (succeed) {
            [self showSuccessHUDWithText:@"Success"];
        }
        else
            [self okAlertWithTitle:@"Sorry!" message:@"There was an error. Please try again."];
    }];
}

#pragma mark - Button Actions

-(IBAction)doneButtonAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (IBAction)clearCacheAction:(id)sender {
    MBProgressHUD *loadingHUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    loadingHUD.mode = MBProgressHUDModeIndeterminate;
    loadingHUD.labelText = @"Clearing...";
    [loadingHUD showWhileExecuting:@selector(clearCache) onTarget:self withObject:nil animated:YES];
}
     
-(void)clearCache {
    [PFQuery clearAllCachedResults];
}

- (IBAction)logOutAction:(id)sender {
    
    [self logOutAlert];
}

#pragma mark - HUDs

-(void)showSuccessHUDWithText: (NSString *)text {
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SuccessHUD.png"]];
    hud.mode = MBProgressHUDModeCustomView;
    hud.labelText = text;
    [hud showWhileExecuting:@selector(waitForOneSecond)
                   onTarget:self withObject:nil animated:YES];
    
}

- (void)waitForOneSecond {
    sleep(1);
}

-(void)okAlertWithTitle:(NSString*)title message:(NSString*)message {
    
    if ([UIAlertController class]) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* ok = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
            [alert dismissViewControllerAnimated:YES completion:nil];
        }];
        [alert addAction:ok];
        
        [self presentViewController:alert animated:YES completion:nil];
    }
    
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
        
        [alert show];
    }
    
}

-(void)logOutAlert {
    
    if ([UIAlertController class]) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Are you sure?" message:nil preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
            [alert dismissViewControllerAnimated:YES completion:nil];
        }];
        UIAlertAction *logout = [UIAlertAction actionWithTitle:@"Log out" style:UIAlertActionStyleCancel handler:^(UIAlertAction * action){
            [alert dismissViewControllerAnimated:YES completion:nil];
            [PFUser logOut];
            [self.navigationController.presentingViewController dismissViewControllerAnimated:YES completion:NULL];
        }];
        [alert addAction:cancel];
        [alert addAction:logout];
        
        [self presentViewController:alert animated:YES completion:nil];
    }
    
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Are you sure?" message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"Cancel", @"Log out", nil];
        alert.tag = 20;
        alert.cancelButtonIndex = 1;
        
        [alert show];
    }
    
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 20) { // logout alert
        if (buttonIndex == 1) {
            [PFUser logOut];
            [self.navigationController.presentingViewController dismissViewControllerAnimated:YES completion:NULL];
        }
    }
    
}





@end
