//
//  HomeVC.h
//  Klips
//
//  Created by iOS Developer on 14/12/15.
//  Copyright © 2015 iOS Developer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWRevealViewController.h"
#import "DisplayScrollDataVC.h"
#import "ArtistMusic.h"
#import "PlayVideoVC.h"
#import "SearchVC.h"

@interface HomeVC : UIViewController
@property (weak, nonatomic) IBOutlet UIButton *sideMenuButton;
@property (weak, nonatomic) IBOutlet UIImageView *upArrowImageView;
@property (weak, nonatomic) IBOutlet UIView *languageMenuView;
@property (weak, nonatomic) IBOutlet UIButton *arabicBtn;
@property (weak, nonatomic) IBOutlet UIButton *englishBtn;
@property (weak, nonatomic) IBOutlet UIView *hiddenView;
@property (weak, nonatomic) IBOutlet UIButton *downArrowBtn;

@end
