//
//  DisplayScrollDataVC.m
//  Klips
//
//  Created by iOS Developer on 17/12/15.
//  Copyright © 2015 iOS Developer. All rights reserved.
//

#import "DisplayScrollDataVC.h"

@interface DisplayScrollDataVC ()
{
    AppDelegate *appDelegate;
    UIStoryboard *storyboard;
    NSArray *sectionNameArr;
    NSArray *dataArray;
    NSMutableArray *initialTableDataArray;
    NSString *imgName;
}
@end

@implementation DisplayScrollDataVC
@synthesize passedServerString;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    sectionNameArr = [NSArray arrayWithObjects:@"a",@"b",@"c",@"d",@"e", nil];
    initialTableDataArray = [NSMutableArray array];
    
}

-(void)viewWillAppear:(BOOL)animated
{
   
    self.headLabel.text = self.headerString;
    
    if ([passedServerString isEqualToString:@"get_videos"]) {
        [self getDataForVideos];
        imgName = @"search-video-white.png";
    }
    else if ([passedServerString isEqualToString:@"get_musics"]) {
        [self getDataForMusic];
        imgName = @"search-music-white.png";
    }
    else if ([passedServerString isEqualToString:@"get_images"]) {
        [self getDataForImages];
        imgName = @"search-photos-white.png";
    }
    else if ([passedServerString isEqualToString:@"get_quotes"]) {
        [self getDataForQuotes];
        imgName = @"search-quotes-white.png";
    }
    
    appDelegate=(AppDelegate*)[[UIApplication sharedApplication]delegate];
    
}

#pragma mark - Navigation

- (IBAction)goBackHome:(id)sender {
    SearchVC *viewcontroller = (SearchVC*)[storyboard instantiateViewControllerWithIdentifier: @"searchView"];
    [self presentViewController:viewcontroller animated:YES completion:nil];
}

- (IBAction)backAction:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Getting data from Server

-(void)getDataForVideos
{
    [RequestManager getFromServer:self.passedServerString parameters:[NSMutableDictionary dictionaryWithObjectsAndKeys:[[NSUserDefaults standardUserDefaults] objectForKey:@"user_language"], @"user_language",@"0",@"page", nil] completionHandler:^(NSDictionary *responseDict){
        
        if ([[responseDict valueForKey:@"code"] isEqualToString:@"1"]) {
            
            dataArray = [responseDict valueForKey:@"data"];
            
            [initialTableDataArray removeAllObjects];
            
            for (NSDictionary *dic in dataArray) {
                Results *result = [[Results alloc] init];
                result.categoryNameString = [dic valueForKey:@"video_category_name"];
                result.detailArray = [dic valueForKey:@"video_details"];
                
                result.passDetailArray = [NSMutableArray array];
                
                for (NSDictionary *subDict in result.detailArray) {
                    
                    ArtistMusic *artistmusic=[[ArtistMusic alloc]init];
                    artistmusic.musicIdString=[subDict valueForKey:@"video_id"];
                    artistmusic.musicNameString=[subDict valueForKey:@"video_name"];
                    artistmusic.musicImageUrlString = [subDict valueForKey:@"video_thumbnail_url"];
                    artistmusic.musicFileUrlString = [subDict valueForKey:@"video_file_url"];
                    artistmusic.musicFavoriteStatus = [subDict valueForKey:@"favourite_status"];
                    artistmusic.musicPlaylistStatus = [subDict valueForKey:@"playlist_status"];
                    artistmusic.musicDescription = [subDict valueForKey:@"video_description"];
                    
                    [result.passDetailArray addObject:artistmusic];
                    
                }
                
                [initialTableDataArray addObject:result];
            }
            
            [self.dataTable reloadData];
        }
        [appDelegate hide_LoadingIndicator];
    }];
    
}

-(void)getDataForMusic
{
    [RequestManager getFromServer:self.passedServerString parameters:[NSMutableDictionary dictionaryWithObjectsAndKeys:[[NSUserDefaults standardUserDefaults] objectForKey:@"user_language"], @"user_language",@"0",@"page", nil] completionHandler:^(NSDictionary *responseDict){
        
        if ([[responseDict valueForKey:@"code"] isEqualToString:@"1"]) {
            
            dataArray = [responseDict valueForKey:@"data"];
            
            [initialTableDataArray removeAllObjects];
            
            for (NSDictionary *dic in dataArray) {
                Results *result = [[Results alloc] init];
                result.categoryNameString = [dic valueForKey:@"music_category_name"];
                result.detailArray = [dic valueForKey:@"music_details"];
                
                result.passDetailArray = [NSMutableArray array];
                
                for (NSDictionary *subDict in result.detailArray) {
                    
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
                    [result.passDetailArray addObject:artistmusic];
                    
                }
                
                [initialTableDataArray addObject:result];
            }
            
            [self.dataTable reloadData];
        }
        [appDelegate hide_LoadingIndicator];
    }];
    
}

