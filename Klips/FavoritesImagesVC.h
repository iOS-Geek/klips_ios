//
//  FavoritesImagesVC.h
//  Klips
//
//  Created by iOS Developer on 16/12/15.
//  Copyright © 2015 iOS Developer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWRevealViewController.h"
#import "ImageLargeVC.h"
#import "ArtistMusic.h"
#import "AppDelegate.h"
#import "IconDownloader.h"

@interface FavoritesImagesVC : UIViewController<UITableViewDataSource,UITableViewDelegate>
{
    int favImageCounter;
}
@property(retain,nonatomic) NSMutableDictionary *imageDownloadsInProgress;
@property (weak, nonatomic) IBOutlet UIButton *sideMenuButton;
@property (weak, nonatomic) IBOutlet UITableView *favoriteImagesTable;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;

@end
