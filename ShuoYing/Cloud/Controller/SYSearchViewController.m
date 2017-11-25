//
//  SYSearchViewController.m
//  ShuoYing
//
//  Created by 硕影 on 2017/1/17.
//  Copyright © 2017年 硕影. All rights reserved.
//

#import "SYSearchViewController.h"
#import "QTSearchBar.h"
#import "SYCloudTableViewCell.h"
#import "SYCloudModel.h"
#import "SYCloudContentFrameModel.h"
#import "SYGrapherInfosViewController.h"
#import "SYCloudContentTableViewCell.h"
#import "SYLoginViewController.h"
#import "DeleteOrderView.h"
#import "SYCommentViewController.h"
#import "SYCommentListViewController.h"
#import "SYZanViewController.h"
#import "QTShareView.h"
@interface SYSearchViewController ()<QTSearchBarDelegate,UITableViewDelegate,UITableViewDataSource, QTShareViewDelegate>

{
    QTSearchBar *_searchBar;
    UIButton *_cancleBtn;
    
    NSInteger _count;
    
    NSNumber *_uid;//回复的人的uid
    SYCloudModel *_currentCloudModel;

}

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *dataSourceArr;

@end

@implementation SYSearchViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (_cancleBtn == nil || _searchBar == nil) {
        [self loadSearchBar];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _count = 1;
    [self loadSearchBar];

}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.dataSourceArr.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
        
        SYCloudContentTableViewCell *cell = [SYCloudContentTableViewCell cellWithTableView:tableView];
        cell.imagesView.userInteractionEnabled =NO;
        
        cell.uid = _uid;
        SYCloudContentFrameModel *frameModel = self.dataSourceArr[indexPath.section];
        SYCloudModel *cloudModel = frameModel.cloudModel;
        
        __weak typeof(self)weakself = self;
        __weak typeof(cell)weakcell = cell;
        __weak typeof(cloudModel)weakCloudModel = cloudModel;
        
        //关注的回调
        cell.guanzhuBlock = ^(NSInteger type) {
            if (!LoginStatus) {
                SYLoginViewController *login = [[SYLoginViewController alloc] initWithNibName:@"SYLoginViewController" bundle:nil];
                [self.navigationController pushViewController:login animated:YES];
                return ;
            }
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
        //选中评论的回调
        cell.selectComment = ^(NSIndexPath *commentIndexpath) {
            if (!LoginStatus) {
                SYLoginViewController *login = [[SYLoginViewController alloc] initWithNibName:@"SYLoginViewController" bundle:nil];
                [self.navigationController pushViewController:login animated:YES];
                return ;
            }
            
            NSDictionary *dic = weakCloudModel.reply[commentIndexpath.row];
            
            //评论
            SYCommentViewController *commentVC = [[SYCommentViewController alloc] initWithNibName:@"SYCommentViewController" bundle:nil];
            commentVC.cloudID = weakCloudModel.ID;
            commentVC.frameModel = frameModel;
            commentVC.pid = [dic objectForKey:@"id"];
            commentVC.name = [dic objectForKey:@"u_nick"];
            commentVC.selecteCommentIndexpath = commentIndexpath;
            [weakself.navigationController pushViewController:commentVC animated:YES];
        };
        //删除评论的回调
        cell.deleteComment = ^(NSIndexPath *deleteIndexpth) {
            if (!LoginStatus) {
                SYLoginViewController *login = [[SYLoginViewController alloc] initWithNibName:@"SYLoginViewController" bundle:nil];
                [self.navigationController pushViewController:login animated:YES];
                return ;
            }
            
            NSDictionary *dic = weakCloudModel.reply[deleteIndexpth.row];
            NSString *url = [NSString stringWithFormat:@"%@%@",BaseUrl,@"/get/reply_del.html"];
            NSDictionary *param = @{@"token":UserToken, @"id":[dic objectForKey:@"id"]};
            [weakself deleteCommentActionWithUrl:url param:param IndexPath:deleteIndexpth superIndexpath:indexPath];
        };
        //选中互动视图的回调
        cell.hudongType = ^(NSInteger type) {
            if (!LoginStatus) {
                SYLoginViewController *login = [[SYLoginViewController alloc] initWithNibName:@"SYLoginViewController" bundle:nil];
                [weakself.navigationController pushViewController:login animated:YES];
                return ;
            }
            switch (type) {
                    
                case 0:
                {
                    //没有评论跳转评论页面 有评论跳转评论列表
                    if ([weakCloudModel.reply_count integerValue] == 0) {
                        //评论
                        SYCommentViewController *commentVC = [[SYCommentViewController alloc] initWithNibName:@"SYCommentViewController" bundle:nil];
                        commentVC.cloudID = weakCloudModel.ID;
                        commentVC.frameModel = frameModel;
                        [weakself.navigationController pushViewController:commentVC animated:YES];
                    }else{
                        SYCommentListViewController *commentList = [[SYCommentListViewController alloc] initWithNibName:@"SYCommentListViewController" bundle:nil];
                        commentList.uid = _uid;
                        commentList.cloudID = weakCloudModel.ID;
                        commentList.frameModel = frameModel;
                        [weakself.navigationController pushViewController:commentList animated:YES];
                    }
                }
                    break;
                    
                case 1:
                {
                    if ([weakCloudModel.my integerValue] == 0) {
                        //不是自己发布的作品
                        //点赞 取消点赞
                        if ([weakCloudModel.agree integerValue] == 0) {
                            
                            [self zanActionWithCloudID:weakCloudModel.ID IndexPath:indexPath commentCell:weakcell];
                        }else{
                            SYZanViewController *zan = [[SYZanViewController alloc] init];
                            zan.cloudID = weakCloudModel.ID;
                            [weakself.navigationController pushViewController:zan animated:YES];
                        }
                    }else{
                        
                        SYZanViewController *zan = [[SYZanViewController alloc] init];
                        zan.cloudID = weakCloudModel.ID;
                        [weakself.navigationController pushViewController:zan animated:YES];
                    }
                    
                }
                    break;
                case 2:
                {
                    //                    分享
                    SYCloudContentFrameModel *frameModel = self.dataSourceArr[indexPath.section];
                    SYCloudModel *cloudModel = frameModel.cloudModel;
                    _currentCloudModel = cloudModel;
                    
                    QTShareView *shareView = [QTShareView sharedInstance];
                    shareView.delegate = weakself;
                    [shareView showInView:weakself.view];
                }
                    break;
                    
                default:
                    break;
            }
        };
        
        cell.frameModel = self.dataSourceArr[indexPath.section];
    

    return cell;
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
                    [self.dataSourceArr removeObjectAtIndex:indexpath.section];
                    [self.tableView reloadData];
                }else{
                    SYCloudContentFrameModel *frameModel = self.dataSourceArr[indexpath.section];
                    
                    SYCloudModel *cloudModel = frameModel.cloudModel;
                    if ([cloudModel.follow integerValue] == 0) {
                        for (SYCloudContentFrameModel *cloudFrameModel in self.dataSourceArr) {
                            SYCloudModel *cloudModel111 = cloudFrameModel.cloudModel;
                            if ([cloudModel111.uid integerValue] == [cloudModel.uid integerValue]) {
                                cloudModel.follow = @1;
                                cloudFrameModel.cloudModel = cloudModel;
                            }
                        }
                        cloudModel.follow = @1;
                        [cell.guanzhuBtn setImage:[UIImage imageNamed:@"shouye_follow"] forState:UIControlStateNormal];
                        
                    }else{
                        for (SYCloudContentFrameModel *cloudFrameModel in self.dataSourceArr) {
                            SYCloudModel *cloudModel111 = cloudFrameModel.cloudModel;
                            if ([cloudModel111.uid integerValue] == [cloudModel.uid integerValue]) {
                                cloudModel.follow = @0;
                                cloudFrameModel.cloudModel = cloudModel;
                                
                            }
                        }
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
                SYCloudContentFrameModel *frameModel = self.dataSourceArr[superIndexpath.section - 1];
                SYCloudModel *cloudModel = frameModel.cloudModel;
                NSMutableArray *muReply = [NSMutableArray arrayWithArray:cloudModel.reply];
                [muReply removeObjectAtIndex:indexpath.row];
                
                cloudModel.reply = muReply;
                NSInteger reply_count = [cloudModel.reply_count integerValue];
                cloudModel.reply_count = [NSNumber numberWithInteger:reply_count - 1];
                frameModel.cloudModel = cloudModel;
                
                [self.dataSourceArr replaceObjectAtIndex:superIndexpath.section - 1 withObject:frameModel];
                [self.tableView reloadData];
                
            }else{
                if ([responseResult objectForKey:@"msg"]) {
                    [self showHint:[responseResult objectForKey:@"msg"]];
                }
            }
        }
    }];
    
}

