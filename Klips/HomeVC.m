
//
//  HomeVC.m
//  Klips
//
//  Created by iOS Developer on 14/12/15.
//  Copyright © 2015 iOS Developer. All rights reserved.
//

#import "HomeVC.h"

@interface HomeVC ()
{
    UIStoryboard *storyboard;
    DisplayScrollDataVC *dataScrollViewController;
    AppDelegate *appDelegate;
    NSMutableArray * initialArray;
    NSArray *finalArray;
}
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConst;

@end

@implementation HomeVC
bool isTrending;

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    isTrending = NO;
    self.hiddenView.alpha = 0;
    
    appDelegate=(AppDelegate*)[[UIApplication sharedApplication]delegate];
    
    SWRevealViewController *revealViewController = self.revealViewController;
    if ( revealViewController )
    {
        [self.sideMenuButton addTarget:self.revealViewController action:@selector( revealToggle: ) forControlEvents:UIControlEventTouchUpInside];
        [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    }
    
    storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
}

-(void)viewWillAppear:(BOOL)animated
{
    initialArray=[NSMutableArray array];
    finalArray = [NSArray array];
    
    self.bottomConst.constant = -80;
    [self.languageMenuView setNeedsUpdateConstraints];
    [self.languageMenuView layoutIfNeeded];
    
    dataScrollViewController = (DisplayScrollDataVC *)[storyboard instantiateViewControllerWithIdentifier:@"dataView"];
    
    self.arabicBtn.layer.cornerRadius = 3;
    self.arabicBtn.clipsToBounds = true;
    self.englishBtn.layer.cornerRadius = 3;
    self.englishBtn.clipsToBounds = true;


}

-(void)viewDidAppear:(BOOL)animated
{
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"user_language"])
    {
        self.hiddenView.alpha = 0;
        self.bottomConst.constant = -80;
        [self.languageMenuView setNeedsUpdateConstraints];
        [self.languageMenuView layoutIfNeeded];
        
        if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"user_language"] isEqualToString:@"1"]) {
            [self.arabicBtn setBackgroundColor:[UIColor clearColor]];
            [self.englishBtn setBackgroundColor:[UIColor colorWithRed:206/255.0f green:62/255.0f blue:67/255.0f alpha:1.0]];
        }
        else
        {
            [self.englishBtn setBackgroundColor:[UIColor clearColor]];
            [self.arabicBtn setBackgroundColor:[UIColor colorWithRed:206/255.0f green:62/255.0f blue:67/255.0f alpha:1.0]];
        }
    }
    else
    {
        if (appDelegate.showLanguageAlert)
        {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Select Content Language" message:@"You can change content language anytime by selecting arrow below." preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
                
                self.downArrowBtn.enabled = NO;
                
                self.bottomConst.constant = 0;
                [self.languageMenuView setNeedsUpdateConstraints];
                
                [UIView animateWithDuration:0.6f delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
                    
                    [self.languageMenuView layoutIfNeeded];
                    
                    self.hiddenView.alpha = 1;
                    self.upArrowImageView.alpha = 0;
                    
                } completion:nil];
                
            }];
            [alertController addAction:ok];
            [self presentViewController:alertController animated:YES completion:nil];
        }
    }
}

#pragma mark - Getting data from Server

-(void)getDataFromServer:(NSString*)server


