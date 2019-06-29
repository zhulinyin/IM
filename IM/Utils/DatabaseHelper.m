//
//  DatabaseHelper.m
//  IM
//
//  Created by student on 2019/5/18.
//  Copyright © 2019 zhulinyin. All rights reserved.
//

#import "DatabaseHelper.h"
#import "FMDB.h"

@interface DatabaseHelper()
@property(strong, nonatomic) FMDatabaseQueue* databaseQueue;
@property(strong, nonatomic) NSDateFormatter* dateFormatter;
@property(strong, nonatomic) UserManager *userManager;
@end
static DatabaseHelper *instance;
static dispatch_once_t onceToken;
NSString* const MESSAGE_TABLE_NAME = @"message";
@implementation DatabaseHelper

+(instancetype) getInstance {
    dispatch_once(&onceToken, ^{
        instance = [[DatabaseHelper alloc] init];
        instance.dateFormatter = [[NSDateFormatter alloc]init];
        instance.dateFormatter.dateFormat=@"yyyy-MM-dd hh:mm:ss";
        instance.userManager = [UserManager getInstance];
        [instance createQueue];
    });
    return instance;
}

+(void)attemptDealloc {
    onceToken = 0;
    instance = nil;
}
-(void) createQueue {
    NSString* queuePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"IM.db"];
    
    self.databaseQueue = [FMDatabaseQueue databaseQueueWithPath:queuePath];
    if(self.databaseQueue) {
        NSLog(@"Database create successfully");
        [self createMessageTable];
        [self createSessionListTable];
        [self createRequestTable];
    }
    else {
        NSLog(@"Database create failed");
    }
}

-(void) createMessageTable {
    [self.databaseQueue inDatabase:^(FMDatabase * _Nonnull db) {
        if([db open]) {
            NSString* sql = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS [%@message] (id INTEGER PRIMARY KEY AUTOINCREMENT, chatId text NOT NULL, isMe boolean NOT NULL, type text NOT NULL, content text NOT NULL, timestamp text NOT NULL);", self.userManager.loginUserId];
            BOOL res = [db executeUpdate:sql];
            NSLog(@"%@", res ? @"create message table successfully" : @"create message table failed");
        }
        [db close];
    }];
}

-(void) createSessionListTable {
    [self.databaseQueue inDatabase:^(FMDatabase * _Nonnull db) {
        if([db open]) {
            NSString* sql = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS [%@session] (chatId text PRIMARY KEY, chatName text NOT NULL, profilePicture text NOT NULL, content text NOT NULL, timestamp text NOT NULL, unread integer NOT NULL);", self.userManager.loginUserId];
            BOOL res = [db executeUpdate:sql];
            NSLog(@"%@", res ? @"create session table successfully" : @"create session table failed");
        }
        [db close];
    }];
}

-(void) createFriendListTable {
    [self.databaseQueue inDatabase:^(FMDatabase * _Nonnull db) {
        if([db open]) {
            NSString* sql = [NSString stringWithFormat:
                             @"CREATE TABLE IF NOT EXISTS [%@friendList] (          \
                             UserID TEXT PRIMARY KEY,       \
                             NickName TEXT NOT NULL,        \
                             RemarkName TEXT DEFAULT '',    \
                             Gender TEXT DEFAULT '',        \
                             Birthplace TEXT DEFAULT '',    \
                             ProfilePicture TEXT DEFAULT '',\
                             Description TEXT DEFAULT ''    \
                             );", self.userManager.loginUserId];
            BOOL res = [db executeUpdate:sql];
            NSLog(@"%@", res ? @"create firend table successfully" : @"create firend table failed");
        }
        [db close];
    }];
}

-(void) createRequestTable {
    [self.databaseQueue inDatabase:^(FMDatabase * _Nonnull db) {
        if([db open]) {
            NSString* sql = [NSString stringWithFormat:
                             @"CREATE TABLE IF NOT EXISTS [%@requestList] (          \
                             UserID TEXT PRIMARY KEY,                   \
                             NickName TEXT NOT NULL,        \
                             RemarkName TEXT DEFAULT '',    \
                             Gender TEXT DEFAULT '',        \
                             Birthplace TEXT DEFAULT '',    \
                             ProfilePicture TEXT DEFAULT '',\
                             Description TEXT DEFAULT '',   \
                             CID INTEGER,                   \
                             State TEXT                     \
                             );", self.userManager.loginUserId]; // State : {"accepted", "rejected", "pending"}
            BOOL res = [db executeUpdate:sql];
            NSLog(@"%@", res ? @"create request table successfully" : @"create request table failed");
        }
        [db close];
    }];
}

