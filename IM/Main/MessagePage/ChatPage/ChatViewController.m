//
//  ChatViewController.m
//  IM
//
//  Created by zhulinyin on 2019/4/29.
//  Copyright © 2019 zhulinyin. All rights reserved.
//

#import "ChatViewController.h"
#import "ChatMessageTableViewController.h"

@interface ChatViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation ChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    ChatMessageTableViewController *tableViewController = [[ChatMessageTableViewController alloc] init];
    self.tableView.dataSource = tableViewController;
    self.tableView.delegate = tableViewController;
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
