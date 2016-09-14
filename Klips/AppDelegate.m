//
//  AppDelegate.m
//  Klips
//
//  Created by iOS Developer on 28/10/15.
//  Copyright © 2015 iOS Developer. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate
@synthesize loggedIn,loggedInAsGuest,loggedInWithFb,isMusic,isQuote,showLanguageAlert;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    loggedIn = NO;
    loggedInAsGuest = NO;
    loggedInWithFb = NO;
    isMusic = NO;
    isQuote = NO;
    showLanguageAlert = NO;
    
    [self.window makeKeyAndVisible];
//    launchImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.window.frame.size.width, self.window.frame.size.height)];
//    launchImage.image = [UIImage imageNamed:@"splash_03.png"];
//    [self.window addSubview:launchImage];
//    [self.window bringSubviewToFront:launchImage];
   
    NSString* resourcePath = [[NSBundle mainBundle] resourcePath];
    resourcePath = [resourcePath stringByAppendingString:@"/start_music.mp3"];
    NSLog(@"Path to play: %@", resourcePath);
    NSError* err;
    
    //Initialize our player pointing to the path to our resource
    audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:
                   [NSURL fileURLWithPath:resourcePath] error:&err];
    
    if( err ){
        //bail!
        NSLog(@"Failed with reason: %@", [err localizedDescription]);
    }
    else{
        //set our delegate and begin playback
        audioPlayer.delegate = self;
        [audioPlayer play];
        
    }
    
    
    
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    [[UITabBarItem appearance] setTitleTextAttributes:@{ NSForegroundColorAttributeName : [UIColor whiteColor] }
                                             forState:UIControlStateNormal];
    [[UITabBarItem appearance] setTitleTextAttributes:@{ NSForegroundColorAttributeName : [UIColor colorWithRed:98.0f/255.0f green:54.0f/255.0f blue:58.0f/255.0f alpha:1.0] }
                                             forState:UIControlStateSelected];
    
    //session login
    
    if ([[NSUserDefaults standardUserDefaults]stringForKey:@"logged_user_id"] && [[NSUserDefaults standardUserDefaults]stringForKey:@"logged_user_security_hash"]) {
        
        
        if ([[[NSUserDefaults standardUserDefaults]stringForKey:@"login_type"] isEqualToString:@"facebook"]) {
            loggedInWithFb = YES;
            loggedIn = NO;
        }else if ([[[NSUserDefaults standardUserDefaults]stringForKey:@"login_type"] isEqualToString:@"normal"]){
            loggedInWithFb = NO;
            loggedIn = YES;
        }
        
        
        [RequestManager getFromServer:@"session_login" parameters:[NSMutableDictionary dictionaryWithObjectsAndKeys:[[NSUserDefaults standardUserDefaults]stringForKey:@"logged_user_id"],@"user_id",[[NSUserDefaults standardUserDefaults]stringForKey:@"logged_user_security_hash"],@"user_security_hash", nil] completionHandler:^(NSDictionary *responseDict) {
            
            
            if ([[responseDict valueForKey:@"code"] isEqualToString:@"1"]) {
                
                
                // success
                showLanguageAlert = YES;
                
                NSDictionary *dataDict = [responseDict valueForKey:@"data"];
                
                
                
                [[NSUserDefaults standardUserDefaults]setObject:[dataDict valueForKey:@"user_id"] forKey:@"logged_user_id"];
                
                [[NSUserDefaults standardUserDefaults]setObject:[dataDict valueForKey:@"user_security_hash"] forKey:@"logged_user_security_hash"];
                
                [[NSUserDefaults standardUserDefaults]setObject:[dataDict valueForKey:@"user_first_name"] forKey:@"logged_user_first_name"];
                
                [[NSUserDefaults standardUserDefaults]setObject:[dataDict valueForKey:@"user_last_name"] forKey:@"logged_user_last_name"];
                
                [[NSUserDefaults standardUserDefaults]setObject:[dataDict valueForKey:@"user_email"] forKey:@"logged_user_email"];
                
                if (loggedIn) {
                    [[NSUserDefaults standardUserDefaults]setObject:[dataDict valueForKey:@"countries_id"] forKey:@"logged_countries_id"];
                }
                
                [[NSUserDefaults standardUserDefaults]setObject:[dataDict valueForKey:@"user_profile_image_url"] forKey:@"logged_user_profile_image_url"];
                
                
                
                SWRevealViewController *viewController = (SWRevealViewController *)[storyboard instantiateViewControllerWithIdentifier:@"revealView"];
                [self.window.rootViewController presentViewController:viewController animated:YES completion:nil];
                
            }
            else {
                
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:[responseDict valueForKey:@"message"] preferredStyle:UIAlertControllerStyleAlert];
                
                if ([alertController.message isEqualToString:@""]) {
                    alertController.message = @"Please check your Internet Connection.";
                }
                
                UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
                [alertController addAction:ok];
                
                [self.window.rootViewController presentViewController:alertController animated:YES completion:nil];
                
                loggedIn = NO;
                loggedInWithFb = NO;
                
            }
            
            
        }];
    }
    
    [[FBSDKApplicationDelegate sharedInstance] application:application
                             didFinishLaunchingWithOptions:launchOptions];
    
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [[FBSDKApplicationDelegate sharedInstance] application:application
                                                          openURL:url
                                                sourceApplication:sourceApplication
                                                       annotation:annotation
            ];
}

-(void)playCountWithId:(NSString*)idString
{
    if (loggedIn || loggedInWithFb) {
        
        if (isMusic == YES) {
            
            NSLog(@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"logged_user_id"]);
            NSLog(@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"logged_user_security_hash"]);
            [RequestManager getFromServer:@"music_played_count" parameters:[NSMutableDictionary dictionaryWithObjectsAndKeys:[[NSUserDefaults standardUserDefaults] objectForKey:@"logged_user_id"],@"user_id",[[NSUserDefaults standardUserDefaults] objectForKey:@"logged_user_security_hash"],@"user_security_hash",idString,@"music_id", nil] completionHandler:^(NSDictionary *responseDict){
                if ([[responseDict valueForKey:@"code"] isEqualToString:@"1"]) {
                    NSLog(@"done");
                }
            }];
        }
    }
    
    
}

-(void)show_LoadingIndicator
{
    if(!HUD)
    {
        HUD = [[MBProgressHUD alloc] initWithView:self.window];
        [self.window addSubview:HUD];
        HUD.delegate = self;
        HUD.labelText = @"Loading . . .";
        
    }
    [HUD show:YES];
    [self.window performSelector:@selector(bringSubviewToFront:) withObject:HUD afterDelay:0.1];
    NSLog(@"Hud Shown");
}


-(void)hide_LoadingIndicator
{
    if(HUD)
    {
        [HUD hide:YES];
    }
    NSLog(@"Hud hidden");
}

-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    [audioPlayer stop];
    audioPlayer.delegate = nil;
    audioPlayer = nil;
//    [launchImage removeFromSuperview];
    
}



@end
