//
//  SYCloudViewController.m
//  ShuoYing
//
//  Created by 硕影 on 2016/12/26.
//  Copyright © 2016年 硕影. All rights reserved.
//

#import "SYCloudViewController.h"
#import "SYLoginViewController.h"

#import "SYLabelTableViewCell.h"

#import "SYUpdateViewController.h"

#import "SYCloudTableViewCell.h"
#import "SYCloudModel.h"

#import "SYUserInfos.h"

#import <CoreLocation/CoreLocation.h>
#import "UIView+BadgeValue.h"
#import "SYGrapherInfosViewController.h"
#import "SYMessageViewController.h"
#import "SYSearchViewController.h"
#import "SYSelectCityAlert.h"
#import "SYUpdateMineViewController.h"

#import "SDCycleScrollView.h"
#import "CCPScrollView.h"

#import "SYGuangGaoWebViewController.h"

#import "SYFindViewController.h"
#import "SYBisnessViewController.h"
#import "SYRedBagViewController.h"
//带评论的首页
#import "SYCloudContentFrameModel.h"
#import "SYCloudContentTableViewCell.h"
#import "SYCommentViewController.h"//评论
#import "SYCommentListViewController.h"//评论列表
#import "SYZanViewController.h"//点赞列表
//分享
#import "QTShareView.h"
#import "DeleteOrderView.h"

@interface SYCloudViewController ()<UITableViewDelegate,UITableViewDataSource,UIScrollViewDelegate, CLLocationManagerDelegate, XLPhotoBrowserDelegate, XLPhotoBrowserDatasource,SDCycleScrollViewDelegate,QTShareViewDelegate>

{
    
    NSURLSessionTask *_dataTask;
    
    UIButton *_leftBtn;
    UILabel *_rightLabel;
    
    UIView *_badgeView;
    
    NSArray *_allCitys;
    
    NSNumber *_uid;//回复的人的uid
    
    SYCloudModel *_currentCloudModel;

}

@property (nonatomic, strong) CLLocationManager *locationManager;

@property (nonatomic, strong) NSTimer *timer;//轮播定时器

@property (nonatomic, strong) NSMutableArray *pictureDataSource;

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *dataSoucreArr;

@property (nonatomic, assign) NSInteger page;

@property (nonatomic, strong) SDCycleScrollView *bannerView;

@property (nonatomic, strong) NSMutableArray *gundongArr;

@end

@implementation SYCloudViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    self.tabBarController.navigationController.navigationBar.translucent = NO;
    self.tabBarController.navigationItem.leftBarButtonItem = self.leftBarItem;
    self.tabBarController.navigationItem.rightBarButtonItem = self.rightBarItem;
    self.tabBarController.navigationItem.titleView = self.titleView;
    [self.bannerView adjustWhenControllerViewWillAppera];
    if (LoginStatus) {
        [self getUserInfos];
        [self getUnreadMessage];
    }
    [self getGunDongMessage];

}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self.tableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.page = 1;
    [self.view addSubview:self.tableView];
    [self loadLeftTabbar];
    [self loadRightTarbar];
    [self getDataFromCache];
    
    [self getData];
    [self loadSoliderPicture];
    //定位
//    [self getLocation];
    [self getAllLocation];
    [self initializeLocationService];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginOut) name:@"LoginOut" object:nil];
}

//退出登陆
- (void)loginOut{
    _badgeView.fl_badgeValue = @"0";
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
}

