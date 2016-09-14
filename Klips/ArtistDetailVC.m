//
//  ArtistDetailVC.m
//  Klips
//
//  Created by iOS Developer on 15/12/15.
//  Copyright © 2015 iOS Developer. All rights reserved.
//

#import "ArtistDetailVC.h"

@interface ArtistDetailVC ()
{
    NSMutableArray * fetchMusicArray;
    NSArray *showMusicArray;
    AppDelegate *appDelegate;
    UIStoryboard *storyboard;
}
@end

@implementation ArtistDetailVC
@synthesize imageDownloadsInProgress;
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    appDelegate=(AppDelegate*)[[UIApplication sharedApplication]delegate];
    
    storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    pageCounter = 0;
    imageDownloadsInProgress = [NSMutableDictionary dictionary];
    fetchMusicArray=[NSMutableArray array];
    showMusicArray = [NSArray array];
    
    self.artistImageView.layer.cornerRadius = 40;
    self.artistImageView.clipsToBounds = true;
    
    NSData * imgData = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString: self.selectedArtistImageUrltring]];
    self.artistImageView.image = [UIImage imageWithData: imgData];
    
    self.artistName.text = self.selectedArtistNameString;
    
    self.spinner.hidden = true;
    
    [self getData];
    
}

#pragma mark - Navigation

- (IBAction)goToHome:(id)sender {
    
    SWRevealViewController *viewController = (SWRevealViewController *)[storyboard instantiateViewControllerWithIdentifier:@"revealView"];
    [self presentViewController:viewController animated:YES completion:nil];
}

- (IBAction)backAction:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

#pragma mark - Getting data from Server

-(void)getData


{
    [RequestManager getFromServer:@"artist_musics" parameters:[NSMutableDictionary dictionaryWithObjectsAndKeys:self.selectedArtistIdString,@"artist_id",[NSString stringWithFormat:@"%d",pageCounter],@"page", nil] completionHandler:^(NSDictionary *responseDict){
        
        
        if ([[responseDict valueForKey:@"code"] isEqualToString:@"1"]) {
            
            NSArray *dataArray=[responseDict valueForKey:@"data"];
            
            [fetchMusicArray removeAllObjects];
            
            for (NSDictionary *dic in dataArray) {
                ArtistMusic *artistmusic=[[ArtistMusic alloc]init];
                artistmusic.musicIdString=[dic valueForKey:@"music_id"];
                artistmusic.musicNameString=[dic valueForKey:@"music_name"];
                artistmusic.musicImageUrlString = [dic valueForKey:@"music_thumbnail_url"];
                artistmusic.musicFileUrlString = [dic valueForKey:@"music_file_url"];
                artistmusic.musicFavoriteStatus = [dic valueForKey:@"favourite_status"];
                artistmusic.musicPlaylistStatus = [dic valueForKey:@"playlist_status"];
                artistmusic.musicDescription = [dic valueForKey:@"music_description"];
                [fetchMusicArray addObject:artistmusic];
                
            }
            showMusicArray = [showMusicArray arrayByAddingObjectsFromArray:fetchMusicArray];
            [self.artistMusicTable reloadData];
            
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

#pragma mark - Tableview delegate and data source

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return showMusicArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"artistDetailCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    ArtistMusic *artistmusic=(ArtistMusic*)[showMusicArray objectAtIndex:indexPath.row];
    
    UIImageView *bigImgVw = (UIImageView *)[cell viewWithTag:54];
    UILabel *lbl = (UILabel *)[cell viewWithTag:55];
    UILabel *desLabel = (UILabel *)[cell viewWithTag:56];
    UIImageView *smallImgVw = (UIImageView *)[cell viewWithTag:57];
    
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


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [appDelegate show_LoadingIndicator];
    PlayVideoVC *viewController = (PlayVideoVC *)[storyboard instantiateViewControllerWithIdentifier:@"videoView"];
    ArtistMusic *artistmusic=(ArtistMusic*)[showMusicArray objectAtIndex:indexPath.row];
    viewController.playerUrlString = artistmusic.musicFileUrlString;
    viewController.titleLabelString = artistmusic.musicNameString;
    viewController.imageUrlString = artistmusic.musicImageUrlString;
    viewController.favStatus = artistmusic.musicFavoriteStatus;
    viewController.playlistStatus = artistmusic.musicPlaylistStatus;
    viewController.idString = artistmusic.musicIdString;
    viewController.passedArrayOfSongs = showMusicArray;
    viewController.index = (int)indexPath.row;
    [self presentViewController:viewController animated:YES completion:^{
        [appDelegate hide_LoadingIndicator];
        appDelegate.isMusic = YES;
        [appDelegate playCountWithId:artistmusic.musicIdString];
    }];
    
}


#pragma mark - ScrollView delegate for refreshing table with contents on next page

-(void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset{
    
    if(self.artistMusicTable.contentOffset.y<0){
        //it means table view is pulled down like refresh
        return;
    }
    else if(self.artistMusicTable.contentOffset.y >= (self.artistMusicTable.contentSize.height - self.artistMusicTable.bounds.size.height)) {
        NSLog(@"bottom!");
        self.spinner.hidden = false;
        [self.spinner startAnimating];
        [self refreshPulled];
    }
    
}

-(void)refreshPulled
{
    [fetchMusicArray removeAllObjects];
    pageCounter++;
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
            
            UITableViewCell *cell = (UITableViewCell*)[self.artistMusicTable cellForRowAtIndexPath:indexPath];
            UIImageView *bigImgVw = (UIImageView *)[cell viewWithTag:54];
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
