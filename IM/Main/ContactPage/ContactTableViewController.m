//
//  ContactTableViewController.m
//  Main Page
//
//  Created by Ray Shaw on 2019/4/25.
//  Copyright © 2019年 Ray Shaw. All rights reserved.
//

#import "ContactTableViewController.h"
#import "ContactTableViewCell.h"

@interface ContactTableViewController () <UISearchDisplayDelegate, UISearchBarDelegate>

@property (nonatomic, strong) NSMutableArray<UserModel*> *ContactsArray;
@property (nonatomic, strong) NSArray *searchResults;
@property (strong, nonatomic) IBOutlet UITableView *ContactTableView;
@property (nonatomic, strong) UserModel* SelectiveUser;
@property (strong, nonatomic) UISearchController *searchController;
@property BOOL isSearching;

@end


@implementation ContactTableViewController

//设置状态栏颜色
- (void)setStatusBarBackgroundColor:(UIColor *)color {
    
    UIView *statusBar = [[[UIApplication sharedApplication] valueForKey:@"statusBarWindow"] valueForKey:@"statusBar"];
    if ([statusBar respondsToSelector:@selector(setBackgroundColor:)]) {
        statusBar.backgroundColor = color;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //initializing
    [self getFriendsFromDatabase];
    
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.searchResultsUpdater = self;
    self.searchController.dimsBackgroundDuringPresentation = NO;
    self.searchController.searchBar.delegate = self;
    self.definesPresentationContext = YES;
    
    self.navigationController.navigationBar.backgroundColor = [UIColor colorWithRed:0 green:111/255.0f blue:236/255.0f alpha:1.0f];
    [self setStatusBarBackgroundColor:[UIColor colorWithRed:0 green:111/255.0f blue:236/255.0f alpha:1.0f]];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationItem.title = @"联系人";
    NSDictionary *attributes=[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],NSForegroundColorAttributeName,nil];
    [self.navigationController.navigationBar setTitleTextAttributes:attributes];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    //observer
    [self addObserver:self forKeyPath:@"ContactsArray" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newFriendConfirm:) name:@"newFriendConfirm" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(friendComing:) name:@"friendComing" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateUnreadRequest:) name:@"updateUnreadRequest" object:nil];
    
    // view relative
    self.ContactTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}


- (void)friendComing:(NSNotification *)notification
{
    [self willChangeValueForKey:@"ContactsArray"];
    [self.ContactsArray addObject:notification.object];
    [self didChangeValueForKey:@"ContactsArray"];
}

- (void)updateUnreadRequest:(NSNotification *)notification
{
    [self.ContactTableView reloadData];
}

- (void)newFriendConfirm:(NSNotification *)notification
{
    NSString* newFriendID = notification.object;
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    NSString *url = [URLHelper getURLwithPath:[[NSString alloc] initWithFormat:@"/account/info/user/%@", newFriendID]];
    
    [manager GET:url parameters:nil progress:nil
         success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
             if ([responseObject[@"msg"] isEqualToString:@"ok"])
             {
                 UserModel* newFriend =
                 [[UserModel alloc] initWithProperties:responseObject[@"data"][@"Username"]
                                    NickName:responseObject[@"data"][@"Nickname"]
                                    RemarkName:responseObject[@"data"][@"Username"]
                                    Gender:responseObject[@"data"][@"Gender"]
                                    Birthplace:responseObject[@"data"][@"Region"]
                                    ProfilePicture:responseObject[@"data"][@"Avatar"]];
                 [[DatabaseHelper getInstance] insertFriendWithFriend:newFriend];
                 [self willChangeValueForKey:@"ContactsArray"];
                 [self.ContactsArray addObject:newFriend];
                 [self didChangeValueForKey:@"ContactsArray"];
             }
             else
             {
                 NSLog(@"error: %@", responseObject[@"msg"]);
             }
         }
         failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
             NSLog(@"%@", error.localizedDescription);
         }];
    
}

// search delegate begin
- (void)updateSearchResultsForSearchController:(UISearchController *)searchController
{
    // do nothing, search happens in textDidChanged
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if (searchText.length == 0)
    {
        self.isSearching = false;
        [self.searchController.searchBar endEditing:YES];
        
    }
    else
    {
        self.isSearching = true;
        NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"UserID contains[c] %@", searchText];
        self.searchResults = [self.ContactsArray filteredArrayUsingPredicate:resultPredicate];
    }
    [self.tableView reloadData];
}

