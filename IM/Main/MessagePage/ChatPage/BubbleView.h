//
//  BubbleView.h
//  IM
//
//  Created by zhulinyin on 2019/5/1.
//  Copyright © 2019 zhulinyin. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface BubbleView : UIView
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *textLable;
@property Boolean isLeft;
- (instancetype)initWithPosition:(Boolean)isLeft;
- (void)setContentText:(NSString *)text;
@end

NS_ASSUME_NONNULL_END
