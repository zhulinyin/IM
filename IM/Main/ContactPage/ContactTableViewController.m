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

- (void)viewDidLoad {
    [super viewDidLoad];
    self.ContactsArray = [NSMutableArray array];
    [self initializeTestData];
    
    [self addObserver:self forKeyPath:@"ContactsArray" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    
    [self getContactsFromServer];
    
    self.ContactTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    //self.ContactTableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectZero];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.searchResultsUpdater = self;
    self.searchController.dimsBackgroundDuringPresentation = NO;
    self.searchController.searchBar.delegate = self;
    //self.tableView.tableHeaderView = self.searchController.searchBar;
    self.definesPresentationContext = YES;
    //[self.searchController.searchBar sizeToFit];
}

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController
{
    // do nothing, search happens in textDidChanged
}


- (void)getContactsFromServer
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    NSString *url = [URLHelper getURLwithPath:@"/contact/info"];
    
    [manager GET:url parameters:nil progress:nil
         success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
             if([responseObject[@"state"] isEqualToString:@"ok"])
             {
                 for (id user in responseObject[@"data"])
                 {
                     UserModel* ContactUser = [[UserModel alloc] initWithProperties:user[@"Friend"] NickName:user[@"Username"] RemarkName:user[@"Username"] Gender:@"male" Birthplace:@"Jodl" ProfilePicture:@"teemo.jpg"];
                     [self willChangeValueForKey:@"ContactsArray"];
                     [self.ContactsArray addObject:ContactUser];
                     [self didChangeValueForKey:@"ContactsArray"];
                     
                     
                 }
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

- (void)initializeTestData
{
    UserModel* TestUser1 = [[UserModel alloc] initWithProperties:@"123" NickName:@"teemo" RemarkName:@"teemo" Gender:@"male" Birthplace:@"Jodl" ProfilePicture:@"teemo.jpg"];
    UserModel* TestUser2 = [[UserModel alloc] initWithProperties:@"321" NickName:@"peppa" RemarkName:@"peppa" Gender:@"female" Birthplace:@"UK" ProfilePicture:@"peppa.jpg"];
    [self willChangeValueForKey:@"ContactsArray"];
    [self.ContactsArray addObject:TestUser1];
    [self.ContactsArray addObject:TestUser2];
    [self didChangeValueForKey:@"ContactsArray"];
}

#pragma mark - Table view data source

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

- (UITableViewCell *)tableView:(UITableView *)tableView
cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *reuseID = @"ContactTableCell";
    ContactTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseID];

    if (cell == nil)
    {
        cell = [[ContactTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseID];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    if (indexPath.section == 0)
    {
        if (self.isSearching)
            cell.ContactName.text = [[NSString alloc] initWithFormat:@"查找用户：%@", self.searchController.searchBar.text];
        else
            cell.ContactName.text = @"新的好友";
    }
    else if (indexPath.section == 1)
    {
        UserModel* friend;
        if (self.isSearching)
            friend = self.searchResults[indexPath.row];
        else
            friend = self.ContactsArray[indexPath.row];
        cell.ContactProfilePicture.image = [UIImage imageNamed:friend.ProfilePicture];
        cell.ContactName.text = friend.NickName;
    }
    
    return cell;
}


- (IBAction)showSearchBar:(id)sender
{
    self.ContactTableView.tableHeaderView = self.searchController.searchBar;
    self.searchController.active = YES;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    self.ContactTableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectZero];
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

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"ContactsArray"])
    {
        //NSLog(@"contacts: %@", self.ContactsArray);
        [self.tableView reloadData];
        
    }
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && self.isSearching == NO)
    {
        UIStoryboard *FriendRequestStoryboard = [UIStoryboard storyboardWithName:@"FriendRequestPage" bundle:nil];
        [self.navigationController pushViewController:FriendRequestStoryboard.instantiateInitialViewController animated:YES];
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
                    UserModel* searchedUser = [[UserModel alloc] initWithProperties:responseObject[@"data"][@"Username"]
                                                                  NickName:responseObject[@"data"][@"Nickname"]
                                                                RemarkName:responseObject[@"data"][@"Username"]
                                                                    Gender:responseObject[@"data"][@"Gender"]
                                                                Birthplace:responseObject[@"data"][@"Region"]
                                                                     ProfilePicture:@"peppa"];
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
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:msg delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                    [alertView show];
                }
            }
            failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                NSLog(@"search User fail");
                NSLog(@"%@", error.localizedDescription);
                NSString* msg = [[NSString alloc] initWithFormat:@"用户%@不存在", self.searchController.searchBar.text];
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:msg delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                [alertView show];
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
