//
//  SYGrapherInfosViewController.m
//  ShuoYing
//
//  Created by 硕影 on 2017/1/13.
//  Copyright © 2017年 硕影. All rights reserved.
//

#import "SYGrapherInfosViewController.h"

#import "SYGrapherInfosTableViewCell.h"
#import "SYCloudModel.h"
#import "SYCloudContentFrameModel.h"
#import "SDImageCache.h"
#import "SDWebImageDownloader.h"
#import "XLPhotoBrowser.h"

#import "SYReportGrapherViewController.h"
#import "SYYuePaiView.h"

#import "SYPaymentInfosViewController.h"
#import "CircleProgressView.h"
#import "LXNetworking.h"
#import "ZLPhotoTool.h"
#import "SYLoginViewController.h"

#import "SYChakanGrapherViewController.h"

#import "SYCommentViewController.h"
#import "SYCommentListViewController.h"
#import "SYZanViewController.h"
#import "QTShareView.h"
@interface SYGrapherInfosViewController ()<UITableViewDelegate, UITableViewDataSource,XLPhotoBrowserDelegate,XLPhotoBrowserDatasource, QTShareViewDelegate>
{
    SYYuePaiView *yuepaiView;
    XLPhotoBrowser *_browers;
    UIButton *_yuepaiBtn;
}

@property (nonatomic, copy) NSMutableArray *huodongBtnsArr;

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSDictionary *dataSourceDic;

@property (nonatomic, strong) NSMutableArray *browserImagesArr;

@property (nonatomic, strong) XLPhotoBrowser *photoBrowser;

@property (nonatomic, strong) CircleProgressView *progressView;

@property (nonatomic, strong) UIView *hudongView;

@property (nonatomic, strong) UIButton *zanBtn;
@end

@implementation SYGrapherInfosViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self getData];
    if (self.isFromShouye) {
        [self setData];
    }
    self.tabBarController.tabBar.hidden = NO;
    NSLog(@"%@",self.navigationController.viewControllers);
    for (UIViewController *vc in self.navigationController.viewControllers) {
        if ([vc isKindOfClass:[UITabBarController class]]) {
            UITabBarController *tab = (UITabBarController *)vc;
            tab.tabBar.hidden = NO;
        }
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"详情";
    self.dataSourceDic = nil;
    [self.view addSubview:self.tableView];
    if (!self.isFirst) {
        [self setRightBarItem];
    }
    
    if (self.isFromShouye) {
        [self initBottomView];
        [self setData];
    }
    
}

- (void)initBottomView{
    UIView *huodongView = [[UIView alloc] initWithFrame:CGRectMake(0, kScreenHeight - kNavigationBarHeightAndStatusBarHeight - 50, kScreenWidth, 50)];
    huodongView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:huodongView];
    self.hudongView = huodongView;
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 1)];
    lineView.backgroundColor = HexRGB(0xeaeaea);
    [huodongView addSubview:lineView];
    
    [self.huodongBtnsArr removeAllObjects];
    NSArray *texts = @[@"评论", @"点赞", @"分享"];
    NSArray *images = @[@"shouye_production_comment", @"shouye_production_like_nor", @"shouye_production_share"];
    for (int i = 0; i < 3; i ++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(((kScreenWidth - 2) / 3) * i + i * 1, 0, (kScreenWidth - 2) / 3, 50);
        btn.tag = i;
        [btn setTitleEdgeInsets:UIEdgeInsetsMake(0, 5, 0, -5)];
        [btn setImageEdgeInsets:UIEdgeInsetsMake(0, -5, 0, 5)];
        btn.titleLabel.font = [UIFont systemFontOfSize:15];
        [btn setTitleColor:HexRGB(0x8a8b8e) forState:UIControlStateNormal];
        
        [btn setTitle:texts[i] forState:UIControlStateNormal];
        [btn setImage:[UIImage imageNamed:images[i]] forState:UIControlStateNormal];
        [btn setAdjustsImageWhenHighlighted:NO];
        [btn addTarget:self action:@selector(hudongAction:) forControlEvents:UIControlEventTouchUpInside];
        [huodongView addSubview:btn];
        [self.huodongBtnsArr addObject:btn];
        
        if (i == 1) {
            self.zanBtn = btn;
        }

    }
    
    for (int i = 1; i < 3; i ++) {
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(((kScreenWidth - 2) / 3) * i, 10, 1, 30)];
        lineView.backgroundColor = HexRGB(0xeaeaea);
        [self.hudongView addSubview:lineView];
    }
}

