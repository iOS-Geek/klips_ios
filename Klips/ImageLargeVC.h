//
//  ImageLargeVC.h
//  Klips
//
//  Created by iOS Developer on 16/12/15.
//  Copyright © 2015 iOS Developer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "FullScreenVC.h"
#import "IconDownloader.h"

@interface ImageLargeVC : UIViewController<UICollectionViewDataSource,UICollectionViewDelegate>
@property(retain,nonatomic) NSString *viewerUrlString;
@property(retain,nonatomic) NSString *favStatus;
@property(retain,nonatomic) NSString *headerString;
@property(retain,nonatomic) NSString *imgIdString;
@property (weak, nonatomic) IBOutlet UILabel *headerTitle;
@property (weak, nonatomic) IBOutlet UIButton *FavButton;
@property (weak, nonatomic) IBOutlet UIImageView *viewImage;
@property (weak, nonatomic) IBOutlet UICollectionView *galleryView;
@property(retain,nonatomic) NSArray *passedArrayOfImages;
@property(retain,nonatomic) NSMutableDictionary *imageDownloadsInProgress;
@end