#pragma mark - QTShareViewDelegate
- (void)didSelectedShareBtnWithTag:(NSInteger)tag{
    if (tag == 0) {
        [self shareImageToPlatformType:UMSocialPlatformType_QQ];
    }else if (tag == 1){
        [self shareImageToPlatformType:UMSocialPlatformType_Qzone];
    }else if (tag == 2){
        [self shareImageToPlatformType:UMSocialPlatformType_WechatSession];
    }else if (tag == 3){
        [self shareImageToPlatformType:UMSocialPlatformType_WechatTimeLine];
    }
}

- (void)shareImageToPlatformType:(UMSocialPlatformType)platformType
{
    //分享的内容
    NSString *url = [NSString stringWithFormat:@"http://app.yunxiangguan.cn/photoShow02.html?id=%@&history=index&app=app",_currentCloudModel.ID];
    NSString *title = [NSString stringWithFormat:@"来自%@【龙果云拍】的精彩分享",_currentCloudModel.nick];
    UIImage *image = [[SDImageCache sharedImageCache] imageFromCacheForKey:[NSString stringWithFormat:@"%@%@",ImgUrl,_currentCloudModel.head]];
    //创建分享消息对象
    UMSocialMessageObject *messageObject = [UMSocialMessageObject messageObject];
    UMShareWebpageObject *shareObject = [UMShareWebpageObject shareObjectWithTitle:title descr:@"这是一个可以分享图片，充满爱的摄影平台" thumImage:image];
    shareObject.webpageUrl = url;
    messageObject.shareObject = shareObject;
    //调用分享接口
    [[UMSocialManager defaultManager] shareToPlatform:platformType messageObject:messageObject currentViewController:self completion:^(id data, NSError *error) {
        if (error) {
            NSLog(@"************Share fail with error %@*********",error);
        }else{
            NSLog(@"response data is %@",data);
        }
    }];
    
}


