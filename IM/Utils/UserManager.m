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
    AFHTTPSessionManager *manger = [AFHTTPSessionManager manager];
    NSString *url = @"http://118.89.65.154:8000/account/info";
    [manger GET:url parameters:nil progress:nil
        success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            NSLog(@"getInfo success");
            self.loginUser = [[UserModel alloc] initWithProperties:responseObject[@"data"][@"Username"]
                                                          NickName:responseObject[@"data"][@"Nickname"]
                                                        RemarkName:responseObject[@"data"][@"Username"]
                                                            Gender:responseObject[@"data"][@"Gender"]
                                                         Birthplace:responseObject[@"data"][@"Region"]
                                                    ProfilePicture:responseObject[@"data"][@"Avatar"]];
            NSLog(responseObject[@"data"][@"Avatar"]);
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
    void (^loginEvent)(id) = ^void (id object)
    {
        NSDictionary *result = object;
        if([result[@"state"] isEqualToString:@"ok"])
        {
            NSLog(@"login success");
            self.loginUserId = username;
            // 登陆成功后，获取用户的个人信息
            [self getInfo];
            
//            self.loginUser = [[UserModel alloc] initWithProperties:username NickName:username RemarkName:username Gender:@"man" Birthplace:@"guangzhou" ProfilePicture:@"peppa"];
            self.seq = [[NSUserDefaults standardUserDefaults] integerForKey:[NSString stringWithFormat:@"%@seq", username]];
            [[NSUserDefaults standardUserDefaults] setValue:username forKey:@"loginUsername"];
            
            UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            [UIApplication sharedApplication].keyWindow.rootViewController = mainStoryboard.instantiateInitialViewController;
        }
        else
        {
            NSLog(@"login fail");
        }
    };
    
    NSString *params = [[NSString alloc] initWithFormat:@"username=%@&password=%@", username, password];
    [SessionHelper sendRequest:@"/account/login" method:@"post" parameters:params handler:loginEvent];
    
}

-(void) tryLogin
{
    void (^tryLoginEvent)(id) = ^void (id object)
    {
        NSDictionary *result = object;
        if([result[@"state"] isEqualToString:@"ok"])
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
    };
    
    
    [SessionHelper sendRequest:@"/account/login" method:@"get" parameters:@"" handler:tryLoginEvent];
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
            self.loginUserId = nil;
            [self.socket SRWebSocketClose];
            [[DatabaseHelper getInstance] unregisterNewMessageListener];
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
    [SessionHelper sendRequest:@"/account/logout" method:@"delete" parameters:params handler:returnToLogin];
    
    
}


-(void) register:(NSString *)username withPassword:(NSString *)password
{
    void (^registerEvent)(id) = ^void (id object)
    {
        NSDictionary *result = object;
        if([result[@"state"] isEqualToString:@"ok"])
        {
            NSLog(@"register success");
            // 登陆成功后，获取用户的个人信息
            [self getInfo];
//            self.loginUser = [[UserModel alloc] initWithProperties:username NickName:username RemarkName:username Gender:@"man" Birthplace:@"guangzhou" ProfilePicture:@"peppa"];
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

// 上传图片到服务器
-(void) uploadImage:(NSString* )path withImage:(UIImage* )image
{
    AFHTTPSessionManager *session = [AFHTTPSessionManager manager];
    [session.requestSerializer setValue:@"multipart/form-data" forHTTPHeaderField:@"Content-Type"];
    
    // 处理url
//    NSString* serverDomain = @"http://172.18.32.97:8000";
    NSString* serverDomain = @"http://118.89.65.154:8000";
    NSString* urlString = [serverDomain stringByAppendingString:path];
    NSLog(urlString);
    [session POST:urlString parameters:nil constructingBodyWithBlock:
     ^(id<AFMultipartFormData> _Nonnull formData){
        // 图片转data
        NSData *data = UIImagePNGRepresentation(image);
        [formData appendPartWithFileData :data name:@"file" fileName:@"928-1.png"
                                 mimeType:@"multipart/form-data"];
    } progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id _Nonnull responseObject){
        NSLog(@"uploadImage success");
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error){
        NSLog(@"uploadImage fail");
        NSLog(error.localizedDescription);
    }];
}


@end