-(void)rebuildFriendListTable
{
    [self.databaseQueue inDatabase:^(FMDatabase * _Nonnull db) {
        if([db open]) {
            NSString* sql = [NSString stringWithFormat: @"DROP TABLE [%@friendList];", self.userManager.loginUserId];
            BOOL res = [db executeUpdate:sql];
            NSLog(@"%@", res ? @"drop firend table successfully" : @"drop friend table failed");
        }
        [db close];
    }];
    [self createFriendListTable];
}

-(BOOL)isFriendTableExist
{
    static BOOL result = NO;
    [self.databaseQueue inDatabase:^(FMDatabase * _Nonnull db) {
        if([db open]) {
            FMResultSet* set = [db executeQuery:[NSString stringWithFormat: @"SELECT COUNT(*) FROM sqlite_master WHERE type='table' AND name='%@friendList'", self.userManager.loginUserId]];

            while ([set next])
            {
                
                result = [set intForColumnIndex:0];
                NSLog(@"%d", result);
            }
        }
        [db close];
    }];
    return result;
}



-(NSMutableArray *) querySessions {
    NSMutableArray *sessions = [[NSMutableArray alloc] init];
    
    [self.databaseQueue inDatabase:^(FMDatabase * _Nonnull db) {
        if([db open]) {
            FMResultSet* set = [db executeQuery:[NSString stringWithFormat:@"SELECT * FROM [%@session] order by timestamp desc;", self.userManager.loginUserId]];
            while([set next]) {
                SessionModel* session = [[SessionModel alloc] init];
                session.chatId = [set stringForColumnIndex:0];
                session.chatName = [set stringForColumnIndex:1];
                session.profilePicture = [set stringForColumnIndex:2];
                session.latestMessageContent = [set stringForColumnIndex:3];
                session.latestMessageTimeStamp = [self.dateFormatter dateFromString:[set stringForColumnIndex:4]];
                session.unreadNum = [set intForColumnIndex:5];
                [sessions addObject:session];
            }
        }
        [db close];
    }];
    return sessions;
}

-(NSInteger)queryUnreadNumByChatId:(NSString *)chatId {
    static NSInteger num = 0;
    [self.databaseQueue inDatabase:^(FMDatabase * _Nonnull db) {
        if([db open]) {
            FMResultSet* set = [db executeQuery:[NSString stringWithFormat:@"SELECT unread FROM [%@session] WHERE chatId = '%@';", self.userManager.loginUserId, chatId]];
            if ([set next]) {
                num = [set intForColumnIndex:0];
            }
        }
        [db close];
    }];
    return num;
}

-(void) insertSessionWithSession:(SessionModel *)session {
    [self.databaseQueue inDatabase:^(FMDatabase * _Nonnull db) {
        if([db open]) {
            BOOL res1 = [db executeStatements:[NSString stringWithFormat:@"DELETE FROM [%@session] WHERE chatId = '%@';", self.userManager.loginUserId, session.chatId]];
            NSLog(@"%@", res1 ? @"delete session successfully" : @"delete session failed");
            NSString *sql = [NSString stringWithFormat:@"INSERT INTO [%@session] (chatId, chatName, profilePicture, content, timestamp, unread) VALUES ('%@', '%@', '%@', '%@', '%@', %ld);", self.userManager.loginUserId, session.chatId, session.chatName, session.profilePicture, session.latestMessageContent, [self.dateFormatter stringFromDate:session.latestMessageTimeStamp], session.unreadNum];
            BOOL res2 = [db executeStatements:sql];
            NSLog(@"%@", res2 ? @"insert session successfully" : @"insert session failed");
        }
        [db close];
    }];
}

-(void) insertMessageWithMessage:(MessageModel *) message{
    [self.databaseQueue inDatabase:^(FMDatabase * _Nonnull db)
    {
        if([db open])
        {
            int isMe = [message.SenderID isEqualToString:self.userManager.loginUserId] ? 1 : 0;
            NSString *chatId = [message.SenderID isEqualToString:self.userManager.loginUserId] ? message.ReceiverID : message.SenderID;
            BOOL res = [db executeStatements:[NSString stringWithFormat:@"INSERT INTO [%@message] (chatId, isMe, type, content, timestamp) VALUES ('%@', %d, '%@', '%@', '%@');", self.userManager.loginUserId, chatId, isMe, message.Type, message.Content, [self.dateFormatter stringFromDate:message.TimeStamp]]];
            NSLog(@"%@", res ? @"insert message successfully" : @"insert message failed");
            
            
        }
        [db close];
    }];
}

