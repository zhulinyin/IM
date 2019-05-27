//
//  SessionModel.m
//  IM
//
//  Created by student8 on 2019/5/25.
//  Copyright © 2019 zhulinyin. All rights reserved.
//

#import "SessionModel.h"

@implementation SessionModel

-(instancetype) initWithChatId:(NSString *)chatId withChatName:(NSString *)chatName withProfilePicture:(NSString *)profilePicture withLatestMessageContent:(NSString *)latestMessageContent withLatestMessageTimeStamp:(NSDate *)latestMessageTimeStamp {
    self = [super init];
    if (self)
    {
        self.chatId = chatId;
        self.chatName = chatName;
        self.profilePicture = profilePicture;
        self.latestMessageContent = latestMessageContent;
        self.latestMessageTimeStamp = latestMessageTimeStamp;
    }
    return self;
}
@end
