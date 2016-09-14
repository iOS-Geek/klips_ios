//
//  SingleCategoryDataVC.m
//  Klips
//
//  Created by iOS Developer on 29/02/16.
//  Copyright © 2016 iOS Developer. All rights reserved.
//

#import "SingleCategoryDataVC.h"

@interface SingleCategoryDataVC ()
{
    NSMutableArray * pagedArray;
    UIStoryboard *storyboard;
    AppDelegate *appDelegate;
}
@end

@implementation SingleCategoryDataVC

@synthesize imageDownloadsInProgress;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    appDelegate=(AppDelegate*)[[UIApplication sharedApplication]delegate];
}
-(void)viewWillAppear:(BOOL)animated
{
    if ([self.passedServer isEqualToString:@"Trendings"])
    {
        self.navigateBackBtn.image = [UIImage imageNamed:@"Search-50.png"];
    }
    else
    {
        self.navigateBackBtn.image = [UIImage imageNamed:@"home.png"];
    }
    
    pageCounter = 0;
    imageDownloadsInProgress = [NSMutableDictionary dictionary];
    pagedArray=[NSMutableArray array];
    self.spinner.hidden = true;
    self.categoryHeader.text = self.categoryTitleString;
}

#pragma mark - Getting data from Server

-(void)getDataForVideos
{
    [RequestManager getFromServer:self.passedServer parameters:[NSMutableDictionary dictionaryWithObjectsAndKeys:[[NSUserDefaults standardUserDefaults] objectForKey:@"user_language"], @"user_language",[NSString stringWithFormat:@"%d",pageCounter],@"page", nil] completionHandler:^(NSDictionary *responseDict){
        
        if ([[responseDict valueForKey:@"code"] isEqualToString:@"1"])
        {
            
            NSArray *dataArray = [responseDict valueForKey:@"data"];
            
            NSDictionary *dic = [dataArray objectAtIndex:self.indexCat];
            
            NSArray *detailArray = [dic objectForKey:@"video_details"];
            
            [pagedArray removeAllObjects];
            
            
            for (NSDictionary *subDict in detailArray) {
                
                ArtistMusic *artistmusic=[[ArtistMusic alloc]init];
                artistmusic.musicIdString=[subDict valueForKey:@"video_id"];
                artistmusic.musicNameString=[subDict valueForKey:@"video_name"];
                artistmusic.musicImageUrlString = [subDict valueForKey:@"video_thumbnail_url"];
                artistmusic.musicFileUrlString = [subDict valueForKey:@"video_file_url"];
                artistmusic.musicFavoriteStatus = [subDict valueForKey:@"favourite_status"];
                artistmusic.musicPlaylistStatus = [subDict valueForKey:@"playlist_status"];
                artistmusic.musicDescription = [subDict valueForKey:@"video_description"];
                
                [pagedArray addObject:artistmusic];
                
            }
            
            self.passedArr = [self.passedArr arrayByAddingObjectsFromArray:pagedArray];
            [self.moreDataTable reloadData];
            
        }
        if ([self.spinner isAnimating]) {
            [self.spinner stopAnimating];
            self.spinner.hidden = true;
        }
        
    }];
    
}