-(void) insertFriendWithFriend:(UserModel *) Friend
{
    [self.databaseQueue inDatabase:^(FMDatabase * _Nonnull db) {
        if([db open]) {
            BOOL res = [db executeStatements:[NSString stringWithFormat:@"INSERT INTO [%@friendList] (UserID, NickName, RemarkName, Gender, Birthplace, ProfilePicture, Description) VALUES ('%@', '%@', '%@', '%@', '%@', '%@', '%@');", self.userManager.loginUserId, Friend.UserID, Friend.NickName, Friend.RemarkName, Friend.Gender, Friend.Birthplace, Friend.ProfilePicture, @""]];
            
            NSLog(@"%@", res ? @"insert friend successfully" : @"insert friend failed");
            if (res)
                [[NSNotificationCenter defaultCenter] postNotificationName:@"friendComing" object:Friend];
        }
        [db close];
    }];
}

-(void) insertRequestWithUser:(UserModel *) User Cid:(NSInteger)Cid state:(NSString*)state
{
    
    [self.databaseQueue inDatabase:^(FMDatabase * _Nonnull db) {
        if([db open]) {
            BOOL resDel = [db executeStatements:[NSString stringWithFormat:
                                   @"DELETE \
                                   FROM [%@requestList]\
                                   WHERE UserID='%@'"
                                   , self.userManager.loginUserId, User.UserID]];
            
            NSLog(@"%@", resDel ? @"delete request successfully" : @"delete request failed");
            
            BOOL res = [db executeStatements:[NSString stringWithFormat:
                                              @"INSERT INTO [%@requestList] (UserID, NickName, RemarkName, Gender, Birthplace, ProfilePicture, Description, CID, State) \
                                              VALUES ('%@', '%@', '%@', '%@', '%@', '%@', '%@', '%ld', '%@');"
                                              , self.userManager.loginUserId, User.UserID, User.NickName, User.RemarkName, User.Gender, User.Birthplace, User.ProfilePicture, @"", (long)Cid, state]];
            
            NSLog(@"%@", res ? @"insert request successfully" : @"insert request failed");
        }
        [db close];
    }];
}

-(UserModel *) getFriendByID:(NSString *)friendID
{
    static UserModel* friend;
    [self.databaseQueue inDatabase:^(FMDatabase * _Nonnull db)
     {
         if([db open])
         {
             FMResultSet* set = [db executeQuery:[NSString stringWithFormat:
                                                  @"SELECT *\
                                                  FROM [%@friendList]\
                                                  WHERE UserID='%@'"
                                                  , self.userManager.loginUserId, friendID]];
             if ([set next])
             {
                 friend = [[UserModel alloc] initWithProperties:[set stringForColumnIndex:0]
                                                                  NickName:[set stringForColumnIndex:1]
                                                                RemarkName:[set stringForColumnIndex:2]
                                                                    Gender:[set stringForColumnIndex:3]
                                                                Birthplace:[set stringForColumnIndex:4]
                                                            ProfilePicture:[set stringForColumnIndex:5]];
                 
             }
         }
         [db close];
     }];
    return friend;
}

-(void) deleteFriendByID:(NSString *)friendID
{
    [self.databaseQueue inDatabase:^(FMDatabase * _Nonnull db) {
        if([db open]) {
            BOOL res = [db executeStatements:[NSString stringWithFormat:
                                              @"DELETE              \
                                              FROM [%@friendList]\
                                              WHERE UserID='%@'"
                                              , self.userManager.loginUserId, friendID]];
            
            NSLog(@"%@", res ? @"delete friend successfully" : @"delete friend failed");
        }
        [db close];
    }];
}

-(NSMutableArray *) getAllFriends
{
    NSMutableArray *friendList = [[NSMutableArray alloc] init];
    [self.databaseQueue inDatabase:^(FMDatabase * _Nonnull db)
    {
        if([db open])
        {
            FMResultSet* set = [db executeQuery:[NSString stringWithFormat:@"SELECT * FROM [%@friendList]", self.userManager.loginUserId]];
            while([set next])
            {
                UserModel* friend = [[UserModel alloc] initWithProperties:[set stringForColumnIndex:0]
                                                                 NickName:[set stringForColumnIndex:1]
                                                               RemarkName:[set stringForColumnIndex:2]
                                                                   Gender:[set stringForColumnIndex:3]
                                                               Birthplace:[set stringForColumnIndex:4]
                                                           ProfilePicture:[set stringForColumnIndex:5]];
            
                [friendList addObject:friend];
            }
        }
        [db close];
    }];
    return friendList;
}

