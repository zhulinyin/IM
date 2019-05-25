//
//  UserManager.m
//  IM
//
//  Created by zhulinyin on 2019/5/11.
//  Copyright © 2019 zhulinyin. All rights reserved.
//

#import "UserManager.h"

@interface UserManager()
@property(strong, nonatomic) UserModel *loginUser;
@property(strong, nonatomic) SocketRocketUtility *socket;
@end

@implementation UserManager

static UserManager *instance = nil;


+(instancetype) getInstance
{
    static dispatch_once_t onceToken ;
    dispatch_once(&onceToken, ^{
        instance = [[super allocWithZone:NULL] init];
        instance.socket = [SocketRocketUtility instance];
    }) ;
    
    return instance;
}


+(id) allocWithZone:(struct _NSZone *)zone
{
    return [UserManager getInstance] ;
}


-(id) copyWithZone:(struct _NSZone *)zone
{
    return [UserManager getInstance] ;
}


-(UserModel*) getLoginModel
{
    return self.loginUser;
}


-(void) login:(NSString *)username withPassword:(NSString *)password
{
    void (^loginEvent)(id) = ^void (id object)
    {
        NSDictionary *result = object;
        if([result[@"state"] isEqualToString:@"ok"])
        {
            NSLog(@"login success");
            self.loginUser = [[UserModel alloc] initWithProperties:username NickName:username RemarkName:username Gender:@"man" Birthplace:@"guangzhou" ProfilePicture:@"peppa"];
            self.seq = [[NSUserDefaults standardUserDefaults] integerForKey:[NSString stringWithFormat:@"%@seq", username]];
            [self.socket SRWebSocketOpen];
            UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            [UIApplication sharedApplication].keyWindow.rootViewController = mainStoryboard.instantiateInitialViewController;
        }
        else
        {
            NSLog(@"login fail");
        }
    };
    
    NSString *params = [[NSString alloc] initWithFormat:@"username=%@&password=%@", username, password];
//    NSLog(params);
    [SessionHelper sendRequest:@"/account/login" method:@"post" parameters:params handler:loginEvent];
    
}


-(void) logout
{
    void (^returnToLogin)(id) = ^void (id object)
    {
        NSDictionary *result = object;
        if([result[@"state"] isEqualToString:@"ok"])
        {
            NSLog(@"%@", result[@"msg"]);
            self.loginUser = nil;
            [self.socket SRWebSocketClose];
            UIStoryboard *indexStoryboard = [UIStoryboard storyboardWithName:@"Index" bundle:nil];
            [UIApplication sharedApplication].keyWindow.rootViewController = indexStoryboard.instantiateInitialViewController;
        }
        else
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"登出失败" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alertView show];
            NSLog(@"logout fail");
        }
    };
    
    NSString *params = @"";
    [SessionHelper sendRequest:@"/account/logout" method:@"get" parameters:params handler:returnToLogin];
    
    
}


-(void) register:(NSString *)username withPassword:(NSString *)password
{
    void (^registerEvent)(id) = ^void (id object)
    {
        NSDictionary *result = object;
        if([result[@"state"] isEqualToString:@"ok"])
        {
            NSLog(@"register success");
            self.loginUser = [[UserModel alloc] initWithProperties:username NickName:username RemarkName:username Gender:@"man" Birthplace:@"guangzhou" ProfilePicture:@"peppa"];
            [self.socket SRWebSocketOpen];
            //sign in automatically after successfully signing up
            [self login:username withPassword:password];
        }
        else
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"注册失败" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alertView show];
            NSLog(@"register fail");
        }
    };
    
    NSString *params = [[NSString alloc] initWithFormat:@"username=%@&password=%@", username, password];
    [SessionHelper sendRequest:@"/account/register" method:@"post" parameters:params handler:registerEvent];
}

-(void) modifyInfo:(NSString *)attr withValue:(NSString *)value
{
    void (^modifyInfoEvent)(id) = ^void (id object)
    {
        NSDictionary *result = object;
        if([result[@"state"] isEqualToString:@"ok"])
        {
            NSLog(@"modifyInfo success");
        }
        else
        {
            NSLog(result[@"msg"]);
            NSLog(@"modifyInfo fail");
        }
    };
    NSString *params = [[NSString alloc] initWithFormat:@"value=%@", value];
    NSString *api = [[NSString alloc] initWithFormat:@"/account/info/%@", attr];
    NSLog(api);
    NSLog(params);
    [SessionHelper sendRequest:api method:@"put" parameters:params handler:modifyInfoEvent];
}

@end
