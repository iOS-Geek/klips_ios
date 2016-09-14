//
//  SearchVC.m
//  Klips
//
//  Created by iOS Developer on 19/02/16.
//  Copyright © 2016 iOS Developer. All rights reserved.
//

#import "SearchVC.h"

@interface SearchVC ()
{
    NSMutableArray * pagedArray;
    NSArray *displayArray;
    AppDelegate *appDelegate;
    NSString *categoryString;
    NSString *searchString;
}
@end

@implementation SearchVC

@synthesize imageDownloadsInProgress;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    appDelegate=(AppDelegate*)[[UIApplication sharedApplication]delegate];
    
    self.searchKlipsBar.delegate = self;
    
    pageCounter = 0;
    imageDownloadsInProgress = [NSMutableDictionary dictionary];
    pagedArray=[NSMutableArray array];
    displayArray = [NSArray array];
    
    self.spinner.hidden = true;
    
    self.videoLabel.textColor = [UIColor whiteColor];
    self.videoImg.image = [UIImage imageNamed:@"search-video-white.png"];
    categoryString = @"2";
}

#pragma mark - Selecting category (music/video/image/quote)

- (IBAction)buttonAction:(id)sender {
    UIButton *btn=(UIButton *)sender;
    
    if (btn.tag == 136)
    {
        self.videoLabel.textColor = [UIColor whiteColor];
        self.videoImg.image = [UIImage imageNamed:@"search-video-white.png"];
        categoryString = @"2";
        
        self.musicLabel.textColor = [UIColor colorWithRed:134/255.0f green:64/255.0f blue:71/255.0f alpha:1.0];
        self.musicImg.image = [UIImage imageNamed:@"search-music-color.png"];
        
        self.imageLabel.textColor = [UIColor colorWithRed:134/255.0f green:64/255.0f blue:71/255.0f alpha:1.0];
        self.imageImg.image = [UIImage imageNamed:@"search-photos-color.png"];
        
        self.quoteLabel.textColor = [UIColor colorWithRed:134/255.0f green:64/255.0f blue:71/255.0f alpha:1.0];
        self.quoteImg.image = [UIImage imageNamed:@"search-quotes-color.png"];
    }
    else if (btn.tag == 137)
    {
        self.videoLabel.textColor = [UIColor colorWithRed:134/255.0f green:64/255.0f blue:71/255.0f alpha:1.0];
        self.videoImg.image = [UIImage imageNamed:@"search-video-color.png"];
        
        self.musicLabel.textColor = [UIColor whiteColor];
        self.musicImg.image = [UIImage imageNamed:@"search-music-white.png"];
        categoryString = @"1";
        
        self.imageLabel.textColor = [UIColor colorWithRed:134/255.0f green:64/255.0f blue:71/255.0f alpha:1.0];
        self.imageImg.image = [UIImage imageNamed:@"search-photos-color.png"];
        
        self.quoteLabel.textColor = [UIColor colorWithRed:134/255.0f green:64/255.0f blue:71/255.0f alpha:1.0];
        self.quoteImg.image = [UIImage imageNamed:@"search-quotes-color.png"];
    }
    else if (btn.tag == 138)
    {
        self.videoLabel.textColor = [UIColor colorWithRed:134/255.0f green:64/255.0f blue:71/255.0f alpha:1.0];
        self.videoImg.image = [UIImage imageNamed:@"search-video-color.png"];
        
        self.musicLabel.textColor = [UIColor colorWithRed:134/255.0f green:64/255.0f blue:71/255.0f alpha:1.0];
        self.musicImg.image = [UIImage imageNamed:@"search-music-color.png"];
        
        self.imageLabel.textColor = [UIColor whiteColor];
        self.imageImg.image = [UIImage imageNamed:@"search-photos-white.png"];
        categoryString = @"3";
        
        self.quoteLabel.textColor = [UIColor colorWithRed:134/255.0f green:64/255.0f blue:71/255.0f alpha:1.0];
        self.quoteImg.image = [UIImage imageNamed:@"search-quotes-color.png"];
    }
    else if (btn.tag == 139)
    {
        self.videoLabel.textColor = [UIColor colorWithRed:134/255.0f green:64/255.0f blue:71/255.0f alpha:1.0];
        self.videoImg.image = [UIImage imageNamed:@"search-video-color.png"];
        
        self.musicLabel.textColor = [UIColor colorWithRed:134/255.0f green:64/255.0f blue:71/255.0f alpha:1.0];
        self.musicImg.image = [UIImage imageNamed:@"search-music-color.png"];
        
        self.imageLabel.textColor = [UIColor colorWithRed:134/255.0f green:64/255.0f blue:71/255.0f alpha:1.0];
        self.imageImg.image = [UIImage imageNamed:@"search-photos-color.png"];
        
        self.quoteLabel.textColor = [UIColor whiteColor];
        self.quoteImg.image = [UIImage imageNamed:@"search-quotes-white.png"];
        categoryString = @"4";
    }
    
}

