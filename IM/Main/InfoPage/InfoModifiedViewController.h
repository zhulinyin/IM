//
//  InfoModifiedViewController.h
//  IM
//
//  Created by student7 on 2019/5/18.
//  Copyright © 2019 zhulinyin. All rights reserved.
//

#ifndef infoModifiedViewController_h
#define infoModifiedViewController_h

#import <UIKit/UIKit.h>
#import "UserModel.h"

typedef void(^SubToMainBlock)(UserModel* user);

@interface InfoModifiedViewController : UIViewController

@property (strong, nonatomic) UserModel* change_user;
// 添加一个Block属性
@property (copy,nonatomic) SubToMainBlock data;

- (instancetype) initWithString:(NSString*)str;

@end

#endif /* InfoModifiedViewController_h */
