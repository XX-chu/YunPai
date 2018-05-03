//
//  SYChakanGrapherViewController.m
//  ShuoYing
//
//  Created by 硕影 on 2017/3/29.
//  Copyright © 2017年 硕影. All rights reserved.
//

#import "SYChakanGrapherViewController.h"
#import "SYCloudTableViewCell.h"
#import "SYCloudModel.h"
#import "SYCloudContentFrameModel.h"
#import "SYGrapherInfosViewController.h"
#import "SYCloudContentTableViewCell.h"
#import "DeleteOrderView.h"

#import "SYCommentViewController.h"
#import "SYCommentListViewController.h"
#import "SYLoginViewController.h"
#import "SYZanViewController.h"
#import "QTShareView.h"
@interface SYChakanGrapherViewController ()<UITableViewDelegate, UITableViewDataSource, QTShareViewDelegate>
{
    NSInteger _count;
    SYCloudModel *_currentCloudModel;
}

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSDictionary *dataSourceDic;

@property (nonatomic, strong) NSMutableArray *dataSourceArr;

@end

@implementation SYChakanGrapherViewController

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self.tableView reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _count = 1;
    [self getData];
    [self.view addSubview:self.tableView];
    self.view.backgroundColor = [UIColor whiteColor];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.dataSourceArr.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    SYCloudContentTableViewCell *cell = [SYCloudContentTableViewCell cellWithTableView:tableView];

    cell.uid = self.uid;
    SYCloudContentFrameModel *frameModel = self.dataSourceArr[indexPath.section];
    SYCloudModel *cloudModel = frameModel.cloudModel;
    _currentCloudModel = cloudModel;
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
                    commentVC.frameModel = frameModel;
                    commentVC.cloudID = weakCloudModel.ID;
                    [weakself.navigationController pushViewController:commentVC animated:YES];
                }else{
                    SYCommentListViewController *commentList = [[SYCommentListViewController alloc] initWithNibName:@"SYCommentListViewController" bundle:nil];
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

#pragma mark - 删除评论的事件方法
- (void)deleteCommentActionWithUrl:(NSString *)url param:(NSDictionary *)param IndexPath:(NSIndexPath *)indexpath superIndexpath:(NSIndexPath *)superIndexpath{
    
    [[SYHttpRequest sharedInstance] getDataWithUrl:url Parameter:param ResponseObject:^(NSDictionary *responseResult) {
        
        NSLog(@"删除评论 -- %@",responseResult);
        if ([responseResult objectForKey:@"resError"]) {
            [self showHint:@"服务器不给力，请稍后重试"];
        }else{
            if ([[responseResult objectForKey:@"result"] integerValue] == 1) {
                SYCloudContentFrameModel *frameModel = self.dataSourceArr[superIndexpath.section];
                SYCloudModel *model = frameModel.cloudModel;
                NSInteger reply_count = [model.reply_count integerValue];
                model.reply_count = [NSNumber numberWithInteger:reply_count-1];
                NSMutableArray *muReply = [NSMutableArray arrayWithArray:model.reply];
                [muReply removeObjectAtIndex:indexpath.row];
                model.reply = muReply;
                NSLog(@"cloudModel.reply - %@",model.reply);
                frameModel.cloudModel = model;
                [self.dataSourceArr replaceObjectAtIndex:superIndexpath.section withObject:frameModel];
                
                [self.tableView reloadData];
                
            }else{
                if ([responseResult objectForKey:@"msg"]) {
                    [self showHint:[responseResult objectForKey:@"msg"]];
                }
            }
        }
    }];
    
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
    NSString *url = [NSString stringWithFormat:@"http://m.yunxiangguan.cn/photoShow02.html?id=%@&history=index&app=app",_currentCloudModel.ID];
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


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    SYGrapherInfosViewController *grapherinfos = [[SYGrapherInfosViewController alloc] init];
    grapherinfos.isFirst = YES;
    grapherinfos.isFromShouye = YES;
    SYCloudContentFrameModel *frameModel = self.dataSourceArr[indexPath.section];
    grapherinfos.uid = self.uid;
    grapherinfos.grapherID = frameModel.cloudModel.ID;
    grapherinfos.frameModel = frameModel;
    [self.navigationController pushViewController:grapherinfos animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    SYCloudContentFrameModel *frameModel = self.dataSourceArr[indexPath.section];
    return frameModel.cellHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        UILabel *label = [[UILabel alloc] init];
        label.text = [self.dataSourceDic objectForKey:@"info"];
        label.font = [UIFont systemFontOfSize:13];
        label.numberOfLines = 0;
        CGSize maxSize = [label sizeThatFits:CGSizeMake(kScreenWidth - 30 - 98 -10, MAXFLOAT)];
        
        return 30 + 39 + 17 + 21 + 43 + maxSize.height + 35 + 20;
    }
    
    return 0.0001f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (section != 0) {
        UIView *view = [[UIView alloc] init];
        view.backgroundColor = [UIColor whiteColor];
        return view;
    }
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor whiteColor];
    
    UIView *upView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 30)];
    upView.backgroundColor = [UIColor whiteColor];
    [view addSubview:upView];
    
    
    UILabel *label11 = [[UILabel alloc] init];
    label11.text = [self.dataSourceDic objectForKey:@"info"];
    label11.font = [UIFont systemFontOfSize:13];
    label11.numberOfLines = 0;
    CGSize maxSize = [label11 sizeThatFits:CGSizeMake(kScreenWidth - 30 - 98 -10, MAXFLOAT)];
    
    UIView *middleView = [[UIView alloc] initWithFrame:CGRectMake(0, 30, kScreenWidth, 39 + 17 + 21 + maxSize.height + 43)];
    UIImage *image = [UIImage imageNamed:@"faxian_xiangqing_bg"];
    middleView.layer.contents = (id)image.CGImage;
    [view addSubview:middleView];
    //头像
    UIImageView *headIMG = [[UIImageView alloc] initWithFrame:CGRectMake(15, 27, 98, 98)];

    [headIMG sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",ImgUrl,[self.dataSourceDic objectForKey:@"head"]]] placeholderImage:[UIImage imageNamed:@"faxian_xiangqing_photo"]];
    headIMG.layer.masksToBounds = YES;
    headIMG.layer.cornerRadius = 98 / 2;
    [middleView addSubview:headIMG];
    //名字
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(headIMG.frame) + 10, 39, kScreenWidth - 30 - 98 -10, 18)];
    nameLabel.text = [self.dataSourceDic objectForKey:@"nick"];
    nameLabel.font = [UIFont systemFontOfSize:17];
    nameLabel.textAlignment = NSTextAlignmentCenter;
    [middleView addSubview:nameLabel];
    //简介
    UILabel *intro = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(headIMG.frame) + 10, CGRectGetMaxY(nameLabel.frame) + 21, kScreenWidth - 30 - 98 -10, maxSize.height)];
    intro.numberOfLines = 0;
    intro.text = [self.dataSourceDic objectForKey:@"info"];
    intro.textAlignment = NSTextAlignmentCenter;
    intro.font = [UIFont systemFontOfSize:13];
    [middleView addSubview:intro];

    
    UIView *downView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(middleView.frame), kScreenWidth, 35)];
    UIImageView *imageview = [[UIImageView alloc] initWithFrame:CGRectMake(10, 0, 35, 35)];
    imageview.image = [UIImage imageNamed:@"faxian_xiangqing_icon_camera"];
    imageview.contentMode = UIViewContentModeScaleAspectFit;
    [downView addSubview:imageview];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(imageview.frame) + 5, 7, 65, 21)];
    label.text = @"作品集";
    label.font = [UIFont systemFontOfSize:14];
    [downView addSubview:label];
    
    UIImageView *xingji = [[UIImageView alloc] initWithFrame:CGRectMake(kScreenWidth - 94, 5, 84, 25)];
    xingji.contentMode = UIViewContentModeCenter;
    if ([[self.dataSourceDic objectForKey:@"lv"] integerValue] == 1) {
        xingji.image = [UIImage imageNamed:@"xingji-one"];
    }else if ([[self.dataSourceDic objectForKey:@"lv"] integerValue] == 2){
        xingji.image = [UIImage imageNamed:@"xingji-two"];
    }else if ([[self.dataSourceDic objectForKey:@"lv"] integerValue] == 3){
        xingji.image = [UIImage imageNamed:@"xingji-three"];
    }
    [downView addSubview:xingji];
    UILabel *xingjilabel = [[UILabel alloc] initWithFrame:CGRectMake(kScreenWidth - 170, 7, 76, 21)];
    xingjilabel.text = @"当前等级：";
    xingjilabel.font = [UIFont systemFontOfSize:14];
    [downView addSubview:xingjilabel];
    
    [view addSubview:downView];
    
    UIView *view111 = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(downView.frame), kScreenWidth, 20)];
    view111.backgroundColor = RGB(234, 234, 234);
    [view addSubview:view111];
    
    return view;
}
 

