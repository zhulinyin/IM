//
//  ContactTableViewCell.h
//  Main Page
//
//  Created by Ray Shaw on 2019/4/25.
//  Copyright © 2019年 Ray Shaw. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "URLHelper.h"
#import "UIImageView+WebCache.h"

NS_ASSUME_NONNULL_BEGIN
#define SCREEN_WIDTH    [[UIScreen mainScreen] bounds].size.width
#define SCREEN_HEIGHT   [[UIScreen mainScreen] bounds].size.height
#define ICON_WH 50

@interface ContactTableViewCell : UITableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;
- (void)setPictureOfAsset:(NSString *)pictureName;
- (void)setPictureWithURL:(NSString *)pictureURL;
- (void)setTitle:(NSString *)title;
- (void)setUnreadRequestNum:(NSInteger)unreadNum;

@end

NS_ASSUME_NONNULL_END
