//
//  ForgotPasswordVC.m
//  Klips
//
//  Created by iOS Developer on 14/12/15.
//  Copyright © 2015 iOS Developer. All rights reserved.
//

#import "ForgotPasswordVC.h"

@interface ForgotPasswordVC ()
{
    AppDelegate *appDelegate;
}
@end

@implementation ForgotPasswordVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    appDelegate=(AppDelegate*)[[UIApplication sharedApplication]delegate];
    
    //placeholder color
    
    [self.enterEmailField setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
    
}

#pragma mark - Getting data from Server

-(void)dataForString:(NSString*)serverString andParamaters:(NSMutableDictionary*)paramDict
{
    
    [RequestManager getFromServer:serverString parameters:paramDict completionHandler:^(NSDictionary *responseDict) {
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:[responseDict valueForKey:@"message"] preferredStyle:UIAlertControllerStyleAlert];
        
        
        if ([[responseDict valueForKey:@"code"] isEqualToString:@"1"]) {
            
            // success
            
            UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
                                 {
                                     [self dismissViewControllerAnimated:YES completion:nil];
                                     
                                     
                                 }];
            
            [alertController addAction:ok];
            
        }
        else {
            
            UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
            [alertController addAction:ok];
            
        }
        [appDelegate hide_LoadingIndicator];
        [self presentViewController:alertController animated:YES completion:nil];
    }];
    
}

#pragma mark - Submit Action

- (IBAction)submitAction:(id)sender {
    
    [self.enterEmailField resignFirstResponder];
    if ([self.enterEmailField.text isEqualToString:@""]) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:@"Please enter your email." preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:ok];
        
        [self presentViewController:alertController animated:YES completion:nil];
    }
    else
    {
        [appDelegate show_LoadingIndicator];
        [self dataForString:@"recover" andParamaters:[NSMutableDictionary dictionaryWithObjectsAndKeys:self.enterEmailField.text, @"user_email", nil]];
    }
    
}

#pragma mark - Navigation

- (IBAction)backAction:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

#pragma mark - Keyboard handling with textfield delegates and touches

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    
    UITouch *touch = [touches anyObject];
    if(touch.phase == UITouchPhaseBegan) {
        [self.enterEmailField resignFirstResponder];
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
