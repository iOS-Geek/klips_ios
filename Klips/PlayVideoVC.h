//
//  PlayVideoVC.h
//  Klips
//
//  Created by iOS Developer on 18/12/15.
//  Copyright © 2015 iOS Developer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>
#import "AppDelegate.h"
#import "ArtistMusic.h"

@interface PlayVideoVC : UIViewController

@property (weak, nonatomic) IBOutlet UIView *viewPlayerContainer;
@property (weak, nonatomic) IBOutlet UIButton *playPauseButton;
@property (weak, nonatomic) IBOutlet UILabel *durationLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeDoneLabel;
@property (weak, nonatomic) IBOutlet UILabel *TimeLeftLabel;
@property (weak, nonatomic) IBOutlet UISlider *scrubber;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *videoImage;
@property (weak, nonatomic) IBOutlet UIButton *favButton;
@property (weak, nonatomic) IBOutlet UIButton *playlistButton;

@property (weak, nonatomic) IBOutlet UIView *controlView;

@property(retain,nonatomic) NSString *playerUrlString;
@property(retain,nonatomic) NSString *titleLabelString;
@property(retain,nonatomic) NSString *imageUrlString;
@property(retain,nonatomic) NSString *idString;
@property(retain,nonatomic) NSString *favStatus;
@property(retain,nonatomic) NSString *playlistStatus;
@property(retain,nonatomic) NSArray *passedArrayOfSongs;
@property(nonatomic, assign) int index;

@end
