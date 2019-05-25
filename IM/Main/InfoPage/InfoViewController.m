//
//  InfoViewController.m
//  IM
//
//  Created by zhulinyin on 2019/4/27.
//  Copyright © 2019 zhulinyin. All rights reserved.
//

#import "InfoViewController.h"
#import "InfoModifiedViewController.h"
#import<Photos/Photos.h>

@interface InfoViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

//@property(nonatomic, strong) UITableView *tableView;
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
    
    /*self.tableView = ({
        UITableView *tableView = [[UITableView alloc]
                                  initWithFrame:CGRectMake(0, 50, width, height/2+70) style:UITableViewStylePlain];
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView;
    });*/
    [self.tableView setFrame:CGRectMake(0, 50, width, height/2+70)];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    // 取消多余的横线
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    //[self.view addSubview:self.tableView];
    
    [self loadData];
}

- (void)loadData {
    self.titleList = [NSMutableArray array];
    self.contentList = [NSMutableArray array];
    [self.titleList addObjectsFromArray:[[NSArray alloc] initWithObjects:@"头像", @"昵称", @"账号", @"性别", @"地区",nil]];
    [self.contentList addObjectsFromArray:[[NSArray alloc] initWithObjects:@"小猪佩奇", self.User.NickName, self.User.UserID, self.User.Gender, self.User.Birthplace, nil]];
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
    // 处理跳转情况
    if (self.User == [[UserManager getInstance] getLoginModel]){
        NSString* str = self.titleList[indexPath.row];
        // 处理头像的情况
        if([str isEqualToString:@"头像"]){
            // 修改本地显示
            [self alterHeadPortrait];
            
            // 上传到云端
            
        }
        InfoModifiedViewController *controller = [[InfoModifiedViewController alloc] initWithString:str];
        
        __weak typeof(self) mainPtr = self;
        // Block回调接收数据
        [controller setData:^(UserModel* user){
            mainPtr.User = user;
            // 回调处理事件
            mainPtr.contentList = [NSMutableArray array];
            [mainPtr.contentList addObjectsFromArray:[[NSArray alloc] initWithObjects:@"小猪佩奇", self.User.NickName, self.User.UserID, self.User.Gender, self.User.Birthplace, nil]];
            NSLog(user.Birthplace);
            [mainPtr.tableView reloadData];
        }];
        controller.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:controller animated:YES];
    }
    else{
        NSLog(@"不能修改别的用户信息");
    }
}

- (IBAction)logout:(id)sender
{
    [[UserManager getInstance] logout];
}

- (IBAction)sendMessage:(id)sender
{
    NSString *sendId = [[UserManager getInstance] getLoginModel].UserID;
    NSString *chatId = self.User.UserID;
    NSString *tableName = [sendId intValue] < [chatId intValue] ? [[sendId stringByAppendingString:@"-"] stringByAppendingString:chatId] : [[chatId stringByAppendingString:@"-"] stringByAppendingString:sendId];
    [[DatabaseHelper getInstance] createMessageTable:tableName];
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

- (void)alterHeadPortrait{
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    // 判断授权情况
    if (status == PHAuthorizationStatusRestricted ||
        status == PHAuthorizationStatusDenied) {
        //无权限  这个时候最好给个提示，用户点击是就跳转到应用的权限设置内 用户动动小手即可允许权限
        NSLog(@"no auth");
    }
    else{
        NSLog(@"has auth!!!!!");
    }
    
    //初始化提示框
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    //按钮：从相册选择，类型：UIAlertActionStyleDefault
    [alert addAction:[UIAlertAction actionWithTitle:@"从相册选择" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        //初始化UIImagePickerController
        UIImagePickerController *PickerImage = [[UIImagePickerController alloc]init];
        //获取方式1：通过相册（呈现全部相册），UIImagePickerControllerSourceTypePhotoLibrary
        //获取方式2，通过相机，UIImagePickerControllerSourceTypeCamera
        //获取方法3，通过相册（呈现全部图片），UIImagePickerControllerSourceTypeSavedPhotosAlbum
        PickerImage.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        //允许编辑，即放大裁剪
        PickerImage.allowsEditing = YES;
        //自代理
        PickerImage.delegate = self;
        //页面跳转
        [self presentViewController:PickerImage animated:YES completion:nil];
    }]];
    //按钮：取消，类型：UIAlertActionStyleCancel
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
    
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *) info{
    //定义一个newPhoto，用来存放我们选择的图片。
    UIImage *newPhoto = [info objectForKey:@"UIImagePickerControllerEditedImage"];
    NSLog(@"success pick");
    [self dismissViewControllerAnimated:YES completion:nil];
    // self.User.ProfilePicture = [info objectForKey:@"UIImagePickerControllerEditedImage"];
    [self.tableView reloadData];
    // 测试，成功读取图片
//    UIImageView *imageView = [[UIImageView alloc] initWithImage:newPhoto];
//    [imageView setFrame:CGRectMake(0, 0, newPhoto.size.width, newPhoto.size.height)];
//    [self.view addSubview:imageView];
}

@end
