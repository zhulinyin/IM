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
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    NSString *url = [URLHelper getURLwithPath:[[NSString alloc] initWithFormat:@"/account/info/user/%@", _usernameText.text]];
    
    [manager GET:url parameters:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if([responseObject[@"state"] isEqualToString:@"ok"])
        {
            NSLog(@"get Info success");
        }
        else
        {
            NSLog(@"%@", responseObject[@"msg"]);
            NSLog(@"modifyInfo fail");
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"get Info fail");
        NSLog(@"%@", error.localizedDescription);
    }];
}

@end
