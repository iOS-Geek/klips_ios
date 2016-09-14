//
//  FullScreenVC.h
//  Klips
//
//  Created by iOS Developer on 29/02/16.
//  Copyright © 2016 iOS Developer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@interface FullScreenVC : UIViewController<UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *headerLabel;
@property (weak, nonatomic) IBOutlet UIImageView *fullImgView;
@property(retain,nonatomic) NSString *headerString;
@property (weak, nonatomic) IBOutlet UIScrollView *fullScroll;
@property(retain,nonatomic) NSString *imgUrlString;
@end
