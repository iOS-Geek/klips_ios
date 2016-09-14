//
//  PlayVideoVC.m
//  Klips
//
//  Created by iOS Developer on 18/12/15.
//  Copyright © 2015 iOS Developer. All rights reserved.
//

#import "PlayVideoVC.h"

@interface PlayVideoVC ()
{
    AVPlayer *player;
    AppDelegate *appDelegate;
    UIStoryboard *storyboard;
    UIButton *cancelBtn;
    UITapGestureRecognizer *controlTap;
}

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *fullTopConst;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *fullBottomConst;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topScrubConst; //15
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rightScrubConst; //32
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rightTimeConst; //20
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rightTimeBotConst; //71
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leftTimeBotConst; //71

@end

@implementation PlayVideoVC
int playCount = 0;
CMTime duration;
CMTime durationDone;
bool isPaused;
bool isFull;
bool show;
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    appDelegate=(AppDelegate*)[[UIApplication sharedApplication]delegate];
    
    if (appDelegate.loggedInAsGuest) {
        self.favButton.enabled = NO;
        self.playlistButton.enabled = NO;
    }
    
    storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
   
}


-(void)viewWillAppear:(BOOL)animated
{
    
    controlTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissView)];
    
    isFull = NO;
    
    self.fullTopConst.constant = 60;
    self.fullBottomConst.constant = 185;
    [self.viewPlayerContainer setNeedsUpdateConstraints];
    [self.viewPlayerContainer layoutIfNeeded];
    
  [self setupProperties];
}

-(void)setupProperties
{
    NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:self.imageUrlString]];
    self.videoImage.image = [UIImage imageWithData:imageData];
    
    self.titleLabel.text = self.titleLabelString;
    
    if ([self.favStatus isEqualToString:@"1"])
    {
        [self.favButton setBackgroundImage:[UIImage imageNamed:@"fav-red.png"] forState:UIControlStateNormal];
    }
    else{
        [self.favButton setBackgroundImage:[UIImage imageNamed:@"fav-white.png"] forState:UIControlStateNormal];
    }
    
    if ([self.playlistStatus isEqualToString:@"1"])
    {
        [self.playlistButton setBackgroundImage:[UIImage imageNamed:@"add-play-red.png"] forState:UIControlStateNormal];
    }
    else{
        [self.playlistButton setBackgroundImage:[UIImage imageNamed:@"add-play.png"] forState:UIControlStateNormal];
    }
    
    [self setup];
    [self setSlider];
}

#pragma mark - Video player setup