- (void)setData{
    SYCloudModel *cloudModel = self.frameModel.cloudModel;
    
    UIButton *commentBtn = self.huodongBtnsArr[0];
    UIButton *zanBtn = self.huodongBtnsArr[1];
    
    //互动
    if ([cloudModel.reply_count integerValue] == 0) {
        [commentBtn setTitle:@"评论" forState:UIControlStateNormal];
    }else{
        [commentBtn setTitle:[cloudModel.reply_count stringValue] forState:UIControlStateNormal];
    }
    
    if ([cloudModel.agree integerValue] == 0) {
        //没点赞
        if ([cloudModel.agree_count integerValue] == 0) {
            [zanBtn setTitle:@"点赞" forState:UIControlStateNormal];
        }else{
            [zanBtn setTitle:[cloudModel.agree_count stringValue] forState:UIControlStateNormal];
        }
        [zanBtn setImage:[UIImage imageNamed:@"shouye_production_like_nor"] forState:UIControlStateNormal];
    }else{
        [zanBtn setTitle:[cloudModel.agree_count stringValue] forState:UIControlStateNormal];
        [zanBtn setImage:[UIImage imageNamed:@"shouye_production_like_sel"] forState:UIControlStateNormal];
    }

}

- (void)hudongAction:(UIButton *)sender{
    if (!LoginStatus) {
        SYLoginViewController *login = [[SYLoginViewController alloc] initWithNibName:@"SYLoginViewController" bundle:nil];
        [self.navigationController pushViewController:login animated:YES];
        return ;
    }
    SYCloudModel *cloudModel = self.frameModel.cloudModel;
    switch (sender.tag) {
            
        case 0:
        {
            //没有评论跳转评论页面 有评论跳转评论列表
            if ([cloudModel.reply_count integerValue] == 0) {
                //评论
                SYCommentViewController *commentVC = [[SYCommentViewController alloc] initWithNibName:@"SYCommentViewController" bundle:nil];
                commentVC.cloudID = cloudModel.ID;
                commentVC.frameModel = self.frameModel;
                [self.navigationController pushViewController:commentVC animated:YES];
            }else{
                SYCommentListViewController *commentList = [[SYCommentListViewController alloc] initWithNibName:@"SYCommentListViewController" bundle:nil];
                commentList.uid = self.uid;
                commentList.cloudID = cloudModel.ID;
                commentList.frameModel = self.frameModel;
                [self.navigationController pushViewController:commentList animated:YES];
            }
            
        }
            break;
        case 1:
        {
            if ([cloudModel.my integerValue] == 0) {
                //不是自己发布的作品
                //点赞 取消点赞
                if ([cloudModel.agree integerValue] == 0) {
                    
                    [self zanActionWithCloudID:cloudModel.ID];

                }else{
                    SYZanViewController *zan = [[SYZanViewController alloc] init];
                    zan.cloudID = cloudModel.ID;
                    [self.navigationController pushViewController:zan animated:YES];
                }
            }else{

                SYZanViewController *zan = [[SYZanViewController alloc] init];
                zan.cloudID = cloudModel.ID;
                [self.navigationController pushViewController:zan animated:YES];
            }
            
        }
            break;
        case 2:
        {
            //                    分享
            QTShareView *shareView = [QTShareView sharedInstance];
            shareView.delegate = self;
            [shareView showInView:self.view];
        }
            break;
            
        default:
            break;
    }

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
    NSString *url = [NSString stringWithFormat:@"http://app.yunxiangguan.cn/photoShow02.html?id=%@&history=index&app=app",self.frameModel.cloudModel.ID];
    NSString *title = [NSString stringWithFormat:@"来自%@【龙果云拍】的精彩分享",self.frameModel.cloudModel.nick];
    UIImage *image = [[SDImageCache sharedImageCache] imageFromCacheForKey:[NSString stringWithFormat:@"%@%@",ImgUrl,self.frameModel.cloudModel.head]];
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
- (void)zanActionWithCloudID:(NSNumber *)cloudID{
    
    NSString *url = [NSString stringWithFormat:@"%@%@",BaseUrl,@"/my/agree.html"];
    NSDictionary *param = @{@"token":UserToken, @"id":cloudID};
    [[SYHttpRequest sharedInstance] getDataWithUrl:url Parameter:param ResponseObject:^(NSDictionary *responseResult) {
        
        NSLog(@"点赞 -- %@",responseResult);
        if ([responseResult objectForKey:@"resError"]) {
            [self showHint:@"服务器不给力，请稍后重试"];
        }else{
            if ([[responseResult objectForKey:@"result"] integerValue] == 1) {
                
                SYCloudContentFrameModel *frameModel = self.frameModel;
                
                SYCloudModel *cloudModel = frameModel.cloudModel;
                if ([cloudModel.agree integerValue] == 0) {
                    [self zanShowAnimation];
                    
                    cloudModel.agree = @1;
                    NSInteger count = [cloudModel.agree_count integerValue] + 1;
                    cloudModel.agree_count = [NSNumber numberWithInteger:count];
                    
                    [self.zanBtn setImage:[UIImage imageNamed:@"shouye_production_like_sel"] forState:UIControlStateNormal];
                    [self.zanBtn setTitle:[cloudModel.agree_count stringValue] forState:UIControlStateNormal];
                    
                }else{
                    cloudModel.agree = @0;
                    NSInteger count = [cloudModel.agree_count integerValue] - 1;
                    cloudModel.agree_count = /* DISABLES CODE */ (0)?@0:[NSNumber numberWithInteger:count];
                    [self.zanBtn setImage:[UIImage imageNamed:@"shouye_production_like_nor"] forState:UIControlStateNormal];
                    if ([cloudModel.agree_count integerValue] == 0) {
                        [self.zanBtn setTitle:@"点赞" forState:UIControlStateNormal];
                    }else{
                        [self.zanBtn setTitle:[cloudModel.agree_count stringValue] forState:UIControlStateNormal];
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


- (void)zanShowAnimation{
    UILabel *label = [[UILabel alloc] init];
    label.frame = CGRectMake((kScreenWidth / 3) * 1, -20, kScreenWidth / 3, 50);
    label.text = @"+1";
    label.textColor = NavigationColor;
    label.textAlignment = NSTextAlignmentCenter;
    [self.hudongView addSubview:label];
    
    [UIView animateWithDuration:1 animations:^{
        label.alpha = 0;
        label.frame = CGRectMake((kScreenWidth / 3) * 1, -50, kScreenWidth / 3, 50);
    } completion:^(BOOL finished) {
        [label removeFromSuperview];
    }];
}

- (NSMutableArray *)huodongBtnsArr{
    if (!_huodongBtnsArr) {
        _huodongBtnsArr = [NSMutableArray arrayWithCapacity:0];
    }
    return _huodongBtnsArr;
}

- (void)setRightBarItem{
    UIButton *right = [UIButton buttonWithType:UIButtonTypeCustom];
    right.frame = CGRectMake(0, 0, 50, 40);
    [right setTitle:@"作品集" forState:UIControlStateNormal];
    [right setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    right.titleLabel.font = [UIFont systemFontOfSize:15];
    [right setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [right setTitleEdgeInsets:UIEdgeInsetsMake(0, 10, 0, -10)];
    [right addTarget:self action:@selector(zuopinji:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightbar = [[UIBarButtonItem alloc] initWithCustomView:right];
    self.navigationItem.rightBarButtonItem = rightbar;
}

- (void)zuopinji:(UIButton *)sender{
    if (self.dataSourceDic == nil) {
        return;
    }
    SYChakanGrapherViewController *chakan = [[SYChakanGrapherViewController alloc] init];
    chakan.uid = self.uid;
    chakan.userDic = [self.dataSourceDic objectForKey:@"user"];
    chakan.title = [[self.dataSourceDic objectForKey:@"user"] objectForKey:@"nick"];
    [self.navigationController pushViewController:chakan animated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSArray *data = [self.dataSourceDic objectForKey:@"data"];
    return data.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"cell";
    SYGrapherInfosTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[NSBundle mainBundle] loadNibNamed:@"SYGrapherInfosTableViewCell" owner:nil options:nil][0];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    NSArray *data = [self.dataSourceDic objectForKey:@"data"];
    NSDictionary *dic = data[indexPath.row];
    cell.infosLabel.text = [dic objectForKey:@"imginfo"];
    UIImage *image = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:[NSString stringWithFormat:@"%@%@",ImgUrl,[data[indexPath.row] objectForKey:@"img_min"]]];
    if (image) {
        cell.contentImageView.image = image;
    }else{
        [cell.contentImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",ImgUrl,[data[indexPath.row] objectForKey:@"img_min"]]] placeholderImage:[UIImage imageNamed:@"shangchuan_wode_wutupian"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            [self.tableView reloadData];
        }];

    }

    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSInteger count = [[self.dataSourceDic objectForKey:@"data"] count];
    [self.browserImagesArr removeAllObjects];
    [self.browserImagesArr addObjectsFromArray:[self.dataSourceDic objectForKey:@"data"]];
    // 快速创建并进入浏览模式
    XLPhotoBrowser *browser = [XLPhotoBrowser showPhotoBrowserWithCurrentImageIndex:indexPath.row imageCount:count datasource:self];
    _browers = browser;
    self.photoBrowser = browser;
    __weak typeof(self)weakself = self;
    __weak typeof(browser)weakBrowser = browser;
    browser.browserStyle = XLPhotoBrowserStyleDownload;
    browser.downloadBlock = ^(NSInteger currentIndex){
        if (LoginStatus) {
            NSLog(@"currentIndex - %lu",currentIndex);

            [self shifou0YuanWithPhotoId:[weakself.browserImagesArr[indexPath.row] objectForKey:@"id"] type:@8 indexPath:indexPath];
        }else{
            [weakBrowser dismiss];
            SYLoginViewController *login = [[SYLoginViewController alloc] initWithNibName:@"SYLoginViewController" bundle:nil];
            [self.navigationController pushViewController:login animated:YES];
        }
        
    };
    
}

- (void)downloadImageWithUrl:(NSString *)url{
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    
    UIView __block *view1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
    view1.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.6];
    [window addSubview:view1];
    [view1 addSubview:self.progressView];
    
    
    [LXNetworking downloadWithUrl:[NSString stringWithFormat:@"%@%@",ImgUrl, url] saveToPath:nil progress:^(int64_t bytesProgress, int64_t totalBytesProgress) {
        //封装方法里已经回到主线程，所有这里不用再调主线程了
        _progressView.centerLabel.text = [NSString stringWithFormat:@"%.2f%@",1.0 * bytesProgress/totalBytesProgress,@"%"];
        [_progressView setPercent:1.0 * bytesProgress/totalBytesProgress];
        
    } success:^(id response) {
        NSLog(@"---------%@",response);
        [view1 removeFromSuperview];
        _progressView = nil;
        
        [self saveImageToPhoto:[NSURL URLWithString:(NSString *)response]];
        
        
    } failure:^(NSError *error) {
        
    } showHUD:NO];
    
}

//保存到相册
- (void)saveImageToPhoto:(NSURL *)url{
    // 将相片添加到相册
    [[ZLPhotoTool sharePhotoTool] saveImageToAblumWithUrl:url completion:^(BOOL suc, PHAsset *asset) {
        if (suc) {
            dispatch_async(dispatch_get_main_queue(), ^{
                MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:_browers animated:YES];
                hud.userInteractionEnabled = NO;
                hud.bezelView.color = [UIColor blackColor];
                hud.contentColor = [UIColor whiteColor];
                // Configure for text only and offset down
                hud.mode = MBProgressHUDModeText;
                //    hud.labelText = hint;
                hud.detailsLabel.text = @"成功保存到相册！";
                hud.margin = 10.f;
                CGPoint oldOffset = hud.offset;
                hud.offset = CGPointMake(oldOffset.x, 180);
                hud.removeFromSuperViewOnHide = YES;
                [hud hideAnimated:YES afterDelay:2];
            });
            NSLog(@"保存成功！");
        }else{
            NSLog(@"保存失败");
        }
    }];
}

#pragma mark    -   XLPhotoBrowserDatasource

/**
 *  返回指定位置的高清图片URL
 *
 *  @param browser 浏览器
 *  @param index   位置索引
 *
 *  @return 返回高清大图索引
 */
- (NSURL *)photoBrowser:(XLPhotoBrowser *)browser highQualityImageURLForIndex:(NSInteger)index
{
    NSString *imageUrl = [self.browserImagesArr[index] objectForKey:@"img_min"];
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",ImgUrl,imageUrl]];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSArray *data = [self.dataSourceDic objectForKey:@"data"];
    NSDictionary *dic = data[indexPath.row];
    NSString *str = [dic objectForKey:@"imginfo"];
    CGFloat strHeight = [[Tool sharedInstance] heightForString:str andWidth:kScreenWidth - 20 fontSize:13];
    UIImage *image = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:[NSString stringWithFormat:@"%@%@",ImgUrl,[data[indexPath.row] objectForKey:@"img_min"]]];
   
    if (image) {
        return kScreenWidth / image.size.width * image.size.height + 20 + strHeight;
    }
    return 200;

}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (self.isFromShouye) {
        if (self.dataSourceDic == nil) {
            return 30 + 35 + 150;
        }
        UILabel *intro = [[UILabel alloc] init];
        intro.numberOfLines = 0;
        intro.text = [[self.dataSourceDic objectForKey:@"user"] objectForKey:@"info"];
        intro.textAlignment = NSTextAlignmentLeft;
        intro.font = [UIFont systemFontOfSize:13];
        CGSize maxSize = [intro sizeThatFits:CGSizeMake(kScreenWidth - 126 - 18, MAXFLOAT)];
        if (maxSize.height <= 40) {
            return 30 + 35 + 110 + 40;
        }else{
            return 30 + 35 + 110 + maxSize.height;
        }
    }
    return 275;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (self.isFromShouye) {
        UIView *view = [[UIView alloc] init];
        view.backgroundColor = [UIColor whiteColor];
        UIView *upView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 30)];
        upView.backgroundColor = [UIColor whiteColor];
        [view addSubview:upView];
        UIView *middleView = [[UIView alloc] initWithFrame:CGRectMake(0, 30, kScreenWidth, 150)];
        UIImage *image = [UIImage imageNamed:@"faxian_xiangqing_bg"];
        middleView.layer.contents = (id)image.CGImage;
        [view addSubview:middleView];
        
        //头像
        UIImageView *headIMG = [[UIImageView alloc] initWithFrame:CGRectMake(18, 26, 98, 98)];
        [headIMG sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",ImgUrl,[[self.dataSourceDic objectForKey:@"user"] objectForKey:@"head"]]] placeholderImage:[UIImage imageNamed:@"faxian_xiangqing_photo"]];
        headIMG.layer.masksToBounds = YES;
        headIMG.layer.cornerRadius = 98/2;
        [middleView addSubview:headIMG];
        //名字
        UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(126, 39, kScreenWidth - 126 - 18, 20)];
        nameLabel.text = [[self.dataSourceDic objectForKey:@"user"] objectForKey:@"nick"];
        nameLabel.font = [UIFont systemFontOfSize:17];
        nameLabel.textAlignment = NSTextAlignmentLeft;
        nameLabel.textColor = HexRGB(0x434343);
        [middleView addSubview:nameLabel];
        //简介
        UILabel *intro = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(nameLabel.frame), CGRectGetMaxY(nameLabel.frame) + 21, kScreenWidth - 126 - 18, 40)];
        intro.numberOfLines = 0;
        intro.text = [[self.dataSourceDic objectForKey:@"user"] objectForKey:@"info"];
        intro.textAlignment = NSTextAlignmentLeft;
        intro.font = [UIFont systemFontOfSize:13];
        CGSize maxSize = [intro sizeThatFits:CGSizeMake(kScreenWidth - 126 - 18, MAXFLOAT)];
        if (maxSize.height <= 40) {
            intro.frame = CGRectMake(CGRectGetMinX(nameLabel.frame), CGRectGetMaxY(nameLabel.frame) + 21, kScreenWidth - 126 - 18, 40);
            middleView.frame = CGRectMake(0, 30, kScreenWidth, 110 + 40);
        }else{
            intro.frame = CGRectMake(CGRectGetMinX(nameLabel.frame), CGRectGetMaxY(nameLabel.frame) + 21, kScreenWidth - 126 - 18, maxSize.height);
            middleView.frame = CGRectMake(0, 30, kScreenWidth, 110 + maxSize.height);
        }
        
        [middleView addSubview:intro];
        
        
        
        UIView *downView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(middleView.frame), kScreenWidth, 35)];
        UIImageView *imageview = [[UIImageView alloc] initWithFrame:CGRectMake(10, 0, 35, 35)];
        imageview.image = [UIImage imageNamed:@"faxian_xiangqing_icon_camera"];
        imageview.contentMode = UIViewContentModeScaleAspectFit;
        [downView addSubview:imageview];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(imageview.frame) + 5, 7, 65, 21)];
        label.text = @"照片展示";
        label.font = [UIFont systemFontOfSize:14];
        [downView addSubview:label];
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(kScreenWidth - 80, 0, 70, 35);
        [btn addTarget:self action:@selector(reportGrapher) forControlEvents:UIControlEventTouchUpInside];
        [btn setTitle:@"举报该用户" forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont systemFontOfSize:12];
        [downView addSubview:btn];
        
        [view addSubview:downView];
        
        return view;
    }
    
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor whiteColor];
    
    UIView *upView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 60)];
    upView.backgroundColor = [UIColor whiteColor];
    [view addSubview:upView];
    UIView *middleView = [[UIView alloc] initWithFrame:CGRectMake(0, 60, kScreenWidth, 180)];
    UIImage *image = [UIImage imageNamed:@"faxian_xiangqing_bg"];
    middleView.layer.contents = (id)image.CGImage;
    [view addSubview:middleView];
    //头像
    UIImageView *headIMG = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 70, 70)];
    headIMG.center = CGPointMake(kScreenWidth / 2, 60);
    [headIMG sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",ImgUrl,[[self.dataSourceDic objectForKey:@"user"] objectForKey:@"head"]]] placeholderImage:[UIImage imageNamed:@"faxian_xiangqing_photo"]];
    headIMG.layer.masksToBounds = YES;
    headIMG.layer.cornerRadius = 35;
    [view addSubview:headIMG];
    [view bringSubviewToFront:headIMG];
    //名字
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 40, kScreenWidth - 80, 20)];
    nameLabel.text = [[self.dataSourceDic objectForKey:@"user"] objectForKey:@"nick"];
    nameLabel.font = [UIFont systemFontOfSize:15];
    nameLabel.textAlignment = NSTextAlignmentCenter;
    [middleView addSubview:nameLabel];
    //简介
    UILabel *intro = [[UILabel alloc] initWithFrame:CGRectMake(40, CGRectGetMaxY(nameLabel.frame), kScreenWidth - 80, 40)];
    intro.numberOfLines = 2;
    intro.text = [[self.dataSourceDic objectForKey:@"user"] objectForKey:@"info"];
    intro.textAlignment = NSTextAlignmentCenter;
    intro.font = [UIFont systemFontOfSize:11];
    [middleView addSubview:intro];
    //约拍
    UIButton *yuepaiBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    yuepaiBtn.frame = CGRectMake(0, 0, 75, 30);
    yuepaiBtn.center = CGPointMake(kScreenWidth / 2, CGRectGetMaxY(intro.frame) + 10 + 15);
    [yuepaiBtn setTitle:@"约拍" forState:UIControlStateNormal];
    [yuepaiBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [yuepaiBtn setAdjustsImageWhenHighlighted:NO];
    yuepaiBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    yuepaiBtn.layer.cornerRadius = 5;
    yuepaiBtn.layer.masksToBounds = YES;
    [yuepaiBtn setBackgroundImage:[UIImage imageWithColor:NavigationColor Size:yuepaiBtn.frame.size] forState:UIControlStateNormal];
    [yuepaiBtn addTarget:self action:@selector(yuePaiAction:) forControlEvents:UIControlEventTouchUpInside];
    [middleView addSubview:yuepaiBtn];
    if (self.dataSourceDic.count > 0) {
        yuepaiBtn.enabled = YES;
    }else{
        yuepaiBtn.enabled = NO;
    }
    _yuepaiBtn = yuepaiBtn;
    //价格
    UILabel *priceLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 150, 20)];
    priceLabel.textAlignment = NSTextAlignmentCenter;
    float fee = [[[self.dataSourceDic objectForKey:@"user"] objectForKey:@"fee"] integerValue] / 100;
    priceLabel.text = [NSString stringWithFormat:@"%.2f元／次",fee];
    priceLabel.font = [UIFont systemFontOfSize:13];
    priceLabel.textColor = RGB(252, 91, 98);
    priceLabel.center = CGPointMake(kScreenWidth / 2, CGRectGetMaxY(yuepaiBtn.frame) + 10 + 10);
    [middleView addSubview:priceLabel];
    
    UIView *downView = [[UIView alloc] initWithFrame:CGRectMake(0, 240, kScreenWidth, 35)];
    UIImageView *imageview = [[UIImageView alloc] initWithFrame:CGRectMake(10, 0, 35, 35)];
    imageview.image = [UIImage imageNamed:@"faxian_xiangqing_icon_camera"];
    imageview.contentMode = UIViewContentModeScaleAspectFit;
    [downView addSubview:imageview];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(imageview.frame) + 5, 7, 65, 21)];
    label.text = @"照片展示";
    label.font = [UIFont systemFontOfSize:14];
    [downView addSubview:label];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(kScreenWidth - 80, 0, 70, 35);
    [btn addTarget:self action:@selector(reportGrapher) forControlEvents:UIControlEventTouchUpInside];
    [btn setTitle:@"举报该用户" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:12];
    [downView addSubview:btn];
    
    [view addSubview:downView];
    return view;
}

