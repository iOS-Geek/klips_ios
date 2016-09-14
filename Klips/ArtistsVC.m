//
//  ArtistsVC.m
//  Klips
//
//  Created by iOS Developer on 15/12/15.
//  Copyright © 2015 iOS Developer. All rights reserved.
//

#import "ArtistsVC.h"

@interface ArtistsVC ()
{
    NSMutableArray *artistArray;
    NSArray *displayResultsArray;
    UIStoryboard *storyboard;
    AppDelegate *appDelegate;
}
@end

@implementation ArtistsVC

@synthesize imageDownloadsInProgress;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    appDelegate=(AppDelegate*)[[UIApplication sharedApplication]delegate];
    
    pageCount = 0;
    artistArray=[NSMutableArray array];
    displayResultsArray = [NSArray array];
    imageDownloadsInProgress = [NSMutableDictionary dictionary];
    SWRevealViewController *revealViewController = self.revealViewController;
    if ( revealViewController )
    {
        [self.sideMenuButton addTarget:self.revealViewController action:@selector( revealToggle: ) forControlEvents:UIControlEventTouchUpInside];
        [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    }
    
    storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
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


{[RequestManager getFromServer:@"artists" parameters:[NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d",pageCount],@"page", nil] completionHandler:^(NSDictionary *responseDict){
    
    
    if ([[responseDict valueForKey:@"code"] isEqualToString:@"1"]) {
        
        NSArray *dataArray=[responseDict valueForKey:@"data"];
        
        [artistArray removeAllObjects];
        
        for (NSDictionary *dic in dataArray) {
            Artists *artist=[[Artists alloc]init];
            artist.artistIdString=[dic valueForKey:@"artist_id"];
            artist.artistNameString=[dic valueForKey:@"artist_name"];
            artist.artistImageUrltring = [dic valueForKey:@"artist_thumbnail_url"];
            [artistArray addObject:artist];
            
        }
        displayResultsArray = [displayResultsArray arrayByAddingObjectsFromArray:artistArray];
        [self.artistsTable reloadData];
        
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

#pragma mark - Tableview datasource and delegates

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return displayResultsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"artistCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    Artists *artist=(Artists*)[displayResultsArray objectAtIndex:indexPath.row];
    
    UIImageView *imgVw = (UIImageView *)[cell viewWithTag:52];
    UILabel *lbl = (UILabel *)[cell viewWithTag:53];
    
    if (!artist.post_image) {
        imgVw.image=nil;
        [self startIconDownload:artist forIndexPath:indexPath];
    }
    else{
        imgVw.image=artist.post_image;
    }
    
    lbl.text = artist.artistNameString;
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [appDelegate show_LoadingIndicator];
    
    ArtistDetailVC *viewController = (ArtistDetailVC *)[storyboard instantiateViewControllerWithIdentifier:@"artistDetailView"];
    Artists *artist=(Artists*)[displayResultsArray objectAtIndex:indexPath.row];
    viewController.selectedArtistIdString = artist.artistIdString;
    viewController.selectedArtistNameString = artist.artistNameString;
    viewController.selectedArtistImageUrltring = artist.artistImageUrltring;
    [self presentViewController:viewController animated:YES completion:^{
        [appDelegate hide_LoadingIndicator];
    }];
}

#pragma mark - ScrollView delegate for refreshing table with contents on next page

-(void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset{
    
    if(self.artistsTable.contentOffset.y<0){
        //it means table view is pulled down like refresh
        return;
    }
    else if(self.artistsTable.contentOffset.y >= (self.artistsTable.contentSize.height - self.artistsTable.bounds.size.height)) {
        NSLog(@"bottom!");
        self.spinner.hidden = false;
        [self.spinner startAnimating];
        [self refreshPulled];
    }
    
}

-(void)refreshPulled
{
    [artistArray removeAllObjects];
    pageCount++;
    [self getData];
    
}

#pragma mark - Setting up Icon Downloader

- (void)startIconDownload:(Artists *)appRecord forIndexPath:(NSIndexPath *)indexPath
{
    IconDownloader *iconDownloader = (imageDownloadsInProgress)[indexPath];
    if (iconDownloader == nil)
    {
        iconDownloader = [[IconDownloader alloc] init];
        iconDownloader.artResult = appRecord;
        [iconDownloader setCompletionHandler:^{
            
            UITableViewCell *cell = (UITableViewCell*)[self.artistsTable cellForRowAtIndexPath:indexPath];
            UIImageView *imgVw = (UIImageView *)[cell viewWithTag:52];
            // Display the newly loaded image
            imgVw.image = appRecord.post_image;
            
            // Remove the IconDownloader from the in progress list.
            // This will result in it being deallocated.
            [self.imageDownloadsInProgress removeObjectForKey:indexPath];
            
        }];
        (self.imageDownloadsInProgress)[indexPath] = iconDownloader;
        [iconDownloader startDownloadFor:@"artist"];
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
