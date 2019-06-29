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
#import "REquestModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface DatabaseHelper : NSObject
+(instancetype) getInstance;
+(void)attemptDealloc;
-(void) insertMessageWithMessage:(MessageModel* ) message;
-(NSMutableArray *) queryAllMessagesWithChatId:(NSString *) chatId;
-(void) insertMessagesWithTableName:(NSString *)tableName withMessages:(NSArray* ) messages;
-(void) registerNewMessagesListener;
-(void) unregisterNewMessageListener;
-(NSMutableArray *) querySessions;
-(void) insertSessionWithSession:(SessionModel *)session;
-(void) createFriendListTable;
-(void) insertFriendWithFriend:(UserModel *) Friend;
-(void) selectFriendByID:(NSString*) UserID;
-(void) rebuildFriendListTable;
-(NSString *) getProfilePictureURLwithUserID:(NSString*) FriendID;
-(BOOL)isFriendTableExist;
-(void)getFriendsFromServer;
-(NSMutableArray *) getAllFriends;
-(NSMutableArray *) getAllRequest;
-(void) updateRequestStateWithID:(NSString *) userID state:(NSString *)state;
-(void) deleteMessages:(NSString *) chatId;
-(UserModel *) getFriendByID:(NSString *)friendID;
-(void) deleteFriendByID:(NSString *)friendID;

@end

NS_ASSUME_NONNULL_END
