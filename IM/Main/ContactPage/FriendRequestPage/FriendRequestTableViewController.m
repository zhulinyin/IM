//
//  FriendRequestTableViewController.m
//  IM
//
//  Created by student14 on 2019/5/18.
//  Copyright © 2019 zhulinyin. All rights reserved.
//

#import "FriendRequestTableViewController.h"

@interface FriendRequestTableViewController ()

@property (nonatomic, strong) NSMutableArray<RequestModel*> *requestList;
@property (strong, nonatomic) IBOutlet UITableView *FriendRequestTableView;
@end

@implementation FriendRequestTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.requestList = [[DatabaseHelper getInstance] getAllRequest];
    
    //[self initializeTestData];
    self.FriendRequestTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateRequest:) name:@"requestChange" object:nil];
    
    [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:[NSString stringWithFormat:@"%@unreadRequestNum", [UserManager getInstance].getLoginModel.UserID]];
    //NSNumber* unreadNum = [[NSNumber alloc] initWithInteger:0];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateUnreadRequest" object:nil];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

#pragma mark - Table view data source


- (void)updateRequest:(NSNotification *)notification{
    self.requestList = [[DatabaseHelper getInstance] getAllRequest];
    [self.FriendRequestTableView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return self.requestList.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *reuseID = @"FriendRequestTableCell";
    FriendRequestTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseID forIndexPath:indexPath];
    
    if (cell == nil)
    {
        cell = [[FriendRequestTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseID];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    RequestModel* request =  self.requestList[indexPath.row];
    UserModel* user = request.User;
    cell.Nickname.text = user.NickName;
    NSString *imagePath = [URLHelper getURLwithPath:user.ProfilePicture];
    [cell.ProfilePicture sd_setImageWithURL:[NSURL URLWithString:imagePath]
                                  placeholderImage:[UIImage imageNamed:@"peppa"]
                                         completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                             NSLog(@"error== %@",error);
                                         }];
    if ([request.State isEqualToString:@"accepted"])
    {
        [self AcceptCell:cell];
    }
    else if ([request.State isEqualToString:@"rejected"])
    {
        [self RejectCell:cell];
    }
    else
    {
        // do nothing
    }
    
    NSLog(@"UserID:%@ CID:%ld state:%@", user.UserID, (long)request.Cid, request.State);
    
    return cell;
}


- (void)AcceptCell:(FriendRequestTableViewCell *)cell
{
    [self DeactivateCell:cell];
    cell.RejectButton.backgroundColor = [UIColor grayColor];
    [cell.AcceptButton setTitle:@"已接受" forState:UIControlStateNormal];
}

- (void)RejectCell:(FriendRequestTableViewCell *)cell
{
    [self DeactivateCell:cell];
    cell.AcceptButton.backgroundColor = [UIColor grayColor];
    [cell.RejectButton setTitle:@"已拒绝" forState:UIControlStateNormal];
}

-(void)DeactivateCell:(FriendRequestTableViewCell *)cell
{
    cell.AcceptButton.enabled = NO;
    cell.RejectButton.enabled = NO;
}

-(void)ReactivateCell:(FriendRequestTableViewCell *)cell
{
    cell.AcceptButton.enabled = YES;
    cell.RejectButton.enabled = YES;
}

- (IBAction)AcceptRequest:(id)sender
{
    //get the cell
    UIButton *AcceptButton = sender;
    FriendRequestTableViewCell *cell = [[AcceptButton superview] superview];
    NSIndexPath *indexPath = [self.FriendRequestTableView indexPathForCell:cell];
   
    [self DeactivateCell:cell];
    
    
    NSString* FriendID = self.requestList[indexPath.row].User.UserID;
    NSString* Cid = [[NSString alloc] initWithFormat:@"%ld", (long)self.requestList[indexPath.row].Cid];
    
    NSDictionary* params = @{@"cid":Cid, @"to":FriendID, @"info":@"hello"};
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    NSString *url = [URLHelper getURLwithPath:@"/content/add"];
    
    [manager POST:url parameters:params progress:nil
     success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
         if([responseObject[@"state"] isEqualToString:@"ok"])
         {
             NSLog(@"%@", responseObject[@"msg"]);
             [self AcceptCell:cell];
             [[DatabaseHelper getInstance] updateRequestStateWithID:FriendID state:@"accepted"];
             [[DatabaseHelper getInstance] insertFriendWithFriend:self.requestList[indexPath.row].User];
         }
         else
         {
             NSLog(@"%@", responseObject[@"msg"]);
             [self ReactivateCell:cell];
         }
     }
     failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
         NSLog(@"%@", error.localizedDescription);
     }];
    
}

- (IBAction)RejectFriend:(id)sender
{
    //get the cell
    UIButton *RejectButton = sender;
    FriendRequestTableViewCell *cell = [[RejectButton superview] superview];
    NSIndexPath *indexPath = [self.FriendRequestTableView indexPathForCell:cell];
    
    NSString* FriendID = self.requestList[indexPath.row].User.UserID;
    [[DatabaseHelper getInstance] updateRequestStateWithID:FriendID state:@"rejected"];
    [self RejectCell:cell];
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