- (void)reportGrapher{
    SYReportGrapherViewController *report = [[SYReportGrapherViewController alloc] init];
    report.dataSourceDic = [self.dataSourceDic objectForKey:@"user"];
    [self.navigationController pushViewController:report animated:YES];
}

- (void)yuePaiAction:(UIButton *)sender{
    SYYuePaiView *view = [[[NSBundle mainBundle] loadNibNamed:@"SYYuePaiView" owner:self options:nil] lastObject];
    yuepaiView = view;
    view.phoneLabel.text = [[self.dataSourceDic objectForKey:@"user"] objectForKey:@"user"];
    __weak typeof(view)weakView = view;
    view.bolck = ^(NSInteger tag){
        switch (tag) {
            case 0:
                //取消
                [weakView removeFromSuperview];
                break;
            case 1:
            {
                [weakView removeFromSuperview];

                //呼叫
                NSString *num = [[NSString alloc]initWithFormat:@"telprompt://%@",weakView.phoneLabel.text]; //而这个方法则打电话前先弹框 是否打电话 然后打完电话之后回到程序中 网上说这个方法可能不合法 无法通过审核
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:num]]; //拨号
            }
                break;
            case 2:
                
            {
                [weakView removeFromSuperview];
                if (LoginStatus) {
                    //支付
                    
                    /*
                    SYPaymentInfosViewController *payment = [[SYPaymentInfosViewController alloc] initWithType:isFromYuYueGrapher];
                    payment.dataSourceDic = [self.dataSourceDic objectForKey:@"user"];
                    [self.navigationController pushViewController:payment animated:YES];
                     */
                    [self shifou0YuanWithPhotoId:[[self.dataSourceDic objectForKey:@"user"] objectForKey:@"id"] type:@5 indexPath:nil];
                }else{
                    SYLoginViewController *login = [[SYLoginViewController alloc] initWithNibName:@"SYLoginViewController" bundle:nil];
                    [self.navigationController pushViewController:login animated:YES];
                }
                
            }
                break;
                
            default:
                break;
        }
    };
    view.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
    view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.6];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissView)];
    [view addGestureRecognizer:tap];
    view.userInteractionEnabled = YES;
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    [window addSubview:view];
}

