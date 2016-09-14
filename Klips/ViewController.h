//
//  ViewController.h
//  Klips
//
//  Created by iOS Developer on 28/10/15.
//  Copyright © 2015 iOS Developer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ForgotPasswordVC.h"
#import "RegistrationVC.h"
#import "SWRevealViewController.h"
#import "AppDelegate.h"

@interface ViewController : UIViewController<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIImageView *logoImage;
@property (weak, nonatomic) IBOutlet UIScrollView *loginScroll;

@end