//
//  containerTableViewCell.m
//  Klips
//
//  Created by iOS Developer on 30/12/15.
//  Copyright © 2015 iOS Developer. All rights reserved.
//

#import "containerTableViewCell.h"
#import "ArtistMusic.h"
@implementation containerTableViewCell
@synthesize sectionName,imageDownloadsInProgress;

- (void)awakeFromNib {
    // Initialization code
    imageDownloadsInProgress = [NSMutableDictionary dictionary];
}

#pragma mark - Collectionview data source and delegate

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.passedDataArr.count;
    
}

-(UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"baseCell";
    
    baseCollectionViewCell *cell = (baseCollectionViewCell*)[collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    cell.sectionName = sectionName;
    
    ArtistMusic *artistMusic = (ArtistMusic*)[self.passedDataArr objectAtIndex:indexPath.row];
    cell.dataTitle.text = artistMusic.musicNameString;
    cell.dataSubTitle.text = artistMusic.musicDescription;
    
    if (!artistMusic.post_image) {
        cell.dataImageView.image=nil;
        [self startIconDownload:artistMusic forIndexPath:indexPath];
    }
    else{
        cell.dataImageView.image=artistMusic.post_image;
    }
    
    cell.urlString = artistMusic.musicFileUrlString;
    cell.favString = artistMusic.musicFavoriteStatus;
    cell.playlistString = artistMusic.musicPlaylistStatus;
    if ([self.categoryNameString isEqualToString:@"get_images"] || [self.categoryNameString isEqualToString:@"get_quotes"])
    {
        cell.playImage.hidden = true;
    }
    else
    {
        cell.playImage.hidden = false;
    }
    return cell;
    
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    baseCollectionViewCell *selectedCell = (baseCollectionViewCell*)[collectionView cellForItemAtIndexPath:indexPath];
    if (selectedCell) {
        
        ArtistMusic *artistMusic = (ArtistMusic*)[self.passedDataArr objectAtIndex:indexPath.row];
        
        NSLog(@"row : %ld section : %@ url : %@",(long)indexPath.row,selectedCell.sectionName,selectedCell.urlString);
        
        [self.delegate cellTapped:artistMusic fromArray:self.passedDataArr atIndex:(int)indexPath.row];
        
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
            
            baseCollectionViewCell *cell = (baseCollectionViewCell*)[self.dataCollection cellForItemAtIndexPath:indexPath];
            
            // Display the newly loaded image
            cell.dataImageView.image = appRecord.post_image;
            
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

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
