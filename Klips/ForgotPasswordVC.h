//
//  ForgotPasswordVC.h
//  Klips
//
//  Created by iOS Developer on 14/12/15.
//  Copyright © 2015 iOS Developer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@interface ForgotPasswordVC : UIViewController<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *enterEmailField;

@end