//从本地取出数据
- (void)getDataFromCache{
    
    if (!isFirstActionApp) {
        id result = [XHNetworkCache cacheJsonWithURL:@"SoliderPicture"];
        if (result) {
            NSDictionary *resultDic = (NSDictionary *)result;
            if ([[resultDic objectForKey:@"status"] integerValue] == 0) {
                NSArray *data = [resultDic objectForKey:@"data"];
                [self.pictureDataSource removeAllObjects];
                
                for (NSDictionary *dic in data) {
                    NSString *img_url = [NSString stringWithFormat:@"%@%@",ImgUrl,[dic objectForKey:@"img"]];
                    NSMutableDictionary *mudic = [NSMutableDictionary dictionaryWithCapacity:0];
                    [mudic setDictionary:dic];
                    [mudic setObject:img_url forKey:@"img"];
                    [mudic setObject:[dic objectForKey:@"url"] forKey:@"url"];
                    [self.pictureDataSource addObject:mudic];
                }
                
            }
        }
    }
    
    NSDictionary *responseResult = [XHNetworkCache cacheJsonWithURL:[NSString stringWithFormat:@"%@/%@",Mobile,@"CloudPhoto"]];
    NSArray *data = [responseResult objectForKey:@"data"];
    if (data.count > 0) {
        [self.dataSoucreArr removeAllObjects];
        for (NSDictionary *dic in data) {
            SYCloudModel *model = [SYCloudModel cloudWithDictionary:dic];
            SYCloudContentFrameModel *frameModel = [[SYCloudContentFrameModel alloc] init];
            frameModel.cloudModel = model;
            [self.dataSoucreArr addObject:frameModel];
        }
    }
    [self.tableView reloadData];
}

#pragma mark - SDCycleScrollViewDelegate

- (void)cycleScrollView:(SDCycleScrollView *)cycleScrollView didSelectItemAtIndex:(NSInteger)index
{
    //点击轮播图判断是否跳转订制页面
    NSDictionary *dic = self.pictureDataSource[index];
    
    if ([[dic objectForKey:@"url"] isKindOfClass:[NSString class]]) {
        NSString *url = [dic objectForKey:@"url"];
        if ([url isEqualToString:@"dingzhi"]) {
            SYBisnessViewController *buiness = [[SYBisnessViewController alloc] init];
            buiness.photoID = @1;
            [self.navigationController pushViewController:buiness animated:YES];
        }else{
            XLPhotoBrowser *brower = [XLPhotoBrowser showPhotoBrowserWithCurrentImageIndex:index imageCount:self.pictureDataSource.count datasource:self];
            
            brower.browserStyle = XLPhotoBrowserStylePageControl;
            brower.currentPageDotColor = NavigationColor;
        }
    }else{
        XLPhotoBrowser *brower = [XLPhotoBrowser showPhotoBrowserWithCurrentImageIndex:index imageCount:self.pictureDataSource.count datasource:self];
        
        brower.browserStyle = XLPhotoBrowserStylePageControl;
        brower.currentPageDotColor = NavigationColor;
    }
    
}

- (NSURL *)photoBrowser:(XLPhotoBrowser *)browser highQualityImageURLForIndex:(NSInteger)index{
    return [NSURL URLWithString:[self.pictureDataSource[index] objectForKey:@"img"]];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.dataSoucreArr.count + 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        static NSString *indetifier = @"cell";
        SYLabelTableViewCell *cell = [[NSBundle mainBundle] loadNibNamed:@"SYLabelTableViewCell" owner:nil options:nil][0];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.click = ^(NSInteger btnType){
            if (!LoginStatus) {
                SYLoginViewController *login = [[SYLoginViewController alloc] initWithNibName:@"SYLoginViewController" bundle:nil];
                [self.navigationController pushViewController:login animated:YES];
                return ;
            }
            switch (btnType) {
                case 1111:
                {
                    SYUpdateMineViewController *mine = [[SYUpdateMineViewController alloc] init];
                    [self.navigationController pushViewController:mine animated:YES];
                }
                    break;
                case 2222:
                {
                    SYFindViewController *photo = [[SYFindViewController alloc] init];
                    [self.navigationController pushViewController:photo animated:YES];
                }
                    break;
                case 3333:
                {
                    SYBisnessViewController *buiness = [[SYBisnessViewController alloc] init];
                    buiness.photoID = @1;
                    [self.navigationController pushViewController:buiness animated:YES];
                    
                }
                    break;
                case 4444:
                {
                    SYUpdateViewController *updateVC = [[SYUpdateViewController alloc] init];
                    
                    [self.navigationController pushViewController:updateVC animated:YES];
                    
                }
                    break;
                default:
                    break;
            }
        };
        if (!cell) {
            cell = [[SYLabelTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:indetifier];
        }
        
        return cell;
    }else{

        SYCloudContentTableViewCell *cell = [SYCloudContentTableViewCell cellWithTableView:tableView];
        cell.imagesView.userInteractionEnabled =NO;
        
        cell.uid = _uid;
        SYCloudContentFrameModel *frameModel = self.dataSoucreArr[indexPath.section - 1];
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
                    SYCloudContentFrameModel *frameModel = self.dataSoucreArr[indexPath.section - 1];
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
        
        cell.frameModel = self.dataSoucreArr[indexPath.section - 1];
        return cell;
    }
    
    return nil;
}

