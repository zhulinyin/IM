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
//头像
@property (nonatomic, weak) UIImageView *iconImage;
//气泡
@property (nonatomic, weak) BubbleView *leftBubbleView;
@end

@implementation LeftMessageTableViewCell

+ (instancetype)cellWithTableView:(UITableView *)tableView {
    static NSString *identifier = @"leftMessageTableViewCell";
    // 1.缓存中取
    LeftMessageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    // 2.创建
    if (cell == nil) {
        cell = [[LeftMessageTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
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

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // 1.创建头像
        UIImageView *iconImage = [[UIImageView alloc] init];
        iconImage.image = [UIImage imageNamed:@"peppa"];
        [self.contentView addSubview:iconImage];
        self.iconImage = iconImage;
        
        // 2.创建气泡
        BubbleView *leftBubbleView = [[BubbleView alloc] initWithPosition:YES];
        [leftBubbleView setContentText:@"66666666"];
        [self.contentView addSubview:leftBubbleView];
        self.leftBubbleView = leftBubbleView;
    }
    return self;
}

@end