#pragma mark - Getting data from Server

-(void)getData


{
    [RequestManager getFromServer:@"search" parameters:[NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d",pageCounter],@"page",searchString,@"search",categoryString,@"category",[[NSUserDefaults standardUserDefaults] objectForKey:@"logged_user_id"],@"user_id",[[NSUserDefaults standardUserDefaults] objectForKey:@"logged_user_security_hash"],@"user_security_hash", nil] completionHandler:^(NSDictionary *responseDict){
        
        
        if ([[responseDict valueForKey:@"code"] isEqualToString:@"1"]) {
            
            NSArray *dataArray=[responseDict valueForKey:@"data"];
            
            [pagedArray removeAllObjects];
            
            for (NSDictionary *dic in dataArray) {
                ArtistMusic *artistmusic=[[ArtistMusic alloc]init];
                
                if ([categoryString isEqualToString:@"1"])
                {
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
                    
                }
                else if ([categoryString isEqualToString:@"2"])
                {
                    artistmusic.musicIdString=[dic valueForKey:@"video_id"];
                    artistmusic.musicNameString=[dic valueForKey:@"video_name"];
                    artistmusic.musicImageUrlString = [dic valueForKey:@"video_thumbnail_url"];
                    artistmusic.musicFileUrlString = [dic valueForKey:@"video_file_url"];
                    artistmusic.musicFavoriteStatus = [dic valueForKey:@"favourite_status"];
                    artistmusic.musicPlaylistStatus = [dic valueForKey:@"playlist_status"];
                    artistmusic.musicDescription = [dic valueForKey:@"video_description"];
                    
                }
                else if ([categoryString isEqualToString:@"3"])
                {
                    artistmusic.musicIdString=[dic valueForKey:@"images_id"];
                    artistmusic.musicNameString=[dic valueForKey:@"image_title"];
                    artistmusic.musicImageUrlString = [dic valueForKey:@"image_thumbnail_url"];
                    artistmusic.musicFileUrlString = [dic valueForKey:@"image_file_url"];
                    artistmusic.musicFavoriteStatus = [dic valueForKey:@"favourite_status"];
                    artistmusic.musicDescription = [dic valueForKey:@"image_description"];
                    
                }
                else if ([categoryString isEqualToString:@"4"])
                {
                    artistmusic.musicIdString=[dic valueForKey:@"quote_id"];
                    artistmusic.musicNameString=[dic valueForKey:@"quote_title"];
                    artistmusic.musicImageUrlString = [dic valueForKey:@"quote_thumbnail_url"];
                    artistmusic.musicFileUrlString = [dic valueForKey:@"quote_image_url"];
                    artistmusic.musicFavoriteStatus = [dic valueForKey:@"favourite_status"];
                    artistmusic.musicDescription = [dic valueForKey:@"quote_description"];
                    
                }
                
                [pagedArray addObject:artistmusic];
                
            }
            displayArray = [displayArray arrayByAddingObjectsFromArray:pagedArray];
            
            if (displayArray.count == 0) {
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:@"No Results Found." preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
                [alertController addAction:ok];
                [self presentViewController:alertController animated:YES completion:nil];
            }
            else{
            [self.searchResultTable reloadData];
            }
            
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
        
        [appDelegate hide_LoadingIndicator];
    }];
    
    
    
}

#pragma mark - Tableview delegate and datasource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return displayArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"searchCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    ArtistMusic *artistmusic=(ArtistMusic*)[displayArray objectAtIndex:indexPath.row];
    
    UIImageView *bigImgVw = (UIImageView *)[cell viewWithTag:131];
    UILabel *lbl = (UILabel *)[cell viewWithTag:132];
    UIImageView *smallImgVw = (UIImageView *)[cell viewWithTag:134];
    UILabel *detailLbl = (UILabel *)[cell viewWithTag:135];
    detailLbl.text = artistmusic.musicDescription;
    
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
    
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    ArtistMusic *artistmusic=(ArtistMusic*)[displayArray objectAtIndex:indexPath.row];
    
    UIViewController *newFrontController = nil;
    
    if ([categoryString isEqualToString:@"1"] || [categoryString isEqualToString:@"2"]) {
        PlayVideoVC *viewController = (PlayVideoVC *)[storyboard instantiateViewControllerWithIdentifier:@"videoView"];
        viewController.playerUrlString = artistmusic.musicFileUrlString;
        viewController.titleLabelString = artistmusic.musicNameString;
        viewController.imageUrlString = artistmusic.musicImageUrlString;
        viewController.favStatus = artistmusic.musicFavoriteStatus;
        viewController.playlistStatus = artistmusic.musicPlaylistStatus;
        viewController.idString = artistmusic.musicIdString;
        viewController.passedArrayOfSongs = displayArray;
        viewController.index = (int)indexPath.row;
        newFrontController = viewController;
    }
    else {
        ImageLargeVC *viewController = (ImageLargeVC *)[storyboard instantiateViewControllerWithIdentifier:@"enlargedView"];
        viewController.imgIdString = artistmusic.musicIdString;
        viewController.viewerUrlString = artistmusic.musicFileUrlString;
        viewController.favStatus = artistmusic.musicFavoriteStatus;
        viewController.headerString = artistmusic.musicNameString;
        viewController.passedArrayOfImages = displayArray;
        newFrontController = viewController;
    }
    
    
    [self presentViewController:newFrontController animated:YES completion:^{
        
        if ([categoryString isEqualToString:@"1"]) {
            appDelegate.isMusic = YES;
            [appDelegate playCountWithId:artistmusic.musicIdString];
        }
        else if ([categoryString isEqualToString:@"2"])
        {
            appDelegate.isMusic = NO;
        }
        else if ([categoryString isEqualToString:@"3"])
        {
            appDelegate.isQuote = NO;
        }
        else if ([categoryString isEqualToString:@"4"])
        {
            appDelegate.isQuote = YES;
        }
        
        
    }];
}

