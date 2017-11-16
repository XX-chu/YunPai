//
//  SYCommentListViewController.m
//  ShuoYing
//
//  Created by 硕影 on 2017/7/6.
//  Copyright © 2017年 硕影. All rights reserved.
//

#import "SYCommentListViewController.h"
#import "SYCloudContentFrameModel.h"
#import "SYCloudModel.h"
#import "SYCloudContentTableViewCell.h"
#import "DeleteOrderView.h"
@interface SYCommentListViewController ()<UITextViewDelegate, UITableViewDelegate, UITableViewDataSource,XLPhotoBrowserDelegate,XLPhotoBrowserDatasource>
{
    NSNumber *_pid;
    NSInteger _count;
    NSIndexPath *_currentSelecteCommentIndexpath;
    NSArray *_imgs;
}
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *backViewBottomHCons;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *backViewHCons;
@property (weak, nonatomic) IBOutlet UIView *backView;
@property (weak, nonatomic) IBOutlet UITextView *textView;

@property(nonatomic,assign)NSInteger textOldH;

@property(nonatomic,assign)NSInteger maxTextH;

@property (weak, nonatomic) IBOutlet UIButton *sendBtn;
@property (weak, nonatomic) IBOutlet UILabel *placHoldeLabel;

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, copy) NSMutableArray *dataSourceArr;
@end

#define MAX_LIMIT_NUMS 100

