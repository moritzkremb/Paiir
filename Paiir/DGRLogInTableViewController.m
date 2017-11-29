//
//  DGRLogInTableViewController.m
//  Paiir
//
//  Created by Moritz Kremb on 06/12/14.
//  Copyright (c) 2014 Kremb. All rights reserved.
//

#import "DGRLogInTableViewController.h"
#import "DGRConstants.h"
#import "MBProgressHUD.h"
#import <Parse/Parse.h>

@interface DGRLogInTableViewController ()

@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;

@property (weak, nonatomic) IBOutlet UIButton *facebookButton;

- (IBAction)doneButtonAction:(id)sender;
- (IBAction)cancelButtonAction:(id)sender;
- (IBAction)facebookLogInButtonAction:(id)sender;
- (IBAction)forgotButtonAction:(id)sender;
- (IBAction)tappedOnView:(id)sender;


@end

@implementation DGRLogInTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // adjust fields
    UIColor *color = [UIColor grayColor];
    self.usernameField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Username" attributes:@{NSForegroundColorAttributeName:color}];
    self.passwordField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Password" attributes:@{NSForegroundColorAttributeName:color}];
    
    // round fb button
    self.facebookButton.layer.cornerRadius = 5.0f;
    self.facebookButton.clipsToBounds = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    
    if (section == 2) {
        UILabel *myLabel = [[UILabel alloc] init];
        myLabel.frame = CGRectMake(10, 8, 300, 20);
        myLabel.font = [UIFont fontWithName:@"Avenir Next" size:10];
        myLabel.textAlignment = NSTextAlignmentCenter;
        myLabel.text = @"We will never post to Facebook without your permission.";
        
        UIView *headerView = [[UIView alloc] init];
        [headerView addSubview:myLabel];
        
        return headerView;

    }
    return nil;
}

#pragma mark - UITextFieldDelegate

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.usernameField) {
        [self.passwordField becomeFirstResponder];
    }
    else if (textField == self.passwordField) {
        [self doneButtonAction:nil];
    }
    
    return YES;
}

- (IBAction)tappedOnView:(id)sender {
    [self closeKeyboard];
}


#pragma mark - Actions

- (IBAction)doneButtonAction:(id)sender {
    
    [self closeKeyboard];
    
    // get username and password from textfield
    
    NSString *username = self.usernameField.text;
    NSString *password = self.passwordField.text;
    
    // check if both are complete
    
    if (username && password && username.length != 0 && password.length != 0) {
        
        MBProgressHUD *loginHUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        loginHUD.mode = MBProgressHUDModeIndeterminate;
        loginHUD.labelText = @"Logging In...";
        [loginHUD show:YES];

        // Begin login process
        
        [PFUser logInWithUsernameInBackground:username password:password block:^(PFUser *user, NSError *error){
            [loginHUD hide:YES];
            
            if (!user) {
                NSString *errorString;
                if ([error code] == kPFErrorConnectionFailed) {
                    errorString = @"Connection Problems. Make sure you are conected.";
                } else if ([error code] == kPFErrorObjectNotFound) {
                    errorString = @"Wrong Log In Information.";
                } else if (error) {
                    errorString = @"Sorry something went wrong. Please try again.";

                }
                [self okAlertWithTitle:@"Error" message:errorString];
                
                NSLog(@"Error Message: %@", error);
                
            }
            
            else {
                NSLog(@"User logged in...");
                [self setNotificationsForCurrentUser];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"DGRHomeViewControllerDismissAllPresentedViewControllersAnimated" object:self];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"DGRHomeViewControllerLoadParseObjects" object:self];
            }
        }];
        
    }
    
    else {
        // create UIAlert
        
        [self okAlertWithTitle:@"Missing Information" message:@"Please fill out all fields"];
        
    }

}