#pragma mark - zanAction
- (void)zanActionWithCloudID:(NSNumber *)cloudID
                   IndexPath:(NSIndexPath *)indexpath
                 commentCell:(SYCloudContentTableViewCell *)cell{
    
    NSString *url = [NSString stringWithFormat:@"%@%@",BaseUrl,@"/my/agree.html"];
    NSDictionary *param = @{@"token":UserToken, @"id":cloudID};
    [[SYHttpRequest sharedInstance] getDataWithUrl:url Parameter:param ResponseObject:^(NSDictionary *responseResult) {
        
        NSLog(@"点赞 -- %@",responseResult);
        if ([responseResult objectForKey:@"resError"]) {
            [self showHint:@"服务器不给力，请稍后重试"];
        }else{
            if ([[responseResult objectForKey:@"result"] integerValue] == 1) {
                
                SYCloudContentFrameModel *frameModel = self.dataSourceArr[indexpath.section];
                
                SYCloudModel *cloudModel = frameModel.cloudModel;
                if ([cloudModel.agree integerValue] == 0) {
                    [cell zanShowAnimation];
                    
                    cloudModel.agree = @1;
                    NSInteger count = [cloudModel.agree_count integerValue] + 1;
                    cloudModel.agree_count = [NSNumber numberWithInteger:count];
                    
                    [cell.zanBtn setImage:[UIImage imageNamed:@"shouye_production_like_sel"] forState:UIControlStateNormal];
                    [cell.zanBtn setTitle:[cloudModel.agree_count stringValue] forState:UIControlStateNormal];
                    
                }else{
                    cloudModel.agree = @0;
                    NSInteger count = [cloudModel.agree_count integerValue] - 1;
                    cloudModel.agree_count = /* DISABLES CODE */ (0)?@0:[NSNumber numberWithInteger:count];
                    [cell.zanBtn setImage:[UIImage imageNamed:@"shouye_production_like_nor"] forState:UIControlStateNormal];
                    if ([cloudModel.agree_count integerValue] == 0) {
                        [cell.zanBtn setTitle:@"点赞" forState:UIControlStateNormal];
                    }else{
                        [cell.zanBtn setTitle:[cloudModel.agree_count stringValue] forState:UIControlStateNormal];
                    }
                }
                
                //                [self.tableView reloadData];
                
            }else{
                if ([responseResult objectForKey:@"msg"]) {
                    [self showHint:[responseResult objectForKey:@"msg"]];
                }
            }
        }
    }];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    SYCloudContentFrameModel *frameModel = self.dataSourceArr[indexPath.section];
    //        return 90 + (kScreenWidth - 50) / 3 + 20;
    return frameModel.cellHeight;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.00001f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view = [[UIView alloc] init];
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 13;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *view = [[UIView alloc] init];
    return view;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.dataSourceArr.count > 0) {
        
        SYGrapherInfosViewController *grapherinfos = [[SYGrapherInfosViewController alloc] init];
        SYCloudContentFrameModel *frameModel = self.dataSourceArr[indexPath.section];
        SYCloudModel *model = frameModel.cloudModel;
        _currentCloudModel = model;
        
        grapherinfos.uid = _uid;
        grapherinfos.grapherID = model.ID;
        grapherinfos.isFromShouye = YES;
        grapherinfos.frameModel = frameModel;
        [self.navigationController pushViewController:grapherinfos animated:YES];
    }
}

