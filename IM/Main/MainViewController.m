//
//  MainViewController.m
//  IM
//
//  Created by student8 on 2019/6/15.
//  Copyright © 2019 zhulinyin. All rights reserved.
//

#import "MainViewController.h"

@interface MainViewController ()

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIStoryboard *messageSB = [UIStoryboard storyboardWithName:@"MessagePage" bundle:nil];
    UIStoryboard *contactSB = [UIStoryboard storyboardWithName:@"ContactPage" bundle:nil];
    UIStoryboard *infoSB = [UIStoryboard storyboardWithName:@"Info" bundle:nil];
    
    UINavigationController *messageNav = [messageSB instantiateInitialViewController];
    UIViewController *messageVc = messageNav.topViewController;
    messageVc.tabBarItem.title = @"消息";
    messageVc.tabBarItem.image = [UIImage imageNamed:@"xiaoxi"];
    
    UINavigationController *contactNav = [contactSB instantiateInitialViewController];
    UIViewController *contactVc = contactNav.topViewController;
    contactVc.tabBarItem.title = @"联系人";
    contactVc.tabBarItem.image = [UIImage imageNamed:@"tongxunlu"];
    
    UINavigationController *infoNav = [infoSB instantiateInitialViewController];
    UIViewController *infoVc = infoNav.topViewController;
    infoVc.tabBarItem.title = @"个人信息";
    infoVc.tabBarItem.image = [UIImage imageNamed:@"wode"];
    
    self.viewControllers = @[messageNav, contactNav, infoNav];
    // Do any additional setup after loading the view.
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
