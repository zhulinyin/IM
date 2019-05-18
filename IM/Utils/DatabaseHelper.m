//
//  DatabaseHelper.m
//  IM
//
//  Created by student on 2019/5/18.
//  Copyright © 2019 zhulinyin. All rights reserved.
//

#import "DatabaseHelper.h"
#import "FMDatabaseQueue.h"
#import "../Main/Model/MessageModel.h"
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
        self.database = db;
        BOOL res = [db executeStatements:[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (id integer PRIMARY KEY AUTOINCREMENT, from text NOT NULL, to text NOT NULL, type text NOT NULL, content text NOT NULL, timestamp text NOT NULL);", MESSAGE_TABLE_NAME]];
        NSLog(@"%@", res ? @"create table successfully" : @"create table failed");
    }];
}

-(void) insertMessage:(MessageModel* ) message {
    [self.databaseQueue inDatabase:^(FMDatabase * _Nonnull db) {
        if([db open]) {
            BOOL res = [db executeStatements:[NSString stringWithFormat:@"INSERT INTO %@ (from, to, type, content, timestamp) VALUES ('%@', '%@', '%@', '%@', '%@');", MESSAGE_TABLE_NAME, message.SenderID, message.ReceiverID, message.Type, message.Content, [self.dateFormatter stringFromDate:message.TimeStamp]]];
            NSLog(@"%@", res ? @"insert message successfully" : @"insert message failed");
        }
        [db close];
    }];
}

-(NSMutableArray *) queryMessage:(NSString* ) userId {
    NSMutableArray *messages = [[NSMutableArray alloc] init];
    [self.databaseQueue inDatabase:^(FMDatabase * _Nonnull db) {
        if([db open]) {
            FMResultSet* set = [db executeQuery:[NSString stringWithFormat:@"SELECT * FROM %@ WHERE from = '%@' or to = '%@';", MESSAGE_TABLE_NAME, userId, userId]];
            if([set next]) {
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
@end
