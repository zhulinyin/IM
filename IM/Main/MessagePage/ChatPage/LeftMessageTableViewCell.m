//
//  LeftMessageTableViewCell.m
//  IM
//
//  Created by zhulinyin on 2019/4/29.
//  Copyright © 2019 zhulinyin. All rights reserved.
//

#import "LeftMessageTableViewCell.h"
#import "BubbleView.h"
@interface LeftMessageTableViewCell()

@end

@implementation LeftMessageTableViewCell

+ (instancetype)cellWithTableView:(UITableView *)tableView withImage:(NSString *)iconImageName withMessage:(NSString *)message {
    static NSString *identifier = @"leftMessageTableViewCell";
    // 1.缓存中取
    LeftMessageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    // 2.创建
    if (cell == nil) {
        cell = [[LeftMessageTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    cell.iconImage.image = [UIImage imageNamed:iconImageName];
    cell.messageBubble.isLeft = YES;
    [cell.messageBubble setContentText:message];
    return cell;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
