//
//  AppDelegate.h
//  Klips
//
//  Created by iOS Developer on 28/10/15.
//  Copyright © 2015 iOS Developer. All rights reserved.
//

#define BaseUrl @"http://erginus.net/klips_web/api/"

#import <UIKit/UIKit.h>
#import "RequestManager.h"
#import "SWRevealViewController.h"
#import "MBProgressHUD.h"
#import <AVFoundation/AVFoundation.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKShareKit/FBSDKShareKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate,MBProgressHUDDelegate,AVAudioPlayerDelegate>{
    MBProgressHUD *HUD;
    AVAudioPlayer *audioPlayer;
//    UIImageView *launchImage;
}

@property (strong, nonatomic) UIWindow *window;

@property (assign, nonatomic) BOOL loggedIn;
@property (assign, nonatomic) BOOL loggedInWithFb;
@property (assign, nonatomic) BOOL loggedInAsGuest;
@property (assign, nonatomic) BOOL isMusic;
@property (assign, nonatomic) BOOL isQuote;
@property (assign, nonatomic) BOOL showLanguageAlert;

-(void)playCountWithId:(NSString*)idString;
-(void)show_LoadingIndicator;
-(void)hide_LoadingIndicator;

@end