- (IBAction)showSearchBar:(id)sender
{
    self.ContactTableView.tableHeaderView = self.searchController.searchBar;
    self.searchController.active = YES;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    self.ContactTableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectZero];
    self.isSearching = false;
    [self.ContactTableView reloadData];
}

// search end

#pragma mark - Table view data source
//table view delegate begin
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
        return 1;
    
    if (self.isSearching)
        return self.searchResults.count;
    else
        return self.ContactsArray.count;
}

- (NSString* )tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (!self.isSearching && section == 1)
        return @"我的好友";
    return @"";
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *reuseID = @"ContactTableCell233";
    ContactTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseID];

    if (cell == nil)
    {
        cell = [[ContactTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseID];
    }
    
    if (indexPath.section == 0)
    {
        if (self.isSearching)
        {
            [cell setTitle:[[NSString alloc] initWithFormat:@"查找用户：%@", self.searchController.searchBar.text]];
            [cell setPictureOfAsset:@"search"];
        }
        else
        {
            [cell setTitle:@"新的好友"];
            [cell setPictureOfAsset:@"friendRequest"];

            NSInteger unreadNum = [[NSUserDefaults standardUserDefaults] integerForKey:[NSString stringWithFormat:@"%@unreadRequestNum", [UserManager getInstance].getLoginModel.UserID]];
            [cell setUnreadRequestNum:unreadNum];
        }
    }
    else if (indexPath.section == 1)
    {
        UserModel* friend;
        if (self.isSearching)
            friend = self.searchResults[indexPath.row];
        else
            friend = self.ContactsArray[indexPath.row];

        [cell setPictureWithURL:friend.ProfilePicture];
        [cell setTitle:friend.NickName];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && self.isSearching == NO)
    {
        UIStoryboard *FriendRequestStoryboard = [UIStoryboard storyboardWithName:@"FriendRequestPage" bundle:nil];
        FriendRequestTableViewController* FriendVC = FriendRequestStoryboard.instantiateInitialViewController;
        FriendVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:FriendVC animated:YES];
    }
    else if (indexPath.section == 0 && self.isSearching == YES)
    {
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        NSString *url = [URLHelper getURLwithPath:[[NSString alloc] initWithFormat:@"/account/info/user/%@", self.searchController.searchBar.text]];
        
        [manager GET:url parameters:nil progress:nil
             success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                 if ([responseObject[@"msg"] isEqualToString:@"ok"])
                 {
                     NSLog(@"here");
                     UserModel* searchedUser =
                     [[UserModel alloc] initWithProperties:responseObject[@"data"][@"Username"]
                                        NickName:responseObject[@"data"][@"Nickname"]
                                        RemarkName:responseObject[@"data"][@"Username"]
                                        Gender:responseObject[@"data"][@"Gender"]
                                        Birthplace:responseObject[@"data"][@"Region"]
                                        ProfilePicture:responseObject[@"data"][@"Avatar"]];
                     UIStoryboard *searchUserInfoStoryboard = [UIStoryboard storyboardWithName:@"Info" bundle:nil];
                     
                     InfoViewController *InfoVC = [searchUserInfoStoryboard instantiateViewControllerWithIdentifier:@"personal_info"];
                     InfoVC.User = searchedUser;
                     InfoVC.isFriend = NO;
                     InfoVC.hidesBottomBarWhenPushed = YES;
                     [self.navigationController pushViewController:InfoVC animated:YES];
                 }
                 else
                 {
                     NSString* msg = [[NSString alloc] initWithFormat:@"用户%@不存在", self.searchController.searchBar.text];
                     UIAlertController * alert = [UIAlertController
                                                  alertControllerWithTitle:msg
                                                  message:@""
                                                  preferredStyle:UIAlertControllerStyleAlert];
                     
                     UIAlertAction* yesButton = [UIAlertAction
                                                 actionWithTitle:@"确定"
                                                 style:UIAlertActionStyleDefault
                                                 handler:^(UIAlertAction * action) {
                                                     //Handle your yes please button action here
                                                 }];
                     
                     [alert addAction:yesButton];
                     
                     
                     [self presentViewController:alert animated:YES completion:nil];
                    
                 }
             }
             failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                 NSLog(@"search User fail");
                 NSLog(@"%@", error.localizedDescription);
                 NSString* msg = [[NSString alloc] initWithFormat:@"用户%@不存在", self.searchController.searchBar.text];
                 UIAlertController * alert = [UIAlertController
                                              alertControllerWithTitle:msg
                                              message:@""
                                              preferredStyle:UIAlertControllerStyleAlert];
                 
                 UIAlertAction* yesButton = [UIAlertAction
                                             actionWithTitle:@"确定"
                                             style:UIAlertActionStyleDefault
                                             handler:^(UIAlertAction * action) {
                                                 //Handle your yes please button action here
                                             }];
                 
                 [alert addAction:yesButton];
                 
                 
                 [self presentViewController:alert animated:YES completion:nil];
                 
             }];
    }
    else if (indexPath.section == 1)
    {
        UIStoryboard *searchUserInfoStoryboard = [UIStoryboard storyboardWithName:@"Info" bundle:nil];
        
        InfoViewController *InfoVC = [searchUserInfoStoryboard instantiateViewControllerWithIdentifier:@"personal_info"];
        InfoVC.hidesBottomBarWhenPushed = YES;
        InfoVC.isFriend = YES;
        if (self.isSearching)
            InfoVC.User = self.searchResults[indexPath.row];
        else
            InfoVC.User = self.ContactsArray[indexPath.row];
        [self.navigationController pushViewController:InfoVC animated:YES];
    }
}
// table view delegate end


