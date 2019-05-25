//
//  FriendRequestTableViewCell.h
//  IM
//
//  Created by student14 on 2019/5/18.
//  Copyright © 2019 zhulinyin. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FriendRequestTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *ProfilePicture;
@property (weak, nonatomic) IBOutlet UILabel *Nickname;
@property (weak, nonatomic) IBOutlet UIButton *AcceptButton;
@property (weak, nonatomic) IBOutlet UIButton *RejectButton;

@end

NS_ASSUME_NONNULL_END
