//
//  DGRSettingsChangeUsernameViewController.m
//  Paiir
//
//  Created by Moritz Kremb on 23/10/14.
//  Copyright (c) 2014 Kremb. All rights reserved.
//

#import "DGRSettingsChangeUsernameViewController.h"
#import "DGRConstants.h"
#import "MBProgressHUD.h"

@interface DGRSettingsChangeUsernameViewController ()

@property NSInteger yOffset;
@property NSInteger counter;

@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *emailField;

@property (weak, nonatomic) IBOutlet UILabel *usernameAvailableText;
@property (weak, nonatomic) IBOutlet UILabel *usernameAvailableImage;

@property (weak, nonatomic) IBOutlet UILabel *emailAvailableText;
@property (weak, nonatomic) IBOutlet UILabel *emailAvailableImage;

-(IBAction)doneButtonAction:(id)sender;

@end

@implementation DGRSettingsChangeUsernameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _counter = 0;
    _yOffset = 35.0f;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITextFieldDelegate

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    
    [UIView animateWithDuration:0.2f animations:^{
        [self.view setFrame:CGRectMake(0, -_yOffset, self.view.frame.size.width, self.view.frame.size.height)];
    }];
    _counter++;
    return YES;
}


- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    if (textField == self.usernameField) {
        [self setUsernameAvailability:textField.text];
    }
    if (textField == self.emailField) {
        [self setEmailAvailability:textField.text];
    }
    
    if (_counter == 2) {
        _counter--;
        return YES;
    }
    else {
        [UIView animateWithDuration:0.2f animations:^{
            [self.view setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
            _counter--;
        }];
    }
    
    return YES;
    
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.usernameField) {
        [self setUsernameAvailability:textField.text];
        [self.usernameField resignFirstResponder];
    }
    
    if (textField == self.emailField) {
        [self setEmailAvailability:textField.text];
        [self.emailField resignFirstResponder];
    }

        
    return YES;
}

- (IBAction)tappedOnView:(id)sender {
    [self.usernameField resignFirstResponder];
    [self.emailField resignFirstResponder];
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

-(void)setEmailAvailability:(NSString*)email {
    
    if ([email isEqualToString:@""]) {
        self.emailAvailableText.text = nil;
        self.emailAvailableImage.backgroundColor = nil;
    }
    
    else {
        
        PFQuery *searchQuery = [PFUser query];
        [searchQuery whereKeyExists:@"email"];
        [searchQuery whereKey:@"email" equalTo:email];
        NSLog(@"start search");
        
        [searchQuery findObjectsInBackgroundWithBlock:^(NSArray *results, NSError *error){
            if (results.count > 0) {
                self.emailAvailableText.text = @"email taken :(";
                [self.emailAvailableImage setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"UsernameUnavailable.png"]]];
                NSLog(@"found");
                
            }
            else {
                self.emailAvailableText.text = @"email not yet taken!";
                [self.emailAvailableImage setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"UsernameAvailable.png"]]];
                NSLog(@"not found");
                
                
            }
            
        }];
        
    }
    
}


#pragma mark - Button

-(IBAction)doneButtonAction:(id)sender {
    [self.usernameField resignFirstResponder];
    [self.emailField resignFirstResponder];
    
    if ([PFUser currentUser]) {
        if ([self.emailField.text isEqualToString:@""] && [self.usernameField.text isEqualToString:@""]) {
            [self okAlertWithTitle:@"Error" message:@"You have to change at least one field."];
        }
        
        else {
            
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hud.mode = MBProgressHUDModeIndeterminate;
            hud.labelText = @"Loading...";
            [hud show:YES];
            
            PFUser *user = [PFUser currentUser];
            if (self.usernameField.text && ![self.usernameField.text isEqualToString:@""]) {
                user[@"username"] = self.usernameField.text;
                user[@"canonicalUsername"] = [self.usernameField.text lowercaseString];
            }
            
            if (self.emailField.text && ![self.emailField.text isEqualToString:@""]) {
                user[@"email"] = self.emailField.text;
            }
        
            [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
                [hud hide:YES];
                
                if (succeeded) {
                    [self showSuccessHUDWithText:@"Success."];
                }
                else {
                    [self okAlertWithTitle:@"Sorry!" message:@"An error occured, please try again."];
                }
            }];

        }
        
    }
    else {
        [self okAlertWithTitle:@"Sorry!" message:@"It seems that you are not logged in. Please log in first then try again."];
        
    }

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



@end
