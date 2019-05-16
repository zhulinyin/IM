//
//  InfoViewController.m
//  IM
//
//  Created by zhulinyin on 2019/4/27.
//  Copyright © 2019 zhulinyin. All rights reserved.
//

#import "InfoViewController.h"

@interface InfoViewController ()<UITableViewDelegate, UITableViewDataSource>

@property(nonatomic, strong) UITableView *tableView;
@property(nonatomic, strong) NSMutableArray<NSString*> *titleList;
@property(nonatomic, strong) NSMutableArray<NSString*> *contentList;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;
@property (weak, nonatomic) IBOutlet UIButton *logoutButton;

@end

@implementation InfoViewController

- (instancetype) init {
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // [self.navigationController setNavigationBarHidden:NO animated:NO];
    self.navigationController.navigationBarHidden = NO;
    // Do any additional setup after loading the view.
    if (self.User == nil)
    {
        self.User = [[UserManager getInstance] getLoginModel];
    }
    self.ProfilePicture.image = [UIImage imageNamed:self.User.ProfilePicture];
    self.NickName.text = self.User.NickName;
    self.ID.text = self.User.UserID;
    self.Gender.text = self.User.Gender;
    self.Birthplace.text = self.User.Birthplace;
    
    if (self.User == [[UserManager getInstance] getLoginModel])
        self.sendButton.hidden = YES;
    else
        self.logoutButton.hidden = YES;
        
    
    
    self.navigationItem.title = @"个人信息";
    // 获取屏幕的宽高
    CGRect rect = [[UIScreen mainScreen] bounds];
    CGSize size = rect.size;
    CGFloat width = size.width;
    CGFloat height = size.height;
    
    self.tableView = ({
        UITableView *tableView = [[UITableView alloc]
                                  initWithFrame:CGRectMake(0, 50, width, height/2+70) style:UITableViewStylePlain];
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView;
    });
    // 取消多余的横线
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    [self.view addSubview:self.tableView];
    
    [self loadData];
}

- (void)loadData {
    self.titleList = [NSMutableArray array];
    self.contentList = [NSMutableArray array];
    [self.titleList addObjectsFromArray:[[NSArray alloc] initWithObjects:@"头像", @"昵称", @"账号", @"性别", @"地区",nil]];
    [self.contentList addObjectsFromArray:[[NSArray alloc] initWithObjects:@"小猪佩奇", @"Peppa", @"peppy", @"female", @"UK",nil]];
}

#pragma mark ------------ UITableViewDataSource ------------------

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.titleList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellID = [NSString stringWithFormat:@"cellID:%zd", indexPath.section];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (nil == cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    
    // cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.text = self.titleList[indexPath.row];
    cell.textLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:18.f];
    if (indexPath.row != 0){
        UILabel *rightLabel = [[UILabel alloc]initWithFrame:CGRectMake(0,0,70,55)];
        rightLabel.text = self.contentList[indexPath.row];
        rightLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14.f];
        rightLabel.textColor = [UIColor grayColor];
        cell.accessoryView = rightLabel;
        //cell.accessoryView.backgroundColor = [UIColor redColor];   //加上红色容易看清楚
    }
    else{
        cell.accessoryView = ({
            UIImageView *imgV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:self.User.ProfilePicture]];
            CGRect frame = imgV.frame;
            frame = CGRectMake(0, 0, 100, 55);
            imgV.frame = frame;
            [imgV setContentMode:UIViewContentModeScaleAspectFit];
            imgV;
        });
    }
    return cell;
}

#pragma mark ------------ UITableViewDelegate ------------------

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    InfoViewController *controller = [[InfoViewController alloc] init];
    controller.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:controller animated:YES];
}


- (IBAction)logout:(id)sender
{
    [[UserManager getInstance] logout];
}
- (IBAction)sendMessage:(id)sender
{
    ChatViewController *viewController = [[ChatViewController alloc] initWithContact:self.User];
    viewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:viewController animated:YES];
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