-(void)getDataForImages
{
    [RequestManager getFromServer:self.passedServerString parameters:[NSMutableDictionary dictionaryWithObjectsAndKeys:@"0",@"page", nil] completionHandler:^(NSDictionary *responseDict){
        
        if ([[responseDict valueForKey:@"code"] isEqualToString:@"1"]) {
            
            dataArray = [responseDict valueForKey:@"data"];
            
            [initialTableDataArray removeAllObjects];
            
            for (NSDictionary *dic in dataArray) {
                Results *result = [[Results alloc] init];
                result.categoryNameString = [dic valueForKey:@"image_category_name"];
                result.detailArray = [dic valueForKey:@"image_details"];
                
                result.passDetailArray = [NSMutableArray array];
                
                for (NSDictionary *subDict in result.detailArray) {
                    ArtistMusic *artistmusic=[[ArtistMusic alloc]init];
                    artistmusic.musicIdString=[subDict valueForKey:@"images_id"];
                    artistmusic.musicNameString=[subDict valueForKey:@"image_title"];
                    artistmusic.musicImageUrlString = [subDict valueForKey:@"image_thumbnail_url"];
                    artistmusic.musicFileUrlString = [subDict valueForKey:@"image_file_url"];
                    artistmusic.musicFavoriteStatus = [subDict valueForKey:@"favourite_status"];
                    artistmusic.musicDescription = [subDict valueForKey:@"image_description"];
                    
                    [result.passDetailArray addObject:artistmusic];
                    
                }
                
                [initialTableDataArray addObject:result];
            }
            
            [self.dataTable reloadData];
        }
        [appDelegate hide_LoadingIndicator];
    }];
    
}

-(void)getDataForQuotes
{
    [RequestManager getFromServer:self.passedServerString parameters:[NSMutableDictionary dictionaryWithObjectsAndKeys:[[NSUserDefaults standardUserDefaults] objectForKey:@"user_language"], @"user_language",@"0",@"page", nil] completionHandler:^(NSDictionary *responseDict){
        
        if ([[responseDict valueForKey:@"code"] isEqualToString:@"1"]) {
            
            dataArray = [responseDict valueForKey:@"data"];
            
            [initialTableDataArray removeAllObjects];
            
            for (NSDictionary *dic in dataArray) {
                Results *result = [[Results alloc] init];
                result.categoryNameString = [dic valueForKey:@"quote_category_name"];
                result.detailArray = [dic valueForKey:@"quote_details"];
                
                result.passDetailArray = [NSMutableArray array];
                
                for (NSDictionary *subDict in result.detailArray) {
                    ArtistMusic *artistmusic=[[ArtistMusic alloc]init];
                    artistmusic.musicIdString=[subDict valueForKey:@"quote_id"];
                    artistmusic.musicNameString=[subDict valueForKey:@"quote_title"];
                    artistmusic.musicImageUrlString = [subDict valueForKey:@"quote_thumbnail_url"];
                    artistmusic.musicFileUrlString = [subDict valueForKey:@"quote_file_url"];
                    artistmusic.musicFavoriteStatus = [subDict valueForKey:@"favourite_status"];
                    artistmusic.musicDescription = [subDict valueForKey:@"quote_description"];
                    
                    [result.passDetailArray addObject:artistmusic];
                    
                }
                
                [initialTableDataArray addObject:result];
            }
            
            [self.dataTable reloadData];
        }
        [appDelegate hide_LoadingIndicator];
    }];
    
}