-(void)setup
{
    
    AVPlayerViewController *playerViewController = [[AVPlayerViewController alloc] init];
    playerViewController.videoGravity = AVLayerVideoGravityResizeAspect;
    playerViewController.showsPlaybackControls = NO;
    NSURL *url = [NSURL URLWithString:self.playerUrlString];
    AVURLAsset *asset = [AVURLAsset assetWithURL: url];
    AVPlayerItem *item = [AVPlayerItem playerItemWithAsset: asset];
    player = [[AVPlayer alloc] initWithPlayerItem: item];
    [playerViewController.view setFrame:CGRectMake(0, 0, _viewPlayerContainer.bounds.size.width, _viewPlayerContainer.bounds.size.height)];
    playerViewController.player = player;
    
    duration = player.currentItem.asset.duration;
    durationDone = [player currentTime];
    
    self.durationLabel.text = [self timeStringForDuration:duration];
    self.timeDoneLabel.text = [self timeStringForDuration:durationDone];
    self.TimeLeftLabel.text = [self timeStringForDuration:duration];
    
    [_viewPlayerContainer addSubview:playerViewController.view];
    
    cancelBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 25, 25)];
    cancelBtn.backgroundColor = [UIColor colorWithRed:51/255.0f green:51/255.0f blue:51/255.0f alpha:0.5];
    [cancelBtn setBackgroundImage:[UIImage imageNamed:@"Delete-50.png"] forState:UIControlStateNormal];
    [cancelBtn addTarget:self action:@selector(cancelButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [playerViewController.view addSubview:cancelBtn];
    
    cancelBtn.hidden = true;
    
    [player addObserver:self
             forKeyPath:@"rate"
                options:NSKeyValueObservingOptionNew
                context:NULL];
    
}

-(void)cancelButtonAction
{
    isFull = NO;
    
    [self.viewPlayerContainer removeGestureRecognizer:controlTap];
    
    NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
    [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
    
    self.fullTopConst.constant = 60;
    self.fullBottomConst.constant = 185;
    self.topScrubConst.constant = 15;
    self.leftTimeBotConst.constant = 71;
    self.rightTimeBotConst.constant = 71;
    self.rightTimeConst.constant = 20;
    self.rightScrubConst.constant = 32;
    self.titleLabel.hidden = false;
    self.durationLabel.hidden = false;
    self.videoImage.hidden = false;
    
    
    [self.viewPlayerContainer setNeedsUpdateConstraints];
    [self.viewPlayerContainer layoutIfNeeded];
    
    cancelBtn.hidden = true;
}

-(void)dismissView
{
    if (show) {
        self.controlView.hidden = YES;
        cancelBtn.hidden = YES;
        self.scrubber.hidden = YES;
        self.timeDoneLabel.hidden = YES;
        self.TimeLeftLabel.hidden = YES;
        show = NO;
    }
    else{
        self.controlView.hidden = NO;
        cancelBtn.hidden = NO;
        self.scrubber.hidden = NO;
        self.timeDoneLabel.hidden = NO;
        self.TimeLeftLabel.hidden = NO;
        show = YES;
    }
}

#pragma mark - Slider Setup

-(void)setSlider{
    
    [NSTimer scheduledTimerWithTimeInterval:0.001 target:self selector:@selector(updateSlider) userInfo:nil repeats:YES];
    isPaused = NO;
    self.scrubber.maximumValue = [self durationInSeconds];
    self.scrubber.minimumValue = 0.00000;
    self.scrubber.continuous = YES;
}

- (void)updateSlider {
    if (isPaused == NO) {
        
        self.scrubber.maximumValue = [self durationInSeconds];
        self.scrubber.value = [self currentTimeInSeconds];
        
        duration = player.currentItem.asset.duration;
        durationDone = [player currentTime];
        CMTime result = CMTimeSubtract(duration, durationDone);
        self.timeDoneLabel.text = [self timeStringForDuration:durationDone];
        self.TimeLeftLabel.text = [self timeStringForDuration:result];
        
    }
}

- (Float64)durationInSeconds {
    duration = player.currentItem.asset.duration;
    Float64 dur = CMTimeGetSeconds(duration);
    return dur;
}


- (Float64)currentTimeInSeconds {
    Float64 dur = CMTimeGetSeconds([player currentTime]);
    return dur;
}

-(IBAction)sliding:(id)sender{
    isPaused = YES;
    [player pause];
}
- (IBAction)slidingFinished:(id)sender {
    CMTime showingTime = CMTimeMake(self.scrubber.value *1000, 1000);
    
    [player seekToTime:showingTime toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
    
    isPaused = NO;
    [player play];
}

#pragma mark - Navigation

- (IBAction)goBackHome:(id)sender {
    SWRevealViewController *viewController = (SWRevealViewController *)[storyboard instantiateViewControllerWithIdentifier:@"revealView"];
    [self presentViewController:viewController animated:YES completion:nil];
}

- (IBAction)backAction:(id)sender {
    [player pause];
    [player removeObserver:self forKeyPath:@"rate"];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Handling play/pause

- (IBAction)playVideo:(id)sender {
    playCount++;
    if (playCount%2 == 0) {
        [sender setBackgroundImage:[UIImage imageNamed:@"play.png"] forState:UIControlStateNormal];
        [player pause];
    }else{
        [sender setBackgroundImage:[UIImage imageNamed:@"pause_circle_filled.png"] forState:UIControlStateNormal];
        [player play];
    }
    
}

#pragma mark - Share Action

- (IBAction)shareButtonAction:(id)sender {
    
    // NSString *myWebsite = self.playerUrlString;
    
    NSString *informatory = @"Check out this video link:";
    NSURL *myWebsite = [NSURL URLWithString:self.playerUrlString];
    
    NSArray *objectsToShare = @[informatory,myWebsite];
    
    UIActivityViewController *activityVw = [[UIActivityViewController alloc] initWithActivityItems:objectsToShare applicationActivities:nil];
    
    [self presentViewController:activityVw animated:YES completion:nil];
    
    
    //    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    //    {
    //        NSLog(@"iPad");
    //        activityVw.popoverPresentationController.sourceView = self.view;
    //        //        activityViewController.popoverPresentationController.sourceRect = self.frame;
    //        [self presentViewController:activityVw
    //                           animated:YES
    //                         completion:nil];
    //    }
    //    else
    //    {
    //        NSLog(@"iPhone");
    //        [self presentViewController:activityVw
    //                           animated:YES
    //                         completion:nil];
    //    }
    
}

#pragma mark - Next/previous handling

- (IBAction)previousItem:(id)sender {
    
    self.index--;
    
    if (self.index < 0) {
        self.index = (int)self.passedArrayOfSongs.count - 1;
    }
    ArtistMusic *artistmusic=(ArtistMusic*)[self.passedArrayOfSongs objectAtIndex:self.index];
    self.playerUrlString = artistmusic.musicFileUrlString;
    self.titleLabelString = artistmusic.musicNameString;
    self.imageUrlString = artistmusic.musicImageUrlString;
    self.favStatus = artistmusic.musicFavoriteStatus;
    self.playlistStatus = artistmusic.musicPlaylistStatus;
    self.idString = artistmusic.musicIdString;
    
    [self setupProperties];
}

- (IBAction)nextItem:(id)sender {
    
    self.index++;
    
    if (self.index >= self.passedArrayOfSongs.count) {
        self.index = 0;
    }
    
    ArtistMusic *artistmusic=(ArtistMusic*)[self.passedArrayOfSongs objectAtIndex:self.index];
    self.playerUrlString = artistmusic.musicFileUrlString;
    self.titleLabelString = artistmusic.musicNameString;
    self.imageUrlString = artistmusic.musicImageUrlString;
    self.favStatus = artistmusic.musicFavoriteStatus;
    self.playlistStatus = artistmusic.musicPlaylistStatus;
    self.idString = artistmusic.musicIdString;
    
    [self setupProperties];
}

#pragma mark - Getting data from Server

-(void)getDataFor:(NSString*)serverString usingParameters:(NSMutableDictionary*)dictionary


{
    [RequestManager getFromServer:serverString parameters:dictionary completionHandler:^(NSDictionary *responseDict){
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:[responseDict valueForKey:@"message"] preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:ok];
        [self presentViewController:alertController animated:YES completion:nil];
        
        
    }];
    
    
    
}

#pragma mark - Make favorite action

- (IBAction)addFavoriteAction:(id)sender {
    
    if ([self.favStatus isEqualToString:@"1"]) {
        self.favStatus = @"0";
        [self.favButton setBackgroundImage:[UIImage imageNamed:@"fav-white.png"] forState:UIControlStateNormal];
    }
    else if ([self.favStatus isEqualToString:@"0"]){
        self.favStatus = @"1";
        [self.favButton setBackgroundImage:[UIImage imageNamed:@"fav-red.png"] forState:UIControlStateNormal];
    }
    
    
    if (appDelegate.isMusic) {
        
        [self getDataFor:@"favourite_music_operations" usingParameters:[NSMutableDictionary dictionaryWithObjectsAndKeys:[[NSUserDefaults standardUserDefaults] objectForKey:@"logged_user_id"],@"user_id",[[NSUserDefaults standardUserDefaults] objectForKey:@"logged_user_security_hash"],@"user_security_hash",self.idString,@"music_id",self.favStatus,@"music_favourite_status", nil]];
        
    }
    else{
        [self getDataFor:@"favourite_video_operations" usingParameters:[NSMutableDictionary dictionaryWithObjectsAndKeys:[[NSUserDefaults standardUserDefaults] objectForKey:@"logged_user_id"],@"user_id",[[NSUserDefaults standardUserDefaults] objectForKey:@"logged_user_security_hash"],@"user_security_hash",self.idString,@"video_id",self.favStatus,@"video_favourite_status", nil]];
    }
}

#pragma mark - Add to playlist Action

- (IBAction)addToPlaylistAction:(id)sender {
    if ([self.playlistStatus isEqualToString:@"1"]) {
        self.playlistStatus = @"0";
        [self.playlistButton setBackgroundImage:[UIImage imageNamed:@"add-play.png"] forState:UIControlStateNormal];
        
    }
    else if ([self.playlistStatus isEqualToString:@"0"]){
        self.playlistStatus = @"1";
        [self.playlistButton setBackgroundImage:[UIImage imageNamed:@"add-play-red.png"] forState:UIControlStateNormal];
    }
    
    if (appDelegate.isMusic) {
        
        [self getDataFor:@"music_playlist_operations" usingParameters:[NSMutableDictionary dictionaryWithObjectsAndKeys:[[NSUserDefaults standardUserDefaults] objectForKey:@"logged_user_id"],@"user_id",[[NSUserDefaults standardUserDefaults] objectForKey:@"logged_user_security_hash"],@"user_security_hash",self.idString,@"music_id",self.playlistStatus,@"music_status_id", nil]];
        
    }
    else{
        [self getDataFor:@"video_playlist_operations" usingParameters:[NSMutableDictionary dictionaryWithObjectsAndKeys:[[NSUserDefaults standardUserDefaults] objectForKey:@"logged_user_id"],@"user_id",[[NSUserDefaults standardUserDefaults] objectForKey:@"logged_user_security_hash"],@"user_security_hash",self.idString,@"video_id",self.playlistStatus,@"video_status_id", nil]];
    }
    
}

#pragma mark - Full screen action

- (IBAction)enterFullScreenMode:(id)sender {
    
    isFull = YES;
    
    [self.viewPlayerContainer addGestureRecognizer:controlTap];
    
    NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationLandscapeLeft];
    [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
    
    cancelBtn.hidden = false;
    
    self.fullTopConst.constant = 0;
    self.fullBottomConst.constant = 0;
    self.topScrubConst.constant = 82;
    self.leftTimeBotConst.constant = 4;
    self.rightTimeBotConst.constant = 4;
    self.rightTimeConst.constant = 175;
    self.rightScrubConst.constant = 187;
    self.titleLabel.hidden = true;
    self.durationLabel.hidden = true;
    self.videoImage.hidden = true;
    
    show = YES;
    
    [self.viewPlayerContainer setNeedsUpdateConstraints];
    [self.viewPlayerContainer layoutIfNeeded];

    [self.view bringSubviewToFront:self.controlView];
    [self.view bringSubviewToFront:self.scrubber];
    [self.view bringSubviewToFront:self.timeDoneLabel];
    [self.view bringSubviewToFront:self.TimeLeftLabel];
    
//    self.viewPlayerContainer.transform = CGAffineTransformRotate(self.viewPlayerContainer.transform, (M_PI / 2.0));
}

#pragma mark - adding observer to player

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSString *,id> *)change
                       context:(void *)context {
    if ([keyPath isEqualToString:@"rate"]) {
        float rate = [change[NSKeyValueChangeNewKey] floatValue];
        if (rate == 0.0) {
            // Playback stopped
            
            duration = player.currentItem.asset.duration;
            durationDone = [player currentTime];
            
            
            if (CMTimeCompare(durationDone, duration) == 0) {
                player.actionAtItemEnd = AVPlayerActionAtItemEndPause;
                [self.playPauseButton setBackgroundImage:[UIImage imageNamed:@"play.png"] forState:UIControlStateNormal];
                playCount = 0;
                [player seekToTime:kCMTimeZero];
            }
        } else if (rate == 1.0) {
            // Normal playback
            
        } else if (rate == -1.0) {
            // Reverse playback
        }
    }
}

-(NSString*)timeStringForDuration:(CMTime)time
{
    NSUInteger durationSeconds = (long)CMTimeGetSeconds(time);
    //    NSUInteger hours = floor(durationSeconds / 3600);
    NSUInteger minutes = floor(durationSeconds % 3600 / 60);
    NSUInteger seconds = floor(durationSeconds % 3600 % 60);
    //    NSString *timeString = [NSString stringWithFormat:@"%02ld:%02ld:%02ld", hours, minutes, seconds];
    //    NSLog(@"Time|%@", time);
    NSString *timeString = [NSString stringWithFormat:@"%02ld:%02ld",  (unsigned long)minutes, (unsigned long)seconds];
    return timeString;
}



#pragma mark - Orientation

- (UIInterfaceOrientationMask) supportedInterfaceOrientations {
    if (isFull) {
        return UIInterfaceOrientationMaskLandscapeLeft;
    }else
    {
    return UIInterfaceOrientationMaskPortrait;
    }
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
