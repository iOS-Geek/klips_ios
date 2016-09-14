//
//  EditProfileVC.h
//  Klips
//
//  Created by iOS Developer on 15/12/15.
//  Copyright © 2015 iOS Developer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWRevealViewController.h"
#import "VSDropdown.h"
#import "AppDelegate.h"

@interface EditProfileVC : UIViewController<UITextFieldDelegate,UIGestureRecognizerDelegate,UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet UIButton *sideMenuButton;
@property (weak, nonatomic) IBOutlet UIImageView *userImageView;
@property (weak, nonatomic) IBOutlet UITextField *editFirstTextField;
@property (weak, nonatomic) IBOutlet UITextField *editLastTextField;
@property (weak, nonatomic) IBOutlet UITextField *editMailTextField;
@property (weak, nonatomic) IBOutlet UITextField *editCountryTextField;
@property (weak, nonatomic) IBOutlet UIView *bgView;
@property (weak, nonatomic) IBOutlet UIView *popUpView;

@end
