//
//  Artists.h
//  Klips
//
//  Created by iOS Developer on 24/12/15.
//  Copyright © 2015 iOS Developer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppDelegate.h"

@interface Artists : NSObject
@property(retain,nonatomic) NSString *artistIdString;
@property(retain,nonatomic) NSString *artistNameString;
@property(retain,nonatomic) NSString *artistImageUrltring;
@property(nonatomic, strong) UIImage *post_image;
@end
