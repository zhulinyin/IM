//
//  InfoViewController.m
//  IM
//
//  Created by zhulinyin on 2019/4/27.
//  Copyright © 2019 zhulinyin. All rights reserved.
//

#import "InfoViewController.h"

@interface InfoViewController ()

@end

@implementation InfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if (self.User == nil)
    {
        self.User = [[UserModel alloc] initWithProperties:@"peppa ID" NickName:@"Peppa" RemarkName:@"peppy" Gender:@"female" Birthplace:@"UK" ProfilePicture:@"peppa.jpg"];
    }
    self.ProfilePicture.image = [UIImage imageNamed:self.User.ProfilePicture];
    self.NickName.text = self.User.NickName;
    self.ID.text = self.User.UserID;
    self.Gender.text = self.User.Gender;
    self.Birthplace.text = self.User.Birthplace;
    /*[self.NickName sizeToFit];
    [self.ID sizeToFit];
    [self.Gender sizeToFit];
    [self.Birthplace sizeToFit];*/
    
}
- (IBAction)logout:(id)sender {
    NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:defaultConfigObject delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    NSURL *url = [NSURL URLWithString:@"http://118.89.65.154:8000/account/logout/"];
    NSURLSessionDataTask *task = [session dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if(error == nil) {
            if(NSClassFromString(@"NSJSONSerialization")) {
                NSError *e = nil;
                id object = [NSJSONSerialization JSONObjectWithData:data options:0 error:&e];
                if(e) {
                    NSLog(@"error");
                }
                if([object isKindOfClass:[NSDictionary class]]) {
                    NSDictionary *result = object;
                    if([result[@"state"] isEqualToString:@"ok"]) {
                        NSLog(@"logout success");
                        UIStoryboard *indexStoryboard = [UIStoryboard storyboardWithName:@"Index" bundle:nil];
                        [UIApplication sharedApplication].keyWindow.rootViewController = indexStoryboard.instantiateInitialViewController;
                    }
                    else {
                        NSLog(@"logout fail");
                    }
                }
                else {
                    NSLog(@"Not dictionary");
                }
            }
        }
        else {
            NSLog(@"网络异常");
        }
    }];
    [task resume];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
