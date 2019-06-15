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
@property (strong, nonatomic) UILabel *Circle;

@end

@implementation MessageTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.layoutMargins = UIEdgeInsetsZero;
        //头像
        self.ContactProfilePicture = [[UIImageView alloc] init];
        self.ContactProfilePicture.contentMode = UIViewContentModeScaleAspectFit;
        self.ContactProfilePicture.image = [UIImage imageNamed:@"default"];
        self.ContactProfilePicture.frame = CGRectMake(15, 10, ICON_WH, ICON_WH);
        [self.contentView addSubview:self.ContactProfilePicture];
        
        //未读消息
        self.Circle = [[UILabel alloc] init];
        self.Circle.font = [UIFont systemFontOfSize:12];
        self.Circle.textColor = [UIColor whiteColor];
        self.Circle.backgroundColor = [UIColor redColor];
        self.Circle.textAlignment = NSTextAlignmentCenter;
        self.Circle.frame = CGRectMake(3+ICON_WH, 7, 18, 18);
        self.Circle.layer.cornerRadius = self.Circle.frame.size.width*0.5;
        self.Circle.layer.masksToBounds = YES;
        
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
    NSString *imagePath = [URLHelper getURLwithPath:session.profilePicture];
    [self.ContactProfilePicture sd_setImageWithURL:[NSURL URLWithString:imagePath]
            placeholderImage:[UIImage imageNamed:@"default"]
                   completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                       NSLog(@"error== %@",error);
                   }];
    self.ContactName.text = session.chatName;
    self.MessageAbstract.text = session.latestMessageContent;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd hh:mm:ss";
    self.TimeStamp.text = [dateFormatter stringFromDate:session.latestMessageTimeStamp];
    if (session.unreadNum > 0) {
        if (session.unreadNum > 99)
            self.Circle.text = @"...";
        else
            self.Circle.text = [NSString stringWithFormat:@"%ld", session.unreadNum];
        [self.contentView addSubview:self.Circle];
    }
    else
        [self.Circle removeFromSuperview];
}

- (void)addLongGes:(id)target action:(SEL)action {
    UILongPressGestureRecognizer *longGes = [[UILongPressGestureRecognizer alloc]initWithTarget:target action:action];
    //设定最小的长按时间 按不够这个时间不响应手势
    longGes.minimumPressDuration = 1;
    [self.contentView addGestureRecognizer:longGes];
}
@end