// delete swipe
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return YES if you want the specified item to be editable.
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        //add code here for when you hit delete
        UserModel* selectedFriend = self.ContactsArray[indexPath.row];
        
        NSLog(@"%@", selectedFriend);
        
        NSString* msg = [[NSString alloc] initWithFormat:@"确认删除%@?", selectedFriend.NickName];
        UIAlertController * alert = [UIAlertController
                                     alertControllerWithTitle:msg
                                     message:@""
                                     preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* yesButton = [UIAlertAction
                                    actionWithTitle:@"删除"
                                    style:UIAlertActionStyleDestructive
                                    handler:^(UIAlertAction * action) {
                                        //Handle your yes please button action here
                                        [self deleteFriend:selectedFriend];
                                    }];
        
        UIAlertAction* noButton = [UIAlertAction
                                   actionWithTitle:@"取消"
                                   style:UIAlertActionStyleCancel
                                   handler:^(UIAlertAction * action) {
                                       //Handle your no please button action here
                                   }];
        
        [alert addAction:yesButton];
        [alert addAction:noButton];
        
        
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (void)deleteFriend:(UserModel* )friend
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    NSString *url = [URLHelper getURLwithPath:@"/contact/delete"];
    
    NSDictionary* parameters = @{@"username": friend.UserID};
    [manager POST:url parameters:parameters progress:nil
         success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
             NSLog(@"%@", responseObject);
             if ([responseObject[@"state"] isEqualToString:@"ok"])
             {
                 [[DatabaseHelper getInstance] deleteFriendByID:friend.UserID];
                 NSLog(@"delete %@ successfully", friend.UserID);
                 [self getFriendsFromDatabase];
             }
             else
             {
                 NSLog(@"%@", responseObject[@"msg"]);
             }
         }
         failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
             
             NSLog(@"%@", error.localizedDescription);
         }];
}
// delete swipe end

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"ContactsArray"])
    {
        [self.ContactTableView reloadData];
    }
}

- (IBAction)freshContactList:(id)sender
{
    [[DatabaseHelper getInstance] rebuildFriendListTable];
    [[DatabaseHelper getInstance] getFriendsFromServer];
    self.ContactsArray = [[NSMutableArray alloc] init];
}




-(void)getFriendsFromDatabase
{
    self.ContactsArray = [[DatabaseHelper getInstance] getAllFriends];
}

/*
- (BOOL) shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    if ( [identifier isEqualToString:@"ShowUserInfo"])
    {
        NSIndexPath *indexPath = [self.ContactTableView indexPathForCell:sender];
        if (indexPath.section == 0)
            return NO;
        return YES;
    }
    return YES;
}*/

/*
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    if ([[segue identifier] isEqualToString:@"ShowUserInfo"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        InfoViewController *InfoVC = [segue destinationViewController];
        InfoVC.hidesBottomBarWhenPushed = YES;
        InfoVC.isFriend = YES;
        InfoVC.User = self.ContactsArray[indexPath.row];
    }
    // Pass the selected object to the new view controller.
 }
 */





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

@end
