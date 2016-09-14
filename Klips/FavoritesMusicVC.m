//
//  FavoritesMusicVC.m
//  Klips
//
//  Created by iOS Developer on 16/12/15.
//  Copyright © 2015 iOS Developer. All rights reserved.
//

#import "FavoritesMusicVC.h"

@interface FavoritesMusicVC ()
{
    NSMutableArray * pagedFavMusicArray;
    NSArray *displayFavMusicArray;
    AppDelegate *appDelegate;
    UIStoryboard *storyboard;
}
@end

@implementation FavoritesMusicVC

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
    self.tabBarItem.selectedImage = [[UIImage imageNamed:@"song-purple.png"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    self.tabBarItem.image = [[UIImage imageNamed:@"tab_music_white.png"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    }

-(void)viewWillAppear:(BOOL)animated
{
    favMusicCounter = 0;
    imageDownloadsInProgress = [NSMutableDictionary dictionary];
    pagedFavMusicArray=[NSMutableArray array];
    displayFavMusicArray = [NSArray array];
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
    [RequestManager getFromServer:@"favourite_musics" parameters:[NSMutableDictionary dictionaryWithObjectsAndKeys:[[NSUserDefaults standardUserDefaults] objectForKey:@"logged_user_id"],@"user_id",[[NSUserDefaults standardUserDefaults] objectForKey:@"logged_user_security_hash"],@"user_security_hash",[NSString stringWithFormat:@"%d",favMusicCounter],@"page", nil] completionHandler:^(NSDictionary *responseDict){
        
        
        if ([[responseDict valueForKey:@"code"] isEqualToString:@"1"]) {
            
            NSArray *dataArray=[responseDict valueForKey:@"data"];
            
            [pagedFavMusicArray removeAllObjects];
            
            for (NSDictionary *dic in dataArray) {
                ArtistMusic *artistmusic=[[ArtistMusic alloc]init];
                artistmusic.musicIdString=[dic valueForKey:@"music_id"];
                artistmusic.musicNameString=[dic valueForKey:@"music_name"];
                artistmusic.musicImageUrlString = [dic valueForKey:@"music_thumbnail_url"];
                artistmusic.musicFileUrlString = [dic valueForKey:@"music_file_url"];
                artistmusic.musicFavoriteStatus = [dic valueForKey:@"favourite_status"];
                artistmusic.musicPlaylistStatus = [dic valueForKey:@"playlist_status"];
                artistmusic.musicDescription = [dic valueForKey:@"music_description"];
                
                NSArray *receivedArr = [dic valueForKey:@"artist_details"];
                
                artistmusic.artistDetails=[NSMutableArray array];
                
                for (NSDictionary *val in receivedArr) {
                    [artistmusic.artistDetails addObject:[val valueForKey:@"artist_name"]];
                    
                }
                [pagedFavMusicArray addObject:artistmusic];
                
            }
            displayFavMusicArray = [displayFavMusicArray arrayByAddingObjectsFromArray:pagedFavMusicArray];
            [self.favoriteMusicTable reloadData];
            
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

#pragma mark - TableView data source and delegate

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return displayFavMusicArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"musicFavoriteCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    ArtistMusic *artistmusic=(ArtistMusic*)[displayFavMusicArray objectAtIndex:indexPath.row];
    
    UIImageView *bigImgVw = (UIImageView *)[cell viewWithTag:66];
    UILabel *lbl = (UILabel *)[cell viewWithTag:67];
    UIImageView *smallImgVw = (UIImageView *)[cell viewWithTag:69];
    UILabel *lblDes = (UILabel *)[cell viewWithTag:68];
    
    UIButton *removeButton = (UIButton*)[cell viewWithTag:70];
    removeButton.tag = indexPath.row;
    [removeButton addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    
    if (!artistmusic.post_image) {
        bigImgVw.image=nil;
        [self startIconDownload:artistmusic forIndexPath:indexPath];
    }
    else{
        bigImgVw.image=artistmusic.post_image;
    }
    
    smallImgVw.image = [UIImage imageNamed:@"play.png"];
    lbl.text = artistmusic.musicNameString;
    
    lblDes.text = artistmusic.musicDescription;
    
    return cell;
    
}

-(void)buttonClicked:(id)sender
{
    
    [appDelegate show_LoadingIndicator];
    NSLog(@"tag number is = %ld",(long)[sender tag]);
    
    ArtistMusic *artistmusic=(ArtistMusic*)[displayFavMusicArray objectAtIndex:[sender tag]];
    NSString *mId = artistmusic.musicIdString;
    
    
    [RequestManager getFromServer:@"favourite_music_operations" parameters:[NSMutableDictionary dictionaryWithObjectsAndKeys:[[NSUserDefaults standardUserDefaults] objectForKey:@"logged_user_id"],@"user_id",[[NSUserDefaults standardUserDefaults] objectForKey:@"logged_user_security_hash"],@"user_security_hash",mId,@"music_id",@"0",@"music_favourite_status", nil] completionHandler:^(NSDictionary *responseDict){
        
        
        if ([[responseDict valueForKey:@"code"] isEqualToString:@"1"]) {
            
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:[responseDict valueForKey:@"message"] preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
                [pagedFavMusicArray removeAllObjects];
                pagedFavMusicArray = [displayFavMusicArray mutableCopy];
                [pagedFavMusicArray removeObjectAtIndex:[sender tag]];
                displayFavMusicArray = [NSArray arrayWithArray:pagedFavMusicArray];
                
                [self.favoriteMusicTable reloadData];
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
    ArtistMusic *artistmusic=(ArtistMusic*)[displayFavMusicArray objectAtIndex:indexPath.row];
    viewController.playerUrlString = artistmusic.musicFileUrlString;
    viewController.titleLabelString = artistmusic.musicNameString;
    viewController.imageUrlString = artistmusic.musicImageUrlString;
    viewController.favStatus = artistmusic.musicFavoriteStatus;
    viewController.playlistStatus = artistmusic.musicPlaylistStatus;
    viewController.idString = artistmusic.musicIdString;
    viewController.passedArrayOfSongs = displayFavMusicArray;
    viewController.index = (int)indexPath.row;
    [self presentViewController:viewController animated:YES completion:^{
        [appDelegate hide_LoadingIndicator];
        appDelegate.isMusic = YES;
        [appDelegate playCountWithId:artistmusic.musicIdString];
    }];
    
}

#pragma mark - ScrollView delegate for refreshing table with contents on next page

-(void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset{
    
    if(self.favoriteMusicTable.contentOffset.y<0){
        //it means table view is pulled down like refresh
        return;
    }
    else if(self.favoriteMusicTable.contentOffset.y >= (self.favoriteMusicTable.contentSize.height - self.favoriteMusicTable.bounds.size.height)) {
        NSLog(@"bottom!");
        self.spinner.hidden = false;
        [self.spinner startAnimating];
        [self refreshPulled];
    }
    
}

-(void)refreshPulled
{
    [pagedFavMusicArray removeAllObjects];
    favMusicCounter++;
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
            
            UITableViewCell *cell = (UITableViewCell*)[self.favoriteMusicTable cellForRowAtIndexPath:indexPath];
            UIImageView *bigImgVw = (UIImageView *)[cell viewWithTag:66];
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
