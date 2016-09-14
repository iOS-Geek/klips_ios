//
//  FavoritesQuotesVC.h
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

@interface FavoritesQuotesVC : UIViewController<UITableViewDataSource,UITableViewDelegate>
{
    int favQuoteCounter;
}
@property(retain,nonatomic) NSMutableDictionary *imageDownloadsInProgress;
@property (weak, nonatomic) IBOutlet UIButton *sideMenuButton;
@property (weak, nonatomic) IBOutlet UITableView *favoriteQuoteTable;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;

@end
