//
//  MessageTableViewCell.h
//  IM
//
//  Created by Ray Shaw on 2019/4/29.
//  Copyright © 2019年 zhulinyin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SessionModel.h"
NS_ASSUME_NONNULL_BEGIN
#define SCREEN_WIDTH    [[UIScreen mainScreen] bounds].size.width
#define SCREEN_HEIGHT   [[UIScreen mainScreen] bounds].size.height
#define ICON_WH 50

@interface MessageTableViewCell : UITableViewCell
@property(strong, nonatomic) SessionModel *session;

- (void)addLongGes:(id)target action:(SEL)action;
@end

NS_ASSUME_NONNULL_END
