//
//  LeftMessageTableViewCell.h
//  IM
//
//  Created by zhulinyin on 2019/4/29.
//  Copyright © 2019 zhulinyin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BubbleView.h"
NS_ASSUME_NONNULL_BEGIN

@interface LeftMessageTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *iconImage;
@property (weak, nonatomic) IBOutlet BubbleView *messageBubble;

+ (instancetype)cellWithTableView:(UITableView *)tableView withImage:(NSString *)iconImageName withMessage:(NSString *)message;

@end

NS_ASSUME_NONNULL_END
