//
//  DatabaseHelper.h
//  IM
//
//  Created by student on 2019/5/18.
//  Copyright © 2019 zhulinyin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "../Main/Model/MessageModel.h"
#import "SessionModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface DatabaseHelper : NSObject
+(instancetype) getInstance;
-(void) insertMessageWithTableName:(NSString *) tableName withMessage:(MessageModel* ) message;
-(NSMutableArray *) queryAllMessagesWithUserId:(NSString* ) userId withChatId:(NSString *) chatId;
-(void) insertMessagesWithTableName:(NSString *)tableName withMessages:(NSArray* ) messages;
-(void) registerNewMessagesListener;
-(void) createMessageTable:(NSString *) tableName;
-(void) createSessionListTable:(NSString *) tableName;
-(NSMutableArray *) queryMessageListWithTableName:(NSString *) tableName;
-(void) insertSessionWithTableName:(NSString *)tableName withSession:(SessionModel *)session
@end

NS_ASSUME_NONNULL_END