#pragma mark - Tableview delegates and data source

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return dataArray.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"containerCell";
    
    containerTableViewCell *cell = (containerTableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[containerTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    Results *result = (Results*)[initialTableDataArray objectAtIndex:indexPath.section];
    cell.sectionName = result.categoryNameString;
    cell.passedDataArr = result.passDetailArray;
    cell.categoryNameString = passedServerString;
    cell.delegate = self;
    [cell.dataCollection reloadData];
    return cell;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.dataTable.frame.size.width, 30)];
    headerView.backgroundColor = [UIColor colorWithRed:54.0f/255.0f green:27.0f/255.0f blue:73.0f/255.0f alpha:1.0];
    
    UIImageView *sectonImage = [[UIImageView alloc] initWithFrame:CGRectMake(5, 5, 20, 20)];
    sectonImage.image = [UIImage imageNamed:imgName];
    [headerView addSubview:sectonImage];
    
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(35, 5, headerView.frame.size.width - 95, 20)];
    
    Results *result = (Results*)[initialTableDataArray objectAtIndex:section];
    headerLabel.text = result.categoryNameString;
    headerLabel.font = [UIFont systemFontOfSize:14];
    headerLabel.textColor = [UIColor whiteColor];
    [headerView addSubview:headerLabel];
    
    UIButton *moreButton = [[UIButton alloc] initWithFrame:CGRectMake(headerLabel.frame.origin.y + headerLabel.frame.size.width, 5, 90, 20)];
    [moreButton setTitle:@"View More >" forState:UIControlStateNormal];
    moreButton.titleLabel.font = [UIFont systemFontOfSize:14];
    moreButton.tag = section;
    [moreButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [moreButton addTarget:self action:@selector(viewMoreAction:) forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:moreButton];
    
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 30.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 15.0;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *footerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.dataTable.frame.size.width, 15)];
    footerView.backgroundColor = [UIColor clearColor];
    
    return footerView;
}

-(void)viewMoreAction:(id)sender
{
    
    UIButton *btn = (UIButton*)sender;
    NSLog(@"more in section : %ld",(long)btn.tag);
    [appDelegate show_LoadingIndicator];
    SingleCategoryDataVC *viewController = (SingleCategoryDataVC *)[storyboard instantiateViewControllerWithIdentifier:@"singleView"];
    Results *result = (Results*)[initialTableDataArray objectAtIndex:btn.tag];
    
    NSString *stringToSend;
    
    if ([passedServerString isEqualToString:@"get_videos"]) {
        
        stringToSend = [NSString stringWithFormat:@"Videos - %@",result.categoryNameString];
    }
    else if ([passedServerString isEqualToString:@"get_musics"])
    {
        stringToSend = [NSString stringWithFormat:@"Music - %@",result.categoryNameString];
    }
    else if ([passedServerString isEqualToString:@"get_images"])
    {
        stringToSend = [NSString stringWithFormat:@"Images - %@",result.categoryNameString];
    }
    else if ([passedServerString isEqualToString:@"get_quotes"])
    {
        stringToSend = [NSString stringWithFormat:@"Quotes - %@",result.categoryNameString];
    }
    
    viewController.categoryTitleString = stringToSend;
    viewController.passedArr = result.passDetailArray;
    viewController.passedServer = passedServerString;
    viewController.indexCat = btn.tag;
    [self presentViewController:viewController animated:YES completion:^{
        [appDelegate hide_LoadingIndicator];
    }];
}

#pragma mark - Orientation

- (UIInterfaceOrientationMask) supportedInterfaceOrientations {
    
    return UIInterfaceOrientationMaskPortrait;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - containerTableViewCell Delegate

-(void)cellTapped:(NSDictionary*)dict fromArray:(NSMutableArray *)array atIndex:(int)index{

    [appDelegate show_LoadingIndicator];
    NSLog(@"cell tapped %@",dict);
    ArtistMusic *am = (ArtistMusic*)dict;
    UIViewController *newFrontController = nil;
    if ([passedServerString isEqualToString:@"get_images"] || [passedServerString isEqualToString:@"get_quotes"]) {
        
        ImageLargeVC *viewController = (ImageLargeVC *)[storyboard instantiateViewControllerWithIdentifier:@"enlargedView"];
        viewController.imgIdString = am.musicIdString;
        viewController.viewerUrlString = am.musicFileUrlString;
        viewController.favStatus = am.musicFavoriteStatus;
        viewController.headerString = am.musicNameString;
        viewController.passedArrayOfImages = array;
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
        viewController.passedArrayOfSongs = array;
        viewController.index = index;
        newFrontController = viewController;
        
    }
    [self presentViewController:newFrontController animated:true completion:^{
        
        
        if ([passedServerString isEqualToString:@"get_videos"]) {
            
            appDelegate.isMusic = NO;
        }
        else if ([passedServerString isEqualToString:@"get_musics"])
        {
            appDelegate.isMusic = YES;
            [appDelegate playCountWithId:am.musicIdString];
        }
        else if ([passedServerString isEqualToString:@"get_images"])
        {
            appDelegate.isQuote = NO;
        }
        else if ([passedServerString isEqualToString:@"get_quotes"])
        {
            appDelegate.isQuote = YES;
        }

        [appDelegate hide_LoadingIndicator];
    }];
    
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
