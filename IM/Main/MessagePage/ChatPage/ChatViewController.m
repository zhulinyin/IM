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
@property (nonatomic, strong) DatabaseHelper *databaseHelper;
@property (nonatomic, strong) NSMutableArray *chatMsg;
@end

@implementation ChatViewController

- (instancetype)initWithContact:(UserModel *)chatUser
{
    self = [super init];
    if (self)
    {
        self.loginUser = [[UserManager getInstance] getLoginModel];
        self.chatUser = chatUser;
        self.databaseHelper = [DatabaseHelper getInstance];
        self.chatMsg = [self.databaseHelper queryAllMessagesWithUserId:self.loginUser.UserID withChatId:self.chatUser.UserID];
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

    self.chatView.chatMsg = self.chatMsg;
    [self.view addSubview:self.chatView];
    
    [self.chatView tableViewScrollToBottom];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getNewMessages:) name:@"newMessages" object:nil];
}

- (void)getNewMessages:(NSNotification *)notification{
    NSArray *messages = [notification object];
    for (int i=0; i<messages.count; i++) {
        MessageModel *message = messages[i];
        if([message.SenderID isEqualToString:self.chatUser.UserID]) {
            [self addMessage:message];
        }
    }
    //NSLog(@"%@", messages);
}

//delegate
- (void)sendMessage:(NSString *)type text:(NSString *)text {
    MessageModel* message = [[MessageModel alloc] init];
    message.Type = type;
    message.SenderID = self.loginUser.UserID;
    message.ReceiverID = self.chatUser.UserID;
    message.Content = text;
    [self addMessage:message];
    void (^sendFeedBack)(id) = ^void (id object)
    {
        NSDictionary *result = object;
        if([result[@"state"] isEqualToString:@"ok"])
        {
            NSLog(@"send success");
            NSString *sendId = self.loginUser.UserID;
            NSString *chatId = self.chatUser.UserID;
            NSString *tableName = [sendId intValue] < [chatId intValue] ? [[sendId stringByAppendingString:@"-"] stringByAppendingString:chatId] : [[chatId stringByAppendingString:@"-"] stringByAppendingString:sendId];
            [self.databaseHelper insertMessageWithTableName:tableName withMessage:message];
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
- (void)addMessage:(MessageModel* )message {
    [self.chatMsg addObject:message];
    self.chatView.chatMsg = self.chatMsg;
}

@end
