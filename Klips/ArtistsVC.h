//
//  ArtistsVC.h
//  Klips
//
//  Created by iOS Developer on 15/12/15.
//  Copyright © 2015 iOS Developer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWRevealViewController.h"
#import "ArtistDetailVC.h"
#import "Artists.h"
#import "AppDelegate.h"
#import "IconDownloader.h"

@interface ArtistsVC : UIViewController<UITableViewDataSource,UITableViewDelegate>
{
    int pageCount;
}
@property(retain,nonatomic) NSMutableDictionary *imageDownloadsInProgress;
@property (weak, nonatomic) IBOutlet UITableView *artistsTable;
@property (weak, nonatomic) IBOutlet UIButton *sideMenuButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;

@end
