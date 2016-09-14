//
//  PlaylistMusicVC.m
//  Klips
//
//  Created by iOS Developer on 16/12/15.
//  Copyright © 2015 iOS Developer. All rights reserved.
//

#import "PlaylistMusicVC.h"

@interface PlaylistMusicVC ()
{
    NSMutableArray * pagedMusicArray;
    NSArray *displayMusicArray;
    AppDelegate *appDelegate;
    UIStoryboard *storyboard;
}
@end

@implementation PlaylistMusicVC

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
    musicCounter = 0;
    imageDownloadsInProgress = [NSMutableDictionary dictionary];
    pagedMusicArray=[NSMutableArray array];
    displayMusicArray = [NSArray array];
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
    [RequestManager getFromServer:@"music_playlist" parameters:[NSMutableDictionary dictionaryWithObjectsAndKeys:[[NSUserDefaults standardUserDefaults] objectForKey:@"logged_user_id"],@"user_id",[[NSUserDefaults standardUserDefaults] objectForKey:@"logged_user_security_hash"],@"user_security_hash",[NSString stringWithFormat:@"%d",musicCounter],@"page", nil] completionHandler:^(NSDictionary *responseDict){
        
        
        if ([[responseDict valueForKey:@"code"] isEqualToString:@"1"]) {
            
            NSArray *dataArray=[responseDict valueForKey:@"data"];
            
            [pagedMusicArray removeAllObjects];
            
            for (NSDictionary *dic in dataArray) {
                ArtistMusic *artistmusic=[[ArtistMusic alloc]init];
                artistmusic.musicIdString=[dic valueForKey:@"music_id"];
                artistmusic.musicNameString=[dic valueForKey:@"music_name"];
                artistmusic.musicImageUrlString = [dic valueForKey:@"music_thumbnail_url"];
                artistmusic.musicFileUrlString = [dic valueForKey:@"music_file_url"];
                artistmusic.musicFavoriteStatus = [dic valueForKey:@"favourite_status"];
                artistmusic.musicPlaylistStatus = [dic valueForKey:@"playlist_status"];
                artistmusic.musicDescription = [dic valueForKey:@"music_description"];
                
                [pagedMusicArray addObject:artistmusic];
                
            }
            displayMusicArray = [displayMusicArray arrayByAddingObjectsFromArray:pagedMusicArray];
            [self.userMusicPlaylistTable reloadData];
            
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

#pragma mark - Tableview datasource and delegate

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return displayMusicArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"musicPlaylistCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    ArtistMusic *artistmusic=(ArtistMusic*)[displayMusicArray objectAtIndex:indexPath.row];

    UIImageView *bigImgVw = (UIImageView *)[cell viewWithTag:58];
    UILabel *lbl = (UILabel *)[cell viewWithTag:59];
    UILabel *desLabel = (UILabel *)[cell viewWithTag:60];
    UIImageView *smallImgVw = (UIImageView *)[cell viewWithTag:61];
    
    UIButton *removeButton = (UIButton*)[cell viewWithTag:62];
    removeButton.tag = indexPath.row;
    [removeButton addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
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

-(void)buttonClicked:(id)sender
{
    
    [appDelegate show_LoadingIndicator];
    NSLog(@"tag number is = %ld",(long)[sender tag]);
    
    ArtistMusic *artistmusic=(ArtistMusic*)[displayMusicArray objectAtIndex:[sender tag]];
    NSString *mId = artistmusic.musicIdString;
    
    
    [RequestManager getFromServer:@"music_playlist_operations" parameters:[NSMutableDictionary dictionaryWithObjectsAndKeys:[[NSUserDefaults standardUserDefaults] objectForKey:@"logged_user_id"],@"user_id",[[NSUserDefaults standardUserDefaults] objectForKey:@"logged_user_security_hash"],@"user_security_hash",mId,@"music_id",@"0",@"music_status_id", nil] completionHandler:^(NSDictionary *responseDict){
        
        
        if ([[responseDict valueForKey:@"code"] isEqualToString:@"1"]) {
            
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:[responseDict valueForKey:@"message"] preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
                [pagedMusicArray removeAllObjects];
                pagedMusicArray = [displayMusicArray mutableCopy];
                [pagedMusicArray removeObjectAtIndex:[sender tag]];
                displayMusicArray = [NSArray arrayWithArray:pagedMusicArray];
                
                [self.userMusicPlaylistTable reloadData];
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
    ArtistMusic *artistmusic=(ArtistMusic*)[displayMusicArray objectAtIndex:indexPath.row];
    viewController.playerUrlString = artistmusic.musicFileUrlString;
    viewController.titleLabelString = artistmusic.musicNameString;
    viewController.imageUrlString = artistmusic.musicImageUrlString;
    viewController.favStatus = artistmusic.musicFavoriteStatus;
    viewController.playlistStatus = artistmusic.musicPlaylistStatus;
    viewController.idString = artistmusic.musicIdString;
    viewController.passedArrayOfSongs = displayMusicArray;
    viewController.index = (int)indexPath.row;
    [self presentViewController:viewController animated:YES completion:^{
        [appDelegate hide_LoadingIndicator];
        appDelegate.isMusic = YES;
        [appDelegate playCountWithId:artistmusic.musicIdString];
    }];
}

//- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
//    return YES;
//}
//
//- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
//    if (editingStyle == UITableViewCellEditingStyleDelete) {
//        //remove the deleted object from your data source.
//        //If your data source is an NSMutableArray, do this
////        [displayMusicArray removeObjectAtIndex:indexPath.row];
////        [tableView reloadData]; // tell table to refresh now
//    }
//}
//
//-(NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
//    UITableViewRowAction *button = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"Delete" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath)
//                                    {
//                                        NSLog(@"hhhhh");
//                                    }];
//    button.backgroundColor = [UIColor clearColor]; //arbitrary color
//    
//    return @[button];
//}


#pragma mark - ScrollView delegate for refreshing table with contents on next page

-(void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset{
    
    if(self.userMusicPlaylistTable.contentOffset.y<0){
        //it means table view is pulled down like refresh
        return;
    }
    else if(self.userMusicPlaylistTable.contentOffset.y >= (self.userMusicPlaylistTable.contentSize.height - self.userMusicPlaylistTable.bounds.size.height)) {
        NSLog(@"bottom!");
        self.spinner.hidden = false;
        [self.spinner startAnimating];
        [self refreshPulled];
    }
    
}

-(void)refreshPulled
{
    [pagedMusicArray removeAllObjects];
    musicCounter++;
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
            
            UITableViewCell *cell = (UITableViewCell*)[self.userMusicPlaylistTable cellForRowAtIndexPath:indexPath];
            UIImageView *bigImgVw = (UIImageView *)[cell viewWithTag:58];
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
