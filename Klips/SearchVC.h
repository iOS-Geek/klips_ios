//
//  SearchVC.h
//  Klips
//
//  Created by iOS Developer on 19/02/16.
//  Copyright © 2016 iOS Developer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "PlayVideoVC.h"
#import "ArtistMusic.h"
#import "ImageLargeVC.h"
#import "IconDownloader.h"

@interface SearchVC : UIViewController<UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate>
{
    int pageCounter;
}
@property(retain,nonatomic) NSMutableDictionary *imageDownloadsInProgress;
@property (weak, nonatomic) IBOutlet UITableView *searchResultTable;
@property (weak, nonatomic) IBOutlet UISearchBar *searchKlipsBar;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property (weak, nonatomic) IBOutlet UILabel *videoLabel;
@property (weak, nonatomic) IBOutlet UIImageView *videoImg;
@property (weak, nonatomic) IBOutlet UILabel *musicLabel;
@property (weak, nonatomic) IBOutlet UIImageView *musicImg;
@property (weak, nonatomic) IBOutlet UILabel *imageLabel;
@property (weak, nonatomic) IBOutlet UIImageView *imageImg;
@property (weak, nonatomic) IBOutlet UILabel *quoteLabel;
@property (weak, nonatomic) IBOutlet UIImageView *quoteImg;

@end
