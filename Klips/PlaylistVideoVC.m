//
//  PlaylistVideoVC.m
//  Klips
//
//  Created by iOS Developer on 16/12/15.
//  Copyright © 2015 iOS Developer. All rights reserved.
//

#import "PlaylistVideoVC.h"

@interface PlaylistVideoVC ()
{
    NSMutableArray * pagedVideoArray;
    NSArray *displayVideoArray;
    AppDelegate *appDelegate;
    UIStoryboard *storyboard;
}
@end

@implementation PlaylistVideoVC
@synthesize imageDownloadsInProgress;
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    appDelegate=(AppDelegate*)[[UIApplication sharedApplication]delegate];
    storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    
    SWRevealViewController *revealViewController = self.revealViewController;
    if ( revealViewController )
    {
        [self.sideMenuButton addTarget:self.revealViewController action:@selector( revealToggle: ) forControlEvents:UIControlEventTouchUpInside];
        [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    }
    self.tabBarItem.selectedImage = [[UIImage imageNamed:@"video-purple.png"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    self.tabBarItem.image = [[UIImage imageNamed:@"tab_video_white.png"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    
}

-(void)viewWillAppear:(BOOL)animated
{
    videoCounter = 0;
    imageDownloadsInProgress = [NSMutableDictionary dictionary];
    pagedVideoArray=[NSMutableArray array];
    displayVideoArray = [NSArray array];
    self.spinner.hidden = true;
    [self getData];
}

#pragma mark - Navigation

- (IBAction)goBackHome:(id)sender {
    SWRevealViewController *viewController = (SWRevealViewController *)[storyboard instantiateViewControllerWithIdentifier:@"revealView"];
    [self presentViewController:viewController animated:YES completion:nil];
}

#pragma mark - Getting data from Server

-(void)getData
{
    [RequestManager getFromServer:@"video_playlist" parameters:[NSMutableDictionary dictionaryWithObjectsAndKeys:[[NSUserDefaults standardUserDefaults] objectForKey:@"logged_user_id"],@"user_id",[[NSUserDefaults standardUserDefaults] objectForKey:@"logged_user_security_hash"],@"user_security_hash",[NSString stringWithFormat:@"%d",videoCounter],@"page", nil] completionHandler:^(NSDictionary *responseDict){
        
        
        if ([[responseDict valueForKey:@"code"] isEqualToString:@"1"]) {
            
            NSArray *dataArray=[responseDict valueForKey:@"data"];
            
            [pagedVideoArray removeAllObjects];
            
            for (NSDictionary *dic in dataArray) {
                ArtistMusic *artistmusic=[[ArtistMusic alloc]init];
                artistmusic.musicIdString=[dic valueForKey:@"video_id"];
                artistmusic.musicNameString=[dic valueForKey:@"video_name"];
                artistmusic.musicImageUrlString = [dic valueForKey:@"video_thumbnail_url"];
                artistmusic.musicFileUrlString = [dic valueForKey:@"video_file_url"];
                artistmusic.musicFavoriteStatus = [dic valueForKey:@"favourite_status"];
                artistmusic.musicPlaylistStatus = [dic valueForKey:@"playlist_status"];
                artistmusic.musicDescription = [dic valueForKey:@"video_description"];
                
                [pagedVideoArray addObject:artistmusic];
                
            }
            displayVideoArray = [displayVideoArray arrayByAddingObjectsFromArray:pagedVideoArray];
            [self.videoPlaylistTable reloadData];
            
        }
        else{
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:[responseDict valueForKey:@"message"] preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
            [alertController addAction:ok];
            [self presentViewController:alertController animated:YES completion:nil];
        }
        if ([self.spinner isAnimating]) {
            [self.spinner stopAnimating];
            self.spinner.hidden = true;
        }
    }];
    
    
    
}

#pragma mark - Tableview data source and delegates

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return displayVideoArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"videoPlaylistCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    ArtistMusic *artistmusic=(ArtistMusic*)[displayVideoArray objectAtIndex:indexPath.row];
    
    UIImageView *bigImgVw = (UIImageView *)[cell viewWithTag:62];
    UILabel *lbl = (UILabel *)[cell viewWithTag:63];
    UILabel *desLabel = (UILabel *)[cell viewWithTag:64];
    UIImageView *smallImgVw = (UIImageView *)[cell viewWithTag:65];
    
    UIButton *removeVidButton = (UIButton*)[cell viewWithTag:66];
    removeVidButton.tag = indexPath.row;
    [removeVidButton addTarget:self action:@selector(vidButtonClicked:) forControlEvents:UIControlEventTouchUpInside];

    
    desLabel.text = artistmusic.musicDescription;
    
    if (!artistmusic.post_image) {
        bigImgVw.image=nil;
        [self startIconDownload:artistmusic forIndexPath:indexPath];
    }
    else{
        bigImgVw.image=artistmusic.post_image;
    }
    
    smallImgVw.image = [UIImage imageNamed:@"play.png"];
    lbl.text = artistmusic.musicNameString;
    
    return cell;
    
}

-(void)vidButtonClicked:(id)sender
{
    
    [appDelegate show_LoadingIndicator];
    NSLog(@"tag number is = %ld",(long)[sender tag]);
    
    ArtistMusic *artistmusic=(ArtistMusic*)[displayVideoArray objectAtIndex:[sender tag]];
    NSString *mId = artistmusic.musicIdString;
    
    
    [RequestManager getFromServer:@"video_playlist_operations" parameters:[NSMutableDictionary dictionaryWithObjectsAndKeys:[[NSUserDefaults standardUserDefaults] objectForKey:@"logged_user_id"],@"user_id",[[NSUserDefaults standardUserDefaults] objectForKey:@"logged_user_security_hash"],@"user_security_hash",mId,@"video_id",@"0",@"video_status_id", nil] completionHandler:^(NSDictionary *responseDict){
        
        
        if ([[responseDict valueForKey:@"code"] isEqualToString:@"1"]) {
            
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:[responseDict valueForKey:@"message"] preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
                [pagedVideoArray removeAllObjects];
                pagedVideoArray = [displayVideoArray mutableCopy];
                [pagedVideoArray removeObjectAtIndex:[sender tag]];
                displayVideoArray = [NSArray arrayWithArray:pagedVideoArray];
                
                [self.videoPlaylistTable reloadData];
            }];
            [alertController addAction:ok];
            [self presentViewController:alertController animated:YES completion:nil];
            
        }
        [appDelegate hide_LoadingIndicator];
    }];
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [appDelegate show_LoadingIndicator];
    PlayVideoVC *viewController = (PlayVideoVC *)[storyboard instantiateViewControllerWithIdentifier:@"videoView"];
    ArtistMusic *artistmusic=(ArtistMusic*)[displayVideoArray objectAtIndex:indexPath.row];
    viewController.playerUrlString = artistmusic.musicFileUrlString;
    viewController.titleLabelString = artistmusic.musicNameString;
    viewController.imageUrlString = artistmusic.musicImageUrlString;
    viewController.favStatus = artistmusic.musicFavoriteStatus;
    viewController.playlistStatus = artistmusic.musicPlaylistStatus;
    viewController.idString = artistmusic.musicIdString;
    viewController.passedArrayOfSongs = displayVideoArray;
    viewController.index = (int)indexPath.row;
    [self presentViewController:viewController animated:YES completion:^{
        [appDelegate hide_LoadingIndicator];
        appDelegate.isMusic = NO;
    }];
    
}

#pragma mark - ScrollView delegate for refreshing table with contents on next page

-(void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset{
    
    if(self.videoPlaylistTable.contentOffset.y<0){
        //it means table view is pulled down like refresh
        return;
    }
    else if(self.videoPlaylistTable.contentOffset.y >= (self.videoPlaylistTable.contentSize.height - self.videoPlaylistTable.bounds.size.height)) {
        NSLog(@"bottom!");
        self.spinner.hidden = false;
        [self.spinner startAnimating];
        [self refreshPulled];
    }
    
}

-(void)refreshPulled
{
    [pagedVideoArray removeAllObjects];
    videoCounter++;
    [self getData];
    
}

#pragma mark - Setting up Icon Downloader

- (void)startIconDownload:(ArtistMusic *)appRecord forIndexPath:(NSIndexPath *)indexPath
{
    IconDownloader *iconDownloader = (imageDownloadsInProgress)[indexPath];
    if (iconDownloader == nil)
    {
        iconDownloader = [[IconDownloader alloc] init];
        iconDownloader.results = appRecord;
        [iconDownloader setCompletionHandler:^{
            
            UITableViewCell *cell = (UITableViewCell*)[self.videoPlaylistTable cellForRowAtIndexPath:indexPath];
            UIImageView *bigImgVw = (UIImageView *)[cell viewWithTag:62];
            // Display the newly loaded image
            bigImgVw.image = appRecord.post_image;
            
            // Remove the IconDownloader from the in progress list.
            // This will result in it being deallocated.
            [self.imageDownloadsInProgress removeObjectForKey:indexPath];
            
        }];
        (self.imageDownloadsInProgress)[indexPath] = iconDownloader;
        [iconDownloader startDownloadFor:@"artistmusic"];
    }
}

- (void)terminateAllDownloads
{
    // terminate all pending download connections
    NSArray *allDownloads = [imageDownloadsInProgress allValues];
    [allDownloads makeObjectsPerformSelector:@selector(cancelDownload)];
    
    [imageDownloadsInProgress removeAllObjects];
}

- (void)dealloc
{
    // terminate all pending download connections
    [self terminateAllDownloads];
}


#pragma mark - Orientation

- (UIInterfaceOrientationMask) supportedInterfaceOrientations {
    
    return UIInterfaceOrientationMaskPortrait;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    [self terminateAllDownloads];
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