#pragma mark - ScrollView delegate for refreshing table with contents on next page

-(void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset{
    
    if(self.searchResultTable.contentOffset.y<0){
        //it means table view is pulled down like refresh
        return;
    }
    else if(self.searchResultTable.contentOffset.y >= (self.searchResultTable.contentSize.height - self.searchResultTable.bounds.size.height)) {
        NSLog(@"bottom!");
        self.spinner.hidden = false;
        [self.spinner startAnimating];
        [self refreshPulled];
    }
    
}

-(void)refreshPulled
{
    [pagedArray removeAllObjects];
    pageCounter++;
    NSLog(@"%d",pageCounter);
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
            
            UITableViewCell *cell = (UITableViewCell*)[self.searchResultTable cellForRowAtIndexPath:indexPath];
            UIImageView *bigImgVw = (UIImageView *)[cell viewWithTag:131];
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

#pragma mark - Search bar delegates and keyboard handling

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    searchString = searchBar.text;
    
    [searchBar setShowsCancelButton:NO animated:YES];
    [searchBar resignFirstResponder];
    [appDelegate show_LoadingIndicator];
    displayArray = [NSArray array];
    
    [self.searchResultTable reloadData];
    
    [self getData];
    
    searchBar.text = @"";
    
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar{
    
    [searchBar resignFirstResponder];
    
}


- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if ([searchText length] == 0)
    {
        [searchBar performSelector:@selector(resignFirstResponder)
                        withObject:nil
                        afterDelay:0];
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    
    UITouch *touch = [touches anyObject];
    if(touch.phase == UITouchPhaseBegan) {
        [self.searchKlipsBar resignFirstResponder];
    }
    
}

#pragma mark - Navigation

- (IBAction)backAction:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
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