-(NSMutableArray *) getAllRequest
{
    NSMutableArray *requestList = [[NSMutableArray alloc] init];
    [self.databaseQueue inDatabase:^(FMDatabase * _Nonnull db)
     {
         if([db open])
         {
             FMResultSet* set = [db executeQuery:[NSString stringWithFormat:@"SELECT * FROM [%@requestList]", self.userManager.loginUserId]];
             while([set next])
             {
                 UserModel* user = [[UserModel alloc] initWithProperties:[set stringForColumnIndex:0]
                                                                  NickName:[set stringForColumnIndex:1]
                                                                RemarkName:[set stringForColumnIndex:2]
                                                                    Gender:[set stringForColumnIndex:3]
                                                                Birthplace:[set stringForColumnIndex:4]
                                                            ProfilePicture:[set stringForColumnIndex:5]];
                 RequestModel* request = [[RequestModel alloc] initWithProperties:user State:[set stringForColumnIndex:8] Cid:[[set stringForColumnIndex:7] integerValue]];
                 [requestList addObject:request];
             }
         }
         [db close];
     }];
    return requestList;
}

-(NSMutableArray *) queryAllMessagesWithChatId:(NSString *) chatId{
    NSMutableArray *messages = [[NSMutableArray alloc] init];
    [self.databaseQueue inDatabase:^(FMDatabase * _Nonnull db) {
        if([db open]) {
            FMResultSet* set = [db executeQuery:[NSString stringWithFormat:@"SELECT * FROM [%@message] WHERE chatId = '%@';", self.userManager.loginUserId, chatId]];
            while([set next]) {
                MessageModel* message = [[MessageModel alloc] init];
                BOOL isMe = [set boolForColumnIndex:2];
                message.SenderID = isMe ? self.userManager.loginUserId : chatId;
                message.ReceiverID = isMe ? chatId : self.userManager.getLoginModel.UserID;
                message.Type = [set stringForColumnIndex:3];
                message.Content = [set stringForColumnIndex:4];
                message.TimeStamp = [self.dateFormatter dateFromString:[set stringForColumnIndex:5]];
                [messages addObject:message];
            }
        }
        [db close];
    }];
    return messages;
}

-(void) deleteMessages:(NSString *) chatId {
    [self.databaseQueue inDatabase:^(FMDatabase * _Nonnull db) {
        if([db open]) {
            BOOL res = [db executeStatements:[NSString stringWithFormat:@"DELETE FROM [%@session] WHERE chatId = '%@';", self.userManager.loginUserId, chatId]];
            NSLog(@"%@", res ? @"delete session successfully" : @"delete session failed");
            
            BOOL res2 = [db executeStatements:[NSString stringWithFormat:@"DELETE FROM [%@message] WHERE chatId = '%@';", self.userManager.loginUserId, chatId]];
            NSLog(@"%@", res2 ? @"delete messages successfully" : @"delete messages failed");
        }
        [db close];
    }];
}

-(void) updateRequestStateWithID:(NSString *) userID state:(NSString *)state
{
    [self.databaseQueue inDatabase:^(FMDatabase * _Nonnull db) {
        if([db open]) {
            BOOL res = [db executeStatements:[NSString stringWithFormat:
                                              @"UPDATE [%@requestList]   \
                                              SET STATE = '%@'          \
                                              WHERE UserID = '%@'       "
                                            , self.userManager.loginUserId, state, userID]];
            NSLog(@"%@", res ? @"update request state successfully" : @"update request state failed");
        }
        [db close];
    }];
}
/*
-(void) insertMessagesWithTableName:(NSString *)tableName withMessages:(NSArray* ) messages {
    [self.databaseQueue inDatabase:^(FMDatabase * _Nonnull db) {
        if([db open]) {
            for (int i = 0; i < messages.count; i++) {
                MessageModel* message = messages[i];
                BOOL res = [db executeStatements:[NSString stringWithFormat:@"INSERT INTO [%@] (sendId, type, content, timestamp) VALUES ('%@', '%@', '%@', '%@');", tableName, message.SenderID, message.Type, message.Content, [self.dateFormatter stringFromDate:message.TimeStamp]]];
                NSLog(@"%@", res ? @"insert message successfully" : @"insert message failed");
            }
            
        }
        [db close];
    }];
}*/

-(void) registerNewMessagesListener {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getNewMessages:) name:@"newMessages" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getNewFriendRequest:) name:@"newFriends" object:nil];
}

