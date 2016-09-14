//
//  ContactViewController.m
//  Klips
//
//  Created by iOS Developer on 24/06/16.
//  Copyright © 2016 iOS Developer. All rights reserved.
//

#import "ContactViewController.h"

@interface ContactViewController ()
{
    UIStoryboard *storyboard;
    AppDelegate *appDelegate;
}
@end

@implementation ContactViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    SWRevealViewController *revealViewController = self.revealViewController;
    if ( revealViewController )
    {
        [self.sideMenuButton addTarget:self.revealViewController action:@selector( revealToggle: ) forControlEvents:UIControlEventTouchUpInside];
        [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    }
    
    storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    appDelegate=(AppDelegate*)[[UIApplication sharedApplication]delegate];
    
    [self.contactNameField setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
    [self.contactEmailField setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
    [self.contactNumberField setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapGestureCaptured:)];
    [self.containerScroll addGestureRecognizer:singleTap];

}

#pragma mark - Getting data from Server

-(void)dataForString:(NSString*)serverString andParamaters:(NSMutableDictionary*)paramDict
{
    
    [RequestManager getFromServer:serverString parameters:paramDict completionHandler:^(NSDictionary *responseDict) {
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:[responseDict valueForKey:@"message"] preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:ok];
        [appDelegate hide_LoadingIndicator];
        [self presentViewController:alertController animated:YES completion:nil];
    }];
    
}

- (IBAction)submitData:(id)sender {
    [self singleTapGestureCaptured:nil];
    if ([self.contactNameField.text isEqualToString:@""] || [self.contactEmailField.text isEqualToString:@""] || [self.commentsTextView.text isEqualToString:@""]) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:@"Please fill all the required fields." preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:ok];
        
        [self presentViewController:alertController animated:YES completion:nil];
    }
    else
    {
        [appDelegate show_LoadingIndicator];
        [self dataForString:@"contact" andParamaters:[NSMutableDictionary dictionaryWithObjectsAndKeys:self.contactNameField.text, @"name",self.contactEmailField.text, @"email",self.contactNumberField.text, @"phone",self.commentsTextView.text, @"comments", nil]];
    }
    
}

#pragma mark - Navigation

- (IBAction)goBackHome:(id)sender {
    SWRevealViewController *viewController = (SWRevealViewController *)[storyboard instantiateViewControllerWithIdentifier:@"revealView"];
    [self presentViewController:viewController animated:YES completion:nil];
}

#pragma mark - handling keyboard with textfield delegate and touches

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    
    if (textField.tag == 53 || textField.tag == 54 || textField.tag == 55) {
        [UIView animateWithDuration:0.33
                              delay:0
                            options:UIViewAnimationOptionCurveLinear
                         animations:^{
                             
                             [self.view setFrame:CGRectMake(0,-180,self.view.frame.size.width,self.view.frame.size.height)];
                             
                         } completion:nil];
    }
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    
    if (textField.tag == 53) {
        [self.contactEmailField becomeFirstResponder];
    }
    else if (textField.tag == 54)
    {
        [self.contactNumberField becomeFirstResponder];
    }
    else if (textField.tag == 55)
    {
        [self.commentsTextView becomeFirstResponder];
    }
    
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    [UIView animateWithDuration:0.33
                          delay:0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         
                         [self.view setFrame:CGRectMake(0,-180,self.view.frame.size.width,self.view.frame.size.height)];
                         
                     } completion:nil];
}

- (void)singleTapGestureCaptured:(UITapGestureRecognizer *)gesture
{
    [self.contactNameField resignFirstResponder];
    [self.contactEmailField resignFirstResponder];
    [self.contactNumberField resignFirstResponder];
    [self.commentsTextView resignFirstResponder];
    
    if (self.view.frame.origin.y != 0) {
        [UIView animateWithDuration:0.2
                              delay:0
                            options:UIViewAnimationOptionCurveLinear
                         animations:^{
                             
                             [self.view setFrame:CGRectMake(0,0,self.view.frame.size.width,self.view.frame.size.height)];
                             
                         } completion:nil];
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
