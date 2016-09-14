/*
 Copyright (C) 2015 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 Helper object for managing the downloading of a particular app's icon.
  It uses NSURLSession/NSURLSessionDataTask to download the app's icon in the background if it does not
  yet exist and works in conjunction with the RootViewController to manage which apps need their icon.
 */

#include "AppDelegate.h"
#include "Artists.h"
#include "ArtistMusic.h"
//@class ArtistMusic;
//@class Artists;
@interface IconDownloader : NSObject

@property (nonatomic, strong) ArtistMusic *results;
@property (nonatomic, strong) Artists *artResult;

@property (nonatomic, copy) void (^completionHandler)(void);

//- (void)startDownload;
- (void)startDownloadFor:(NSString*)className;
- (void)cancelDownload;

@end