-(void)getDataForMusic
{
    [RequestManager getFromServer:self.passedServer parameters:[NSMutableDictionary dictionaryWithObjectsAndKeys:[[NSUserDefaults standardUserDefaults] objectForKey:@"user_language"], @"user_language",[NSString stringWithFormat:@"%d",pageCounter],@"page", nil] completionHandler:^(NSDictionary *responseDict){
        
        if ([[responseDict valueForKey:@"code"] isEqualToString:@"1"])
        {
            
            NSArray *dataArray = [responseDict valueForKey:@"data"];
            
            NSDictionary *dic = [dataArray objectAtIndex:self.indexCat];
            
            NSArray *detailArray = [dic objectForKey:@"music_details"];
            
            [pagedArray removeAllObjects];
            
            
            for (NSDictionary *subDict in detailArray) {
                
                ArtistMusic *artistmusic=[[ArtistMusic alloc]init];
                artistmusic.musicIdString=[subDict valueForKey:@"music_id"];
                artistmusic.musicNameString=[subDict valueForKey:@"music_name"];
                artistmusic.musicImageUrlString = [subDict valueForKey:@"music_thumbnail_url"];
                artistmusic.musicFileUrlString = [subDict valueForKey:@"music_file_url"];
                artistmusic.musicFavoriteStatus = [subDict valueForKey:@"favourite_status"];
                artistmusic.musicPlaylistStatus = [subDict valueForKey:@"playlist_status"];
                artistmusic.musicDescription = [subDict valueForKey:@"music_description"];
                
                NSArray *receivedArr = [subDict valueForKey:@"artists_details"];
                
                artistmusic.artistDetails=[NSMutableArray array];
                
                for (NSDictionary *val in receivedArr) {
                    [artistmusic.artistDetails addObject:[val valueForKey:@"artist_name"]];
                    
                }
                
                [pagedArray addObject:artistmusic];
                
            }
            
            self.passedArr = [self.passedArr arrayByAddingObjectsFromArray:pagedArray];
            [self.moreDataTable reloadData];
            
        }
        if ([self.spinner isAnimating]) {
            [self.spinner stopAnimating];
            self.spinner.hidden = true;
        }
        
    }];
    
}
-(void)getDataForImages
{
    [RequestManager getFromServer:self.passedServer parameters:[NSMutableDictionary dictionaryWithObjectsAndKeys:[[NSUserDefaults standardUserDefaults] objectForKey:@"user_language"], @"user_language",[NSString stringWithFormat:@"%d",pageCounter],@"page", nil] completionHandler:^(NSDictionary *responseDict){
        
        if ([[responseDict valueForKey:@"code"] isEqualToString:@"1"])
        {
            
            NSArray *dataArray = [responseDict valueForKey:@"data"];
            
            NSDictionary *dic = [dataArray objectAtIndex:self.indexCat];
            
            NSArray *detailArray = [dic objectForKey:@"image_details"];
            
            [pagedArray removeAllObjects];
            
            
            for (NSDictionary *subDict in detailArray) {
                
                ArtistMusic *artistmusic=[[ArtistMusic alloc]init];
                artistmusic.musicIdString=[subDict valueForKey:@"images_id"];
                artistmusic.musicNameString=[subDict valueForKey:@"image_title"];
                artistmusic.musicImageUrlString = [subDict valueForKey:@"image_thumbnail_url"];
                artistmusic.musicFileUrlString = [subDict valueForKey:@"image_file_url"];
                artistmusic.musicFavoriteStatus = [subDict valueForKey:@"favourite_status"];
                artistmusic.musicDescription = [subDict valueForKey:@"image_description"];
                
                [pagedArray addObject:artistmusic];
                
            }
            
            self.passedArr = [self.passedArr arrayByAddingObjectsFromArray:pagedArray];
            [self.moreDataTable reloadData];
            
        }
        if ([self.spinner isAnimating]) {
            [self.spinner stopAnimating];
            self.spinner.hidden = true;
        }
        
    }];
    
}
-(void)getDataForQuotes
{
    [RequestManager getFromServer:self.passedServer parameters:[NSMutableDictionary dictionaryWithObjectsAndKeys:[[NSUserDefaults standardUserDefaults] objectForKey:@"user_language"], @"user_language",[NSString stringWithFormat:@"%d",pageCounter],@"page", nil] completionHandler:^(NSDictionary *responseDict){
        
        if ([[responseDict valueForKey:@"code"] isEqualToString:@"1"])
        {
            
            NSArray *dataArray = [responseDict valueForKey:@"data"];
            
            NSDictionary *dic = [dataArray objectAtIndex:self.indexCat];
            
            NSArray *detailArray = [dic objectForKey:@"video_details"];
            
            [pagedArray removeAllObjects];
            
            
            for (NSDictionary *subDict in detailArray) {
                
                ArtistMusic *artistmusic=[[ArtistMusic alloc]init];
                artistmusic.musicIdString=[subDict valueForKey:@"quote_id"];
                artistmusic.musicNameString=[subDict valueForKey:@"quote_title"];
                artistmusic.musicImageUrlString = [subDict valueForKey:@"quote_thumbnail_url"];
                artistmusic.musicFileUrlString = [subDict valueForKey:@"quote_file_url"];
                artistmusic.musicFavoriteStatus = [subDict valueForKey:@"favourite_status"];
                artistmusic.musicDescription = [subDict valueForKey:@"quote_description"];
                
                [pagedArray addObject:artistmusic];
                
            }
            
            self.passedArr = [self.passedArr arrayByAddingObjectsFromArray:pagedArray];
            [self.moreDataTable reloadData];
            
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
    return self.passedArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"categoryCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    ArtistMusic *artistmusic=(ArtistMusic*)[self.passedArr objectAtIndex:indexPath.row];
    
    UIImageView *bigImgVw = (UIImageView *)[cell viewWithTag:661];
    UILabel *lbl = (UILabel *)[cell viewWithTag:662];
    UILabel *desLabel = (UILabel *)[cell viewWithTag:663];
    UIImageView *smallImgVw = (UIImageView *)[cell viewWithTag:664];
    
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
    if ([self.passedServer isEqualToString:@"get_images"] || [self.passedServer isEqualToString:@"get_quotes"])
    {
        smallImgVw.hidden = true;
    }
    else
    {
        smallImgVw.hidden = false;
    }
    return cell;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [appDelegate show_LoadingIndicator];
    ArtistMusic *am=(ArtistMusic*)[self.passedArr objectAtIndex:indexPath.row];
    
    UIViewController *newFrontController = nil;
    if ([self.passedServer isEqualToString:@"get_images"] || [self.passedServer isEqualToString:@"get_quotes"]) {
        
        ImageLargeVC *viewController = (ImageLargeVC *)[storyboard instantiateViewControllerWithIdentifier:@"enlargedView"];
        viewController.imgIdString = am.musicIdString;
        viewController.viewerUrlString = am.musicFileUrlString;
        viewController.favStatus = am.musicFavoriteStatus;
        viewController.headerString = am.musicNameString;
        viewController.passedArrayOfImages = self.passedArr;
        newFrontController = viewController;
    }
    else{
        PlayVideoVC *viewController = (PlayVideoVC *)[storyboard instantiateViewControllerWithIdentifier:@"videoView"];
        viewController.playerUrlString = am.musicFileUrlString;
        viewController.titleLabelString = am.musicNameString;
        viewController.imageUrlString = am.musicImageUrlString;
        viewController.favStatus = am.musicFavoriteStatus;
        viewController.playlistStatus = am.musicPlaylistStatus;
        viewController.idString = am.musicIdString;
        viewController.passedArrayOfSongs = self.passedArr;
        viewController.index = (int)indexPath.row;
        newFrontController = viewController;
        
    }
    [self presentViewController:newFrontController animated:true completion:^{
        
        
        if ([self.passedServer isEqualToString:@"get_videos"]) {
            
            appDelegate.isMusic = NO;
        }
        else if ([self.passedServer isEqualToString:@"get_musics"])
        {
            appDelegate.isMusic = YES;
            [appDelegate playCountWithId:am.musicIdString];
        }
        else if ([self.passedServer isEqualToString:@"get_images"])
        {
            appDelegate.isQuote = NO;
        }
        else if ([self.passedServer isEqualToString:@"get_quotes"])
        {
            appDelegate.isQuote = YES;
        }
        else if ([self.passedServer isEqualToString:@"Trendings"])
        {
            appDelegate.isMusic = YES;
            [appDelegate playCountWithId:am.musicIdString];
        }
        [appDelegate hide_LoadingIndicator];
    }];
    
}

#pragma mark - ScrollView delegate for refreshing table with contents on next page

-(void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset{
    
    if(self.moreDataTable.contentOffset.y<0){
        //it means table view is pulled down like refresh
        return;
    }
    else if(self.moreDataTable.contentOffset.y >= (self.moreDataTable.contentSize.height - self.moreDataTable.bounds.size.height)) {
        NSLog(@"bottom!");
        
        if ([self.passedServer isEqualToString:@"Trendings"]) {
            self.spinner.hidden = true;
        }
        else
        {
            self.spinner.hidden = false;
            [self.spinner startAnimating];
            [self refreshPulled];
        }
    }
    
}

-(void)refreshPulled
{
    [pagedArray removeAllObjects];
    pageCounter++;
    
    if ([self.passedServer isEqualToString:@"get_videos"]) {
        [self getDataForVideos];
    }
    else if ([self.passedServer isEqualToString:@"get_musics"]) {
        [self getDataForMusic];
    }
    else if ([self.passedServer isEqualToString:@"get_images"]) {
        [self getDataForImages];
    }
    else if ([self.passedServer isEqualToString:@"get_quotes"]) {
        [self getDataForQuotes];
    }
}

#pragma mark - Navigation

- (IBAction)backButtonAction:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)goToHomeAction:(id)sender {
    
    if ([self.passedServer isEqualToString:@"Trendings"])
    {
        SearchVC *viewcontroller = (SearchVC*)[storyboard instantiateViewControllerWithIdentifier: @"searchView"];
        [self presentViewController:viewcontroller animated:YES completion:nil];
    }
    else
    {
        SWRevealViewController *viewController = (SWRevealViewController *)[storyboard instantiateViewControllerWithIdentifier:@"revealView"];
        [self presentViewController:viewController animated:YES completion:nil];
    }
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
            
            UITableViewCell *cell = (UITableViewCell*)[self.moreDataTable cellForRowAtIndexPath:indexPath];
            UIImageView *bigImgVw = (UIImageView *)[cell viewWithTag:661];
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
