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
@property (weak, nonatomic) IBOutlet UIBarButtonItem *AddFriendButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *AddComfirmButton;
@property (weak, nonatomic) IBOutlet UITextField *FriendID;
@property (weak, nonatomic) IBOutlet UISearchBar *SearchBar;
@property (strong, nonatomic) IBOutlet UISearchDisplayController *SearchBarController;
@property (strong, nonatomic) UISearchController *searchController;

@end


@implementation ContactTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.ContactsArray = [NSMutableArray array];
    [self initializeTestData];
    
    [self addObserver:self forKeyPath:@"ContactsArray" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    
    [self getContactsFromServer];
    
    //self.SearchBarController.displaysSearchBarInNavigationBar = YES;
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
    self.tableView.tableHeaderView = self.searchController.searchBar;
    self.definesPresentationContext = YES;
    [self.searchController.searchBar sizeToFit];
}

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController
{
    NSString *searchString = searchController.searchBar.text;
    [self searchDisplayController:self.searchController shouldReloadTableForSearchString:searchString];
    [self.tableView reloadData];
}


- (void)getContactsFromServer
{
    void (^showContacts)(id) = ^void (id object)
    {
        NSLog(@"%@", [NSString stringWithFormat:@"dictionary:%@", object ]);
        
        for (id user in object[@"data"])
        {
             UserModel* ContactUser = [[UserModel alloc] initWithProperties:user[@"Friend"] NickName:user[@"Username"] RemarkName:user[@"Username"] Gender:@"male" Birthplace:@"Jodl" ProfilePicture:@"teemo.jpg"];
            [self willChangeValueForKey:@"ContactsArray"];
            [self.ContactsArray addObject:ContactUser];
            [self didChangeValueForKey:@"ContactsArray"];
            
            
        }
        //[self initializeFakeData];
    };
    
    [SessionHelper sendRequest:@"/contact/info" method:@"get" parameters:@"" handler:showContacts];
    
    
}

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"UserID contains[c] %@", searchText];
    self.searchResults = [self.ContactsArray filteredArrayUsingPredicate:resultPredicate];
    
    [self.SearchBarController.searchResultsTableView reloadData];
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString
                               scope:[[self.SearchBarController.searchBar scopeButtonTitles]
                                      objectAtIndex:[self.SearchBarController.searchBar
                                                     selectedScopeButtonIndex]]];
    
    return YES;
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.SearchBarController.searchResultsTableView)
        return self.searchResults.count;
    else
        return self.ContactsArray.count;
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
    
    UserModel* friend;
    if (tableView == self.searchDisplayController.searchResultsTableView)
        friend = self.searchResults[indexPath.row];
    else
        friend = self.ContactsArray[indexPath.row];

    cell.ContactProfilePicture.image = [UIImage imageNamed:friend.ProfilePicture];
    cell.ContactName.text = friend.NickName;
    return cell;
}

- (IBAction)AddFriend:(id)sender
{
    NSString* FriendID = self.FriendID.text;
    
    /*void (^registerEvent)(id) = ^void (id object)
    {
        NSDictionary *result = object;
        if([result[@"state"] isEqualToString:@"ok"])
        {
            NSLog(@"Found User");
            NSDictionary *friendJSON = result[@"data"];
            UserModel* friendModel = [[UserModel alloc] initWithProperties:friendJSON[@"Username"] NickName:friendJSON[@"Nickname"] RemarkName:friendJSON[@"Nickname"] Gender:@"male" Birthplace:@"Jodl" ProfilePicture:@"teemo.jpg"];
            UIStoryboard *infoStoryboard = [UIStoryboard storyboardWithName:@"Info" bundle:nil];
            InfoViewController *infoVC = [infoStoryboard instantiateViewControllerWithIdentifier:@"personal_info"];
            infoVC.User = friendModel;
            [self.navigationController pushViewController:infoVC animated:YES];
            
        }
        else
        {
            NSLog(@"User not exist");
        }
    };
    
    NSString *path = [[NSString alloc] initWithFormat:@"/account/info/user/%@", FriendID];
    NSString *params = [[NSString alloc] initWithFormat:@"cid=0username=%@&password=%@", FriendID, @"Hello"];
    [SessionHelper sendRequest:path method:@"get" parameters:params handler:registerEvent];*/
    UIStoryboard *infoStoryboard = [UIStoryboard storyboardWithName:@"Info" bundle:nil];
    InfoViewController *infoVC = [infoStoryboard instantiateViewControllerWithIdentifier:@"personal_info"];
    UserModel* TestUser2 = [[UserModel alloc] initWithProperties:@"321" NickName:@"peppa" RemarkName:@"peppa" Gender:@"female" Birthplace:@"UK" ProfilePicture:@"peppa.jpg"];;
    infoVC.User = TestUser2;
    [self.navigationController pushViewController:infoVC animated:YES];
}

- (IBAction)showSearchBar:(id)sender
{
    //self.SearchBarController.displaysSearchBarInNavigationBar = YES;
    //self.ContactTableView.tableHeaderView = self.SearchBar;
    //self.SearchBarController.active = YES;
    
}

/*
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.SelectiveUser = self.ContactsArray[indexPath.row];
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


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    if ([[segue identifier] isEqualToString:@"ShowUserInfo"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        InfoViewController *InfoVC = [segue destinationViewController];
        InfoVC.hidesBottomBarWhenPushed = YES;
        InfoVC.User = self.ContactsArray[indexPath.row];
    }
    // Pass the selected object to the new view controller.
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"ContactsArray"])
    {
        //NSLog(@"contacts: %@", self.ContactsArray);
        [self.tableView reloadData];
        
    }
}
@end