{
    
    NSLog(@"over her over here :::: %@",[[NSUserDefaults standardUserDefaults] objectForKey:@"user_language"]);
    
    [RequestManager getFromServer:server parameters:[NSMutableDictionary dictionaryWithObjectsAndKeys:[[NSUserDefaults standardUserDefaults] objectForKey:@"user_language"],@"user_language", nil] completionHandler:^(NSDictionary *responseDict){
        
        
        if ([[responseDict valueForKey:@"code"] isEqualToString:@"1"])
        {
            
            NSArray *dataArray=[responseDict valueForKey:@"data"];
            
            [initialArray removeAllObjects];
            
            for (NSDictionary *dic in dataArray) {
                ArtistMusic *artistmusic=[[ArtistMusic alloc]init];
                artistmusic.musicIdString=[dic valueForKey:@"music_id"];
                artistmusic.musicNameString=[dic valueForKey:@"music_name"];
                artistmusic.musicImageUrlString = [dic valueForKey:@"music_thumbnail_url"];
                artistmusic.musicFileUrlString = [dic valueForKey:@"music_file_url"];
                artistmusic.musicFavoriteStatus = [dic valueForKey:@"favourite_status"];
                artistmusic.musicPlaylistStatus = [dic valueForKey:@"playlist_status"];
                
                NSArray *receivedArr = [dic valueForKey:@"artist_details"];
                
                artistmusic.artistDetails=[NSMutableArray array];
                
                for (NSDictionary *val in receivedArr) {
                    [artistmusic.artistDetails addObject:[val valueForKey:@"artist_name"]];
                    
                }
                [initialArray addObject:artistmusic];
                
            }
            finalArray = [finalArray arrayByAddingObjectsFromArray:initialArray];
            
            if (finalArray.count == 0) {
                [appDelegate hide_LoadingIndicator];
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:@"There is no video available!!" preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
                [alertController addAction:ok];
                [self presentViewController:alertController animated:YES completion:nil];
                
            }
            else
            {
            [self success];
            }
        }
        else
        {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:[responseDict valueForKey:@"message"] preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
            [alertController addAction:ok];
            [self presentViewController:alertController animated:YES completion:nil];
        }
        
    }];
    
    
    
}

#pragma mark - Navigation

-(void)success
{
    if (isTrending) {
        SingleCategoryDataVC *viewController = (SingleCategoryDataVC *)[storyboard instantiateViewControllerWithIdentifier:@"singleView"];
        
        NSString *header = @"Trendings";
        viewController.categoryTitleString = header;
        viewController.passedArr = finalArray;
        viewController.passedServer = header;
        [self presentViewController:viewController animated:YES completion:^{
            [appDelegate hide_LoadingIndicator];
        }];
        
    }
    else
    {
                    PlayVideoVC *viewController = (PlayVideoVC *)[storyboard instantiateViewControllerWithIdentifier:@"videoView"];
            ArtistMusic *artistmusic=(ArtistMusic*)[finalArray objectAtIndex:0];
            viewController.playerUrlString = artistmusic.musicFileUrlString;
            viewController.titleLabelString = artistmusic.musicNameString;
            viewController.imageUrlString = artistmusic.musicImageUrlString;
            viewController.favStatus = artistmusic.musicFavoriteStatus;
            viewController.playlistStatus = artistmusic.musicPlaylistStatus;
            viewController.idString = artistmusic.musicIdString;
            viewController.passedArrayOfSongs = finalArray;
            viewController.index = 0;
            [self presentViewController:viewController animated:YES completion:^{
                appDelegate.isMusic = YES;
                [appDelegate playCountWithId:artistmusic.musicIdString];
                [appDelegate hide_LoadingIndicator];
            }];

        
    }
}

#pragma mark - Button Actions

