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
#import "UserManager.h"
NS_ASSUME_NONNULL_BEGIN

@interface DatabaseHelper : NSObject
+(instancetype) getInstance;
-(void) insertMessageWithMessage:(MessageModel* ) message;
-(NSMutableArray *) queryAllMessagesWithChatId:(NSString *) chatId;
-(void) insertMessagesWithTableName:(NSString *)tableName withMessages:(NSArray* ) messages;
-(void) registerNewMessagesListener;
-(void) unregisterNewMessageListener;
-(NSMutableArray *) querySessions;
-(void) insertSessionWithSession:(SessionModel *)session;
-(void) insertFriendWithFriend:(UserModel *) Friend;
-(void) selectFriendByID:(NSString*) UserID;
-(void) rebuildFriendListTable;
-(NSMutableArray *) getAllFriends;

@end

NS_ASSUME_NONNULL_END
