//
//  DGRSignUpTableViewController.m
//  Paiir
//
//  Created by Moritz Kremb on 06/12/14.
//  Copyright (c) 2014 Kremb. All rights reserved.
//

#import "DGRSignUpTableViewController.h"
#import "DGRConstants.h"
#import "MBProgressHUD.h"
#import <Parse/Parse.h>
#import "DGRHomeViewController.h"

@interface DGRSignUpTableViewController ()

@property (weak, nonatomic) IBOutlet UITextField *fbUsernameField;
@property (weak, nonatomic) IBOutlet UILabel *fbUsernameAvailableText;
@property (weak, nonatomic) IBOutlet UILabel *fbUsernameAvailableImage;
@property (weak, nonatomic) IBOutlet UIButton *facebookSignUpButton;


@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UILabel *usernameAvailableText;
@property (weak, nonatomic) IBOutlet UILabel *usernameAvailableImage;
@property (weak, nonatomic) IBOutlet UIButton *emailSignUpButton;

- (IBAction)cancelButtonAction:(id)sender;
- (IBAction)emailSignUpAction:(id)sender;
- (IBAction)backToLogin:(id)sender;
- (IBAction)tappedOnView:(id)sender;
- (IBAction)facebookSignUpAction:(id)sender;

@end

@implementation DGRSignUpTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // make buttons rounded
    self.facebookSignUpButton.layer.cornerRadius = 5.0f;
    self.facebookSignUpButton.clipsToBounds = YES;
    self.emailSignUpButton.layer.cornerRadius = 5.0f;
    self.emailSignUpButton.clipsToBounds = YES;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions

- (IBAction)emailSignUpAction:(id)sender {
    
    // Flurry
    [Flurry logEvent:@"SignUp_SignUpWithEmailAction"];
    
    [self closeKeyboard];
    
    // get text
    NSString *username = self.usernameField.text;
    NSString *canonicalUsername = [self.usernameField.text lowercaseString];
    NSString *password = self.passwordField.text;
    NSString *email = self.emailField.text;
    
    // check if both are complete
    
    if (username && password && email && username.length != 0 && password.length != 0 && email.length != 0) {
        // Begin login process
        
        MBProgressHUD *signUpHUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        signUpHUD.mode = MBProgressHUDModeIndeterminate;
        signUpHUD.labelText = @"Signing Up...";
        [signUpHUD show:YES];
        
        PFUser *newUser = [PFUser user];
        newUser.username = username;
        newUser.password = password;
        newUser.email = email;
        newUser[@"canonicalUsername"] = canonicalUsername;
        
        
        [newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
            [signUpHUD hide:YES];
            
            if (!succeeded) {
                NSString *errorString;
                if ([error code] == kPFErrorConnectionFailed) {
                    errorString = @"Connection Problems. Make sure you are conected.";
                } else if ([error code] == kPFErrorUsernameTaken) {
                    errorString = @"This username is already taken.";
                }
                else if ([error code] == kPFErrorUserEmailTaken) {
                    errorString = @"This email address is already taken.";
                }
                else if (error) {
                    errorString = @"Sorry something went wrong. Please try again.";
                }
                [self okAlertWithTitle:@"Error" message:errorString];
                
                NSLog(@"Error Message: %@", error);
            }
            
            if (succeeded) {
                NSLog(@"User signed up...");
                
                // set stuff
                [self setNotificationsForCurrentUser];
                [self createPaiirScoreObject];
                
                // push to profile picture selection
                UIViewController *profilePictureVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ProfilePictureAtSignUp"];
                [self.navigationController pushViewController:profilePictureVC animated:YES];
                
                
            }
        }];
        
    }
    
    else {
                
        // create UIAlert
        
        [self okAlertWithTitle:@"Missing Information" message:@"Please fill out all fields"];
        
    }

}


