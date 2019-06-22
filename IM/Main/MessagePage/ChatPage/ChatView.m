//
//  ChatView.m
//  IM
//
//  Created by zhulinyin on 2019/5/8.
//  Copyright © 2019 zhulinyin. All rights reserved.
//

#import "ChatView.h"

@interface ChatView () <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>

@property (nonatomic, strong) UITableView *chatTable;
@property (nonatomic, strong) UITextField *inputText;
@property (nonatomic, assign) CGFloat keyboardHeight;


@end

@implementation ChatView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.chatMsg = [NSMutableArray array];
        [self setupSubViews];
    }
    return self;
}

- (void)addMessage:(MessageModel *)message {
    [self.chatMsg addObject:message];
    [self.chatTable reloadData];
    [self tableViewScrollToBottom];
}

- (void)setChatMsg:(NSMutableArray *)chatMsg {
    _chatMsg = chatMsg;
    [self.chatTable reloadData];
    [self tableViewScrollToBottom];
}

- (void)setupSubViews {
    self.chatTable = [[UITableView alloc] init];
    self.chatTable.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 50);
    self.chatTable.delegate = self;
    self.chatTable.dataSource = self;
    self.chatTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.chatTable.allowsSelection = NO;
    [self addSubview:self.chatTable];
    
    self.inputText = [[UITextField alloc] init];
    self.inputText.frame = CGRectMake(10, SCREEN_HEIGHT - 45, SCREEN_WIDTH-20-60, 40);
    self.inputText.returnKeyType = UIReturnKeySend;
    self.inputText.delegate = self;
    self.inputText.backgroundColor = [UIColor whiteColor];
    self.inputText.layer.cornerRadius = 5;
    [self addSubview:self.inputText];
    
    self.imageButton = [UIButton buttonWithType:UIButtonTypeContactAdd];
    self.imageButton.frame = CGRectMake(SCREEN_WIDTH - 65, SCREEN_HEIGHT - 45, 40, 40);
//    self.imageButton.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.imageButton];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
    [self addGestureRecognizer:singleTap];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.chatMsg.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ChatTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[ChatTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    cell.model = self.chatMsg[indexPath.row];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    //计算文字高度需和自定义cell内容尺寸同步
    MessageModel *msgModel = self.chatMsg[indexPath.row];
    if ([msgModel.Type isEqualToString:@"text"]){
        CGSize labelSize = [msgModel.Content boundingRectWithSize: CGSizeMake(SCREEN_WIDTH-160, MAXFLOAT)
                                                          options: NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingTruncatesLastVisibleLine
                                                       attributes: @{NSFontAttributeName:[UIFont systemFontOfSize:15]}
                                                          context: nil].size;
        return labelSize.height + 40;
    }
    else {
        //2.初始化富文本对象
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:@""];
        //3.初始化NSTextAttachment对象
        NSTextAttachment *attchment = [[NSTextAttachment alloc]init];
        attchment.bounds = CGRectMake(0, 0, 100, 100);//设置frame
        //        attchment.image = msgModel.ContentImage;//设置图片
        UIImageView *imgV = [[UIImageView alloc]init];
        NSString *imagePath = [URLHelper getURLwithPath:msgModel.Content];
//        NSLog(imagePath);
        [imgV sd_setImageWithURL:[NSURL URLWithString:imagePath]
//                placeholderImage:[UIImage imageNamed:@"peppa"]
                       completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
//                           NSLog(@"error== %@",error);
                       }];
        attchment.image = imgV.image;
        //4.创建带有图片的富文本
        NSAttributedString *string = [NSAttributedString attributedStringWithAttachment:(NSTextAttachment *)(attchment)];
        [attributedString appendAttributedString:string];   //添加到尾部
        
        CGSize labelSize = [attributedString boundingRectWithSize: CGSizeMake(SCREEN_WIDTH-160, MAXFLOAT)
                                                   options: NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingTruncatesLastVisibleLine
                                                   context: nil].size;
        return labelSize.height + 40;
    }
    
}

- (void)tableViewScrollToBottom {
    
    /*if (self.chatMsg.count > 0) {
        [self.chatTable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.chatMsg.count - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
    }*/
    double delayInSeconds = 0.1;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        
        if ([self.chatMsg count] > 1){
            // 动画之前先滚动到倒数第二个消息
            [self.chatTable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[self.chatMsg count] - 2 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
        }
        //self.chatTableView.hidden = NO;
        if ([self.chatMsg count] > 0){
            NSIndexPath* path = [NSIndexPath indexPathForRow:[self.chatMsg count] - 1 inSection:0];
            [self.chatTable scrollToRowAtIndexPath:path atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        }
    });
}

- (void)keyboardWillShow:(NSNotification *)notice {
    NSValue *value = [[notice userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect frame = [value CGRectValue];
    self.keyboardHeight = frame.size.height;
    [self updataFrame];
}

- (void)keyboardWillHide:(NSNotification *)notice {
    self.keyboardHeight  = 0;
    [self updataFrame];
}

- (void)updataFrame {
    self.chatTable.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 50 - self.keyboardHeight);
    self.inputText.frame = CGRectMake(10, SCREEN_HEIGHT - 45 - self.keyboardHeight , SCREEN_WIDTH - 20 - 60, 40);
    [self tableViewScrollToBottom];
}

- (void)singleTap:(UITapGestureRecognizer *)recognizer {
    [self.inputText resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if ([textField hasText]) {
        if ([self.delegate respondsToSelector:@selector(sendMessage:text:)]) {
            [self.delegate sendMessage:@"text" text:self.inputText.text];
        }
    }
    self.inputText.text = @"";
    //[self.inputText resignFirstResponder];
    return YES;
}

@end