#pragma mark - 删除评论的事件方法
- (void)deleteCommentActionWithUrl:(NSString *)url param:(NSDictionary *)param IndexPath:(NSIndexPath *)indexpath superIndexpath:(NSIndexPath *)superIndexpath{
    
    [[SYHttpRequest sharedInstance] getDataWithUrl:url Parameter:param ResponseObject:^(NSDictionary *responseResult) {
        
        NSLog(@"删除评论 -- %@",responseResult);
        if ([responseResult objectForKey:@"resError"]) {
            [self showHint:@"服务器不给力，请稍后重试"];
        }else{
            if ([[responseResult objectForKey:@"result"] integerValue] == 1) {
                SYCloudContentFrameModel *frameModel = self.dataSoucreArr[superIndexpath.section - 1];
                SYCloudModel *cloudModel = frameModel.cloudModel;
                NSMutableArray *muReply = [NSMutableArray arrayWithArray:cloudModel.reply];
                [muReply removeObjectAtIndex:indexpath.row];
                
                cloudModel.reply = muReply;
                NSInteger reply_count = [cloudModel.reply_count integerValue];
                cloudModel.reply_count = [NSNumber numberWithInteger:reply_count - 1];
                frameModel.cloudModel = cloudModel;
                
                [self.dataSoucreArr replaceObjectAtIndex:superIndexpath.section - 1 withObject:frameModel];
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
                    [self.dataSoucreArr removeObjectAtIndex:indexpath.section - 1];
                    [self.tableView reloadData];
                }else{
                    SYCloudContentFrameModel *frameModel = self.dataSoucreArr[indexpath.section - 1];
                    
                    SYCloudModel *cloudModel = frameModel.cloudModel;
                    if ([cloudModel.follow integerValue] == 0) {
                        for (SYCloudContentFrameModel *cloudFrameModel in self.dataSoucreArr) {
                            SYCloudModel *cloudModel111 = cloudFrameModel.cloudModel;
                            if ([cloudModel111.uid integerValue] == [cloudModel.uid integerValue]) {
                                cloudModel.follow = @1;
                                cloudFrameModel.cloudModel = cloudModel;
                            }
                        }
                        cloudModel.follow = @1;
                        [cell.guanzhuBtn setImage:[UIImage imageNamed:@"shouye_follow"] forState:UIControlStateNormal];
                        
                    }else{
                        for (SYCloudContentFrameModel *cloudFrameModel in self.dataSoucreArr) {
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
                
                SYCloudContentFrameModel *frameModel = self.dataSoucreArr[indexpath.section - 1];
                
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

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        return 100;
    }else{
        SYCloudContentFrameModel *frameModel = self.dataSoucreArr[indexPath.section - 1];
//        return 90 + (kScreenWidth - 50) / 3 + 20;
        return frameModel.cellHeight;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        if (self.gundongArr.count > 0) {
            return kScreenWidth / 2 + 50;
        }
        return kScreenWidth / 2;
    }
    return 0.00001f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 13;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (self.pictureDataSource.count == 0) {
        return nil;
    }
    if (section == 0) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenWidth / 2)];
        
        [view addSubview:self.bannerView];
        NSMutableArray *imagesArr = [NSMutableArray arrayWithCapacity:0];
        for (NSDictionary *dic in self.pictureDataSource) {
            NSString *imgUrl = [dic objectForKey:@"img"];
            [imagesArr addObject:imgUrl];
        }
        self.bannerView.imageURLStringsGroup = imagesArr;
        
        
        if (self.gundongArr.count > 0) {
            UIView *aaa = [[UIView alloc] initWithFrame:CGRectMake(0, kScreenWidth / 2, kScreenWidth, 50)];
            aaa.backgroundColor = HexRGB(0xfbfbfb);
            
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 50)];
            imageView.image = [UIImage imageNamed:@"news_icon"];
            imageView.contentMode = UIViewContentModeCenter;
            [aaa addSubview:imageView];
            
            NSMutableArray *titles = [NSMutableArray arrayWithCapacity:0];
            for (NSDictionary *dic in self.gundongArr) {
                NSString *title = [dic objectForKey:@"title"];
                [titles addObject:title];
            }
            
            CCPScrollView *ccpView = [[CCPScrollView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(imageView.frame) + 5, 0, kScreenWidth - 75, 50)];
            ccpView.titleArray = titles;
            ccpView.titleFont = 14;
            ccpView.titleColor = HexRGB(0x434343);
            ccpView.BGColor = HexRGB(0xfbfbfb);
            __weak typeof(self)weakself = self;
            [ccpView clickTitleLabel:^(NSInteger index, NSString *titleString) {
                [self.gundongArr addObject:[self.gundongArr firstObject]];
                //判断是不是红包消息
                NSDictionary *dic = self.gundongArr[index];
                if ([[dic objectForKey:@"state"] integerValue] == 1) {
                    if (!LoginStatus) {
                        SYLoginViewController *login = [[SYLoginViewController alloc] initWithNibName:@"SYLoginViewController" bundle:nil];
                        [self.navigationController pushViewController:login animated:YES];
                        return ;
                    }
                    
                    SYRedBagViewController *redbag = [[SYRedBagViewController alloc] init];
                    redbag.redbagID = [dic objectForKey:@"id"];
                    [self.navigationController pushViewController:redbag animated:YES];
                    
                }else{
                    SYGuangGaoWebViewController *guanggao = [[SYGuangGaoWebViewController alloc] init];
                    //把第一个元素添加到末尾
                    guanggao.gundongID = [self.gundongArr[index] objectForKey:@"id"];
                    guanggao.title = titleString;
                    [weakself.navigationController pushViewController:guanggao animated:YES];
                }
                
                
                
            }];
            [aaa addSubview:ccpView];
            
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            [btn setImage:[UIImage imageNamed:@"shouye_close"] forState:UIControlStateNormal];
            btn.frame = CGRectMake(kScreenWidth - 40, 0, 40, 50);
            [btn addTarget:self action:@selector(moveGunDong:) forControlEvents:UIControlEventTouchUpInside];
            [aaa addSubview:btn];
            
            [view addSubview:aaa];
        }
        
        return view;
    }
    return nil;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = HexRGB(0xf3f3f3);
    return view;
}

