//
//  ArtistDetailVC.h
//  Klips
//
//  Created by iOS Developer on 15/12/15.
//  Copyright © 2015 iOS Developer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PlayVideoVC.h"
#import "AppDelegate.h"
#import "ArtistMusic.h"
#import "IconDownloader.h"

@interface ArtistDetailVC : UIViewController<UITableViewDataSource,UITableViewDelegate>
{
    int pageCounter;
}
@property(retain,nonatomic) NSMutableDictionary *imageDownloadsInProgress;
@property (weak, nonatomic) IBOutlet UITableView *artistMusicTable;
@property (weak, nonatomic) IBOutlet UIImageView *artistImageView;
@property (weak, nonatomic) IBOutlet UILabel *artistName;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property(retain,nonatomic) NSString *selectedArtistIdString;
@property(retain,nonatomic) NSString *selectedArtistNameString;
@property(retain,nonatomic) NSString *selectedArtistImageUrltring;
@end
