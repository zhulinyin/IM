//
//  InfoModifiedViewController.m
//  IM
//
//  Created by student7 on 2019/5/18.
//  Copyright © 2019 zhulinyin. All rights reserved.
//

#import "InfoModifiedViewController.h"
#import "InfoViewController.h"

@interface InfoModifiedViewController ()
@property (weak, nonatomic) UITextField *editText; // 修改的输入文本框
@property (weak, nonatomic) NSString *titleText; // 页面的标题item

@property (nonatomic, strong) NSArray *markArray;// 标签数组(按钮文字)
@property (nonatomic, strong) NSMutableArray *btnArray;// 按钮数组
@property (nonatomic, strong) UIButton *selectedBtn;// 选中按钮

@end

@implementation InfoModifiedViewController

- (instancetype) initWithString:(NSString*)str{
    self.titleText = str;
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 修改性别需要单独处理，使用button来选择而不是输入
    if ([self.titleText isEqualToString:@"性别"]) {
        [self markArray];
        [self btnArray];
        [self setupRadioBtnView];
        // 添加导航栏右侧按钮
        [self addRightBtn];
    }
    // 修改别的文字信息
    else{
        // 提示信息
        NSMutableString* commonHint = @"请输入你要修改的";
        
        // 获取屏幕的宽高
        CGRect rect = [[UIScreen mainScreen] bounds];
        CGSize size = rect.size;
        CGFloat width = size.width;
        CGFloat height = size.height;
        // 设置背景颜色
        self.view.backgroundColor = [UIColor whiteColor];
        
        self.editText = [[UITextField alloc]initWithFrame:CGRectMake(10, 30, width-30, 30)];
        
        self.editText.placeholder = [commonHint stringByAppendingString:self.titleText];
        [self.editText setValue:[UIColor grayColor] forKeyPath:@"_placeholderLabel.textColor"];
        [self.editText setValue:[UIFont boldSystemFontOfSize:12] forKeyPath:@"_placeholderLabel.font"];
        
        // 下划线
        UIView * onLine = [[UIView alloc]initWithFrame:CGRectMake(0,self.editText.frame.size.height-2,self.editText.frame.size.width,2)];
        onLine.backgroundColor = [UIColor blackColor];
        
        // 添加导航栏右侧按钮
        [self addRightBtn];
        [self.editText addSubview:onLine];
        [self.view addSubview:self.editText];
    }
}

- (void)addRightBtn {
    UIBarButtonItem *rightBarItem = [[UIBarButtonItem alloc] initWithTitle:@"确认" style:UIBarButtonItemStylePlain target:self action:@selector(onClickedOKbtn)];
    self.navigationItem.rightBarButtonItem = rightBarItem;
}

- (void)onClickedOKbtn {
    NSLog(@"onClickedOKbtn");
    if ([self.titleText isEqualToString:@"性别"]) {
        //[self goBackToPersonInfoVCWithNickName:self.selectedBtn.titleLabel.text];
        self.change_user = [[UserManager getInstance] getLoginModel];
        self.change_user.Gender = self.selectedBtn.titleLabel.text;
        _data(self.change_user);
        [self.navigationController popViewControllerAnimated:YES];
    }
    else {
        // Block传值
        self.change_user = [[UserManager getInstance] getLoginModel];
        if ([self.titleText isEqualToString:@"昵称"]){
            self.change_user.NickName = self.editText.text;
        }
        else if ([self.titleText isEqualToString:@"账号"]){
            self.change_user.UserID = self.editText.text;
        }
        else if ([self.titleText isEqualToString:@"地区"]){
            self.change_user.Birthplace = self.editText.text;
        }
        _data(self.change_user);
        [self.navigationController popViewControllerAnimated:YES];
        
    }
}


- (NSArray *)markArray {
    if (!_markArray) {
        NSArray *array = [NSArray array];
        array = @[@"male", @"female",@"unknown"];
        _markArray = array;
    }
    return _markArray;
}

- (NSMutableArray *)btnArray {
    if (!_btnArray) {
        NSMutableArray *array = [NSMutableArray array];
        _btnArray = array;
        
    }
    return _btnArray;
}

- (void)setupRadioBtnView {
    CGFloat UI_View_Width = [UIScreen mainScreen].bounds.size.width;
    CGFloat marginX = 15;
    CGFloat top = 100;
    CGFloat btnH = 30;
    CGFloat width = (250 - marginX * 4) / 3;
    // 按钮背景
//    UIView *btnsBgView = [[UIView alloc] initWithFrame:CGRectMake((UI_View_Width - 250) * 0.5, 50, 250, 300)];
    self.view.backgroundColor = [UIColor whiteColor];
//    [self.view addSubview:btnsBgView];
    // 循环创建按钮
    NSInteger maxCol = 2;
    for (NSInteger i = 0; i < 2; i++) {
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.backgroundColor = [UIColor grayColor];
        btn.layer.cornerRadius = 3.0; // 按钮的边框弧度
        btn.clipsToBounds = YES;
        btn.titleLabel.font = [UIFont boldSystemFontOfSize:12];
        btn.titleLabel.textColor = [UIColor blackColor];
        [btn addTarget:self action:@selector(chooseMark:) forControlEvents:UIControlEventTouchUpInside];
        NSInteger col = i % maxCol; //列
        CGFloat x = marginX + col * (width + marginX);
        NSInteger row = i / maxCol; //行
        CGFloat y = top + row * (btnH + marginX);
        btn.frame=CGRectMake(x+UI_View_Width/2-width-marginX, y, width, btnH);
        [btn setTitle:self.markArray[i] forState:UIControlStateNormal];
        [self.view addSubview:btn];
        btn.tag = i;
        [self.btnArray addObject:btn];
    }
    
    // 创建完btn后再判断是否能选择(之前是已经选取过的)
    for (UIButton *btn in self.view.subviews) {
        if ([@"男" isEqualToString:btn.titleLabel.text]) {
            btn.selected = YES;
            btn.backgroundColor = [UIColor blueColor];
            break;
        }
    }
}

- (void)chooseMark:(UIButton *)sender {
    NSLog(@"点击了%@", sender.titleLabel.text);
    
    self.selectedBtn = sender;
    
    sender.selected = !sender.selected;
    
    for (NSInteger j = 0; j < [self.btnArray count]; j++) {
        UIButton *btn = self.btnArray[j] ;
        if (sender.tag == j) {
            btn.selected = sender.selected;
        } else {
            btn.selected = NO;
        }
        btn.backgroundColor = [UIColor grayColor];
    }
    
    UIButton *btn = self.btnArray[sender.tag];
    if (btn.selected) {
        btn.backgroundColor = [UIColor blueColor];
    } else {
        btn.backgroundColor = [UIColor grayColor];
    }
}




@end