- (void)moveGunDong:(UIButton *)sender{
    [self.gundongArr removeAllObjects];
    [self.tableView reloadData];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section != 0) {
        if (self.dataSoucreArr.count > 0) {

            
            SYGrapherInfosViewController *grapherinfos = [[SYGrapherInfosViewController alloc] init];
            SYCloudContentFrameModel *frameModel = self.dataSoucreArr[indexPath.section - 1];
            SYCloudModel *model = frameModel.cloudModel;
            _currentCloudModel = model;

            grapherinfos.uid = _uid;
            grapherinfos.grapherID = model.ID;
            grapherinfos.isFromShouye = YES;
            grapherinfos.frameModel = frameModel;
            [self.navigationController pushViewController:grapherinfos animated:YES];
        }
    }
}


#pragma mark - LoadTabbar
- (void)loadLeftTabbar{

    UIView *bageView = [[UIView alloc] initWithFrame:CGRectMake(-15, 0, 25, 28)];
    _badgeView = bageView;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(xiaoxiAction)];
    bageView.userInteractionEnabled = YES;
    [bageView addGestureRecognizer:tap];

    UIImage *image = [UIImage imageNamed:@"shouye_icon_xiaoxi"];
    bageView.layer.contents = (id)image.CGImage;
    bageView.fl_badgeValue = @"0";
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    item.width = -15;
    self.leftBarItem = [[UIBarButtonItem alloc] initWithCustomView:bageView];
   
}

- (void)loadRightTarbar{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
    view.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dingweiAction:)];
    [view addGestureRecognizer:tap];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 44, 44-13)];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.image = [UIImage imageNamed:@"shouye_icon_dizhi"];
    [view addSubview:imageView];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(view.frame) - 13, 44, 13)];
    label.text = @"定位";
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize:13];
    label.textColor = [UIColor whiteColor];
    _rightLabel = label;
    [view addSubview:label];

    self.rightBarItem = [[UIBarButtonItem alloc] initWithCustomView:view];
}

