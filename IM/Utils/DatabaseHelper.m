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
        [self createTable];
    }
    else {
        NSLog(@"Database create failed");
    }
}

-(void) createTable {
    [self.databaseQueue inDatabase:^(FMDatabase * _Nonnull db) {
        if([db open]) {
            NSString* sql = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (id INTEGER PRIMARY KEY AUTOINCREMENT, fromId text NOT NULL, toId text NOT NULL, type text NOT NULL, content text NOT NULL, timestamp text NOT NULL);", MESSAGE_TABLE_NAME];
            BOOL res = [db executeUpdate:sql];
            NSLog(@"%@", res ? @"create table successfully" : @"create table failed");
        }
        [db close];
    }];
}

-(void) insertMessage:(MessageModel* ) message {
    [self.databaseQueue inDatabase:^(FMDatabase * _Nonnull db) {
        if([db open]) {
            BOOL res = [db executeStatements:[NSString stringWithFormat:@"INSERT INTO %@ (fromId, toId, type, content, timestamp) VALUES ('%@', '%@', '%@', '%@', '%@');", MESSAGE_TABLE_NAME, message.SenderID, message.ReceiverID, message.Type, message.Content, [self.dateFormatter stringFromDate:message.TimeStamp]]];
            NSLog(@"%@", res ? @"insert message successfully" : @"insert message failed");
        }
        [db close];
    }];
}

-(NSMutableArray *) queryAllMessagesWithUserId:(NSString* ) userId {
    NSMutableArray *messages = [[NSMutableArray alloc] init];
    [self.databaseQueue inDatabase:^(FMDatabase * _Nonnull db) {
        if([db open]) {
            FMResultSet* set = [db executeQuery:[NSString stringWithFormat:@"SELECT * FROM %@ WHERE fromId = '%@' or toId = '%@';", MESSAGE_TABLE_NAME, userId, userId]];
            while([set next]) {
                MessageModel* message = [[MessageModel alloc] init];
                message.SenderID = [set stringForColumnIndex:1];
                message.ReceiverID = [set stringForColumnIndex:2];
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

-(void) insertMessages:(NSArray* ) messages {
    [self.databaseQueue inDatabase:^(FMDatabase * _Nonnull db) {
        if([db open]) {
            for (int i = 0; i < messages.count; i++) {
                MessageModel* message = messages[i];
                BOOL res = [db executeStatements:[NSString stringWithFormat:@"INSERT INTO %@ (fromId, toId, type, content, timestamp) VALUES ('%@', '%@', '%@', '%@', '%@');", MESSAGE_TABLE_NAME, message.SenderID, message.ReceiverID, message.Type, message.Content, [self.dateFormatter stringFromDate:message.TimeStamp]]];
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
    [self insertMessages:messages];
}
@end
