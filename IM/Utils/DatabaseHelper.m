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
        [instance createQueue];
    });
    return instance;
}

-(void) createQueue {
    NSString* queuePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"IM.db"];
    
    self.databaseQueue = [FMDatabaseQueue databaseQueueWithPath:queuePath];
    if(self.databaseQueue) {
        NSLog(@"Database create successfully");
        
    }
    else {
        NSLog(@"Database create failed");
    }
}

-(void) createMessageTable:(NSString *) tableName {
    [self.databaseQueue inDatabase:^(FMDatabase * _Nonnull db) {
        if([db open]) {
            NSString* sql = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS [%@] (id INTEGER PRIMARY KEY AUTOINCREMENT, sendId text NOT NULL, type text NOT NULL, content text NOT NULL, timestamp text NOT NULL);", tableName];
            BOOL res = [db executeUpdate:sql];
            NSLog(@"%@", res ? @"create table successfully" : @"create table failed");
        }
        [db close];
    }];
}

-(void) createSessionListTable:(NSString *) tableName {
    [self.databaseQueue inDatabase:^(FMDatabase * _Nonnull db) {
        if([db open]) {
            NSString* sql = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS [%@] (chatId text PRIMARY KEY, chatName text NOT NULL, profilePicture text NOT NULL, content text NOT NULL, timestamp text NOT NULL);", tableName];
            BOOL res = [db executeUpdate:sql];
            NSLog(@"%@", res ? @"create table successfully" : @"create table failed");
        }
        [db close];
    }];
}

-(NSMutableArray *) queryMessageListWithTableName:(NSString *) tableName {
    NSMutableArray *sessions = [[NSMutableArray alloc] init];
    
    [self.databaseQueue inDatabase:^(FMDatabase * _Nonnull db) {
        if([db open]) {
            FMResultSet* set = [db executeQuery:[NSString stringWithFormat:@"SELECT * FROM [%@] order by timestamp;", tableName]];
            while([set next]) {
                SessionModel* session = [[SessionModel alloc] init];
                session.chatId = [set stringForColumnIndex:0];
                session.chatName = [set stringForColumnIndex:1];
                session.profilePicture = [set stringForColumnIndex:2];
                session.latestMessageContent = [set stringForColumnIndex:3];
                session.latestMessageTimeStamp = [set stringForColumnIndex:4];
                [sessions addObject:session];
            }
        }
        [db close];
    }];
    return sessions;
}

-(void) insertSessionWithTableName:(NSString *)tableName withSession:(SessionModel *)session {
    [self.databaseQueue inDatabase:^(FMDatabase * _Nonnull db) {
        if([db open]) {
            BOOL res1 = [db executeStatements:[NSString stringWithFormat:@"DELETE FROM [%@] WHERE chatId = '%@';", tableName, session.chatId]];
            NSLog(@"%@", res1 ? @"delete session successfully" : @"delete session failed");
            BOOL res2 = [db executeStatements:[NSString stringWithFormat:@"INSERT INTO [%@] (chatId, chatName, profilePicture, content, timestamp) VALUES ('%@', '%@', '%@', '%@', '%@');", tableName, session.chatId, session.chatName, session.profilePicture, session.latestMessageContent, session.latestMessageTimeStamp]];
            NSLog(@"%@", res2 ? @"insert session successfully" : @"insert session failed");
        }
        [db close];
    }];
}

-(void) insertMessageWithTableName:(NSString *) tableName withMessage:(MessageModel *) message {
    [self.databaseQueue inDatabase:^(FMDatabase * _Nonnull db) {
        if([db open]) {
            BOOL res = [db executeStatements:[NSString stringWithFormat:@"INSERT INTO [%@] (sendId, type, content, timestamp) VALUES ('%@', '%@', '%@', '%@');", tableName, message.SenderID, message.Type, message.Content, [self.dateFormatter stringFromDate:message.TimeStamp]]];
            NSLog(@"%@", res ? @"insert message successfully" : @"insert message failed");
        }
        [db close];
    }];
}

-(NSMutableArray *) queryAllMessagesWithUserId:(NSString* ) userId withChatId:(NSString *) chatId{
    NSMutableArray *messages = [[NSMutableArray alloc] init];
    NSString *tableName = [userId intValue] < [chatId intValue] ? [[userId stringByAppendingString:@"-"] stringByAppendingString:chatId] : [[chatId stringByAppendingString:@"-"] stringByAppendingString:userId];
    [self.databaseQueue inDatabase:^(FMDatabase * _Nonnull db) {
        if([db open]) {
            FMResultSet* set = [db executeQuery:[NSString stringWithFormat:@"SELECT * FROM [%@];", tableName]];
            while([set next]) {
                MessageModel* message = [[MessageModel alloc] init];
                message.SenderID = [set stringForColumnIndex:1];
                message.ReceiverID = [message.SenderID isEqualToString:userId] ? chatId : userId;
                message.Type = [set stringForColumnIndex:2];
                message.Content = [set stringForColumnIndex:3];
                message.TimeStamp = [self.dateFormatter dateFromString:[set stringForColumnIndex:4]];
                [messages addObject:message];
            }
        }
        [db close];
    }];
    return messages;
}


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
}

-(void) registerNewMessagesListener {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getNewMessages:) name:@"newMessages" object:nil];
}

- (void)getNewMessages:(NSNotification *)notification{
    NSArray *messages = [notification object];
    for(int i = 0; i < messages.count; i++) {
        MessageModel *message = messages[i];
        NSString *sendId = [message SenderID];
        NSString *chatId = [message ReceiverID];
        NSString *tableName = [sendId intValue] < [chatId intValue] ? [[sendId stringByAppendingString:@"-"] stringByAppendingString:chatId] : [[chatId stringByAppendingString:@"-"] stringByAppendingString:sendId];
        SessionModel *session = [[SessionModel alloc] initWithChatId:sendId withChatName:sendId withProfilePicture:@"peppa" withLatestMessageContent:[message Content] withLatestMessageTimeStamp:[self.dateFormatter stringFromDate:message.TimeStamp]];
        [self insertSessionWithTableName:chatId withSession:session];
        [self insertMessageWithTableName:tableName withMessage:message];
    }
}
@end