#pragma mark - 下载时候调用接口判断是不是0元，0元直接下载
- (void)shifou0YuanWithPhotoId:(NSString *)photoId type:(NSNumber *)type indexPath:(NSIndexPath *)indepath{
    [SVProgressHUD show];
    
    NSString *url = [NSString stringWithFormat:@"%@%@",BaseUrl,@"/alpay/pay.html"];
    NSDictionary *param = @{@"type":type, @"token":UserToken, @"id":photoId, @"paytype":@"APP"};
    __weak typeof(self)weakself = self;
    [[SYHttpRequest sharedInstance] getDataWithUrl:url Parameter:param ResponseObject:^(NSDictionary *responseResult) {
        [SVProgressHUD dismiss];
        NSLog(@"是否0元 -- %@",responseResult);
        if ([responseResult objectForKey:@"resError"]) {
            [self showHint:@"服务器不给力，请稍后重试"];
            return ;
        }else{
            if ([[responseResult objectForKey:@"result"] integerValue] == 1) {
                SYPaymentInfosViewController *payment = nil;
                
                if ([type  isEqual: @8]) {
                    [self.photoBrowser removeFromSuperview];
                    payment = [[SYPaymentInfosViewController alloc] initWithType:isFromShouYeXiaZai];
                    payment.dataSourceDic = weakself.browserImagesArr[indepath.row];
                }else if ([type  isEqual: @5]){
                    payment = [[SYPaymentInfosViewController alloc] initWithType:isFromYuYueGrapher];
                    payment.dataSourceDic = [weakself.dataSourceDic objectForKey:@"user"];
                }
                
                
                [weakself.navigationController pushViewController:payment animated:YES];
                
            }else if([[responseResult objectForKey:@"result"] integerValue] == 4){
                
                if ([type  isEqual: @8]) {
                    UIWindow *window = [UIApplication sharedApplication].keyWindow;
                    
                    UIView __block *view1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
                    view1.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.6];
                    [window addSubview:view1];
                    [view1 addSubview:self.progressView];
                    
                    
                    [LXNetworking downloadWithUrl:[NSString stringWithFormat:@"%@%@",ImgUrl, [responseResult objectForKey:@"img"]] saveToPath:nil progress:^(int64_t bytesProgress, int64_t totalBytesProgress) {
                        //封装方法里已经回到主线程，所有这里不用再调主线程了
                        _progressView.centerLabel.text = [NSString stringWithFormat:@"%.2f%@",1.0 * bytesProgress/totalBytesProgress,@"%"];
                        [_progressView setPercent:1.0 * bytesProgress/totalBytesProgress];
                        
                    } success:^(id response) {
                        NSLog(@"---------%@",response);
                        [view1 removeFromSuperview];
                        _progressView = nil;
                        [self saveImageToPhoto:[NSURL URLWithString:(NSString *)response]];
                        
                    } failure:^(NSError *error) {
                        
                    } showHUD:NO];

                }else{
                    [self showHint:@"约拍成功"];
                }
                
            }else{
                if ([responseResult objectForKey:@"msg"]) {
                    [self showHint:[responseResult objectForKey:@"msg"]];
                }
            }
        }
    }];
    
}

