//
//  SessionHelper.m
//  IM
//
//  Created by Ray Shaw on 2019/5/10.
//  Copyright © 2019年 zhulinyin. All rights reserved.
//

#import "SessionHelper.h"


//NSString* const SERVER_DOMAIN = @"http://172.18.32.97:8000";
NSString* const SERVER_DOMAIN = @"http://118.89.65.154:8000";


@implementation SessionHelper

+ (void)sendRequest:(NSString*)path method:(NSString*)method parameters:(NSString*)parameters handler:(void(^)(id))handler
{
    //NSString* serverDomain = @"http://172.18.32.97:8000";
    //NSString* serverDomain = @"http://118.89.65.154:8000";
    NSString* urlString = [SERVER_DOMAIN stringByAppendingString:path];
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:defaultConfigObject delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    
    [urlRequest setHTTPMethod:method];
    if (![parameters isEqual: @""])
    {
        NSString *params = [[NSString alloc] initWithString:parameters];
        [urlRequest setHTTPBody:[params dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest:urlRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error)
    {
        if(error == nil)
        {
            if(NSClassFromString(@"NSJSONSerialization"))
            {
                NSError *parseError = nil;
                id object = [NSJSONSerialization JSONObjectWithData:data options:0 error:&parseError];
                if(parseError)
                {
                    NSLog(@"parse error: %@", parseError);
                }
                if([object isKindOfClass:[NSDictionary class]])
                {
                    handler(object);
                }
                else
                {
                    NSLog(@"Not dictionary");
                }
            }
        }
        else
        {
            NSLog(@"Network error:%@", error);
        }
    }];
    
    [task resume];
}

@end

