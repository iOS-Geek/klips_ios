//
//  ChangePasswordVC.m
//  Klips
//
//  Created by iOS Developer on 15/12/15.
//  Copyright © 2015 iOS Developer. All rights reserved.
//

#import "ChangePasswordVC.h"

@interface ChangePasswordVC ()
{
    UIStoryboard *storyboard;
    AppDelegate *appDelegate;
}
@end

@implementation ChangePasswordVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    appDelegate=(AppDelegate*)[[UIApplication sharedApplication]delegate];
    
    
    SWRevealViewController *revealViewController = self.revealViewController;
    if ( revealViewController )
    {
        [self.sideMenuButton addTarget:self.revealViewController action:@selector( revealToggle: ) forControlEvents:UIControlEventTouchUpInside];
        [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    }
    
    [self.enterNewPassTextField setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
    [self.confirmNewPassTextField setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
    
}

#pragma mark - Get data from server

-(void)dataForString:(NSString*)serverString andParamaters:(NSMutableDictionary*)paramDict
{
    
    [RequestManager getFromServer:serverString parameters:paramDict completionHandler:^(NSDictionary *responseDict) {
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:[responseDict valueForKey:@"message"] preferredStyle:UIAlertControllerStyleAlert];
        
        
        UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:ok];
        
        
        [self presentViewController:alertController animated:YES completion:nil];
        
        if ([[responseDict valueForKey:@"code"] isEqualToString:@"1"]) {
            NSDictionary *dataDict = [responseDict valueForKey:@"data"];
            [[NSUserDefaults standardUserDefaults]setObject:[dataDict valueForKey:@"user_security_hash"] forKey:@"logged_user_security_hash"];
            
            self.enterNewPassTextField.text = @"";
            self.confirmNewPassTextField.text = @"";
        }
        [appDelegate hide_LoadingIndicator];
    }];
    
}

#pragma mark - Navigation

- (IBAction)goBackHome:(id)sender {
    SWRevealViewController *viewController = (SWRevealViewController *)[storyboard instantiateViewControllerWithIdentifier:@"revealView"];
    [self presentViewController:viewController animated:YES completion:nil];
    
}

#pragma mark - Submit Action

- (IBAction)submitForNewPassword:(id)sender {
    
    [self.enterNewPassTextField resignFirstResponder];
    [self.confirmNewPassTextField resignFirstResponder];
    
    if ([self.enterNewPassTextField.text isEqualToString:@""] || [self.confirmNewPassTextField.text isEqualToString:@""]) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:@"Please fill both the fields." preferredStyle:UIAlertControllerStyleAlert];
        
        
        UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:ok];
        
        
        [self presentViewController:alertController animated:YES completion:nil];
    }
    else {
        [appDelegate show_LoadingIndicator];
        [self dataForString:@"change_password" andParamaters:[NSMutableDictionary dictionaryWithObjectsAndKeys:[[NSUserDefaults standardUserDefaults] objectForKey:@"logged_user_id"],@"user_id",[[NSUserDefaults standardUserDefaults] objectForKey:@"logged_user_security_hash"],@"user_security_hash",self.enterNewPassTextField.text,@"user_login_password",self.confirmNewPassTextField.text,@"confirm_login_password", nil]];
    }
}

#pragma mark - Keyboard handling usng text field delegates and touches

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField.tag == 88) {
        [self.confirmNewPassTextField becomeFirstResponder];
    }
    else
    {
        [textField resignFirstResponder];
    }
    return YES;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    
    UITouch *touch = [touches anyObject];
    if(touch.phase == UITouchPhaseBegan) {
        [self.enterNewPassTextField resignFirstResponder];
        [self.confirmNewPassTextField resignFirstResponder];
    }
    
}

#pragma mark - Orientation

- (UIInterfaceOrientationMask) supportedInterfaceOrientations {
    
    return UIInterfaceOrientationMaskPortrait;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
