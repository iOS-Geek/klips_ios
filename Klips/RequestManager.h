//
//  RequestManager.h
//  Blendedd
//
//  Created by iOS Developer on 15/11/15.
//  Copyright © 2015 Prabh Kiran Kaur. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppDelegate.h"
@interface RequestManager : NSObject

typedef void (^RequestManagerHandler)(NSDictionary* responseDict);

+(void)getFromServer:(NSString*)api parameters:(NSMutableDictionary*)parameters completionHandler:(RequestManagerHandler)handler;

+ (void)uploadImageData:(NSData*)imageData toServer:(NSString*)api withImageName:(NSString*)imageName andParams:(NSDictionary*)paramsDict completionHandler:(RequestManagerHandler)handler;

@end