- (IBAction)facebookLogInButtonAction:(id)sender {
    
    [self closeKeyboard];
    
    MBProgressHUD *loginHUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    loginHUD.mode = MBProgressHUDModeIndeterminate;
    loginHUD.labelText = @"Loading...";
    [loginHUD show:YES];
    
    // Set permissions required from the facebook user account
    NSArray *permissionsArray = @[@"email"];
    
    // Login PFUser using Facebook
    [PFFacebookUtils logInWithPermissions:permissionsArray block:^(PFUser *user, NSError *error) {
        [loginHUD hide:YES];
        
        if (!user) {
            NSString *errorString;
            if ([error code] == 5) {
                errorString = @"Connection Problems. Make sure you are conected.";
            } else if (error) {
                errorString = @"Sorry something went wrong. Please try again.";
            }
            [self okAlertWithTitle:@"Error" message:errorString];
            
            NSLog(@"Error Message: %@", error);


        } else {
            if (user.isNew) {
                NSLog(@"User with facebook signed up and logged in!");
                [self okAlertWithTitle:@"You have not used this Facebook account to sign up to Paiir yet." message:@"Please Log In with username and password and then connect your Facebook account in Settings, or Sign Up with a new account."];
                [[PFUser currentUser] deleteInBackground];
                
            } else {
                NSLog(@"User with facebook logged in!");
                [self setNotificationsForCurrentUser];
                [self loadFacebookData];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"DGRHomeViewControllerDismissAllPresentedViewControllersAnimated" object:self];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"DGRHomeViewControllerLoadParseObjects" object:self];
            }
        }
    }];
    
}

-(void)loadFacebookData {
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
    }];
    
}


- (IBAction)forgotButtonAction:(id)sender {
    if ([UIAlertController class]) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Please enter your Email address." message:@"We will send you password reset instructions" preferredStyle:UIAlertControllerStyleAlert];
        
        
        
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
        }];
        UIAlertAction *send = [UIAlertAction actionWithTitle:@"Send" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
            UITextField *textField = alert.textFields[0];
            [self sendEmail:textField.text];
        }];
        [alert addAction:cancel];
        [alert addAction:send];
        
        [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
            textField.placeholder = @"Email address";
        }];
        
        [self presentViewController:alert animated:YES completion:nil];
    }
    
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Please enter your Email address." message:@"We will send you password reset instructions." delegate:self cancelButtonTitle:nil otherButtonTitles:@"Cancel", @"Send", nil];
        alert.delegate = self;
        alert.alertViewStyle = UIAlertViewStylePlainTextInput;
        UITextField *textField = [alert textFieldAtIndex:0];
        textField.placeholder = @"Email address";
        alert.tag = 10;
        [alert show];
    }
    
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 10) {
        if (buttonIndex == 1) {
            UITextField *textField = [alertView textFieldAtIndex:0];
            [self sendEmail:textField.text];
        }
    }
}

-(void)sendEmail: (NSString *)email {
    
    MBProgressHUD *forgotHUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    forgotHUD.mode = MBProgressHUDModeIndeterminate;
    forgotHUD.labelText = @"Sending...";
    [forgotHUD show:YES];
    
    [PFUser requestPasswordResetForEmailInBackground:email block:^(BOOL succeeded, NSError *error){
        
        [forgotHUD hide:YES];
        
        if (succeeded) {
            [self showSuccessHUDWithText:@"Email Sent"];
        }
        else {
            
            [self okAlertWithTitle:@"Sorry!" message:@"This Email is not associated with any user."];
            
            NSLog(@"Error for forgot password.");
            
        }
        
    }];
}


#pragma mark - Navigation

- (IBAction)cancelButtonAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:NULL];
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

-(void)setNotificationsForCurrentUser {
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    if ([PFUser currentUser]) {
        [currentInstallation setObject:[PFUser currentUser] forKey:@"user"];
    }
    [currentInstallation saveInBackground];
}

-(void)closeKeyboard {
    [self.usernameField resignFirstResponder];
    [self.passwordField resignFirstResponder];
}


@end
