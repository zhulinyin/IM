//
//  BubbleView.m
//  IM
//
//  Created by zhulinyin on 2019/5/1.
//  Copyright © 2019 zhulinyin. All rights reserved.
//

#import "BubbleView.h"

@implementation BubbleView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)initWithPosition:(Boolean)isLeft
{
    if (self = [super init])
    {
        self.imageView = [[UIImageView alloc]initWithFrame:self.bounds];
        [self addSubview:self.imageView];
        self.textLable = [[UILabel alloc]init];
        [self addSubview:self.textLable];
        self.textLable.font = [UIFont systemFontOfSize:16];
        self.textLable.numberOfLines = 0;
        self.isLeft = isLeft;
    }
    return self;
}
- (void)setContentText:(NSString *)text
{
    self.textLable.text = text;
    CGSize maxSize = CGSizeMake(200, 990);
    CGSize size = [self.textLable sizeThatFits:maxSize];
    self.textLable.frame = CGRectMake(0, 0, size.width, size.height);
    self.imageView.frame = CGRectMake(-10, -10, size.width + 25 , size.height + 20);
    UIImage *image = [UIImage imageNamed:self.isLeft?@"LeftMessageBubble":@"RightMessageBubble"];
    self.imageView.image = [self resizableImage:image];
}
- (UIImage*)resizableImage:(UIImage *)image
{
    //图片拉伸区域
    CGFloat top = image.size.height - 8;
    CGFloat left = image.size.width / 2 - 2;
    CGFloat right = image.size.width / 2 + 2;
    CGFloat bottom = image.size.height - 4;
    //重点 进行图片拉伸
    return [image resizableImageWithCapInsets:UIEdgeInsetsMake(top, left, bottom, right) resizingMode:UIImageResizingModeStretch];
}

@end
