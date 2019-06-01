//
//  ChatViewController.h
//  IM
//
//  Created by zhulinyin on 2019/5/8.
//  Copyright © 2019 zhulinyin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserModel.h"
#import "../../../Utils/DatabaseHelper.h"

NS_ASSUME_NONNULL_BEGIN

@interface ChatViewController : UIViewController

- (instancetype)initWithContact:(UserModel *)chatUser;

@end

NS_ASSUME_NONNULL_END
