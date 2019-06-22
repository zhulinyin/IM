//
//  ContactTableViewCell.m
//  Main Page
//
//  Created by Ray Shaw on 2019/4/25.
//  Copyright © 2019年 Ray Shaw. All rights reserved.
//

#import "ContactTableViewCell.h"

@interface ContactTableViewCell()

@property (strong, nonatomic) UIImageView *Icon;
@property (strong, nonatomic) UILabel *Text;
@property (strong, nonatomic) UILabel *Circle;

@end

@implementation ContactTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.layoutMargins = UIEdgeInsetsZero;
        //头像
        self.Icon = [[UIImageView alloc] init];
        self.Icon.contentMode = UIViewContentModeScaleAspectFit;
        self.Icon.image = [UIImage imageNamed:@"default"];
        self.Icon.frame = CGRectMake(15, 10, ICON_WH, ICON_WH);
        [self.contentView addSubview:self.Icon];
        
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
        self.Text = [[UILabel alloc] init];
        self.Text.font = [UIFont systemFontOfSize:20];
        self.Text.numberOfLines = 1;
        self.Text.textColor = [UIColor blackColor];
        self.Text.frame = CGRectMake(25 + ICON_WH, 25, 200, 20);
        [self.contentView addSubview:self.Text];
        
    }
    return self;
}

- (void)setPictureOfAsset:(NSString *)pictureName
{
    self.Icon.image = [UIImage imageNamed:pictureName];
}

- (void)setPictureWithURL:(NSString *)pictureURL
{
    NSString *imagePath = [URLHelper getURLwithPath:pictureURL];
    [self.Icon sd_setImageWithURL:[NSURL URLWithString:imagePath]
                                  placeholderImage:[UIImage imageNamed:@"default"]
                                         completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                             NSLog(@"error== %@",error);
                                         }];
}

- (void)setTitle:(NSString *)title
{
    self.Text.text = title;
}

- (void)setUnreadRequestNum:(NSInteger)unreadNum
{
    if (unreadNum > 0)
    {
        if (unreadNum > 99)
            self.Circle.text = @"...";
        else
            self.Circle.text = [NSString stringWithFormat:@"%ld", unreadNum];
        [self.contentView addSubview:self.Circle];
    }
    else
        [self.Circle removeFromSuperview];
}



@end
