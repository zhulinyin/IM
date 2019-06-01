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
@property(strong, nonatomic) FMDatabase* database;
@property(strong, nonatomic) NSDateFormatter* dateFormatter;
@property(strong, nonatomic) UserManager *userManager;
@end

NSString* const MESSAGE_TABLE_NAME = @"message";
@implementation DatabaseHelper

+(instancetype) getInstance {
    static DatabaseHelper* instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[DatabaseHelper alloc] init];
        instance.dateFormatter = [[NSDateFormatter alloc]init];
        instance.dateFormatter.dateFormat=@"yyyy-MM-dd hh:mm:ss";
        instance.userManager = [UserManager getInstance];
        [instance createQueue];
    });
    return instance;
}

-(void) createQueue {
    NSString* queuePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"IM.db"];
    
    self.databaseQueue = [FMDatabaseQueue databaseQueueWithPath:queuePath];
    if(self.databaseQueue) {
        NSLog(@"Database create successfully");
        [self createMessageTable];
        [self createSessionListTable];
        [self createFriendListTable];
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
            NSString* sql = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS [%@session] (chatId text PRIMARY KEY, chatName text NOT NULL, profilePicture text NOT NULL, content text NOT NULL, timestamp text NOT NULL);", self.userManager.loginUserId];
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
                             @"CREATE TABLE IF NOT EXISTS %@ (          \
                             UserID INTEGER PRIMARY KEY AUTOINCREMENT,  \
                             NickName TEXT NOT NULL,        \
                             RemarkName TEXT DEFAULT '',    \
                             Gender TEXT DEFAULT '',        \
                             Birthplace TEXT DEFAULT '',    \
                             ProfilePicture TEXT DEFAULT '',\
                             Description TEXT DEFAULT ''    \
                             );", self.userManager.loginUserId];
            BOOL res = [db executeUpdate:sql];
            NSLog(@"%@", res ? @"create session table successfully" : @"create session table failed");
        }
        [db close];
    }];
}

-(NSMutableArray *) querySessions {
    NSMutableArray *sessions = [[NSMutableArray alloc] init];
    
    [self.databaseQueue inDatabase:^(FMDatabase * _Nonnull db) {
        if([db open]) {
            FMResultSet* set = [db executeQuery:[NSString stringWithFormat:@"SELECT * FROM [%@session] order by timestamp;", self.userManager.loginUserId]];
            while([set next]) {
                SessionModel* session = [[SessionModel alloc] init];
                session.chatId = [set stringForColumnIndex:0];
                session.chatName = [set stringForColumnIndex:1];
                session.profilePicture = [set stringForColumnIndex:2];
                session.latestMessageContent = [set stringForColumnIndex:3];
                session.latestMessageTimeStamp = [self.dateFormatter dateFromString:[set stringForColumnIndex:4]];
                [sessions addObject:session];
            }
        }
        [db close];
    }];
    return sessions;
}

-(void) insertSessionWithSession:(SessionModel *)session {
    [self.databaseQueue inDatabase:^(FMDatabase * _Nonnull db) {
        if([db open]) {
            BOOL res1 = [db executeStatements:[NSString stringWithFormat:@"DELETE FROM [%@session] WHERE chatId = '%@';", self.userManager.loginUserId, session.chatId]];
            NSLog(@"%@", res1 ? @"delete session successfully" : @"delete session failed");
            BOOL res2 = [db executeStatements:[NSString stringWithFormat:@"INSERT INTO [%@session] (chatId, chatName, profilePicture, content, timestamp) VALUES ('%@', '%@', '%@', '%@', '%@');", self.userManager.loginUserId, session.chatId, session.chatName, session.profilePicture, session.latestMessageContent, [self.dateFormatter stringFromDate:session.latestMessageTimeStamp]]];
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
            BOOL res = [db executeStatements:[NSString stringWithFormat:@"INSERT INTO %@ (UserID, NickName, RemarkName, Gender, Birthplace, ProfilePicture, Description) VALUES ('%@', '%@', '%@', '%@', '%@', '%@', '%@');", self.userManager.loginUserId, Friend.UserID, Friend.NickName, Friend.RemarkName, Friend.Gender, Friend.Birthplace, Friend.ProfilePicture, @""]];
            
            NSLog(@"%@", res ? @"insert message successfully" : @"insert message failed");
        }
        [db close];
    }];
}

-(void) selectFriendByID:(NSString*) UserID
{
    
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
}

-(void) unregisterNewMessageListener {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)getNewMessages:(NSNotification *)notification{
    NSArray *messages = [notification object];
    for(int i = 0; i < messages.count; i++) {
        MessageModel *message = messages[i];
        NSString *sendId = [message SenderID];
        SessionModel *session = [[SessionModel alloc] initWithChatId:sendId withChatName:sendId withProfilePicture:@"peppa" withLatestMessageContent:message.Content withLatestMessageTimeStamp:message.TimeStamp];
        [self insertSessionWithSession:session];
        [self insertMessageWithMessage:message];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"sessionChange" object:nil];
}
@end
