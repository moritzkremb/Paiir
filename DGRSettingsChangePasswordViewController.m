//
//  DGRSettingsChangePasswordViewController.m
//  Paiir
//
//  Created by Moritz Kremb on 24/10/14.
//  Copyright (c) 2014 Kremb. All rights reserved.
//

#import "DGRSettingsChangePasswordViewController.h"
#import "DGRConstants.h"
#import "MBProgressHUD.h"

@interface DGRSettingsChangePasswordViewController ()

@property NSInteger yOffset;
@property NSInteger counter;

@property (weak, nonatomic) IBOutlet UITextField *passwordOldField;
@property (weak, nonatomic) IBOutlet UITextField *passwordNewField;
@property (weak, nonatomic) IBOutlet UITextField *passwordNewAgainField;


-(IBAction)doneButtonAction:(id)sender;

@end

@implementation DGRSettingsChangePasswordViewController

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
    if (textField == self.passwordOldField) {
        [self.passwordOldField resignFirstResponder];
    }
    
    if (textField == self.passwordNewField) {
        [self.passwordNewField resignFirstResponder];
    }
    
    if (textField == self.passwordNewAgainField) {
        [self.passwordNewAgainField resignFirstResponder];
    }
    
    return YES;
}

- (IBAction)tappedOnView:(id)sender {
    [self.passwordOldField resignFirstResponder];
    [self.passwordNewField resignFirstResponder];
    [self.passwordNewAgainField resignFirstResponder];
}


#pragma mark - Button

-(IBAction)doneButtonAction:(id)sender {
    [self.passwordOldField resignFirstResponder];
    [self.passwordNewField resignFirstResponder];
    [self.passwordNewAgainField resignFirstResponder];
    
    if ([PFUser currentUser]) {
        if ([self.passwordOldField.text isEqualToString:@""] || [self.passwordNewField.text isEqualToString:@""] || [self.passwordNewAgainField.text isEqualToString:@""]) {
            [self okAlertWithTitle:@"Error" message:@"Missing information."];
        }
        
        else if (![self.passwordNewField.text isEqualToString:self.passwordNewAgainField.text]) {
            [self okAlertWithTitle:@"Error" message:@"The new passwords you entered do not match. Please try again."];
        }
        
        else {
            
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hud.mode = MBProgressHUDModeIndeterminate;
            hud.labelText = @"Loading...";
            [hud show:YES];
            
            PFUser *user = [PFUser currentUser];
            [PFUser logInWithUsernameInBackground:user.username password:self.passwordOldField.text block:^(PFUser *user, NSError *error){
                if (user) {
                    user.password = self.passwordNewField.text;
                    
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
                else {
                    [hud hide:YES];
                    [self okAlertWithTitle:@"Error" message:@"The current password you entered is not correct."];
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
