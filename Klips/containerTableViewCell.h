//
//  containerTableViewCell.h
//  Klips
//
//  Created by iOS Developer on 30/12/15.
//  Copyright © 2015 iOS Developer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "baseCollectionViewCell.h"
#import "AppDelegate.h"
#import "PlayVideoVC.h"
#import "IconDownloader.h"

@protocol containerTableViewCellDelegate <NSObject>
    
-(void)cellTapped:(ArtistMusic*)dict fromArray:(NSMutableArray*)array atIndex:(int)index;

@end

@interface containerTableViewCell : UITableViewCell<UICollectionViewDataSource,UICollectionViewDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *dataCollection;
@property(retain,nonatomic) NSString *sectionName;
@property(retain,nonatomic) NSString *categoryNameString;
@property(retain,nonatomic) NSMutableArray *passedDataArr;
@property(retain,nonatomic) NSMutableDictionary *imageDownloadsInProgress;
@property id <containerTableViewCellDelegate> delegate;


@end
