//
//  ViewController.m
//  Klips
//
//  Created by iOS Developer on 28/10/15.
//  Copyright © 2015 iOS Developer. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
{
    AppDelegate *appDelegate;
    UIStoryboard *storyboard;
    NSString *emailFromFacebook;
    NSString *userIdFromFacebook;
    NSString *firstNameFromFacebook;
    NSString *lastNameFromFacebook;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.logoImage.layer.cornerRadius = 12;
    self.logoImage.clipsToBounds = true;
    
    //placeholder color
    
    [self.emailTextField setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
    [self.passwordTextField setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapGestureCaptured:)];
    [self.loginScroll addGestureRecognizer:singleTap];
    
    appDelegate=(AppDelegate*)[[UIApplication sharedApplication]delegate];
    storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
}

#pragma mark - Getting data from Server

-(void)dataForString:(NSString*)serverString andParamaters:(NSMutableDictionary*)paramDict
{
    
    [RequestManager getFromServer:serverString parameters:paramDict completionHandler:^(NSDictionary *responseDict) {
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:[responseDict valueForKey:@"message"] preferredStyle:UIAlertControllerStyleAlert];
        if ([alertController.message isEqualToString:@""]) {
            alertController.message = @"Please check your Internet Connection.";
        }
        
        if ([[responseDict valueForKey:@"code"] isEqualToString:@"1"]) {
            
            
            // success
            appDelegate.showLanguageAlert = YES;
            
            UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
                                 {
                                     SWRevealViewController *viewController = (SWRevealViewController *)[storyboard instantiateViewControllerWithIdentifier:@"revealView"];
                                     [self presentViewController:viewController animated:YES completion:nil];
                                     
                                     
                                 }];
            
            [alertController addAction:ok];
            
            NSDictionary *dataDict = [responseDict valueForKey:@"data"];
            
            
            
            [[NSUserDefaults standardUserDefaults]setObject:[dataDict valueForKey:@"user_id"] forKey:@"logged_user_id"];
            
            [[NSUserDefaults standardUserDefaults]setObject:[dataDict valueForKey:@"user_security_hash"] forKey:@"logged_user_security_hash"];
            
            [[NSUserDefaults standardUserDefaults]setObject:[dataDict valueForKey:@"user_first_name"] forKey:@"logged_user_first_name"];
            
            [[NSUserDefaults standardUserDefaults]setObject:[dataDict valueForKey:@"user_last_name"] forKey:@"logged_user_last_name"];
            
            [[NSUserDefaults standardUserDefaults]setObject:[dataDict valueForKey:@"user_email"] forKey:@"logged_user_email"];
            
            if (appDelegate.loggedIn) {
                [[NSUserDefaults standardUserDefaults]setObject:[dataDict valueForKey:@"countries_id"] forKey:@"logged_countries_id"];
            }
            
            [[NSUserDefaults standardUserDefaults]setObject:[dataDict valueForKey:@"user_profile_image_url"] forKey:@"logged_user_profile_image_url"];
            
            self.emailTextField.text = @"";
            self.passwordTextField.text = @"";
            
        }
        else {
            
            appDelegate.loggedIn = NO;
            appDelegate.loggedInWithFb = NO;
            UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
            [alertController addAction:ok];
            
        }
        [appDelegate hide_LoadingIndicator];
        [self presentViewController:alertController animated:YES completion:nil];
    }];
    
}

#pragma mark - Button Actions

- (IBAction)registerButtonAction:(id)sender {
    
    RegistrationVC *viewController = (RegistrationVC *)[storyboard instantiateViewControllerWithIdentifier:@"registerView"];
    [self presentViewController:viewController animated:YES completion:nil];
    
}

- (IBAction)forgotPasswordAction:(id)sender {
    
    ForgotPasswordVC *viewController = (ForgotPasswordVC *)[storyboard instantiateViewControllerWithIdentifier:@"forgetfulView"];
    [self presentViewController:viewController animated:YES completion:nil];
    
}

