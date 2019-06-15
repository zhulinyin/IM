//
//  ChatTableViewCell.m
//  IM
//
//  Created by zhulinyin on 2019/5/8.
//  Copyright © 2019 zhulinyin. All rights reserved.
//

#import "ChatTableViewCell.h"

#define ICON_WH 40

@interface ChatTableViewCell()

@property (nonatomic, strong) UIImageView  *bubbleIV;   //气泡
@property (nonatomic, strong) UIImageView *iconIV;      //头像
@property (nonatomic, strong) UILabel *contentLabel;    //文字


@end
@implementation ChatTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor clearColor];
        UIView *backView = [[UIView alloc] initWithFrame:self.frame];
        self.selectedBackgroundView = backView;
        self.selectedBackgroundView.backgroundColor = [UIColor clearColor];
        
        [self setupSubviews];
    }
    return self;
}

- (void)setupSubviews {
    
    //头像
    self.iconIV = [[UIImageView alloc] init];
    self.iconIV.frame = CGRectMake(0, 0, ICON_WH, ICON_WH);
    self.iconIV.contentMode = UIViewContentModeScaleAspectFit;
    self.iconIV.image = [UIImage imageNamed:@"default_icon"];
    [self.contentView addSubview:self.iconIV];
    
    //背景气泡
    self.bubbleIV = [[UIImageView alloc] init];
    self.bubbleIV.userInteractionEnabled = YES;
    [self.contentView addSubview:self.bubbleIV];
    
    //消息内容
    self.contentLabel = [[UILabel alloc] init];
    self.contentLabel.font = [UIFont systemFontOfSize:15];
    self.contentLabel.numberOfLines = 0;
    self.contentLabel.textColor = [UIColor grayColor];
    [self.bubbleIV addSubview:self.contentLabel];
}

- (void)setModel:(MessageModel *)model {
    UserModel *loginUser = [[UserManager getInstance] getLoginModel];
    CGSize labelSize;
    if ([model.Type isEqualToString:@"text"]){
        //计算文字长度
        self.contentLabel.text = model.Content;
        labelSize = [model.Content boundingRectWithSize: CGSizeMake(SCREEN_WIDTH-160, MAXFLOAT)
                                                       options: NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingTruncatesLastVisibleLine
                                                    attributes: @{NSFontAttributeName:self.contentLabel.font}
                                                       context: nil].size;
        self.contentLabel.frame = CGRectMake([model.SenderID isEqualToString:loginUser.UserID] ? 10 : 20 , 5, labelSize.width, labelSize.height + 10);
    }
    else if ([model.Type isEqualToString:@"image"]){
        // 使用url来获取图片，而不是传参数
        UIImageView *imgV = [[UIImageView alloc]init];
        NSLog(model.Content);
        NSString *imagePath = [URLHelper getURLwithPath:model.Content];
        NSLog(imagePath);
        [imgV sd_setImageWithURL:[NSURL URLWithString:imagePath]
                placeholderImage:[UIImage imageNamed:@"peppa"]
                       completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                           NSLog(@"error== %@",error);
                       }];
        
        
        //2.初始化富文本对象
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:@""];
        //3.初始化NSTextAttachment对象
        NSTextAttachment *attchment = [[NSTextAttachment alloc]init];
        attchment.bounds = CGRectMake(0, 0, 100, 100);//设置frame
//        attchment.image = model.ContentImage;//设置图片
        attchment.image = imgV.image;//设置图片
        
        //4.创建带有图片的富文本
        NSAttributedString *string = [NSAttributedString attributedStringWithAttachment:(NSTextAttachment *)(attchment)];
        [attributedString appendAttributedString:string];   //添加到尾部
        self.contentLabel.attributedText = attributedString;
        
        
        labelSize = [attributedString boundingRectWithSize: CGSizeMake(SCREEN_WIDTH-160, MAXFLOAT)
                                                       options: NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingTruncatesLastVisibleLine
                                                       context: nil].size;
        self.contentLabel.frame = CGRectMake([model.SenderID isEqualToString:loginUser.UserID] ? 10 : 20 , 5, labelSize.width, labelSize.height + 10);
    }
    //计算气泡位置
    CGFloat bubbleX = [model.SenderID isEqualToString:loginUser.UserID] ? (SCREEN_WIDTH - ICON_WH - 25 - labelSize.width - 30) : (ICON_WH + 25);
    self.bubbleIV.frame = CGRectMake(bubbleX, 20, self.contentLabel.frame.size.width + 30, self.contentLabel.frame.size.height+10);
    
    //头像位置
    CGFloat iconX = [model.SenderID isEqualToString:loginUser.UserID] ? (SCREEN_WIDTH - ICON_WH - 15) : 15;
    self.iconIV.frame = CGRectMake(iconX, 15, ICON_WH, ICON_WH);
    self.iconIV.image = [UIImage imageNamed: [model.SenderID isEqualToString:loginUser.UserID] ? @"peppa" : @"teemo"];
    
    //拉伸气泡
    UIImage *backImage = [UIImage imageNamed: [model.SenderID isEqualToString:loginUser.UserID] ?  @"bubble_right" : @"bubble_left"];
    backImage = [backImage resizableImageWithCapInsets:UIEdgeInsetsMake(30, 30, 10, 30) resizingMode:UIImageResizingModeStretch];
    self.bubbleIV.image = backImage;
}

@end
