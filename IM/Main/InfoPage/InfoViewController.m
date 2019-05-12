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

@end

@implementation InfoViewController

- (instancetype) init_self {
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if (self.User == nil)
    {
        self.User = [[UserModel alloc] initWithProperties:@"peppa ID" NickName:@"Peppa" RemarkName:@"peppy" Gender:@"female" Birthplace:@"UK" ProfilePicture:@"peppa.jpg"];
    }
    self.ProfilePicture.image = [UIImage imageNamed:self.User.ProfilePicture];
    self.NickName.text = self.User.NickName;
    self.ID.text = self.User.UserID;
    self.Gender.text = self.User.Gender;
    self.Birthplace.text = self.User.Birthplace;
    /*[self.NickName sizeToFit];
    [self.ID sizeToFit];
    [self.Gender sizeToFit];
    [self.Birthplace sizeToFit];*/
    
    self.navigationItem.title = @"个人信息";
    
    self.tableView = ({
        UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView;
    });
    // [self.view addSubview:self.tableView];
    
    [self loadData];
}

- (void)loadData {
    self.contentList = [NSMutableArray array];
    [self.contentList addObjectsFromArray:[[NSArray alloc] initWithObjects:@"头像", @"昵称", @"账号", @"性别", @"地区",nil]];
    self.titleList = [NSMutableArray array];
    [self.titleList addObjectsFromArray:[[NSArray alloc] initWithObjects:@"小猪佩奇", @"Peppa", @"peppy", @"female", @"UK",nil]];
}

#pragma mark ------------ UITableViewDataSource ------------------

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.contentList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellID = [NSString stringWithFormat:@"cellID:%zd", indexPath.section];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (nil == cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    
    //        cell.imageView.image = [UIImage imageNamed:@"icon_directory.jpg"];
    cell.textLabel.text = self.contentList[indexPath.row];
    
    UILabel *rightLabel = [[UILabel alloc]initWithFrame:CGRectMake(0,0,70,45)];
    rightLabel.text = self.titleList[indexPath.row];
    cell.accessoryView = rightLabel;
    cell.accessoryView.backgroundColor = [UIColor redColor];   //加上红色容易看清楚
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

#pragma mark ------------ UITableViewDelegate ------------------

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    InfoViewController *controller = [[InfoViewController alloc] init];
    controller.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:controller animated:YES];
}


- (IBAction)logout:(id)sender {
    NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:defaultConfigObject delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    NSURL *url = [NSURL URLWithString:@"http://118.89.65.154:8000/account/logout/"];
    NSURLSessionDataTask *task = [session dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if(error == nil) {
            if(NSClassFromString(@"NSJSONSerialization")) {
                NSError *e = nil;
                id object = [NSJSONSerialization JSONObjectWithData:data options:0 error:&e];
                if(e) {
                    NSLog(@"error");
                }
                if([object isKindOfClass:[NSDictionary class]]) {
                    NSDictionary *result = object;
                    if([result[@"state"] isEqualToString:@"ok"]) {
                        NSLog(@"logout success");
                        UIStoryboard *indexStoryboard = [UIStoryboard storyboardWithName:@"Index" bundle:nil];
                        [UIApplication sharedApplication].keyWindow.rootViewController = indexStoryboard.instantiateInitialViewController;
                    }
                    else {
                        NSLog(@"logout fail");
                    }
                }
                else {
                    NSLog(@"Not dictionary");
                }
            }
        }
        else {
            NSLog(@"网络异常");
        }
    }];
    [task resume];
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
