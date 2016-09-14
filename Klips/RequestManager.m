//
//  RequestManager.m
//  Blendedd
//
//  Created by iOS Developer on 15/11/15.
//  Copyright © 2015 Prabh Kiran Kaur. All rights reserved.
//

#import "RequestManager.h"

@implementation RequestManager

+(void)getFromServer:(NSString*)api parameters:(NSMutableDictionary*)parameters completionHandler:(RequestManagerHandler)handler
{
//    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    
    NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration: defaultConfigObject delegate: nil delegateQueue: [NSOperationQueue mainQueue]];
    
    NSURL * url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",BaseUrl,api]];
    
    NSArray *temp = [[NSArray alloc] init];
    temp = [parameters allKeys];
    NSString *paramterString=@"";
    NSEnumerator *e = [temp objectEnumerator];
    id object;
    while (object = [e nextObject]) {
        paramterString=[[[[paramterString stringByAppendingString:object] stringByAppendingString:@"="]stringByAppendingString:[parameters objectForKey:object]]stringByAppendingString:@"&"];
    }
    paramterString = [paramterString substringToIndex:paramterString.length-1];
    
    NSMutableURLRequest * urlRequest = [NSMutableURLRequest requestWithURL:url];
    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest setHTTPBody:[paramterString dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSURLSessionDataTask * dataTask =[defaultSession dataTaskWithRequest:urlRequest
                                                       completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                           NSLog(@"Response:%@ %@\n", response, error);
                                                           NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
                                                           NSLog(@"response status code: %ld", (long)[httpResponse statusCode]);
                                                           [[NSUserDefaults standardUserDefaults]setObject:[NSString stringWithFormat:@"%ld",(long)[httpResponse statusCode]] forKey:@"status_code"];
                                                           
                                                               if(error == nil)
                                                               {
                                                                   dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                                                                       NSDictionary* responseDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                                                                       NSLog(@"Parsed");
                                                                       dispatch_async(dispatch_get_main_queue(), ^{
                                                                           if(handler != nil && responseDict != nil)
                                                                               handler(responseDict);
                                                                           NSLog(@"Parse and send");
                                                                       });
                                                                   });
                                                               }
                                                               else
                                                               {
                                                                   NSLog(@"Connection Error :- %@", [error description]);
                                                                   
                                                                   NSDictionary *dict =[NSDictionary dictionaryWithObjectsAndKeys:@"1",@"error", nil];
                                                                   handler(dict);
                                                               }
                                                           
                                                           
                                                         
                                                           
                                                       }];
    [dataTask resume];
    
}

+ (void)uploadImageData:(NSData*)imageData toServer:(NSString*)api withImageName:(NSString*)imageName andParams:(NSDictionary*)paramsDict completionHandler:(RequestManagerHandler)handler
{
    NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration: defaultConfigObject delegate: nil delegateQueue: [NSOperationQueue mainQueue]];
    
    // creating a NSMutableURLRequest that we can manipulate before sending
     NSURL * url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",BaseUrl,api]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    
    // setting the HTTP method
    [request setHTTPMethod:@"POST"];
    
    // we want a JSON response
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    // the boundary string. Can be whatever we want, as long as it doesn't appear as part of "proper" fields
    NSString *boundary = @"qqqq___winter_is_coming_!___qqqq";
    
    // setting the Content-type and the boundary
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    [request setValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    // we need a buffer of mutable data where we will write the body of the request
    NSMutableData *body = [NSMutableData data];
    
    
    // writing the basic parameters
    for (NSString *key in paramsDict) {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", key] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"%@\r\n", [paramsDict objectForKey:key]] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    
    
    
    // creating a NSData representation of the image
    //NSData *imageData = UIImageJPEGRepresentation(image, 1.0);
    //NSString *fileNameStr = [NSString stringWithFormat:@"%@.jpg", imageName];
    NSString *fileNameStr = imageName;
    
    
    // if we have successfully obtained a NSData representation of the image
    if (imageData) {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"user_profile_image\"; filename=\"%@\"\r\n", fileNameStr] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"Content-Type: image/png\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:imageData];
        [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    else
        NSLog(@"no image data!!!");
    
    // we close the body with one last boundary
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    
    // assigning the completed NSMutableData buffer as the body of the HTTP POST request
    [request setHTTPBody:body];
    
    NSURLSessionDataTask * dataTask =[defaultSession dataTaskWithRequest:request
                                                       completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                           NSLog(@"Response:%@ %@\n", response, error);
                                                           if(error == nil)
                                                           {
                                                               // NSString * text = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
                                                               dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                                                                   NSDictionary* responseDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                                                                   NSLog(@"Parsed");
                                                                   dispatch_async(dispatch_get_main_queue(), ^{
                                                                       if(handler != nil && responseDict != nil)
                                                                           handler(responseDict);
                                                                       NSLog(@"Parse and send");
                                                                   });
                                                               });
                                                           }
                                                           else
                                                           {
                                                               NSLog(@"Connection Error :- %@", [error description]);
                                                               
                                                               NSDictionary *dict =[NSDictionary dictionaryWithObjectsAndKeys:@"1",@"error", nil];
                                                               handler(dict);
                                                           }
                                                           
                                                       }];
    [dataTask resume];

    
}

@end