- (IBAction)facebookSignUpAction:(id)sender {
    
    // Flurry
    [Flurry logEvent:@"SignUp_SignUpWithFacebookAction"];
    
    [self closeKeyboard];
    
    // get text
    NSString *username = self.fbUsernameField.text;
    NSString *canonicalUsername = [self.fbUsernameField.text lowercaseString];
    
    if (username && username.length != 0) {
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

                    // set stuff
                    [self setNotificationsForCurrentUser];
                    [self createPaiirScoreObject];
                    [self loadFacebookData];
                    
                    // set username
                    PFUser *user = [PFUser currentUser];
                    user[@"username"] = username;
                    user[@"canonicalUsername"] = canonicalUsername;
                    [user saveInBackground];
                    
                    // push to profile picture selection
                    UIViewController *profilePictureVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ProfilePictureAtSignUp"];
                    [self.navigationController pushViewController:profilePictureVC animated:YES];

                    
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
    
    else {
        [self okAlertWithTitle:@"Please choose a username" message:@"You can change it later"];
    }
    
    
    
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



#pragma mark - Table view data source

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    
    if (section == 0) {
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

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    // FB
    if (textField == self.fbUsernameField) {
        [self setFBUsernameAvailability:textField.text];
    }
    
    // Email
    if (textField == self.usernameField) {
        [self setUsernameAvailability:textField.text];
    }
    return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    // FB
    if (textField == self.fbUsernameField) {
        [self setFBUsernameAvailability:textField.text];
        [self.fbUsernameField resignFirstResponder];
    }
    
    // Email
    if (textField == self.usernameField) {
        [self setUsernameAvailability:textField.text];
        [self.passwordField becomeFirstResponder];
    }
    else if (textField == self.passwordField) {
        [self.emailField becomeFirstResponder];
    }
    else if (textField == self.emailField) {
        [self emailSignUpAction:nil];
    }
    
    return YES;
}

- (IBAction)tappedOnView:(id)sender {
    [self closeKeyboard];
}

-(void)setUsernameAvailability:(NSString*)username {
    
    if ([username isEqualToString:@""]) {
        self.usernameAvailableText.text = nil;
        self.usernameAvailableImage.backgroundColor = nil;
    }
    
    else {
        
        NSString *canonicalUsername = [username lowercaseString];
        PFQuery *searchQuery = [PFUser query];
        [searchQuery whereKeyExists:@"username"];
        [searchQuery whereKey:@"canonicalUsername" equalTo:canonicalUsername];
        NSLog(@"start search");
        
        [searchQuery findObjectsInBackgroundWithBlock:^(NSArray *results, NSError *error){
            if (results.count > 0) {
                self.usernameAvailableText.text = @"username taken :(";
                [self.usernameAvailableImage setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"UsernameUnavailable.png"]]];
                NSLog(@"found");
                
            }
            else {
                self.usernameAvailableText.text = @"username available!";
                [self.usernameAvailableImage setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"UsernameAvailable.png"]]];
                NSLog(@"not found");
                
                
            }
            
        }];
        
    }
    
}

-(void)setFBUsernameAvailability:(NSString*)username {
    
    if ([username isEqualToString:@""]) {
        self.fbUsernameAvailableText.text = nil;
        self.fbUsernameAvailableImage.backgroundColor = nil;
    }
    
    else {
        
        NSString *canonicalUsername = [username lowercaseString];
        PFQuery *searchQuery = [PFUser query];
        [searchQuery whereKeyExists:@"username"];
        [searchQuery whereKey:@"canonicalUsername" equalTo:canonicalUsername];
        NSLog(@"start search");
        
        [searchQuery findObjectsInBackgroundWithBlock:^(NSArray *results, NSError *error){
            if (results.count > 0) {
                self.fbUsernameAvailableText.text = @"username taken :(";
                [self.fbUsernameAvailableImage setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"UsernameUnavailable.png"]]];
                NSLog(@"found");
                
            }
            else {
                self.fbUsernameAvailableText.text = @"username available!";
                [self.fbUsernameAvailableImage setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"UsernameAvailable.png"]]];
                NSLog(@"not found");
                
                
            }
            
        }];
        
    }
    
}



#pragma mark - Other Methods

-(void)setNotificationsForCurrentUser {
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    if ([PFUser currentUser]) {
        [currentInstallation setObject:[PFUser currentUser] forKey:@"user"];
    }
    [currentInstallation saveInBackground];
}

