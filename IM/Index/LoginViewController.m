//
//  ViewController.m
//  IM
//
//  Created by zhulinyin on 2019/4/22.
//  Copyright © 2019 zhulinyin. All rights reserved.
//

#import "LoginViewController.h"
#import "../Utils/UserManager.h"

@interface LoginViewController ()
@property (weak, nonatomic) IBOutlet UITextField *usernameText; // 用户名输入文本框
@property (weak, nonatomic) IBOutlet UITextField *passwordText; // 密码输入文本框
@property (weak, nonatomic) IBOutlet UIButton *loginBtn;    // 登录按钮
@property (weak, nonatomic) IBOutlet UIButton *registerBtn; // 注册按钮
@property (weak, nonatomic) IBOutlet UIImageView *userLoginAvatar;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}
/*
 登录功能
 */
- (IBAction)loginEvent:(id)sender {
    [[UserManager getInstance] login:self.usernameText.text withPassword:self.passwordText.text];
}
- (IBAction)usernameInputDone:(id)sender {
    
    if ([_usernameText.text  isEqual: @""]) {
        _userLoginAvatar.image = [UIImage imageNamed:@"peppa"];
        return;
    }
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    NSString *url = [URLHelper getURLwithPath:[[NSString alloc] initWithFormat:@"/account/info/user/%@", _usernameText.text]];
    
    [manager GET:url parameters:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if([responseObject[@"state"] isEqualToString:@"ok"])
        {
            NSLog(@"get Info success");
            [_userLoginAvatar sd_setImageWithURL:[NSURL URLWithString:[[NSString alloc] initWithFormat:@"http://118.89.65.154:8000%@", responseObject[@"data"][@"Avatar"]]]
                placeholderImage:[UIImage imageNamed:@"peppa"]
               completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                   NSLog(@"error== %@",error);
                   if (error) {
                       _userLoginAvatar.image = [UIImage imageNamed:@"peppa"];
                   }
               }];
        }
        else
        {
            NSLog(@"%@", responseObject[@"msg"]);
            _userLoginAvatar.image = [UIImage imageNamed:@"peppa"];
            NSLog(@"get Info fail1");
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"get Info fail2");
        NSLog(@"%@", error.localizedDescription);
        _userLoginAvatar.image = [UIImage imageNamed:@"peppa"];
    }];
}

@end
