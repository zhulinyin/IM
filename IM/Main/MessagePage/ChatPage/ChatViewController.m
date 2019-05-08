//
//  ChatViewController.m
//  IM
//
//  Created by zhulinyin on 2019/5/8.
//  Copyright © 2019 zhulinyin. All rights reserved.
//

#import "ChatViewController.h"
#import "ChatView.h"
@interface ChatViewController () <ChatViewDelegate>
@property (nonatomic, strong) ChatView *chatView;
@property (nonatomic, strong) NSMutableArray *chatMsg;
@end

@implementation ChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor lightGrayColor];
    self.chatMsg = [NSMutableArray array];
    
    self.chatView = [[ChatView alloc] init];
    self.chatView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    //self.chatView.backgroundColor = [UIColor redColor];
    self.chatView.delegate = self;
    [self.view addSubview:self.chatView];
    
    [self addMessage:@"text" form:@"0" text:@"今天你吃饭了吗"];
    [self addMessage:@"text" form:@"1" text:@"吃了啊"];
    [self addMessage:@"text" form:@"0" text:@"哈哈哈哈\n哈哈哈哈哈\n哈哈哈哈哈哈"];
    [self addMessage:@"text" form:@"1" text:@"你笑啥"];
}

//delegate
- (void)sendMessage:(NSString *)type text:(NSString *)text {
    [self addMessage:type form:@"1" text:text];
}

//新增消息
- (void)addMessage:(NSString *)type form:(NSString *)form text:(NSString *)text {
    
    MessageModel *msgModel = [[MessageModel alloc] init];
    msgModel.Type = type;
    msgModel.SenderID = form;
    msgModel.Content = text;
    [self.chatMsg addObject:msgModel];
    
    self.chatView.chatMsg = self.chatMsg;
}

@end