- (void)dismissView{
    [yuepaiView removeFromSuperview];
}

- (void)getData{
    
    NSString *url = [NSString stringWithFormat:@"%@%@",BaseUrl,@"/get/photos.html"];
    NSDictionary *param = nil;
    if (LoginStatus) {
        param = @{@"id":self.grapherID, @"token":UserToken};

    }else{
        param = @{@"id":self.grapherID};

    }
    [[SYHttpRequest sharedInstance] getDataWithUrl:url Parameter:param ResponseObject:^(NSDictionary *responseResult) {
        
        NSLog(@"摄影师作品详情 -- %@",responseResult);
        if ([responseResult objectForKey:@"resError"]) {
            [self showHint:@"服务器不给力，请稍后重试"];
        }else{
            if ([[responseResult objectForKey:@"result"] integerValue] == 1) {
                
                self.dataSourceDic = responseResult;
                [self.tableView reloadData];

            }else{
                if ([responseResult objectForKey:@"msg"]) {
                    [self showHint:[responseResult objectForKey:@"msg"]];
                }
            }
        }
    }];
}


- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight - kNavigationBarHeightAndStatusBarHeight - 50) style:UITableViewStyleGrouped];
        _tableView.backgroundColor = BackGroundColor;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.showsVerticalScrollIndicator = NO;
        [_tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return _tableView;
}

- (NSMutableArray *)browserImagesArr{
    if (!_browserImagesArr) {
        _browserImagesArr = [NSMutableArray arrayWithCapacity:0];
    }
    return _browserImagesArr;
}

//在当前window添加进度条
- (CircleProgressView *)progressView{
    if (!_progressView) {
        _progressView = [[CircleProgressView alloc] initWithFrame:CGRectMake(0, 0, 80, 80)];
        _progressView.center = CGPointMake(kScreenWidth / 2, kScreenHeight / 2);
        
    }
    return _progressView;
}

@end
