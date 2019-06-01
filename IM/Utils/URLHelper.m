//
//  URLHelper.m
//  IM
//
//  Created by student5 on 2019/6/1.
//  Copyright © 2019 zhulinyin. All rights reserved.
//

#import "URLHelper.h"


NSString* const SOCKET_DOMAIN = @"ws://118.89.65.154:6789";
NSString* const SERVER_DOMAIN = @"http://172.18.32.97:8000";
//NSString* const SERVER_DOMAIN = @"http://118.89.65.154:8000";

@implementation URLHelper

+ (NSString*)getURLwithPath:(NSString*)path
{
    return [SERVER_DOMAIN stringByAppendingString:path];
}

+ (NSString*)getSocketDomain
{
    return SOCKET_DOMAIN;
}

@end
