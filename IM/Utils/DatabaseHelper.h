//
//  DatabaseHelper.h
//  IM
//
//  Created by student on 2019/5/18.
//  Copyright © 2019 zhulinyin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "../Main/Model/MessageModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface DatabaseHelper : NSObject
+(instancetype) getInstance;
-(void) insertMessage:(MessageModel* ) message;
-(NSMutableArray *) queryAllMessagesWithUserId:(NSString* ) userId;
-(void) insertMessages:(NSArray* ) messages;
-(void) registerNewMessagesListener;
@end

NS_ASSUME_NONNULL_END
