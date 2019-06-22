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
@property (weak, nonatomic) IBOutlet UIButton *regBtn;
@property (weak, nonatomic) IBOutlet UIImageView *userLoginAvatar;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    NSString *username = [[NSUserDefaults standardUserDefaults] stringForKey:@"loginUsername"];
    NSString *avatar = [[NSUserDefaults standardUserDefaults] stringForKey:@"loginUserAvatar"];
    NSString *imagePath = [URLHelper getURLwithPath:avatar];
    self.usernameText.text = username;
    [self.userLoginAvatar sd_setImageWithURL:[NSURL URLWithString:imagePath]
                            placeholderImage:[UIImage imageNamed:@"default"]
                                   completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                       NSLog(@"error== %@",error);
                                   }];
    _regBtn.layer.borderColor = [[UIColor colorWithRed:0 green:111/255.0f blue:236/255.0f alpha:1.0f] CGColor];
    //[self.navigationController.navigationBar setTintColor:color(0xFF9C9C9C)[UIColor ]];
    self.navigationController.navigationBar.backgroundColor = [UIColor whiteColor];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];//以及隐隐都得设置为[UIImage new]
    self.navigationController.navigationBar.shadowImage = [UIImage new];
}
/*
 登录功能
 */
- (IBAction)loginEvent:(id)sender {
    [[UserManager getInstance] login:self.usernameText.text withPassword:self.passwordText.text];
}
- (IBAction)regEvent:(id)sender {
    [[UserManager getInstance] register:self.usernameText.text withPassword:self.passwordText.text];
}
- (IBAction)usernameInputDone:(id)sender {
    
    if ([_usernameText.text isEqualToString:@""]) {
        _userLoginAvatar.image = [UIImage imageNamed:@"default"];
        return;
    }
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    NSString *url = [URLHelper getURLwithPath:[[NSString alloc] initWithFormat:@"/account/info/user/%@", _usernameText.text]];
    
    [manager GET:url parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if([responseObject[@"state"] isEqualToString:@"ok"])
        {
            NSLog(@"get Info success");
            NSString *imagePath = [URLHelper getURLwithPath:responseObject[@"data"][@"Avatar"]];
            [self.userLoginAvatar sd_setImageWithURL:[NSURL URLWithString:imagePath]
                                    placeholderImage:[UIImage imageNamed:@"default"]
                                           completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                               NSLog(@"error== %@",error);
                                           }];
        }
        else
        {
            NSLog(@"%@", responseObject[@"msg"]);
            self.userLoginAvatar.image = [UIImage imageNamed:@"default"];
            NSLog(@"get Info fail1");
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"get Info fail2");
        NSLog(@"%@", error.localizedDescription);
        self.userLoginAvatar.image = [UIImage imageNamed:@"default"];
    }];
    
}

@end
