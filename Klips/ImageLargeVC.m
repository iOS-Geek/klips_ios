//
//  ImageLargeVC.m
//  Klips
//
//  Created by iOS Developer on 16/12/15.
//  Copyright © 2015 iOS Developer. All rights reserved.
//

#import "ImageLargeVC.h"
#import "ArtistMusic.h"

@interface ImageLargeVC ()
{
    AppDelegate *appDelegate;
    UIStoryboard *storyboard;
}
@end

@implementation ImageLargeVC

@synthesize imageDownloadsInProgress;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    appDelegate=(AppDelegate*)[[UIApplication sharedApplication]delegate];
    
    storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
}

-(void)viewWillAppear:(BOOL)animated
{
    imageDownloadsInProgress = [NSMutableDictionary dictionary];
    if (appDelegate.loggedInAsGuest) {
        self.FavButton.enabled = NO;
    }
    NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:self.viewerUrlString]];
    self.viewImage.image = [UIImage imageWithData:imageData];
    
    self.headerTitle.text = self.headerString;
    
    if ([self.favStatus isEqualToString:@"1"])
    {
        [self.FavButton setBackgroundImage:[UIImage imageNamed:@"fav-red.png"] forState:UIControlStateNormal];
    }
    else{
        [self.FavButton setBackgroundImage:[UIImage imageNamed:@"fav-white.png"] forState:UIControlStateNormal];
    }

}

#pragma mark - Navigation

- (IBAction)goBackHome:(id)sender {
    SWRevealViewController *viewController = (SWRevealViewController *)[storyboard instantiateViewControllerWithIdentifier:@"revealView"];
    [self presentViewController:viewController animated:YES completion:nil];
}

- (IBAction)backAction:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
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

#pragma mark - Colletionview delegate and data source

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.passedArrayOfImages.count;
    
}

-(UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"galleryCell";
    
    UICollectionViewCell *cell = (UICollectionViewCell*)[collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    
    UIImageView *imgvw = (UIImageView*)[cell viewWithTag:77];
    imgvw.backgroundColor = [UIColor clearColor];
    
    ArtistMusic *artistMusic = (ArtistMusic*)[self.passedArrayOfImages objectAtIndex:indexPath.row];
    
    if (!artistMusic.post_image) {
        imgvw.image=nil;
        [self startIconDownload:artistMusic forIndexPath:indexPath];
    }
    else{
        imgvw.image=artistMusic.post_image;
    }
    return cell;
    
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    ArtistMusic *artistMusic = (ArtistMusic*)[self.passedArrayOfImages objectAtIndex:indexPath.row];
    self.headerString = artistMusic.musicNameString;
    self.headerTitle.text = self.headerString;
    self.imgIdString = artistMusic.musicIdString;
    self.favStatus = artistMusic.musicFavoriteStatus;
    self.viewerUrlString = artistMusic.musicFileUrlString;
    NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:self.viewerUrlString]];
    self.viewImage.image = [UIImage imageWithData:imageData];
    if ([self.favStatus isEqualToString:@"1"])
    {
        [self.FavButton setBackgroundImage:[UIImage imageNamed:@"fav-red.png"] forState:UIControlStateNormal];
    }
    else{
        [self.FavButton setBackgroundImage:[UIImage imageNamed:@"fav-white.png"] forState:UIControlStateNormal];
    }
    
}

#pragma mark - Favourite and share action

- (IBAction)makeFavouriteAction:(id)sender {
    
    if ([self.favStatus isEqualToString:@"1"]) {
        self.favStatus = @"0";
        [self.FavButton setBackgroundImage:[UIImage imageNamed:@"fav-white.png"] forState:UIControlStateNormal];
    }
    else if ([self.favStatus isEqualToString:@"0"]){
        self.favStatus = @"1";
        [self.FavButton setBackgroundImage:[UIImage imageNamed:@"fav-red.png"] forState:UIControlStateNormal];
    }
    
    if (appDelegate.isQuote) {
        
        [self getDataFor:@"favourite_quote_operations" usingParameters:[NSMutableDictionary dictionaryWithObjectsAndKeys:[[NSUserDefaults standardUserDefaults] objectForKey:@"logged_user_id"],@"user_id",[[NSUserDefaults standardUserDefaults] objectForKey:@"logged_user_security_hash"],@"user_security_hash",self.imgIdString,@"quote_id",self.favStatus,@"quote_favourite_status", nil]];
        
    }
    else{
        [self getDataFor:@"favourite_image_operations" usingParameters:[NSMutableDictionary dictionaryWithObjectsAndKeys:[[NSUserDefaults standardUserDefaults] objectForKey:@"logged_user_id"],@"user_id",[[NSUserDefaults standardUserDefaults] objectForKey:@"logged_user_security_hash"],@"user_security_hash",self.imgIdString,@"image_id",self.favStatus,@"image_favourite_status", nil]];
    }
    
}


- (IBAction)shareFunctionality:(id)sender {
    
    NSString *informatory = @"Check out this image link:";
    
//    NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:self.viewerUrlString]];
    
    NSURL *myWebsite = [NSURL URLWithString:self.viewerUrlString];
    
    NSArray *objectsToShare = @[informatory, myWebsite];
    
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

#pragma mark - Full screen action

- (IBAction)viewInFullScreen:(id)sender {
    FullScreenVC *viewController = (FullScreenVC *)[storyboard instantiateViewControllerWithIdentifier:@"fullView"];
    viewController.headerString = self.headerString;
    viewController.imgUrlString = self.viewerUrlString;
    [self presentViewController:viewController animated:NO completion:nil];
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
            
            UICollectionViewCell *cell = (UICollectionViewCell*)[self.galleryView cellForItemAtIndexPath:indexPath];
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
