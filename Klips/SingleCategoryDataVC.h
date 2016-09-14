//
//  SingleCategoryDataVC.h
//  Klips
//
//  Created by iOS Developer on 29/02/16.
//  Copyright © 2016 iOS Developer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "ArtistMusic.h"
#import "PlayVideoVC.h"
#import "ImageLargeVC.h"
#import "IconDownloader.h"
#import "SearchVC.h"

@interface SingleCategoryDataVC : UIViewController<UITableViewDataSource,UITableViewDelegate>
{
    int pageCounter;
}
@property(retain,nonatomic) NSMutableDictionary *imageDownloadsInProgress;
@property(retain,nonatomic) NSString *categoryTitleString;
@property(retain,nonatomic) NSArray *passedArr;
@property(retain,nonatomic) NSString *passedServer;
@property (weak, nonatomic) IBOutlet UITableView *moreDataTable;
@property (weak, nonatomic) IBOutlet UILabel *categoryHeader;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property (weak, nonatomic) IBOutlet UIImageView *navigateBackBtn;
@property(nonatomic, assign) int indexCat;
@end
