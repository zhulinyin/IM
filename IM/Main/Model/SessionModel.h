//
//  SessionModel.h
//  IM
//
//  Created by student8 on 2019/5/25.
//  Copyright © 2019 zhulinyin. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SessionModel : NSObject

@property(strong, nonatomic) NSString *chatId;
@property(strong, nonatomic) NSString *chatName;
@property(strong, nonatomic) NSString *profilePicture;
@property(strong, nonatomic) NSString *latestMessageContent;
@property(strong, nonatomic) NSDate *latestMessageTimeStamp;

-(instancetype) initWithChatId:(NSString *)chatId withChatName:(NSString *)chatName withProfilePicture:(NSString *)profilePicture withLatestMessageContent:(NSString *)latestMessageContent withLatestMessageTimeStamp:(NSDate *)latestMessageTimeStamp;
@end

NS_ASSUME_NONNULL_END