@implementation SYCommentListViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    if([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    }
    
    if (self.dataSourceArr.count > 3) {
        [self.dataSourceArr removeObjectsInRange:NSMakeRange(3, self.dataSourceArr.count - 3)];
        SYCloudModel *cloudModel = self.frameModel.cloudModel;
        cloudModel.reply = self.dataSourceArr;
        self.frameModel.cloudModel = cloudModel;
    }
    
    if (self.dataSourceArr.count == 3) {
        SYCloudModel *cloudModel = self.frameModel.cloudModel;
        cloudModel.reply = self.dataSourceArr;
        self.frameModel.cloudModel = cloudModel;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    if([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
    self.title = @"全部评论";
    self.view.backgroundColor = [UIColor whiteColor];
    _pid = nil;
    _count = 1;
    [self initController];
    [self.view addSubview:self.tableView];
    [self getData];
}

- (void)getData{
    [SVProgressHUD show];
    NSString *url = [NSString stringWithFormat:@"%@%@",BaseUrl,@"/get/reply_list.html"];
    NSDictionary *param = @{@"id":self.cloudID, @"page":@1};
    [[SYHttpRequest sharedInstance] getDataWithUrl:url Parameter:param ResponseObject:^(NSDictionary *responseResult) {
        [SVProgressHUD dismiss];
        if ([self.tableView.mj_header isRefreshing]) {
            [self.tableView.mj_header endRefreshing];
        }
        _count = 1;
        NSLog(@"评论列表 -- %@",responseResult);
        if ([responseResult objectForKey:@"resError"]) {
            [self showHint:@"服务器不给力，请稍后重试"];
        }else{
            if ([[responseResult objectForKey:@"result"] integerValue] == 1) {
                NSArray *data = [responseResult objectForKey:@"data"];
                if (data.count >= 10) {
                    [_tableView.mj_footer resetNoMoreData];
                }else{
                    [_tableView.mj_footer endRefreshingWithNoMoreData];
                }
                if (data.count > 0) {
                    [self.dataSourceArr removeAllObjects];
                    [self.dataSourceArr addObjectsFromArray:data];
                    SYCloudModel *cloudModel = self.frameModel.cloudModel;
                    cloudModel.reply = self.dataSourceArr;
                    self.frameModel.cloudModel = cloudModel;
                }
                
                [self.tableView reloadData];
            }else{
                if ([responseResult objectForKey:@"msg"]) {
                    [self showHint:[responseResult objectForKey:@"msg"]];
                }
            }
        }
    }];
}

- (void)getMoreData{
    _count ++;
    NSString *url = [NSString stringWithFormat:@"%@%@",BaseUrl,@"/get/reply_list.html"];
    NSDictionary *param = @{@"id":self.cloudID, @"page":[NSNumber numberWithInteger:_count]};
    [[SYHttpRequest sharedInstance] getDataWithUrl:url Parameter:param ResponseObject:^(NSDictionary *responseResult) {

        NSLog(@"评论列表 -- %@",responseResult);
        if ([responseResult objectForKey:@"resError"]) {
            [self showHint:@"服务器不给力，请稍后重试"];
            _count --;
        }else{
            if ([[responseResult objectForKey:@"result"] integerValue] == 1) {
                NSArray *data = [responseResult objectForKey:@"data"];
                if (data.count >= 10) {
                    [_tableView.mj_footer resetNoMoreData];
                }else{
                    [_tableView.mj_footer endRefreshingWithNoMoreData];
                }
                if (data.count > 0) {
                    [self.dataSourceArr addObjectsFromArray:data];
                    SYCloudModel *cloudModel = self.frameModel.cloudModel;
                    cloudModel.reply = self.dataSourceArr;
                    cloudModel.reply_count = [NSNumber numberWithInteger:[data count]];
                    self.frameModel.cloudModel = cloudModel;
                }
                
                [self.tableView reloadData];
            }else{
                _count--;
                if ([responseResult objectForKey:@"msg"]) {
                    [self showHint:[responseResult objectForKey:@"msg"]];
                }
            }
        }
    }];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (self.dataSourceArr.count == 0) {
        return 0;
    }
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (self.dataSourceArr.count == 0) {
        return 0;
    }
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    SYCloudContentTableViewCell *cell = [SYCloudContentTableViewCell cellWithTableView:tableView];
    cell.uid = self.uid;
    SYCloudModel *cloudModel = self.frameModel.cloudModel;
    __weak typeof(self)weakself = self;
    __weak typeof(cloudModel)weakCloudModel = cloudModel;
    __weak typeof(cell)weakcell = cell;
    __weak typeof(indexPath)weakSuperIndexpath = indexPath;
    NSArray *reply = self.frameModel.cloudModel.reply;
    _imgs = cloudModel.imgs;
    cell.selecteImageView = ^(NSInteger selecteIndex) {
        XLPhotoBrowser *brower = [XLPhotoBrowser showPhotoBrowserWithCurrentImageIndex:selecteIndex imageCount:_imgs.count datasource:self];
        brower.browserStyle = XLPhotoBrowserStylePageControl;
        brower.currentPageDotColor = NavigationColor;
    };
    
    cell.selectComment = ^(NSIndexPath *commentIndexpath) {
        _currentSelecteCommentIndexpath = commentIndexpath;
        NSDictionary *dic = reply[commentIndexpath.row];
        _pid = (NSNumber *)[dic objectForKey:@"id"];
        NSString *name = [dic objectForKey:@"u_nick"];
        [weakself.textView becomeFirstResponder];
        weakself.placHoldeLabel.text = [NSString stringWithFormat:@"回复 %@",name];
    };
    cell.deleteComment = ^(NSIndexPath *deleteIndexpth) {
        SYCloudModel *cloudModel = weakself.frameModel.cloudModel;
        NSDictionary *dic = cloudModel.reply[deleteIndexpth.row];
        NSString *url = [NSString stringWithFormat:@"%@%@",BaseUrl,@"/get/reply_del.html"];
        NSDictionary *param = @{@"token":UserToken, @"id":[dic objectForKey:@"id"]};
        [weakself deleteCommentActionWithUrl:url param:param IndexPath:deleteIndexpth superIndexpath:weakSuperIndexpath];
    };
    
    //关注的回调
    cell.guanzhuBlock = ^(NSInteger type) {
        switch (type) {
            case 0:
            {
                //自己发布的 要删除
                DeleteOrderView *view = [[NSBundle mainBundle] loadNibNamed:@"DeleteOrderView" owner:nil options:nil][0];
                view.frame = [UIScreen mainScreen].bounds;
                view.tishiLabel.text = @"你确定要删除这条云拍作品吗？";
                [view.leftBtn setTitle:@"取消" forState:UIControlStateNormal];
                [view.rightBtn setTitle:@"确定" forState:UIControlStateNormal];
                __weak typeof(view)weakView = view;
                view.leftBlock = ^{
                    
                    [weakView dismiss];
                };
                view.rightBlock = ^{
                    NSString *url = [NSString stringWithFormat:@"%@%@",BaseUrl,@"/pho/del.html"];
                    NSDictionary *param = @{@"token":UserToken, @"id":weakCloudModel.ID};
                    [weakself guanzhuActionWithUrl:url Param:param IndexPath:indexPath commentCell:weakcell Type:0];
                    [weakView dismiss];
                };
                [view show];
                
            }
                break;
            case 1:
            {
                //没有关注
                NSString *url = [NSString stringWithFormat:@"%@%@",BaseUrl,@"/my/follow.html"];
                NSDictionary *param = @{@"token":UserToken, @"id":weakCloudModel.uid};
                [weakself guanzhuActionWithUrl:url Param:param IndexPath:indexPath commentCell:weakcell Type:1];
            }
                break;
            case 2:
            {
                //                    要关注
                NSString *url = [NSString stringWithFormat:@"%@%@",BaseUrl,@"/my/follow.html"];
                NSDictionary *param = @{@"token":UserToken, @"id":weakCloudModel.uid};
                [weakself guanzhuActionWithUrl:url Param:param IndexPath:indexPath commentCell:weakcell Type:2];
            }
                break;
                
            default:
                break;
        }
    };

    
    cell.hudongView.hidden = YES;
    cell.frameModel = self.frameModel;
    
    return cell;
}
#pragma mark - 点击查看大图
- (NSURL *)photoBrowser:(XLPhotoBrowser *)browser highQualityImageURLForIndex:(NSInteger)index{
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",ImgUrl,_imgs[index]]];
}

#pragma makr - 关注-取消关注-删除作品的事件方法
- (void)guanzhuActionWithUrl:(NSString *)url
                       Param:(NSDictionary *)param
                   IndexPath:(NSIndexPath *)indexpath
                 commentCell:(SYCloudContentTableViewCell *)cell
                        Type:(NSInteger)type{
    
    [[SYHttpRequest sharedInstance] getDataWithUrl:url Parameter:param ResponseObject:^(NSDictionary *responseResult) {
        
        NSLog(@"关注-取消关注-删除作品 -- %@",responseResult);
        if ([responseResult objectForKey:@"resError"]) {
            [self showHint:@"服务器不给力，请稍后重试"];
        }else{
            if ([[responseResult objectForKey:@"result"] integerValue] == 1) {
                if (type == 0) {
                    [self.navigationController popViewControllerAnimated:YES];
                }else{
                    SYCloudContentFrameModel *frameModel = self.frameModel;
                    
                    SYCloudModel *cloudModel = frameModel.cloudModel;
                    if ([cloudModel.follow integerValue] == 0) {
                        
                        cloudModel.follow = @1;
                        [cell.guanzhuBtn setImage:[UIImage imageNamed:@"shouye_follow"] forState:UIControlStateNormal];
                        
                    }else{
                        cloudModel.follow = @0;
                        [cell.guanzhuBtn setImage:[UIImage imageNamed:@"shouye_unfollow"] forState:UIControlStateNormal];
                        
                    }
                    
                    [self.tableView reloadData];
                    [self showHint:[responseResult objectForKey:@"msg"]];
                }
                
            }else{
                if ([responseResult objectForKey:@"msg"]) {
                    [self showHint:[responseResult objectForKey:@"msg"]];
                }
            }
        }
    }];
    
}


#pragma mark - 删除评论的事件方法
- (void)deleteCommentActionWithUrl:(NSString *)url param:(NSDictionary *)param IndexPath:(NSIndexPath *)indexpath superIndexpath:(NSIndexPath *)superIndexpath{
    
    [[SYHttpRequest sharedInstance] getDataWithUrl:url Parameter:param ResponseObject:^(NSDictionary *responseResult) {
        
        NSLog(@"删除评论 -- %@",responseResult);
        if ([responseResult objectForKey:@"resError"]) {
            [self showHint:@"服务器不给力，请稍后重试"];
        }else{
            if ([[responseResult objectForKey:@"result"] integerValue] == 1) {
                SYCloudContentFrameModel *frameModel = self.frameModel;
                SYCloudModel *cloudModel = frameModel.cloudModel;
                NSMutableArray *muReply = [NSMutableArray arrayWithArray:cloudModel.reply];
                [muReply removeObjectAtIndex:indexpath.row];
                cloudModel.reply = muReply;
                NSInteger count = [cloudModel.reply_count integerValue];
                cloudModel.reply_count = [NSNumber numberWithInteger:count-1];
                NSLog(@"cloudModel.reply - %@",cloudModel.reply);
                self.frameModel.cloudModel = cloudModel;
                [self.dataSourceArr removeObjectAtIndex:indexpath.row];
                [self.tableView reloadData];
            }else{
                if ([responseResult objectForKey:@"msg"]) {
                    [self showHint:[responseResult objectForKey:@"msg"]];
                }
            }
        }
    }];
    
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return self.frameModel.cellHeight - 51;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 20;
}

- (IBAction)sendAction:(UIButton *)sender {
    [self.textView resignFirstResponder];
    if (self.textView.text.length == 0) {
        [self showHint:@"请输入您要评论的内容"];
        return;
    }
    [SVProgressHUD show];
    NSString *url = [NSString stringWithFormat:@"%@%@",BaseUrl,@"/get/reply.html"];
    NSDictionary *param = nil;
    if (_pid == nil) {
        param = @{@"id":self.cloudID, @"token":UserToken, @"msg":self.textView.text};
    }else{
        param = @{@"id":self.cloudID, @"token":UserToken, @"msg":self.textView.text, @"pid":_pid};
    }
    [[SYHttpRequest sharedInstance] getDataWithUrl:url Parameter:param ResponseObject:^(NSDictionary *responseResult) {
        [SVProgressHUD dismiss];
        NSLog(@"评论 -- %@",responseResult);
        if ([responseResult objectForKey:@"resError"]) {
            [self showHint:@"服务器不给力，请稍后重试"];
        }else{
            if ([[responseResult objectForKey:@"result"] integerValue] == 1) {
                self.textView.text = nil;
                [self textViewDidChange:self.textView];
                //评论成功后 把评论数量加1
                NSInteger replyCount = [self.frameModel.cloudModel.reply_count integerValue];
                self.frameModel.cloudModel.reply_count = [NSNumber numberWithInteger:replyCount+1];
                NSDictionary *reply_data = [responseResult objectForKey:@"data"];
                if (_currentSelecteCommentIndexpath) {
                    [self.dataSourceArr insertObject:reply_data atIndex:_currentSelecteCommentIndexpath.row + 1];

                }else{
                    [self.dataSourceArr insertObject:reply_data atIndex:self.dataSourceArr.count];
                }
                SYCloudModel *cloudModel = self.frameModel.cloudModel;
                cloudModel.reply = self.dataSourceArr;
                self.frameModel.cloudModel = cloudModel;
                
                [self.tableView reloadData];
            }else{
                if ([responseResult objectForKey:@"msg"]) {
                    [self showHint:[responseResult objectForKey:@"msg"]];
                }
            }
        }
    }];
}

- (void)initController{
    self.textView.delegate = self;
    self.textView.scrollEnabled = NO;
    self.textView.scrollsToTop = NO;
    self.textView.backgroundColor = self.backView.backgroundColor;
    //当textview的字符串为0时发送（rerurn）键无效
    self.textView.enablesReturnKeyAutomatically = YES;
    self.textView.keyboardType = UIKeyboardTypeDefault;
    //键盘return样式变成发送
    self.textView.returnKeyType = UIReturnKeySend;
    //监听键盘
    [[NSNotificationCenter defaultCenter] addObserver:self
     
                                             selector:@selector(keyboardWasShown:)
     
                                                 name:UIKeyboardWillChangeFrameNotification object:nil];
    
    
    // 计算最大高度 = (每行高度 * 总行数 + 文字上下间距)
    _maxTextH = ceil(self.textView.font.lineHeight * 4 + self.textView.textContainerInset.top + self.textView.textContainerInset.bottom);
    
}

#pragma mark ================textViewdelegate=========================
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    //不支持系统表情的输入
    if ([[textView textInputMode]primaryLanguage]==nil||[[[textView textInputMode]primaryLanguage]isEqualToString:@"emoji"]) {
        return NO;
    }
    
    if (textView==self.textView && [text isEqualToString:@"\n"]){ //判断输入的字是否是回车，即按下return
        //在这里做你响应return键的代码
        
        [self sendAction:nil];
        [self textViewDidChange:textView];
        return NO; //这里返回NO，就代表return键值失效，即页面上按下return，不会出现换行，如果为yes，则输入页面会换行
    }
    return YES;
}


- (void)textViewDidChange:(UITextView *)textView {
    if ([textView.text length] == 0) {
        [self.placHoldeLabel setHidden:NO];
        [self.sendBtn setImage:[UIImage imageNamed:@"comment_write_sent"] forState:UIControlStateNormal];
        self.sendBtn.enabled = NO;
    }else{
        [self.placHoldeLabel setHidden:YES];
        [self.sendBtn setImage:[UIImage imageNamed:@"comment_write_sent_sel"] forState:UIControlStateNormal];
        self.sendBtn.enabled = YES;
    }
    
    UITextRange *selectedRange = [textView markedTextRange];
    
    //获取高亮部分
    
    UITextPosition *pos = [textView positionFromPosition:selectedRange.start offset:0];
    
    //如果在变化中是高亮部分在变，就不要计算字符了
    
    if (selectedRange && pos) {
        
        return;
    }
    
    NSString  *nsTextContent = textView.text;
    
    NSInteger existTextNum = nsTextContent.length;
    
    if (existTextNum > MAX_LIMIT_NUMS){
        //截取到最大位置的字符(由于超出截部分在should时被处理了所在这里这了提高效率不再判断)
        
        NSString *s = [nsTextContent substringToIndex:MAX_LIMIT_NUMS];
        
        [textView setText:s];
        
    }
    
    
    
    NSInteger height = ceilf([self.textView sizeThatFits:CGSizeMake(self.textView.bounds.size.width, MAXFLOAT)].height);

    if (_textOldH!=height) {
        // 最大高度，可以滚动
        self.textView.scrollEnabled = height > _maxTextH && _maxTextH > 0;
        
        if (self.textView.scrollEnabled==NO) {
            _backViewHCons.constant = height + 19;//距离上下边框各为5，所以加10
            [self.view layoutIfNeeded];
        }
        _textOldH = height;
        
    }
}


- (void)keyboardWasShown:(NSNotification*)aNotification {
    [self.view bringSubviewToFront:self.backView];
    // 获取键盘弹出时长
    CGFloat duration = [aNotification.userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue];
    //键盘高度
    CGRect keyBoardFrame = [[[aNotification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat screenH = [UIScreen mainScreen].bounds.size.height;
    //调增backView距离父视图底部的距离
    _backViewBottomHCons.constant = keyBoardFrame.origin.y != screenH?keyBoardFrame.size.height:0;
    if (keyBoardFrame.origin.y == screenH) {
        self.placHoldeLabel.text = @"写评论";
        
    }
    [UIView animateWithDuration:duration animations:^{
        [self.view layoutIfNeeded];
    }];
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight - kNavigationBarHeightAndStatusBarHeight - 53) style:UITableViewStyleGrouped];
        _tableView.backgroundColor = [UIColor whiteColor];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.showsHorizontalScrollIndicator = NO;
        _tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
            [self getData];
        }];
        _tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
            [self getMoreData];
        }];
    }
    return _tableView;
}

- (NSMutableArray *)dataSourceArr{
    if (!_dataSourceArr) {
        _dataSourceArr = [NSMutableArray arrayWithCapacity:0];
    }
    return _dataSourceArr;
}

@end