-(void) unregisterNewMessageListener {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)getNewMessages:(NSNotification *)notification{
    NSArray *messages = [notification object];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    
    for(int i = 0; i < messages.count; i++) {
        MessageModel *message = messages[i];
        NSString *sendId = [message SenderID];
        if ([[dict allKeys] containsObject:sendId]) {
            NSInteger num = [[dict objectForKey:sendId] integerValue];
            [dict setValue:@(num+1) forKey:sendId];
        }
        else {
            NSInteger num = [self queryUnreadNumByChatId:sendId];
            [dict setValue:@(num+1) forKey:sendId];
        }
        UserModel* friend = [self getFriendByID:sendId];
        
        NSString *imagePath = friend.ProfilePicture;
        NSString *chatName = friend.NickName;
        NSString *content = [message.Type isEqualToString:@"text"] ? message.Content : @"[图片]";
        SessionModel *session = [[SessionModel alloc] initWithChatId:sendId withChatName:chatName withProfilePicture:imagePath withLatestMessageContent:content withLatestMessageTimeStamp:message.TimeStamp withUnreadNum:[dict[sendId] integerValue]];
        [self insertSessionWithSession:session];
        [self insertMessageWithMessage:message];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"sessionChange" object:nil];
    }
}

- (void)getFriendsFromServer
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    NSString *url = [URLHelper getURLwithPath:@"/contact/info"];
    
    [manager GET:url parameters:nil progress:nil
         success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
             NSLog(@"%@", responseObject);
             if([responseObject[@"state"] isEqualToString:@"ok"])
             {
                 for (id user in responseObject[@"data"])
                 {
                     NSString *friendUrl = [URLHelper getURLwithPath:[[NSString alloc] initWithFormat:@"/account/info/user/%@", user[@"Friend"]]];
                     [manager GET:friendUrl parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable friendsInfo) {
                         if ([friendsInfo[@"state"] isEqualToString:@"ok"])
                         {
                             UserModel* friend = [[UserModel alloc] initWithProperties:friendsInfo[@"data"][@"Username"]
                                                                              NickName:friendsInfo[@"data"][@"Nickname"]
                                                                            RemarkName:friendsInfo[@"data"][@"Nickname"]
                                                                                Gender:friendsInfo[@"data"][@"Gender"]
                                                                            Birthplace:friendsInfo[@"data"][@"Region"]
                                                                        ProfilePicture:friendsInfo[@"data"][@"Avatar"]];
                             [[DatabaseHelper getInstance] insertFriendWithFriend:friend];
                         }
                         else
                         {
                             NSLog(@"%@", friendsInfo[@"msg"]);
                         }
                         
                     } failure:
                      ^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                          NSLog(@"get friend info fail");
                      }];
                 }
             }
             else
             {
                 NSLog(@"%@", responseObject[@"msg"]);
             }
         }
         failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
             NSLog(@"%@", error.localizedDescription);
         }];
}


- (void)getNewFriendRequest:(NSNotification *)notification
{
    NSArray *messages = [notification object];
    NSLog(@"%@", messages);
    for (int i=0; i<messages.count; i++)
    {
        MessageModel *message = messages[i];
        NSLog(@"%@", message);
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        NSString *url = [URLHelper getURLwithPath:[[NSString alloc] initWithFormat:@"/account/info/user/%@", message.SenderID]];
        
        [manager GET:url parameters:nil progress:nil
             success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                 NSLog(@"%@", responseObject);
                 if ([responseObject[@"state"] isEqualToString:@"ok"])
                 {
                     
                     UserModel* user = [[UserModel alloc] initWithProperties:responseObject[@"data"][@"Username"]
                                                                      NickName:responseObject[@"data"][@"Nickname"]
                                                                    RemarkName:responseObject[@"data"][@"Username"]
                                                                        Gender:responseObject[@"data"][@"Gender"]
                                                                    Birthplace:responseObject[@"data"][@"Region"]
                                                                ProfilePicture:responseObject[@"data"][@"Avatar"]];
                     [self insertRequestWithUser:user Cid:[message.Content integerValue]  state:@"pending"];
                     [[NSNotificationCenter defaultCenter] postNotificationName:@"requestChange" object:nil];
                 }
                 else
                 {
                     NSLog(@"%@", responseObject[@"msg"]);
                 }
             }
             failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                 
                 NSLog(@"%@", error.localizedDescription);
             }];
        
        
        //[self.FriendRequestTableView reloadData];
        
    }
}

@end