//消息
- (void)xiaoxiAction{
    if (!LoginStatus) {
        SYLoginViewController *login = [[SYLoginViewController alloc] initWithNibName:@"SYLoginViewController" bundle:nil];
        [self.navigationController pushViewController:login animated:YES];
        return ;
    }
    SYMessageViewController *message = [[SYMessageViewController alloc] init];
    [self.navigationController pushViewController:message animated:YES];
}

//定位
- (void)dingweiAction:(UITapGestureRecognizer *)tap{
//    NSDictionary *lastSelectedValue = nil;
//    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"seletedProvinceAndCity"]) {
//        lastSelectedValue = [[NSUserDefaults standardUserDefaults] objectForKey:@"seletedProvinceAndCity"];
//    }
//    
//    [SYSelectCityAlert showWithTitle:@"选择省市" titles:_allCitys selectIndex:^(NSDictionary *selectCityDic) {
//        NSLog(@"selectCityDic - %@",selectCityDic);
//        if ([[selectCityDic objectForKey:@"city"] length] > 3) {
//            _rightLabel.font = [UIFont systemFontOfSize:10];
//        }else{
//            _rightLabel.font = [UIFont systemFontOfSize:13];
//
//        }
//        _rightLabel.text = [selectCityDic objectForKey:@"city"];
//
//        NSUserDefaults *us = [NSUserDefaults standardUserDefaults];
//        [us setObject:selectCityDic forKey:@"seletedProvinceAndCity"];
//        [us synchronize];
//        
//    } lastTimeSelectedValue:lastSelectedValue];

}