- (void)followTeamPaiir {
    /*
    PFObject *teamPaiirObject = [PFObject objectWithoutDataWithClassName:@"_User" objectId:@"e6UnzxoN5h"];
    
    PFObject *newFollow = [PFObject objectWithClassName:@"Activity"];
    newFollow[@"type"] = @"follow";
    newFollow[@"fromUser"] = [PFUser currentUser];
    newFollow[@"fromUserObjectId"] = [PFUser currentUser].objectId;
    newFollow[@"toUser"] = teamPaiirObject;
    newFollow[@"toUserObjectId"] = @"e6UnzxoN5h";
    [newFollow saveInBackground];
    
    // get team paiir intro photos
    PFQuery *teamPaiirIntroPhotos = [PFQuery queryWithClassName:@"CPhoto"];
    [teamPaiirIntroPhotos whereKey:@"objectId" containedIn:@[@"Zki1XeSblO", @"EjtRAkyO1K"]];
    [teamPaiirIntroPhotos includeKey:@"owner"];
    [teamPaiirIntroPhotos includeKey:@"completor"];
    [teamPaiirIntroPhotos includeKey:@"imageToComplete.creator"];
    
    teamPaiirIntroPhotos.cachePolicy = kPFCachePolicyNetworkOnly;
    [teamPaiirIntroPhotos addAscendingOrder:@"createdAt"];
    NSArray *introPhotos = [NSArray arrayWithArray:[teamPaiirIntroPhotos findObjects]];
    
    DGRHomeViewController *homeVC = (DGRHomeViewController*)self.presentingViewController.childViewControllers[0];
    homeVC.newUserSignedUp = YES;
    homeVC.teamPaiirIntroPhotos = introPhotos;
    NSLog(@"Intro photos find succeeded.");
    NSLog(@"%@", homeVC.teamPaiirIntroPhotos);
    
    
     // set seen so it doesnt show up in recent
     PFObject *seenPhoto = [PFObject objectWithClassName:@"Activity"];
     seenPhoto[@"type"] = @"seen";
     seenPhoto[@"fromUser"] = [PFUser currentUser];
     seenPhoto[@"fromUserObjectId"] = [PFUser currentUser].objectId;
     seenPhoto[@"photoPointer"] = object;
     seenPhoto[@"photoPointerObjectId"] = object.objectId;
     [seenPhoto saveInBackground];
     */
    
}

-(void)createPaiirScoreObject {
    // paiir score object
    PFObject *paiirScoreObject = [PFObject objectWithClassName:@"PaiirScore"];
    paiirScoreObject[@"user"] = [PFUser currentUser];
    paiirScoreObject[@"userObjectId"] = [PFUser currentUser].objectId;
    paiirScoreObject[@"scoreCount"] = @0;
    [paiirScoreObject saveInBackground];
    
    // And Highlight count object
    PFObject *highlightCountObject = [PFObject objectWithClassName:@"HighlightCount"];
    highlightCountObject[@"user"] = [PFUser currentUser];
    highlightCountObject[@"userObjectId"] = [PFUser currentUser].objectId;
    highlightCountObject[@"highlightCount"] = @0;
    [highlightCountObject saveInBackground];
    
}



#pragma mark - Navigation

- (IBAction)cancelButtonAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (IBAction)backToLogin:(id)sender {
    
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DGRLaunchPageRemoveTutorialView" object:self];
    [self dismissViewControllerAnimated:YES completion:NULL];


    /*
    self.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    [UIView animateKeyframesWithDuration:0.5f
                                   delay:0.0f
                                 options:UIViewKeyframeAnimationOptionCalculationModeLinear
                              animations:^{
                                  self.view.frame = CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height);
                              }
                              completion:^(BOOL finished){
                                  [self.parentViewController.view removeFromSuperview];
                              }];
    */
    
}

- (IBAction)unwindToSignUp:(UIStoryboardSegue *)unwindSegue {
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

-(void)closeKeyboard {
    [self.fbUsernameField resignFirstResponder];
    [self.usernameField resignFirstResponder];
    [self.passwordField resignFirstResponder];
    [self.emailField resignFirstResponder];
}


@end
