//
//  InfoViewController.m
//  IM
//
//  Created by zhulinyin on 2019/4/27.
//  Copyright © 2019 zhulinyin. All rights reserved.
//

#import "InfoViewController.h"

@interface InfoViewController ()

@end

@implementation InfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if (self.User == nil)
    {
        self.User = [[UserModel alloc] initWithProperties:@"peppa ID" NickName:@"Peppa" RemarkName:@"peppy" Gender:@"female" Birthplace:@"UK" ProfilePicture:@"peppa.jpg"];
    }
    self.ProfilePicture.image = [UIImage imageNamed:self.User.ProfilePicture];
    self.NickName.text = self.User.NickName;
    self.ID.text = self.User.UserID;
    self.Gender.text = self.User.Gender;
    self.BIrthplace.text = self.User.Birthplace;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
