//
//  ArtistMusic.h
//  Klips
//
//  Created by iOS Developer on 28/12/15.
//  Copyright © 2015 iOS Developer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppDelegate.h"

@interface ArtistMusic : NSObject
@property(retain,nonatomic) NSString *musicIdString;
@property(retain,nonatomic) NSString *musicNameString;
@property(retain,nonatomic) NSString *musicImageUrlString;
@property(retain,nonatomic) NSString *musicFileUrlString;
@property(retain,nonatomic) NSString *musicFavoriteStatus;
@property(retain,nonatomic) NSString *musicPlaylistStatus;
@property(retain,nonatomic) NSString *musicDescription;
@property(retain,nonatomic) NSMutableArray *artistDetails;
@property(nonatomic, strong) UIImage *post_image;
@end