- (IBAction)showVideoData:(id)sender {
    dataScrollViewController.passedServerString = @"get_videos";
    dataScrollViewController.headerString = @"Videos";
    [appDelegate show_LoadingIndicator];
    [self presentViewController:dataScrollViewController animated:YES completion:nil];
}
- (IBAction)showMusicData:(id)sender {
    dataScrollViewController.passedServerString = @"get_musics";
    dataScrollViewController.headerString = @"Music";
    [appDelegate show_LoadingIndicator];
    [self presentViewController:dataScrollViewController animated:YES completion:nil];
}
- (IBAction)showQuotesData:(id)sender {
    dataScrollViewController.passedServerString = @"get_quotes";
    dataScrollViewController.headerString = @"Quotes";
    [appDelegate show_LoadingIndicator];
    [self presentViewController:dataScrollViewController animated:YES completion:nil];
}
- (IBAction)showImagesData:(id)sender {
    dataScrollViewController.passedServerString = @"get_images";
    dataScrollViewController.headerString = @"Images";
    [appDelegate show_LoadingIndicator];
    [self presentViewController:dataScrollViewController animated:YES completion:nil];
}
- (IBAction)feelingLuckyAction:(id)sender {
    isTrending = NO;
    [appDelegate show_LoadingIndicator];
    [self getDataFromServer:@"random_musics"];
    
}
- (IBAction)getTrendingMusic:(id)sender {
    isTrending = YES;
    [appDelegate show_LoadingIndicator];
    [self getDataFromServer:@"trending_musics"];
}
- (IBAction)gotoFavoritesAction:(id)sender {
    
    if (appDelegate.loggedInAsGuest == YES) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"You Are Not Logged In!!" message:@"Please log in to your account." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:ok];
        [self presentViewController:alertController animated:YES completion:nil];
    }
    else
    {
        UITabBarController *viewController = (UITabBarController*)[storyboard instantiateViewControllerWithIdentifier: @"favoritesTabBar"];
        [self.revealViewController pushFrontViewController:viewController animated:YES];
    }
}
- (IBAction)gotoPlaylistAction:(id)sender {
    
    if (appDelegate.loggedInAsGuest == YES) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"You Are Not Logged In!!" message:@"Please log in to your account." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:ok];
        [self presentViewController:alertController animated:YES completion:nil];
    }
    else
    {
        UITabBarController *viewController = (UITabBarController*)[storyboard instantiateViewControllerWithIdentifier: @"playlistTabBar"];
        [self.revealViewController pushFrontViewController:viewController animated:YES];
    }
}

- (IBAction)searchAction:(id)sender {
    
    SearchVC *viewcontroller = (SearchVC*)[storyboard instantiateViewControllerWithIdentifier: @"searchView"];
    [self presentViewController:viewcontroller animated:YES completion:nil];
    
}

#pragma mark - Selecting language

- (IBAction)showLanguageMenu:(id)sender {
    
    self.bottomConst.constant = 0;
    [self.languageMenuView setNeedsUpdateConstraints];
    
    [UIView animateWithDuration:0.4f delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        
        [self.languageMenuView layoutIfNeeded];
        
        self.hiddenView.alpha = 1;
        
        self.upArrowImageView.alpha = 0;
        
    } completion:nil];
    
}

- (IBAction)hideLanguageMenu:(id)sender {
    
    self.bottomConst.constant = -80;
    [self.languageMenuView setNeedsUpdateConstraints];
    
    [UIView animateWithDuration:0.4f delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        
        [self.languageMenuView layoutIfNeeded];
        
        self.hiddenView.alpha = 0;
        
        self.upArrowImageView.alpha = 1;
        
    } completion:nil];
    
}

- (IBAction)btnClick:(id)sender {
    
    self.downArrowBtn.enabled = YES;
    
    appDelegate.showLanguageAlert = NO;
    
    if (self.arabicBtn == sender) {
        
        [self.arabicBtn setBackgroundColor:[UIColor colorWithRed:206/255.0f green:62/255.0f blue:67/255.0f alpha:1.0]];
        [self.englishBtn setBackgroundColor:[UIColor clearColor]];
        
        [[NSUserDefaults standardUserDefaults] setObject:@"2" forKey:@"user_language"];
        
    }else{
        
        [self.arabicBtn setBackgroundColor:[UIColor clearColor]];
        [self.englishBtn setBackgroundColor:[UIColor colorWithRed:206/255.0f green:62/255.0f blue:67/255.0f alpha:1.0]];
        
        [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"user_language"];
    }
    
    [self hideLanguageMenu:nil];
}

#pragma mark - Orientation

- (UIInterfaceOrientationMask) supportedInterfaceOrientations {
    
    return UIInterfaceOrientationMaskPortrait;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