#pragma mark - GetData
- (void)getData{
    self.page = 1;
    NSDictionary *param = nil;
    if (LoginStatus) {
        param = @{@"page":@1, @"token":UserToken};
    }else{
        param = @{@"page":@1};
    }
    NSString *url = [NSString stringWithFormat:@"%@%@",BaseUrl,@"/get/amigo.html"];
    _dataTask = [[SYHttpRequest sharedInstance] getDataWithUrl:url Parameter:param ResponseObject:^(NSDictionary *responseResult) {
        if ([_tableView.mj_header isRefreshing]) {
            [_tableView.mj_header endRefreshing];
        }
        NSLog(@"首页摄影师展示 -- %@",responseResult);
        if ([responseResult objectForKey:@"resError"]) {
            [self showHint:@"服务器不给力，请稍后重试"];
        }else{
            if ([[responseResult objectForKey:@"result"] integerValue] == 1) {
                
                [XHNetworkCache saveJsonResponseToCacheFile:responseResult andURL:[NSString stringWithFormat:@"%@/%@",Mobile,@"CloudPhoto"]];
                _uid = (NSNumber *)[responseResult objectForKey:@"uid"];
                NSArray *data = [responseResult objectForKey:@"data"];
                if (data.count >= 10) {
                    [_tableView.mj_footer resetNoMoreData];
                }
                if (data.count > 0) {
                    [self.dataSoucreArr removeAllObjects];
                    for (NSDictionary *dic in data) {
                        SYCloudModel *model = [SYCloudModel cloudWithDictionary:dic];
                        SYCloudContentFrameModel *frameModel = [[SYCloudContentFrameModel alloc] init];
                        frameModel.cloudModel = model;
                        [self.dataSoucreArr addObject:frameModel];
                    }
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
    self.page ++;
    
    NSDictionary *param = nil;
    if (LoginStatus) {
        param = @{@"page":[NSNumber numberWithInteger:self.page], @"token":UserToken};
    }else{
        param = @{@"page":[NSNumber numberWithInteger:self.page]};
    }

    NSString *url = [NSString stringWithFormat:@"%@%@",BaseUrl,@"/get/amigo.html"];

    _dataTask = [[SYHttpRequest sharedInstance] getDataWithUrl:url Parameter:param ResponseObject:^(NSDictionary *responseResult) {
        [_tableView.mj_footer endRefreshing];
        NSLog(@"首页摄影师展示更多 -- %@",responseResult);
        if ([responseResult objectForKey:@"resError"]) {
            self.page --;
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
                        [self.dataSoucreArr addObject:frameModel];
                    }
                    [self.tableView reloadData];
                    return ;
                }
                if (data.count > 0) {
                    
                    for (NSDictionary *dic in data) {
                        SYCloudModel *model = [SYCloudModel cloudWithDictionary:dic];
                        SYCloudContentFrameModel *frameModel = [[SYCloudContentFrameModel alloc] init];
                        frameModel.cloudModel = model;
                        [self.dataSoucreArr addObject:frameModel];
                    }
                }
                
                [self.tableView reloadData];
                
            }else{
                self.page --;
                if ([responseResult objectForKey:@"msg"]) {
                    [self showHint:[responseResult objectForKey:@"msg"]];
                }
            }
        }
    }];
}

//获取用户信息
- (void)getUserInfos{
    
    NSString *url = [NSString stringWithFormat:@"%@%@",BaseUrl,@"/user/user.html"];
    NSDictionary *param = @{@"token":UserToken};
    [[SYHttpRequest sharedInstance] getDataWithUrl:url Parameter:param ResponseObject:^(NSDictionary *responseResult) {
        if ([_tableView.mj_header isRefreshing]) {
            [_tableView.mj_header endRefreshing];
        }
        
        NSLog(@"获取用户信息 -- %@",responseResult);
        if ([responseResult objectForKey:@"resError"]) {
            
        }else{
            if ([[responseResult objectForKey:@"result"] integerValue] == 1) {
                NSDictionary *data = [responseResult objectForKey:@"data"];
                SYUserInfos *userinfos = [SYUserInfos userinfosWithDictionry:data];
                //归档
                [[Tool sharedInstance] saveObject:userinfos WithPath:[NSString stringWithFormat:@"%@",Mobile]];
                
            }else{
                if ([responseResult objectForKey:@"msg"]) {
                    [self showHint:[responseResult objectForKey:@"msg"]];
                }
            }
        }
    }];
}

//获取未读消息统计
- (void)getUnreadMessage{
    NSString *url = [NSString stringWithFormat:@"%@%@",BaseUrl,@"/user/read.html"];
    NSDictionary *param = @{@"token":UserToken};
    [[SYHttpRequest sharedInstance] getDataWithUrl:url Parameter:param ResponseObject:^(NSDictionary *responseResult) {
        
        NSLog(@"获取未读消息 -- %@",responseResult);
        if ([responseResult objectForKey:@"resError"]) {
            
        }else{
            if ([[responseResult objectForKey:@"result"] integerValue] == 1) {
                if ([responseResult objectForKey:@"count"]) {
                    NSInteger count = [[responseResult objectForKey:@"count"] integerValue];
                    
                    if (count == 0) {
                        [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
                        _badgeView.fl_badgeValue = @"0";
                    }else{
                        [UIApplication sharedApplication].applicationIconBadgeNumber = count;
                        _badgeView.fl_badgeValue = [NSString stringWithFormat:@"%ld",(long)count];
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

//轮播图
- (void)loadSoliderPicture{
    NSString *url = [NSString stringWithFormat:@"%@%@",BaseUrl,@"/get/banner.html"];
    
    __weak typeof(self)weakself = self;
    
    AFHTTPSessionManager *sessionManager = [AFHTTPSessionManager manager];
    
    sessionManager.requestSerializer.timeoutInterval = 10.f;
    
    sessionManager.responseSerializer = [AFHTTPResponseSerializer serializer];
    sessionManager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/json",@"text/html",@"text/javascript", nil];
    NSString *str = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [sessionManager POST:str parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([weakself.tableView.mj_header isRefreshing]) {
            [weakself.tableView.mj_header endRefreshing];
        }
        
        id result = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil];
        //把数据缓存在本地
        [XHNetworkCache save_asyncJsonResponseToCacheFile:result andURL:@"SoliderPicture" completed:^(BOOL result) {
            NSLog(@"SoliderPicture Cache - %d",result);
        }];
        if ([result isKindOfClass:[NSDictionary class]]) {
            NSDictionary *resultDic = (NSDictionary *)result;
            NSLog(@"轮播图Dic -- %@",resultDic);
            
            if ([[resultDic objectForKey:@"status"] integerValue] == 0) {
                NSArray *data = [resultDic objectForKey:@"data"];
                [weakself.pictureDataSource removeAllObjects];
                
                for (NSDictionary *dic in data) {
                    NSString *img_url = [NSString stringWithFormat:@"%@%@",ImgUrl,[dic objectForKey:@"img"]];
                    NSMutableDictionary *mudic = [NSMutableDictionary dictionaryWithCapacity:0];
                    [mudic setDictionary:dic];
                    [mudic setObject:img_url forKey:@"img"];
                    [mudic setObject:[dic objectForKey:@"url"] forKey:@"url"];
                    [weakself.pictureDataSource addObject:mudic];
                }
                [weakself.tableView reloadData];
                
            }else{
                if ([weakself.tableView.mj_header isRefreshing]) {
                    [weakself.tableView.mj_header endRefreshing];
                }
                if ([resultDic objectForKey:@"msg"]) {
                    [weakself showHint:[resultDic objectForKey:@"msg"]];
                }else{
                    [weakself showHint:@"获取数据失败"];
                }
            }
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if ([weakself.tableView.mj_header isRefreshing]) {
            [weakself.tableView.mj_header endRefreshing];
        }
        NSLog(@"连接超时");
        
    }];
    
}

- (void)getGunDongMessage{
    NSString *url = [NSString stringWithFormat:@"%@%@",BaseUrl,@"/get/msglist.html"];
    NSDictionary *param = @{@"state":@1};
    [[SYHttpRequest sharedInstance] getDataWithUrl:url Parameter:param ResponseObject:^(NSDictionary *responseResult) {
        
        NSLog(@"获取滚动消息 -- %@",responseResult);
        if ([responseResult objectForKey:@"resError"]) {
            
        }else{
            if ([responseResult objectForKey:@"result"] && [[responseResult objectForKey:@"result"] integerValue] == 1) {
                NSArray *data = [responseResult objectForKey:@"data"];
                [self.gundongArr addObjectsFromArray:data];
                [self.tableView reloadData];
            }else{
                
            }
            
        }
    }];
}

//获取当前城市
- (void)getLocation{
    NSString *url = [NSString stringWithFormat:@"%@%@",BaseUrl,@"/logon/city.html"];
    [[SYHttpRequest sharedInstance] getDataWithUrl:url Parameter:nil ResponseObject:^(NSDictionary *responseResult) {
        
        NSLog(@"获取定位城市 -- %@",responseResult);
        if ([responseResult objectForKey:@"resError"]) {
            
        }else{
            _rightLabel.text = [responseResult objectForKey:@"city"];

        }
    }];
}

- (void)getAllLocation
{
    AFHTTPSessionManager *sessionManager = [AFHTTPSessionManager manager];
    sessionManager.responseSerializer = [AFHTTPResponseSerializer serializer];
    sessionManager.requestSerializer.timeoutInterval = 10.f;
    sessionManager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/json",@"text/html",@"text/javascript", nil];
    NSString *urlString = [NSString stringWithFormat:@"%@%@",BaseUrl,@"/logon/zone.html"];
    NSString *str = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    [sessionManager POST:str parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        id result = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil];
//        NSLog(@"所有城市 - %@",result);
        
        if ([result isKindOfClass:[NSArray class]]) {
            NSArray *resultArr = (NSArray *)result;
            _allCitys = resultArr;
            
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
}

#pragma mark - CLLocation
- (void)initializeLocationService{
    //初始化定位管理器
    _locationManager = [[CLLocationManager alloc] init];
    //设置代理
    _locationManager.delegate = self;
    //设置定位精确到米
    _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    //设置过滤器为无
    _locationManager.distanceFilter = 10.0f;
    [_locationManager requestAlwaysAuthorization];
    //开始定位
    [_locationManager startUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray *)locations
{
    NSLog(@"%lu", (unsigned long)[locations count]);
    
    CLLocation *newLocation = [locations lastObject];
//    CLLocationCoordinate2D oldCoordinate = newLocation.coordinate;
    
//    CLLocation *newLocation = locations[1];
    CLLocationCoordinate2D newCoordinate = newLocation.coordinate;
    NSLog(@"经度：%f,纬度：%f",newCoordinate.longitude,newCoordinate.latitude);
    
    float jingdu = newCoordinate.longitude;
    float weidu = newCoordinate.latitude;
    NSUserDefaults *us = [NSUserDefaults standardUserDefaults];
    [us setObject:[NSNumber numberWithFloat:jingdu] forKey:@"jingdu"];
    [us setObject:[NSNumber numberWithFloat:weidu] forKey:@"weidu"];
    [us synchronize];
    
    // 计算两个坐标距离
    //    float distance = [newLocation distanceFromLocation:oldLocation];
    //    NSLog(@"%f",distance);
    
//    [manager stopUpdatingLocation];
    
    //------------------位置反编码---5.0之后使用-----------------
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:newLocation
                   completionHandler:^(NSArray *placemarks, NSError *error){
                       
                       for (CLPlacemark *place in placemarks) {
                           _rightLabel.text =place.locality;
                           NSUserDefaults *us = [NSUserDefaults standardUserDefaults];
                           [us setObject:place.locality forKey:@"dingweiCity"];
                           [us synchronize];
                           // 位置名
                           //                           NSLog(@"thoroughfare,%@",place.thoroughfare);       // 街道
                           //                           NSLog(@"subThoroughfare,%@",place.subThoroughfare); // 子街道
                           //                           NSLog(@"locality,%@",place.locality);               // 市
                           //                           NSLog(@"subLocality,%@",place.subLocality);         // 区
                           //                           NSLog(@"country,%@",place.country);                 // 国家
                       }
                       
                   }];
}

#pragma mark - layzLoad
- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight - 64 - self.tabBarController.tabBar.frame.size.height) style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = BackGroundColor;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
            [self getData];
            [self loadSoliderPicture];
            [self getAllLocation];
            [self getGunDongMessage];
            
        }];
        _tableView.mj_footer = [MJRefreshAutoStateFooter footerWithRefreshingBlock:^{
            [self getMoreData];
        }];
        _tableView.mj_footer.automaticallyHidden = YES;
        [_tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
        
    }
    return _tableView;
}

- (SDCycleScrollView *)bannerView{
    if (!_bannerView) {
        _bannerView = [SDCycleScrollView cycleScrollViewWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenWidth / 2) delegate:self placeholderImage:[UIImage imageNamed:@"shangchuan_wode_wutupian"]];
        _bannerView.pageControlAliment = SDCycleScrollViewPageContolAlimentCenter;
        _bannerView.currentPageDotColor = NavigationColor;
        _bannerView.autoScrollTimeInterval = 4;
    }
    return _bannerView;
}

- (UIButton *)titleView{
    if (!_titleView) {

        _titleView = [UIButton buttonWithType:UIButtonTypeCustom];
        _titleView.frame = CGRectMake(0, 0, kScreenWidth / 2, 30) ;
        _titleView.layer.masksToBounds = YES;
        _titleView.layer.cornerRadius = 15;
        [_titleView setAdjustsImageWhenHighlighted:NO];
        [_titleView setImage:[UIImage imageNamed:@"shouye_icon_sousuo"] forState:UIControlStateNormal];
        [_titleView setTitle:@"大家都在搜：儿童" forState:UIControlStateNormal];                                                                                                                                                                                                                                                                                                                      
        [_titleView setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        _titleView.backgroundColor = [UIColor whiteColor];
        _titleView.titleLabel.font = [UIFont systemFontOfSize:11];
        [_titleView addTarget:self action:@selector(searchAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _titleView;
}

- (void)searchAction:(UIButton *)sender{
    SYSearchViewController *search = [[SYSearchViewController alloc] init];
    [self.navigationController pushViewController:search animated:YES];
}

- (NSMutableArray *)pictureDataSource{
    if (!_pictureDataSource) {
        _pictureDataSource = [NSMutableArray arrayWithCapacity:0];
    }
    return _pictureDataSource;
}

- (NSMutableArray *)dataSoucreArr{
    if (!_dataSoucreArr) {
        _dataSoucreArr = [NSMutableArray arrayWithCapacity:0];
    }
    return _dataSoucreArr;
}

- (NSMutableArray *)gundongArr{
    if (!_gundongArr) {
        _gundongArr = [NSMutableArray arrayWithCapacity:0];
    }
    return _gundongArr;
}

@end
