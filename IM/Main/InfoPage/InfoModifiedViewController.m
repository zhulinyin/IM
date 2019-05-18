//
//  InfoModifiedViewController.m
//  IM
//
//  Created by student7 on 2019/5/18.
//  Copyright © 2019 zhulinyin. All rights reserved.
//

#import "InfoModifiedViewController.h"

@interface InfoModifiedViewController ()
@property (weak, nonatomic) UITextField *editText; // 修改的输入文本框
@property (weak, nonatomic) NSString *titleText; // 页面的标题item

@end

@implementation InfoModifiedViewController

- (instancetype) initWithString:(NSString*)str{
    self.titleText = str;
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 获取屏幕的宽高
    CGRect rect = [[UIScreen mainScreen] bounds];
    CGSize size = rect.size;
    CGFloat width = size.width;
    CGFloat height = size.height;
    // 设置背景颜色
    self.view.backgroundColor = [UIColor whiteColor];
    NSLog(self.titleText);
    self.editText.placeholder = @"这是一个提示";
    self.editText = [[UITextField alloc]initWithFrame:CGRectMake(10, 30, width-30, 30)];
    // 下划线
    UIView * onLine = [[UIView alloc]initWithFrame:CGRectMake(0,self.editText.frame.size.height-2,self.editText.frame.size.width,2)];
    onLine.backgroundColor = [UIColor blackColor];
    
    [self.editText addSubview:onLine];
    [self.view addSubview:self.editText];
}
/*
 登录功能
 */
- (IBAction)loginEvent:(id)sender {
    
}

@end
