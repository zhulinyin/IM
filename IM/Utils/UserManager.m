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


// 获取用户的信息
-(void) getInfo{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    NSString *url = [URLHelper getURLwithPath:@"/account/info"];
    [manager GET:url parameters:nil progress:nil
        success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            NSLog(@"getInfo success");
            self.loginUser = [[UserModel alloc] initWithProperties:responseObject[@"data"][@"Username"]
                                                          NickName:responseObject[@"data"][@"Nickname"]
                                                        RemarkName:responseObject[@"data"][@"Username"]
                                                            Gender:responseObject[@"data"][@"Gender"]
                                                         Birthplace:responseObject[@"data"][@"Region"]
                                                    ProfilePicture:responseObject[@"data"][@"Avatar"]];
            NSLog(@"%@", responseObject[@"data"][@"Avatar"]);
            [[NSUserDefaults standardUserDefaults] setValue:responseObject[@"data"][@"Avatar"] forKey:@"loginUserAvatar"];
            [[DatabaseHelper getInstance] registerNewMessagesListener];
            [self.socket SRWebSocketOpen];
    }
        failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            NSLog(@"getInfo fail");
            NSLog(@"%@", error.localizedDescription);
    }];
}


-(void) login:(NSString *)username withPassword:(NSString *)password
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    NSString *url = [URLHelper getURLwithPath:@"/account/login"];
    NSDictionary *params = @{@"username":username, @"password":password};
    
    [manager POST:url parameters:params progress:nil
        success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            if([responseObject[@"state"] isEqualToString:@"ok"])
            {
                NSLog(@"login success");
                self.loginUserId = username;
                // 登陆成功后，获取用户的个人信息
                [self getInfo];
                self.seq = [[NSUserDefaults standardUserDefaults] integerForKey:[NSString stringWithFormat:@"%@seq", username]];
                [[NSUserDefaults standardUserDefaults] setValue:username forKey:@"loginUsername"];
                
                MainViewController *vc = [[MainViewController alloc] init];
                [UIApplication sharedApplication].keyWindow.rootViewController = vc;
            }
            else
            {
                NSLog(@"login fail");
            }
        }
        failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            NSLog(@"login fail");
            NSLog(@"%@", error.localizedDescription);
        }];
}

-(void) tryLogin
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    NSString *url = [URLHelper getURLwithPath:@"/account/login"];
    
    [manager GET:url parameters:nil progress:nil
        success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            if([responseObject[@"state"] isEqualToString:@"ok"])
            {
                NSLog(@"login success");
                NSString *username = [[NSUserDefaults standardUserDefaults] stringForKey:@"loginUsername"];
                self.loginUserId = username;
                // 登陆成功后，获取用户的个人信息
                [self getInfo];
                
                //            self.loginUser = [[UserModel alloc] initWithProperties:username NickName:username RemarkName:username Gender:@"man" Birthplace:@"guangzhou" ProfilePicture:@"peppa"];
                self.seq = [[NSUserDefaults standardUserDefaults] integerForKey:[NSString stringWithFormat:@"%@seq", username]];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:@"tryLogin" object:@"success"];
                
            }
            else
            {
                NSLog(@"login fail");
                [[NSNotificationCenter defaultCenter] postNotificationName:@"tryLogin" object:@"fail"];
            }
        }
        failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            NSLog(@"login fail");
            NSLog(@"%@", error.localizedDescription);
        }];
}

