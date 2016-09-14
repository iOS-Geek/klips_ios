//
//  RegistrationVC.h
//  Klips
//
//  Created by iOS Developer on 14/12/15.
//  Copyright © 2015 iOS Developer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VSDropdown.h"
#import "AppDelegate.h"

@interface RegistrationVC : UIViewController<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *firstNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *lastNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *countryTextField;

@end
