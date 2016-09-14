//
//  DisplayScrollDataVC.h
//  Klips
//
//  Created by iOS Developer on 17/12/15.
//  Copyright © 2015 iOS Developer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PlayVideoVC.h"
#import "ImageLargeVC.h"
#import "containerTableViewCell.h"
#import "Results.h"
#import "ArtistDetailVC.h"
#import "SingleCategoryDataVC.h"
#import "SearchVC.h"

@interface DisplayScrollDataVC : UIViewController<UITableViewDataSource,UITableViewDelegate,containerTableViewCellDelegate>

@property (weak, nonatomic) IBOutlet UILabel *headLabel;
@property (weak, nonatomic) IBOutlet UITableView *dataTable;
@property(retain,nonatomic) NSString *passedServerString;
@property(retain,nonatomic) NSString *headerString;
@end
