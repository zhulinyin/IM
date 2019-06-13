//
//  FriendRequestTableViewController.m
//  IM
//
//  Created by student14 on 2019/5/18.
//  Copyright © 2019 zhulinyin. All rights reserved.
//

#import "FriendRequestTableViewController.h"

@interface FriendRequestTableViewController ()

@property (nonatomic, strong) NSMutableArray<UserModel*> *RequestList;
@property (strong, nonatomic) IBOutlet UITableView *FriendRequestTableView;
@end

@implementation FriendRequestTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.RequestList = [NSMutableArray array];
    
    //[self initializeTestData];
    self.FriendRequestTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getNewFriendRequest:) name:@"newFriends" object:nil];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

#pragma mark - Table view data source

- (void)initializeTestData
{
    
    UserModel* TestUser1 = [[UserModel alloc] initWithProperties:@"123" NickName:@"teemo" RemarkName:@"teemo" Gender:@"male" Birthplace:@"Jodl" ProfilePicture:@"teemo.jpg"];
    UserModel* TestUser2 = [[UserModel alloc] initWithProperties:@"321" NickName:@"peppa" RemarkName:@"peppa" Gender:@"female" Birthplace:@"UK" ProfilePicture:@"peppa.jpg"];
    [self.RequestList addObject:TestUser1];
    [self.RequestList addObject:TestUser2];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return self.RequestList.count;
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
    
    cell.ProfilePicture.image = [UIImage imageNamed:self.RequestList[indexPath.row].ProfilePicture];
    cell.Nickname.text = self.RequestList[indexPath.row].NickName;
    
    return cell;
}

- (void)getNewFriendRequest:(NSNotification *)notification
{
    NSArray *messages = [notification object];
    
    for (int i=0; i<messages.count; i++)
    {
        MessageModel *message = messages[i];
        NSLog(@"%@", message);
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        NSString *url = [URLHelper getURLwithPath:[[NSString alloc] initWithFormat:@"/account/info/user/%@", message.SenderID]];
        
        [manager GET:url parameters:nil progress:nil
             success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                 NSLog(@"%@", responseObject);
                 if ([responseObject[@"state"] isEqualToString:@"ok"])
                 {
                     
                     UserModel* friend = [[UserModel alloc] initWithProperties:responseObject[@"data"][@"Username"]
                                                                            NickName:responseObject[@"data"][@"Nickname"]
                                                                          RemarkName:responseObject[@"data"][@"Username"]
                                                                              Gender:responseObject[@"data"][@"Gender"]
                                                                          Birthplace:responseObject[@"data"][@"Region"]
                                                                      ProfilePicture:responseObject[@"data"][@"Avatar"]];
                     [self.RequestList addObject:friend];
                     NSLog(@"%lu", (unsigned long)self.RequestList.count);
                     [self.FriendRequestTableView reloadData];
                 }
                 else
                 {
                     NSLog(@"%@", responseObject[@"msg"]);
                 }
             }
             failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                
                 NSLog(@"%@", error.localizedDescription);
             }];

        //
        //[self.FriendRequestTableView reloadData];
    }
}

- (IBAction)AcceptRequest:(id)sender
{
    
    
    UIButton *AcceptButton = sender;
    FriendRequestTableViewCell *cell = [[AcceptButton superview] superview];
    NSIndexPath *indexPath = [self.FriendRequestTableView indexPathForCell:cell];
    cell.AcceptButton.enabled = NO;
    cell.RejectButton.enabled = NO;
    NSString* FriendID = self.RequestList[indexPath.row].UserID;
    NSDictionary* params = @{@"cid":@0, @"to":FriendID, @"info":@"hello"};
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    NSString *url = [URLHelper getURLwithPath:@"/content/add"];
    
    [manager GET:url parameters:params progress:nil
     success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
         if([responseObject[@"state"] isEqualToString:@"ok"])
         {
             NSLog(@"%@", responseObject[@"msg"]);
             cell.RejectButton.backgroundColor = [UIColor grayColor];
         }
         else
         {
             NSLog(@"%@", responseObject[@"msg"]);
             cell.AcceptButton.enabled = YES;
             cell.RejectButton.enabled = YES;
         }
     }
     failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
         NSLog(@"%@", error.localizedDescription);
     }];
    
}

- (IBAction)RejectFriend:(id)sender
{
    //https://stackoverflow.com/questions/31649220/detect-tap-on-a-button-in-uitableviewcell-for-uitableview-containing-multiple-se/31649321#31649321
    CGPoint touchPoint = [sender convertPoint:CGPointZero toView:self.FriendRequestTableView]; // maintable --> replace your tableview name
    NSIndexPath *clickedButtonIndexPath = [self.FriendRequestTableView indexPathForRowAtPoint:touchPoint];
    
    //FriendRequestTableViewCell *cell = [self tableView:self.FriendRequestTableView cellForRowAtIndexPath:clickedButtonIndexPath];
    UIButton *RejectButton = sender;
    FriendRequestTableViewCell *cell = [[RejectButton superview] superview];
    cell.AcceptButton.backgroundColor = [UIColor grayColor];
    cell.RejectButton.backgroundColor = [UIColor grayColor];
    cell.AcceptButton.enabled = NO;
    cell.RejectButton.enabled = NO;
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
