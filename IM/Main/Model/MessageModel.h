//
//  MessageModel.h
//  IM
//
//  Created by Ray Shaw on 2019/4/27.
//  Copyright © 2019年 zhulinyin. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MessageModel : NSObject

@property NSInteger* Seq;
@property (weak, nonatomic) NSString* SenderID;
@property (weak, nonatomic) NSString* ReceiverID;
@property (weak, nonatomic) NSDate* TimeStamp;
@property (weak, nonatomic) NSString* Type;
@property (weak, nonatomic) NSString* Content;
- (instancetype)initWithProperties:(NSInteger *)Seq
                          SenderID:(NSString *)SenderID
                        ReceiverID:(NSString *)ReceiverID
                         TimeStamp:(NSDate *)TimeStamp
                              Type:(NSString *)Type
                           Content:(NSString *)Content;

@end

NS_ASSUME_NONNULL_END
