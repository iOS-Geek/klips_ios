//
//  baseCollectionViewCell.h
//  Klips
//
//  Created by iOS Developer on 30/12/15.
//  Copyright © 2015 iOS Developer. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface baseCollectionViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *dataImageView;
@property (weak, nonatomic) IBOutlet UILabel *dataTitle;
@property (weak, nonatomic) IBOutlet UILabel *dataSubTitle;
@property (weak, nonatomic) IBOutlet UIImageView *playImage;
@property(retain,nonatomic) NSString *sectionName;
@property(retain,nonatomic) NSString *urlString;
@property(retain,nonatomic) NSString *favString;
@property(retain,nonatomic) NSString *playlistString;
@end
