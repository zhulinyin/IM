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
    NSMutableArray* messages = [self.databaseHelper queryAllMessagesWithUserId:self.loginUser.UserID];
    self.chatView.chatMsg = messages;
    [self.view addSubview:self.chatView];
    [self.chatView tableViewScrollToBottom];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getNewMessages:) name:@"newMessages" object:nil];
}

- (void)getNewMessages:(NSNotification *)notification{
    NSArray *messages = [notification object];
    for (int i=0; i<messages.count; i++) {
        if([messages[i][@"From"] isEqualToString:self.chatUser.UserID]) {
            MessageModel* message = [[MessageModel alloc] init];
            message.SenderID = messages[i][@"From"];
            message.ReceiverID = messages[i][@"Username"];
            message.Type = messages[i][@"Type"];
            message.Content = messages[i][@"content"][@"Cstr"];
            message.TimeStamp = messages[i][@"content"][@"Timestamp"];
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
    [self.databaseHelper insertMessage:message];
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
- (void)addMessage:(MessageModel* )message {
    [self.chatView addMessage:message];
}

@end
