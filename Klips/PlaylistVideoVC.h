//
//  PlaylistVideoVC.h
//  Klips
//
//  Created by iOS Developer on 16/12/15.
//  Copyright © 2015 iOS Developer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWRevealViewController.h"
#import "PlayVideoVC.h"
#import "ArtistMusic.h"
#import "IconDownloader.h"

@interface PlaylistVideoVC : UIViewController<UITableViewDelegate,UITableViewDataSource>
{
    int videoCounter;
}
@property(retain,nonatomic) NSMutableDictionary *imageDownloadsInProgress;
@property (weak, nonatomic) IBOutlet UIButton *sideMenuButton;
@property (weak, nonatomic) IBOutlet UITableView *videoPlaylistTable;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;

@end
