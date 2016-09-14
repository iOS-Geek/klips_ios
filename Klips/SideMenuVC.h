//
//  SideMenuVC.h
//  Klips
//
//  Created by iOS Developer on 14/12/15.
//  Copyright © 2015 iOS Developer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "SWRevealViewController.h"
#import "HomeVC.h"
#import "ArtistsVC.h"
#import "EditProfileVC.h"
#import "ChangePasswordVC.h"
#import "AboutViewController.h"
#import "ContactViewController.h"

@interface SideMenuVC : UIViewController<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *menuTable;
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UIButton *editButton;
@property (weak, nonatomic) IBOutlet UILabel *fullNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *emailAdressLabel;


@end
