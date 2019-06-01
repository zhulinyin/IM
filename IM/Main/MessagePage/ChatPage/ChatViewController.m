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
@property(strong, nonatomic) NSDateFormatter* dateFormatter;
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
        self.chatMsg = [self.databaseHelper queryAllMessagesWithChatId:chatUser.UserID];
        self.dateFormatter.dateFormat = @"yyyy-MM-dd hh:mm:ss";
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

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if(self.chatMsg.count > 0) {
        SessionModel *session = [[SessionModel alloc] initWithChatId:self.chatUser.UserID withChatName:self.chatUser.NickName withProfilePicture:self.chatUser.ProfilePicture withLatestMessageContent:[self.chatMsg[self.chatMsg.count-1] Content] withLatestMessageTimeStamp:[self.chatMsg[self.chatMsg.count-1] TimeStamp]];
        [self.databaseHelper insertSessionWithSession:session];
    }
    
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
    message.TimeStamp = [NSDate date];
    [self addMessage:message];
    
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    NSString *url = [URLHelper getURLwithPath:[[NSString alloc] initWithFormat:@"/content/%@", type]];
    NSDictionary* params = @{@"to":self.chatUser.UserID, @"data":text, @"timestamp":message.TimeStamp};
    
    [manager POST:url parameters:params progress:nil
         success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
             if([responseObject[@"state"] isEqualToString:@"ok"])
             {
                 NSLog(@"send success");
                 [self.databaseHelper insertMessageWithMessage:message];
             }
             else
             {
                 NSLog(@"send fail");
             }
         }
         failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
             NSLog(@"send fail");
             NSLog(@"%@", error.localizedDescription);
         }];
}

//新增消息
- (void)addMessage:(MessageModel* )message {
    [self.chatMsg addObject:message];
    self.chatView.chatMsg = self.chatMsg;
}

@end
