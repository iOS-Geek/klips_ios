//
//  ContactViewController.h
//  Klips
//
//  Created by iOS Developer on 24/06/16.
//  Copyright © 2016 iOS Developer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWRevealViewController.h"
#import "AppDelegate.h"

@interface ContactViewController : UIViewController<UITextFieldDelegate,UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UIButton *sideMenuButton;
@property (weak, nonatomic) IBOutlet UITextField *contactNameField;
@property (weak, nonatomic) IBOutlet UITextField *contactEmailField;
@property (weak, nonatomic) IBOutlet UITextField *contactNumberField;
@property (weak, nonatomic) IBOutlet UITextView *commentsTextView;
@property (weak, nonatomic) IBOutlet UIScrollView *containerScroll;

@end
