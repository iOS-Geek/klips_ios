//
//  ChangePasswordVC.h
//  Klips
//
//  Created by iOS Developer on 15/12/15.
//  Copyright © 2015 iOS Developer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@interface ChangePasswordVC : UIViewController
@property (weak, nonatomic) IBOutlet UIButton *sideMenuButton;
@property (weak, nonatomic) IBOutlet UITextField *enterNewPassTextField;
@property (weak, nonatomic) IBOutlet UITextField *confirmNewPassTextField;

@end