- (IBAction)loginButtonAction:(id)sender {
    
    if ([self.emailTextField.text isEqualToString:@""] || [self.passwordTextField.text isEqualToString:@""]) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:@"Please fill both the fields." preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:ok];
        
        [self presentViewController:alertController animated:YES completion:nil];
        
    }
    else{
        
        [[NSUserDefaults standardUserDefaults] setObject:@"normal" forKey:@"login_type"];
        appDelegate.loggedIn = YES;
        [self.emailTextField resignFirstResponder];
        [self.passwordTextField resignFirstResponder];
        [appDelegate show_LoadingIndicator];
        [self dataForString:@"login" andParamaters:[NSMutableDictionary dictionaryWithObjectsAndKeys:self.emailTextField.text, @"user_login_email", self.passwordTextField.text, @"user_login_password", nil]];
        
    }
}

- (IBAction)loginAsGuest:(id)sender {
    
    appDelegate.showLanguageAlert = YES;
    SWRevealViewController *viewController = (SWRevealViewController *)[storyboard instantiateViewControllerWithIdentifier:@"revealView"];
    [self presentViewController:viewController animated:YES completion:^{
        appDelegate.loggedInAsGuest = YES;
    }];
    
}

- (IBAction)facebookLogin:(id)sender {
    
    // change info.plist for blendedd facebook login currently using fha's fb login
    // 1- FacebookAppID
    // 2-FacebookAppSecret
    // 3-FacebookDisplayName
    // 4-UrlTypes/UrlSchemes/item0
    
    
    FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
    
    if ([FBSDKAccessToken currentAccessToken]) {
        [login logOut];
        //picView.profileID=[FBSDKAccessToken currentAccessToken].userID;
    }
    
    [login logInWithReadPermissions:@[@"email",@"public_profile"] fromViewController:self handler:^(FBSDKLoginManagerLoginResult *result, NSError *error)
     
     {
         if (error)
         {
             // Process error
         } else if (result.isCancelled)
         {
             // Handle cancellations
             
             UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Try Again" message:@"Login Failed from facebook" preferredStyle:UIAlertControllerStyleAlert];
             
             UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
             [alertController addAction:ok];
             [self presentViewController:alertController animated:YES completion:nil];
             
         } else
         {
             
             // If you ask for multiple permissions at once, you
             // should check if specific permissions missing
             if ([result.grantedPermissions containsObject:@"email"]) {
                 // Do work
                 
                 [appDelegate show_LoadingIndicator];
                 
                 NSMutableDictionary* parameters = [NSMutableDictionary dictionary];
                 [parameters setValue:@"id,first_name,last_name,gender,email" forKey:@"fields"];
                 
                 [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:parameters]
                  startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
                      if (!error) {
                          
                          //// Do here what you want after login success from facebook
                          
                          emailFromFacebook = [NSString stringWithFormat:@"%@",result[@"email"]];
                          firstNameFromFacebook = [NSString stringWithFormat:@"%@",result[@"first_name"]];
                          lastNameFromFacebook = [NSString stringWithFormat:@"%@",result[@"last_name"]];
                          userIdFromFacebook = [NSString stringWithFormat:@"%@",result[@"id"]];
                          
                          [[NSUserDefaults standardUserDefaults] setObject:@"facebook" forKey:@"login_type"];
                          appDelegate.loggedInWithFb = YES;
                          [self dataForString:@"social_media_login" andParamaters:[NSMutableDictionary dictionaryWithObjectsAndKeys:@"facebook",@"social_media_plateform",userIdFromFacebook,@"social_media_id",emailFromFacebook,@"user_email",firstNameFromFacebook,@"user_first_name",lastNameFromFacebook,@"user_last_name", nil]];
                      }
                      
                      
                  }];
             }
         }
     }];
    
    
}

#pragma mark - Textfield delegate to handle keyboard

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    
    if (textField.tag == 11) {
        [self.passwordTextField becomeFirstResponder];
    }
    else
    {
        [textField resignFirstResponder];
    }
    
    return YES;
}

- (void)singleTapGestureCaptured:(UITapGestureRecognizer *)gesture
{
    [self.emailTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
    
    
}

#pragma mark - Orientation

- (UIInterfaceOrientationMask) supportedInterfaceOrientations {
    
    return UIInterfaceOrientationMaskPortrait;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