-(void) logout
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    NSString *url = [URLHelper getURLwithPath:@"/account/logout"];
    
    
    [manager DELETE:url parameters:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
     {
         if([responseObject[@"state"] isEqualToString:@"ok"])
         {
             NSLog(@"%@", responseObject[@"msg"]);
             self.loginUser = nil;
             self.loginUserId = @"";
             [self.socket SRWebSocketClose];
             [[DatabaseHelper getInstance] unregisterNewMessageListener];
             [DatabaseHelper attemptDealloc];
             UIStoryboard *indexStoryboard = [UIStoryboard storyboardWithName:@"Index" bundle:nil];
             [UIApplication sharedApplication].keyWindow.rootViewController = indexStoryboard.instantiateInitialViewController;
         }
         else
         {
             UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"登出失败" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
             [alertView show];
             NSLog(@"logout fail");
         }
     } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error)
     {
         NSLog(@"logout fail");
         NSLog(@"%@", error.localizedDescription);
     }];
    
}


-(void) register:(NSString *)username withPassword:(NSString *)password
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    NSString *url = [URLHelper getURLwithPath:@"/account/register"];
    NSDictionary *params = @{@"username":username, @"password":password};
    
    [manager POST:url parameters:params progress:nil
       success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
           if([responseObject[@"state"] isEqualToString:@"ok"])
           {
               NSLog(@"register success");
               //sign in automatically after successfully signing up
               [self login:username withPassword:password];
           }
           else
           {
               UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"注册失败" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
               [alertView show];
               NSLog(@"register fail");
           }
       }
       failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
           UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"注册失败" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
           [alertView show];
           NSLog(@"register fail");
           NSLog(@"%@", error.localizedDescription);
       }];
                    
}

-(void) modifyInfo:(NSString *)attr withValue:(NSString *)value
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    NSString *url = [URLHelper getURLwithPath:[[NSString alloc] initWithFormat:@"/account/info/%@", attr]];
    NSDictionary *params = @{@"value":value};

    [manager PUT:url parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if([responseObject[@"state"] isEqualToString:@"ok"])
        {
            NSLog(@"modifyInfo success");
        }
        else
        {
            NSLog(@"%@", responseObject[@"msg"]);
            NSLog(@"modifyInfo fail");
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"modifyInfo fail");
        NSLog(@"%@", error.localizedDescription);
    }];
}

// 上传图片到服务器
-(void) uploadImage:(NSString* )path withImage:(UIImage* )image
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager.requestSerializer setValue:@"multipart/form-data" forHTTPHeaderField:@"Content-Type"];
    
    // 处理url
    NSString* urlString = [URLHelper getURLwithPath:path];
    NSLog(@"%@", urlString);
    [manager POST:urlString parameters:nil constructingBodyWithBlock:
     ^(id<AFMultipartFormData> _Nonnull formData){
        // 图片转data
        NSData *data = UIImagePNGRepresentation(image);
        [formData appendPartWithFileData :data name:@"file" fileName:@"928-1.png"
                                 mimeType:@"multipart/form-data"];
    } progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id _Nonnull responseObject){
        NSLog(@"uploadImage success");
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error){
        NSLog(@"uploadImage fail");
        NSLog(@"%@", error.localizedDescription);
    }];
}

// 发送图片e给好友
-(void) sendImage:(NSString* )path withImage:(UIImage* )image
       withToUser:(NSString* )userName
         withDate:(NSDate* )timestamp
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager.requestSerializer setValue:@"multipart/form-data" forHTTPHeaderField:@"Content-Type"];
    
    // 处理url
    NSString* urlString = [URLHelper getURLwithPath:path];
    NSLog(@"%@", urlString);
    // 添加参数
    NSDictionary* params = @{@"to":userName, @"timestamp":timestamp};
    // 发送图片
    [manager POST:urlString parameters:params constructingBodyWithBlock:
     ^(id<AFMultipartFormData> _Nonnull formData){
         // 图片转data
         NSData *data = UIImagePNGRepresentation(image);
         [formData appendPartWithFileData :data name:@"file" fileName:@"928-1.png"
                                  mimeType:@"multipart/form-data"];
     } progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id _Nonnull responseObject){
         NSLog(responseObject[@"msg"]);
     } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error){
         NSLog(@"sendImage fail");
         NSLog(@"%@", error.localizedDescription);
     }];
}


@end
