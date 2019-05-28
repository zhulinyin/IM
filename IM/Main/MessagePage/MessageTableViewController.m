//
//  MessageTableViewController.m
//  IM
//
//  Created by Ray Shaw on 2019/4/29.
//  Copyright © 2019年 zhulinyin. All rights reserved.
//

#import "MessageTableViewController.h"
#import "MessageTableViewCell.h"
#import "../Model/MessageModel.h"
#import "ChatPage/ChatViewController.h"

@interface MessageTableViewController ()
@property (strong, nonatomic) IBOutlet UITableView *MessageTableView;
@property (nonatomic, strong) NSMutableArray<SessionModel*> *sessionsArray;

@end

@implementation MessageTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.MessageTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.MessageTableView.separatorInset = UIEdgeInsetsZero;
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.sessionsArray = [[DatabaseHelper getInstance] querySessions];
    [self.MessageTableView reloadData];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateSession:) name:@"sessionChange" object:nil];
}

-(void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)updateSession:(NSNotification *)notification{
    self.sessionsArray = [[DatabaseHelper getInstance] querySessions];
    [self.MessageTableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning Incomplete implementation, return the number of rows
    //return self.MessagesArray.count;
    return self.sessionsArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SessionModel *session = self.sessionsArray[indexPath.row];
    MessageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell2"];
    
    // Configure the cell...
    if (cell == nil)
    {
        cell = [[MessageTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell2"];
        //cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    cell.session = session;
    return cell;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    SessionModel *session = self.sessionsArray[indexPath.row];
    UserModel *chatUser = [[UserModel alloc] initWithProperties:session.chatId NickName:session.chatName RemarkName:session.chatName Gender:@"man" Birthplace:@"guangzhou" ProfilePicture:@"teemo"];
    ChatViewController *viewController = [[ChatViewController alloc] initWithContact:chatUser];
    viewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:viewController animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    //计算文字高度需和自定义cell内容尺寸同步
    return 70;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
