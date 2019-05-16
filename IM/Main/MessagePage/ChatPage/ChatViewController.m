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
@property (nonatomic, strong) UserModel *loginUser;
@property (nonatomic, strong) UserModel *chatUser;
@end

@implementation ChatViewController

- (instancetype)initWithContact:(UserModel *)chatUser
{
    self = [super init];
    if (self)
    {
        self.loginUser = [[UserManager getInstance] getLoginModel];
        self.chatUser = chatUser;
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor lightGrayColor];
    
    self.chatView = [[ChatView alloc] init];
    self.chatView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    self.chatView.delegate = self;
    [self.view addSubview:self.chatView];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getNewMessages:) name:@"newMessages" object:nil];
}

- (void)getNewMessages:(NSNotification *)notification{
    NSArray *messages = [notification object];
    for (int i=0; i<messages.count; i++) {
        if([messages[i][@"From"] isEqualToString:self.chatUser.UserID]) {
            [self addMessage:messages[i][@"Type"] from:messages[i][@"From"] text:messages[i][@"content"]];
        }
    }
    //NSLog(@"%@", messages);
}

//delegate
- (void)sendMessage:(NSString *)type text:(NSString *)text {
    [self addMessage:type from:self.loginUser.UserID text:text];
    
    void (^sendFeedBack)(id) = ^void (id object)
    {
        NSDictionary *result = object;
        if([result[@"state"] isEqualToString:@"ok"])
        {
            NSLog(@"send success");
        }
        else
        {
            NSLog(@"send fail");
        }
    };
    
    
    NSString *path = [[NSString alloc] initWithFormat:@"/content/%@", type];
    NSString *params = [[NSString alloc] initWithFormat:@"to=%@&data=%@", self.chatUser.UserID, text];
    [SessionHelper sendRequest:path method:@"post" parameters:params handler:sendFeedBack];
}

//新增消息
- (void)addMessage:(NSString *)type from:(NSString *)from text:(NSString *)text {
    
    MessageModel *msgModel = [[MessageModel alloc] init];
    msgModel.Type = type;
    msgModel.SenderID = from;
    msgModel.Content = text;
    [self.chatView addMessage:msgModel];
}

@end
