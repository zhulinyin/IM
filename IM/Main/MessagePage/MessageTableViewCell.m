//
//  MessageTableViewCell.m
//  IM
//
//  Created by Ray Shaw on 2019/4/29.
//  Copyright © 2019年 zhulinyin. All rights reserved.
//

#import "MessageTableViewCell.h"

@interface MessageTableViewCell()
@property (strong, nonatomic) UIImageView *ContactProfilePicture;
@property (strong, nonatomic) UILabel *ContactName;
@property (strong, nonatomic) UILabel *MessageAbstract;
@property (strong, nonatomic) UILabel *TimeStamp;
@property (strong, nonatomic) UIView *Circle;

@end

@implementation MessageTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.layoutMargins = UIEdgeInsetsZero;
        //头像
        self.ContactProfilePicture = [[UIImageView alloc] init];
        self.ContactProfilePicture.frame = CGRectMake(0, 0, ICON_WH, ICON_WH);
        self.ContactProfilePicture.contentMode = UIViewContentModeScaleAspectFit;
        self.ContactProfilePicture.image = [UIImage imageNamed:@"default_icon"];
        self.ContactProfilePicture.frame = CGRectMake(15, 10, ICON_WH, ICON_WH);
        [self.contentView addSubview:self.ContactProfilePicture];
        
        //昵称
        self.ContactName = [[UILabel alloc] init];
        self.ContactName.font = [UIFont systemFontOfSize:18];
        self.ContactName.numberOfLines = 1;
        self.ContactName.textColor = [UIColor blackColor];
        self.ContactName.frame = CGRectMake(25 + ICON_WH, 10, 200, 20);
        [self.contentView addSubview:self.ContactName];
        
        //摘要
        self.MessageAbstract = [[UILabel alloc] init];
        self.MessageAbstract.font = [UIFont systemFontOfSize:15];
        self.MessageAbstract.numberOfLines = 1;
        self.MessageAbstract.textColor = [UIColor grayColor];
        //self.MessageAbstract.lineBreakMode = UILineBreakModeTailTruncation;
        self.MessageAbstract.frame = CGRectMake(25 + ICON_WH, 35, SCREEN_WIDTH - 100, 20);
        [self.contentView addSubview:self.MessageAbstract];
        
        //时间戳
        self.TimeStamp = [[UILabel alloc] init];
        self.TimeStamp.font = [UIFont systemFontOfSize:15];
        self.TimeStamp.numberOfLines = 1;
        self.TimeStamp.textColor = [UIColor grayColor];
        self.TimeStamp.frame = CGRectMake(SCREEN_WIDTH - 160, 10, 160, 20);
        [self.contentView addSubview:self.TimeStamp];
    }
    return self;
}

-(void)setSession:(SessionModel *)session {
    self.ContactProfilePicture.image = [UIImage imageNamed:@"peppa"];
    self.ContactName.text = session.chatId;
    self.MessageAbstract.text = session.latestMessageContent;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd hh:mm:ss";
    self.TimeStamp.text = [dateFormatter stringFromDate:session.latestMessageTimeStamp];
}

@end
