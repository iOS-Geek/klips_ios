//
//  FavoritesQuotesVC.m
//  Klips
//
//  Created by iOS Developer on 16/12/15.
//  Copyright © 2015 iOS Developer. All rights reserved.
//

#import "FavoritesQuotesVC.h"

@interface FavoritesQuotesVC ()
{
    NSMutableArray * pagedFavQuoteArray;
    NSArray *displayFavQuoteArray;
    AppDelegate *appDelegate;
    UIStoryboard *storyboard;
}
@end

@implementation FavoritesQuotesVC

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
    self.tabBarItem.selectedImage = [[UIImage imageNamed:@"quotes-purple.png"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    self.tabBarItem.image = [[UIImage imageNamed:@"tab_quotes_white.png"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
   
}

-(void)viewWillAppear:(BOOL)animated
{
    favQuoteCounter = 0;
    imageDownloadsInProgress = [NSMutableDictionary dictionary];
    pagedFavQuoteArray=[NSMutableArray array];
    displayFavQuoteArray = [NSArray array];
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
    [RequestManager getFromServer:@"favourite_quotes" parameters:[NSMutableDictionary dictionaryWithObjectsAndKeys:[[NSUserDefaults standardUserDefaults] objectForKey:@"logged_user_id"],@"user_id",[[NSUserDefaults standardUserDefaults] objectForKey:@"logged_user_security_hash"],@"user_security_hash",[NSString stringWithFormat:@"%d",favQuoteCounter],@"page", nil] completionHandler:^(NSDictionary *responseDict){
        
        
        if ([[responseDict valueForKey:@"code"] isEqualToString:@"1"]) {
            
            NSArray *dataArray=[responseDict valueForKey:@"data"];
            
            [pagedFavQuoteArray removeAllObjects];
            
            for (NSDictionary *dic in dataArray) {
                ArtistMusic *artistmusic=[[ArtistMusic alloc]init];
                artistmusic.musicIdString=[dic valueForKey:@"quote_id"];
                artistmusic.musicNameString=[dic valueForKey:@"quote_title"];
                artistmusic.musicImageUrlString = [dic valueForKey:@"quote_thumbnail_url"];
                artistmusic.musicFileUrlString = [dic valueForKey:@"quote_image_url"];
                artistmusic.musicFavoriteStatus = [dic valueForKey:@"favourite_status"];
                artistmusic.musicDescription = [dic valueForKey:@"quote_description"];
                
                [pagedFavQuoteArray addObject:artistmusic];
                
            }
            displayFavQuoteArray = [displayFavQuoteArray arrayByAddingObjectsFromArray:pagedFavQuoteArray];
            [self.favoriteQuoteTable reloadData];
            
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

#pragma mark - Tableview delegates and data source

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return displayFavQuoteArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"quotesFavouriteCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    ArtistMusic *artistmusic=(ArtistMusic*)[displayFavQuoteArray objectAtIndex:indexPath.row];
    
    UIImageView *bigImgVw = (UIImageView *)[cell viewWithTag:77];
    UILabel *lbl = (UILabel *)[cell viewWithTag:78];
    UILabel *lblDes = (UILabel *)[cell viewWithTag:79];
    
    UIButton *removeButton = (UIButton*)[cell viewWithTag:80];
    removeButton.tag = indexPath.row;
    [removeButton addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];

    
    lblDes.text = artistmusic.musicDescription;
    
    if (!artistmusic.post_image) {
        bigImgVw.image=nil;
        [self startIconDownload:artistmusic forIndexPath:indexPath];
    }
    else{
        bigImgVw.image=artistmusic.post_image;
    }
    
    lbl.text = artistmusic.musicNameString;
    
    return cell;
    
}

-(void)buttonClicked:(id)sender
{
    
    [appDelegate show_LoadingIndicator];
    NSLog(@"tag number is = %ld",(long)[sender tag]);
    
    ArtistMusic *artistmusic=(ArtistMusic*)[displayFavQuoteArray objectAtIndex:[sender tag]];
    NSString *mId = artistmusic.musicIdString;
    
    
    [RequestManager getFromServer:@"favourite_quote_operations" parameters:[NSMutableDictionary dictionaryWithObjectsAndKeys:[[NSUserDefaults standardUserDefaults] objectForKey:@"logged_user_id"],@"user_id",[[NSUserDefaults standardUserDefaults] objectForKey:@"logged_user_security_hash"],@"user_security_hash",mId,@"quote_id",@"0",@"quote_favourite_status", nil] completionHandler:^(NSDictionary *responseDict){
        
        
        if ([[responseDict valueForKey:@"code"] isEqualToString:@"1"]) {
            
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:[responseDict valueForKey:@"message"] preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
                [pagedFavQuoteArray removeAllObjects];
                pagedFavQuoteArray = [displayFavQuoteArray mutableCopy];
                [pagedFavQuoteArray removeObjectAtIndex:[sender tag]];
                displayFavQuoteArray = [NSArray arrayWithArray:pagedFavQuoteArray];
                
                [self.favoriteQuoteTable reloadData];
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
    ImageLargeVC *viewController = (ImageLargeVC *)[storyboard instantiateViewControllerWithIdentifier:@"enlargedView"];
    ArtistMusic *artistmusic=(ArtistMusic*)[displayFavQuoteArray objectAtIndex:indexPath.row];
    viewController.imgIdString = artistmusic.musicIdString;
    viewController.viewerUrlString = artistmusic.musicFileUrlString;
    viewController.favStatus = artistmusic.musicFavoriteStatus;
    viewController.headerString = artistmusic.musicNameString;
    viewController.passedArrayOfImages = displayFavQuoteArray;
    [self presentViewController:viewController animated:YES completion:^{
        [appDelegate hide_LoadingIndicator];
        appDelegate.isQuote = YES;
    }];
    
}

#pragma mark - ScrollView delegate for refreshing table with contents on next page

-(void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset{
    
    if(self.favoriteQuoteTable.contentOffset.y<0){
        //it means table view is pulled down like refresh
        return;
    }
    else if(self.favoriteQuoteTable.contentOffset.y >= (self.favoriteQuoteTable.contentSize.height - self.favoriteQuoteTable.bounds.size.height)) {
        NSLog(@"bottom!");
        self.spinner.hidden = false;
        [self.spinner startAnimating];
        [self refreshPulled];
    }
    
}

-(void)refreshPulled
{
    [pagedFavQuoteArray removeAllObjects];
    favQuoteCounter++;
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
            
            UITableViewCell *cell = (UITableViewCell*)[self.favoriteQuoteTable cellForRowAtIndexPath:indexPath];
            UIImageView *bigImgVw = (UIImageView *)[cell viewWithTag:77];
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