- (void)getData{
    [SVProgressHUD show];
    NSString *url = [NSString stringWithFormat:@"%@%@",BaseUrl,@"/pho/amigo.html"];
    NSDictionary *param = nil;
    if (self.isFromMyGuanZhu) {
        if (LoginStatus) {
            param = @{@"token":UserToken, @"id":[self.userDic objectForKey:@"uid"], @"page":@1};
        }else{
            param = @{@"id":[self.userDic objectForKey:@"uid"], @"page":@1};
        }
    }else{
        if (LoginStatus) {
            param = @{@"token":UserToken, @"id":[self.userDic objectForKey:@"id"], @"page":@1};
        }else{
            param = @{@"id":[self.userDic objectForKey:@"id"], @"page":@1};
        }
    }
    [[SYHttpRequest sharedInstance] getDataWithUrl:url Parameter:param ResponseObject:^(NSDictionary *responseResult) {
        [SVProgressHUD dismiss];
        if ([_tableView.mj_header isRefreshing]) {
            [_tableView.mj_header endRefreshing];
        }
        NSLog(@"摄影师作品集 -- %@",responseResult);
        if ([responseResult objectForKey:@"resError"]) {
            [self showHint:@"服务器不给力，请稍后重试"];
        }else{
            if ([[responseResult objectForKey:@"result"] integerValue] == 1) {
                
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
                }
                self.dataSourceDic = [responseResult objectForKey:@"user"];
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
    NSString *url = [NSString stringWithFormat:@"%@%@",BaseUrl,@"/pho/amigo.html"];
    NSDictionary *param = nil;
    if (self.isFromMyGuanZhu) {
        param = @{@"id":[self.userDic objectForKey:@"uid"], @"page":[NSNumber numberWithInteger:_count]};
    }else{
        param = @{@"id":[self.userDic objectForKey:@"id"], @"page":[NSNumber numberWithInteger:_count]};
    }

    
    [[SYHttpRequest sharedInstance] getDataWithUrl:url Parameter:param ResponseObject:^(NSDictionary *responseResult) {
        [_tableView.mj_footer endRefreshing];
        NSLog(@"摄影师作品集 -- %@",responseResult);
        if ([responseResult objectForKey:@"resError"]) {
            _count --;
            
            [self showHint:@"服务器不给力，请稍后重试"];
        }else{
            if ([[responseResult objectForKey:@"result"] integerValue] == 1) {
                
                NSArray *data = [responseResult objectForKey:@"data"];
                if (data.count < 10) {
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
                
            }else{
                _count --;
                if ([responseResult objectForKey:@"msg"]) {
                    [self showHint:[responseResult objectForKey:@"msg"]];
                }
            }
        }
    }];
}

- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight - kNavigationBarHeightAndStatusBarHeight) style:UITableViewStyleGrouped];
        _tableView.backgroundColor = RGB(234, 234, 234);
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.showsVerticalScrollIndicator = NO;
        [_tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
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
