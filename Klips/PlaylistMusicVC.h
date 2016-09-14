//
//  PlaylistMusicVC.h
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

@interface PlaylistMusicVC : UIViewController<UITableViewDataSource,UITableViewDelegate>
{
   int musicCounter;
}
@property(retain,nonatomic) NSMutableDictionary *imageDownloadsInProgress;
@property (weak, nonatomic) IBOutlet UIButton *sideMenuButton;
@property (weak, nonatomic) IBOutlet UITableView *userMusicPlaylistTable;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;

@end