- (void)loadFaildView{
    UIImageView *imageview = [[UIImageView alloc] initWithFrame:CGRectMake(0, 40, kScreenWidth, 260)];
    imageview.image = [UIImage imageNamed:@"sousuo_nothing"];
    imageview.contentMode = UIViewContentModeScaleAspectFit;
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(imageview.frame) + 10, kScreenWidth, 20)];
    label.text = @"不开森，没有亲想要的图片";
    label.textColor = [UIColor darkGrayColor];
    label.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:label];
    
    [self.view addSubview:imageview];
}

//加载搜索条
- (void)loadSearchBar{
    //添加取消返回按钮
    _cancleBtn = [[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth - 60, 5, 40, 30)];
    [_cancleBtn setTitle:@"取消" forState:UIControlStateNormal];
    [_cancleBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _cancleBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [_cancleBtn addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationController.navigationBar addSubview:_cancleBtn];
    
    _searchBar = [QTSearchBar searchBarWith:CGRectMake(15, 5, kScreenWidth - 80, 30)];
    _searchBar.returnKeyType = UIReturnKeySearch;
//    [_searchBar becomeFirstResponder];
    
    _searchBar.searchDelegate = self;
    self.navigationItem.leftBarButtonItem = nil;
    [self.navigationController.navigationBar addSubview:_searchBar];
    
}

- (void)keyBoardSearchWithText:(NSString *)text{
    if (text.length == 0) {
        return;
    }
    
    [self getDataWith:text];
}

- (void)getDataWith:(NSString *)text{
    NSString *url = [NSString stringWithFormat:@"%@%@",BaseUrl,@"/get/amigo.html"];
    NSDictionary *param = nil;
    if (LoginStatus) {
        param = @{@"page":@1, @"keywords":text, @"type":@0, @"token":UserToken};
    }else{
        param = @{@"page":@1, @"keywords":text, @"type":@0};
    }
    [[SYHttpRequest sharedInstance] getDataWithUrl:url Parameter:param ResponseObject:^(NSDictionary *responseResult) {
        [_searchBar resignFirstResponder];
        if ([_tableView.mj_header isRefreshing]) {
            [_tableView.mj_header endRefreshing];
        }
        NSLog(@"搜素结果 -- %@",responseResult);
        if ([responseResult objectForKey:@"resError"]) {
            
        }else{
            if ([[responseResult objectForKey:@"result"] integerValue] == 1) {
                _count = 1;
                if ([responseResult objectForKey:@"data"]) {
                    
                    _uid = (NSNumber *)[responseResult objectForKey:@"uid"];
                    NSArray *data = [responseResult objectForKey:@"data"];
                    if (data.count >= 10) {
                        [_tableView.mj_footer resetNoMoreData];
                    }
                    if (data.count > 0) {
                        [self.dataSourceArr removeAllObjects];
                        for (NSDictionary *dic in data) {
                            SYCloudModel *model = [SYCloudModel cloudWithDictionary:dic];
                            SYCloudContentFrameModel *frameModel = [[SYCloudContentFrameModel alloc] init];
                            frameModel.cloudModel = model;
                            [self.dataSourceArr addObject:frameModel];
                        }
                        [self.tableView removeFromSuperview];
                        [self.view addSubview:self.tableView];
                        [self.tableView reloadData];
                    }else{
                        [self.tableView removeFromSuperview];
                        [self loadFaildView];
                    }
                    
                }
                
            }else{
                if ([responseResult objectForKey:@"msg"]) {
                    [self showHint:[responseResult objectForKey:@"msg"]];
                }
            }
        }
    }];
}

- (void)getMoreDataWith:(NSString *)text{
    _count ++;
    NSString *url = [NSString stringWithFormat:@"%@%@",BaseUrl,@"/get/amigo.html"];
    
    NSDictionary *param = nil;
    if (LoginStatus) {
        param = @{@"page":[NSNumber numberWithInteger:_count], @"keywords":text, @"type":@0, @"token":UserToken};
    }else{
        param = @{@"page":[NSNumber numberWithInteger:_count], @"keywords":text, @"type":@0};
    }
    [[SYHttpRequest sharedInstance] getDataWithUrl:url Parameter:param ResponseObject:^(NSDictionary *responseResult) {
        [_searchBar resignFirstResponder];
        NSLog(@"搜素结果 -- %@",responseResult);
        if ([responseResult objectForKey:@"resError"]) {
            _count --;
        }else{
            if ([[responseResult objectForKey:@"result"] integerValue] == 1) {
                if ([responseResult objectForKey:@"data"]) {
                    NSArray *data = [responseResult objectForKey:@"data"];
                    if (data.count < 10) {
                        _count --;
                        [_tableView.mj_footer endRefreshingWithNoMoreData];
                        for (NSDictionary *dic in data) {
                            SYCloudModel *model = [SYCloudModel cloudWithDictionary:dic];
                            SYCloudContentFrameModel *frameModel = [[SYCloudContentFrameModel alloc] init];
                            frameModel.cloudModel = model;
                            [self.dataSourceArr addObject:frameModel];
                        }
                        [self.tableView reloadData];
                        return ;
                    }
                    if (data.count > 0) {
                        
                        for (NSDictionary *dic in data) {
                            SYCloudModel *model = [SYCloudModel cloudWithDictionary:dic];
                            SYCloudContentFrameModel *frameModel = [[SYCloudContentFrameModel alloc] init];
                            frameModel.cloudModel = model;
                            [self.dataSourceArr addObject:frameModel];
                        }
                    }
                    
                    [self.tableView reloadData];
                    
                }
                
            }else{
                _count --;
                if ([responseResult objectForKey:@"msg"]) {
                    [self showHint:[responseResult objectForKey:@"msg"]];
                }
            }
        }
    }];
}

- (void)back:(UIButton *)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [_searchBar removeFromSuperview];
    [_cancleBtn removeFromSuperview];
    _searchBar = nil;
    _cancleBtn = nil;
}

- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight - kNavigationBarHeightAndStatusBarHeight) style:UITableViewStyleGrouped];
        _tableView.backgroundColor = BackGroundColor;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
            [self getDataWith:_searchBar.text];
        }];
        _tableView.mj_footer = [MJRefreshAutoStateFooter footerWithRefreshingBlock:^{
            [self getMoreDataWith:_searchBar.text];
        }];
        _tableView.mj_footer.automaticallyHidden = YES;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
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
