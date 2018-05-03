//
//  SYBisnessViewController.m
//  ShuoYing
//
//  Created by 硕影 on 2017/4/24.
//  Copyright © 2017年 硕影. All rights reserved.
//

#import "SYBisnessViewController.h"

#import "SYPhotoNameTableViewCell.h"
#import "SYPhotoNameModel.h"

#import "SYPhotoShangpinTableViewCell.h"
#import "SYProductListModel.h"

#import "SYPhotoStudioPinglunCell.h"
#import "SYCommentModel.h"

#import "SYBisnessInfosViewController.h"
#import "QTShareView.h"
#import "XFDialogOptionButton.h"
#import "SYBusnessPhotosViewController.h"

@interface SYBisnessViewController ()<UITableViewDelegate, UITableViewDataSource, QTShareViewDelegate>
{
    UIButton *_backBtn;
    UIButton *_rightBtn;
    
    NSInteger _productCount;
    NSInteger _pinglunCount;
    
    BOOL _isOpen;
    BOOL _isAppear;
    
    NSInteger _pinglunAllCount;
    
    UIView *_customNaviBar;
    UIView *_lineView;
}

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *photoNameArr;

@property (nonatomic, strong) NSMutableArray *productArr;

@property (nonatomic, strong) NSMutableArray *commentArr;

@property (nonatomic, strong) NSDictionary *productDic;

@property (nonatomic, strong) UIButton *fanhuiDingbu;

@property (nonatomic, weak) XFDialogFrame *dialogView;

@property (nonatomic, strong) NSMutableArray *availableMaps;
@end

static const NSInteger BusnessCount = 5;

@implementation SYBisnessViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setTranslucent:YES];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageWithColor:[UIColor clearColor] Size:CGSizeMake(kScreenWidth, kNavigationBarHeightAndStatusBarHeight)] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage imageWithColor:[UIColor clearColor] Size:CGSizeMake(kScreenWidth, 1)];

    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageWithColor:NavigationColor Size:CGSizeMake(kScreenWidth, kNavigationBarHeightAndStatusBarHeight)] forBarMetrics:UIBarMetricsDefault];
self.navigationController.navigationBar.shadowImage = [UIImage imageWithColor:NavigationColor Size:CGSizeMake(kScreenWidth, 1)];
    [self.navigationController.navigationBar setTranslucent:NO];

    [self.navigationController setNavigationBarHidden:NO animated:YES];

}

- (void)popAction{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)shareAction:(UIButton *)sender{
    if (self.photoNameArr.count == 0) {
        return;
    }
    QTShareView *sharView = [QTShareView sharedInstance];
    sharView.delegate = self;
    [sharView showInView:self.view];
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
    SYPhotoNameModel *model = self.photoNameArr[0];
    NSString *url = [NSString stringWithFormat:@"http://m.yunxiangguan.cn/photoShop.html?id=%@&app=app",model.photoNameID];
    NSString *title = [NSString stringWithFormat:@"来自%@【龙果云拍】的精彩分享",model.name];
    UIImage *image = [[SDImageCache sharedImageCache] imageFromCacheForKey:[NSString stringWithFormat:@"%@%@",ImgUrl,model.img]];
    //创建分享消息对象
    UMSocialMessageObject *messageObject = [UMSocialMessageObject messageObject];
    UMShareWebpageObject *shareObject = [UMShareWebpageObject shareObjectWithTitle:title descr:model.info thumImage:image];
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


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _productCount = 1;
    _pinglunCount = 0;
    _isAppear = NO;
    _isOpen = NO;
    [self.view addSubview:self.tableView];
    [self initCustomNavigationBar];

    [self getData];
    [self getShangpinList];
    [self getShangpinPinglun];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return self.photoNameArr.count;
    }else if (section == 1){
        if (_isOpen) {
            return self.productArr.count;
        }else{
            if (self.productArr.count > BusnessCount) {
                return BusnessCount;
            }else{
                return self.productArr.count;
            }
        }
    }else{
        return self.commentArr.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        static NSString *identifier = @"photonameCell";
        SYPhotoNameTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (!cell) {
            cell = [[NSBundle mainBundle] loadNibNamed:@"SYPhotoNameTableViewCell" owner:nil options:nil][0];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        SYPhotoNameModel *model = self.photoNameArr[indexPath.row];
        cell.photoNameModel = self.photoNameArr[indexPath.row];
        __weak typeof(self)weakself = self;
        cell.imgBlock = ^{
            SYBusnessPhotosViewController *photos = [[SYBusnessPhotosViewController alloc] init];
            if (weakself.photoNameArr.count > 0) {
                SYPhotoNameModel *model = weakself.photoNameArr[0];
                photos.imgsArr = model.imgs;
                [weakself.navigationController pushViewController:photos animated:YES];
            }
        };
        cell.callblock = ^{
           weakself.dialogView = [[XFDialogOptionButton dialogWithTitle:@"商家电话"
                                             attrs:@{
                                                     XFDialogTitleViewBackgroundColor : [UIColor whiteColor],
                                                     XFDialogTitleColor: HexRGB(0x434343), 
                                                     XFDialogOptionTextList: @[model.tel], XFDialogOptionCancelTextColor:HexRGB(0x434343)
                                                     }
                                    commitCallBack:^(NSString *inputText) {
                                        NSLog(@"你选择的是: %@",inputText);
                                        NSMutableString* str=[[NSMutableString alloc] initWithFormat:@"telprompt://%@",inputText];
                                        // NSLog(@"str======%@",str);
                                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
                                        
                                        [weakself.dialogView hideWithAnimationBlock:nil];
                                    }] showWithAnimationBlock:nil];
            
        };
        cell.mapBlock = ^{

            [self openMap];
        };
        return cell;
    }else if (indexPath.section == 1){
        static NSString *identifier = @"productCell";
        SYPhotoShangpinTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (!cell) {
            cell = [[NSBundle mainBundle] loadNibNamed:@"SYPhotoShangpinTableViewCell" owner:nil options:nil][0];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        cell.model = self.productArr[indexPath.row];
        return cell;
    }else{
        static NSString *identifier = @"commemtCell";
        SYPhotoStudioPinglunCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (!cell) {
            cell = [[NSBundle mainBundle] loadNibNamed:@"SYPhotoStudioPinglunCell" owner:nil options:nil][0];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        cell.commemtModel = self.commentArr[indexPath.row];
        
        __weak typeof(indexPath)weakIP = indexPath;
        __weak typeof(self)weakself = self;
        cell.youyongBlock = ^{
            
            SYCommentModel *model = weakself.commentArr[weakIP.row];

            [weakself youwuyongWithStr:@"you" youwuID:model.commentID IndexPath:weakIP];
        };
        cell.wuyongBlock = ^{
            
            SYCommentModel *model = weakself.commentArr[weakIP.row];
            [weakself youwuyongWithStr:@"wu" youwuID:model.commentID IndexPath:weakIP];
        };
        
        return cell;
    }
}

- (void)openMap{
    [self.availableMaps removeAllObjects];
    NSUserDefaults *us = [NSUserDefaults standardUserDefaults];
    double jingdu = [[us objectForKey:@"jingdu"] doubleValue];
    double weidu = [[us objectForKey:@"weidu"] doubleValue];
    double endJingdu = 0.00f;
    double endweidu = 0.00f;
    NSString __block *startName = @"";
    NSString *endName =@"";
    if (self.photoNameArr.count > 0) {
        SYPhotoNameModel *model = self.photoNameArr[0];
        endJingdu = [model.longa doubleValue];
        endweidu = [model.lat doubleValue];
        endName = model.address;
    }
    CLLocationCoordinate2D startCoor = CLLocationCoordinate2DMake(weidu, jingdu);
    CLLocationCoordinate2D endCoor = CLLocationCoordinate2DMake(endweidu, endJingdu);
    CLLocationCoordinate2D newStartCoor = [Tool wgs84ToBd09:startCoor];
    
    //创建地理编码对象
    CLGeocoder *geocoder=[[CLGeocoder alloc]init];
    //创建位置
    CLLocation *location=[[CLLocation alloc]initWithLatitude:newStartCoor.latitude longitude:newStartCoor.longitude];
    
    //反地理编码
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        //判断是否有错误或者placemarks是否为空
        if (error !=nil || placemarks.count==0) {
            NSLog(@"%@",error);
            return ;
        }
        for (CLPlacemark *placemark in placemarks) {
            //赋值详细地址
            NSLog(@"name - %@",placemark.name);
            startName = placemark.name;
        }
        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"baidumap://"]]){
            NSString *urlStr = @"";
            if ([startName isEqualToString:@""]) {
                urlStr = [NSString stringWithFormat:@"baidumap://map/direction?origin=%f,%f&destination=%f,%f&mode=driving",newStartCoor.latitude, newStartCoor.longitude, endCoor.latitude, endCoor.longitude];
            }else{
                urlStr = [[NSString stringWithFormat:@"baidumap://map/direction?origin=name:%@|latlng:%lf,%lf&destination=name:%@|latlng:%f,%f&mode=driving",startName, newStartCoor.latitude, newStartCoor.longitude, endName, endCoor.latitude, endCoor.longitude] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            }
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlStr]];
        }else{
            [self showHint:@"没有安装百度地图，无法导航"];
        }
    }];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 1) {
        SYProductListModel *model = self.productArr[indexPath.row];
        if ([model.line integerValue] == 1) {
            //线上
            SYProductListModel *model = self.productArr[indexPath.row];
            SYBisnessInfosViewController *infos = [[SYBisnessInfosViewController alloc] initWithIsFromXSorXXType:isFromXS shangpinID:model.productID shangjiaID:self.photoID];
            
            [self.navigationController pushViewController:infos animated:YES];
        }else{
            //线下
            SYProductListModel *model = self.productArr[indexPath.row];
            SYBisnessInfosViewController *infos = [[SYBisnessInfosViewController alloc] initWithIsFromXSorXXType:isFromXX shangpinID:model.productID shangjiaID:self.photoID];
            
            [self.navigationController pushViewController:infos animated:YES];
        }
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        return 320;
    }else if(indexPath.section == 1){
        return 84;
    }else{
        SYCommentModel *model = self.commentArr[indexPath.row];
        NSString *info = model.info;
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth - 79, 0)];
        label.text = info;
        label.font = [UIFont systemFontOfSize:14];
        label.numberOfLines = 0;
        CGSize maxSize = [label sizeThatFits:CGSizeMake(label.frame.size.width, MAXFLOAT)];
        CGFloat pictureHeight = (kScreenWidth - 65 - 14 - 26) / 3;
        
        NSString *reply = [NSString stringWithFormat:@"商家回复:%@",model.reply];
        UILabel *reply_label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth - 80, 0)];
        reply_label.text = reply;
        reply_label.font = [UIFont systemFontOfSize:14];
        reply_label.numberOfLines = 0;
        CGSize reply_maxSize = [reply_label sizeThatFits:CGSizeMake(label.frame.size.width, MAXFLOAT)];
        
        if (model.img_200.count > 0) {
            if (model.reply.length > 0) {
                return 140 + pictureHeight + maxSize.height + reply_maxSize.height;
            }
            return 130 + pictureHeight + maxSize.height;
        }else{
            if (model.reply.length > 0) {
                return 130 + maxSize.height + reply_maxSize.height;
            }
            return 120 + maxSize.height;
        }
        
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return 0.0001f;
    }
    return 60;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return nil;
    }
    if (section == 1) {
        UIView *view = [[UIView alloc] init];
        view.backgroundColor = HexRGB(0xf3f3f3);
        UIView *view1 = [[UIView alloc] initWithFrame:CGRectMake(0, 14, kScreenWidth, 46)];
        view1.backgroundColor = [UIColor whiteColor];
        [view addSubview:view1];
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 45, kScreenWidth, 1)];
        lineView.backgroundColor = RGB(242, 242, 242);
        [view1 addSubview:lineView];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, 15, kScreenWidth - 30, 15)];
        label.text = @"商品列表";
        label.textColor = NavigationColor;
        label.font = [UIFont systemFontOfSize:15];
        [view1 addSubview:label];
        
        return view;
    }
    
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = HexRGB(0xf3f3f3);
    UIView *view1 = [[UIView alloc] initWithFrame:CGRectMake(0, 14, kScreenWidth, 46)];
    view1.backgroundColor = [UIColor whiteColor];
    [view addSubview:view1];
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 45, kScreenWidth, 1)];
    lineView.backgroundColor = RGB(242, 242, 242);
    [view1 addSubview:lineView];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, 15, kScreenWidth - 30, 15)];
    label.text = [NSString stringWithFormat:@"评价(%ld)", _pinglunAllCount];
    label.textColor = NavigationColor;
    label.font = [UIFont systemFontOfSize:15];
    [view1 addSubview:label];
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (section == 0 || section == 2) {
        return 0.00001f;
    }
    if (self.productArr.count < 4) {
        return 0.00001f;
    }
    return 46;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    if (section == 1) {
        if (self.productArr.count < 4) {
            return nil;
        }
        UIView *view = [[UIView alloc] init];
        view.backgroundColor = [UIColor whiteColor];
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(0, 0, kScreenWidth, 46);
        btn.titleLabel.font = [UIFont systemFontOfSize:15];
        [btn setAdjustsImageWhenHighlighted:NO];
        
        NSInteger shengyuCount = 0;
        if (_isOpen) {
            shengyuCount = [[self.productDic objectForKey:@"count"] integerValue] - self.productArr.count;
        }else{
            if (self.productArr.count > BusnessCount) {
                shengyuCount = [[self.productDic objectForKey:@"count"] integerValue] - BusnessCount;
            }else{
                shengyuCount = [[self.productDic objectForKey:@"count"] integerValue] - self.productArr.count;
            }
        }
        
        if (shengyuCount <= 0) {
            [btn setTitle:@"已展开全部商品列表" forState:UIControlStateNormal];
            [btn setImage:[UIImage imageNamed:@"quancheng_jiantou_shang"] forState:UIControlStateNormal];
        }else{
            [btn setTitle:[NSString stringWithFormat:@"其他%ld个商品列表",shengyuCount] forState:UIControlStateNormal];
            [btn setImage:[UIImage imageNamed:@"PhotoShop_pulldownlist_nor"] forState:UIControlStateNormal];
        }
        
        UILabel *label = [[UILabel alloc] init];
        label.text = btn.titleLabel.text;
        label.font = [UIFont systemFontOfSize:15];
        label.numberOfLines = 1;
        CGSize maxSize = [label sizeThatFits:CGSizeMake(MAXFLOAT, 46)];
        
        [btn setTitleColor:HexRGB(0x818181) forState:UIControlStateNormal];
        
        [btn setImageEdgeInsets:UIEdgeInsetsMake(0, maxSize.width + 5, 0, -maxSize.width + 5)];
        [btn setTitleEdgeInsets:UIEdgeInsetsMake(0, -16, 0, 16)];
        [btn addTarget:self action:@selector(isSelecteMoreProduct:) forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:btn];
        return view;
    }
    return nil;
}

- (void)isSelecteMoreProduct:(UIButton *)sender{
    //收起
    if (_isOpen) {
        if (self.productArr.count == [[self.productDic objectForKey:@"count"] integerValue]) {
            _isOpen = NO;
            
            [self.tableView reloadData];
            return;
        }
    }
    
    sender.userInteractionEnabled = NO;
    _productCount ++;
    NSString *url = [NSString stringWithFormat:@"%@%@",BaseUrl,@"/store/goods.html"];
    NSDictionary *param = @{@"id":self.photoID, @"page":[NSNumber numberWithInteger:_productCount]};
    [[SYHttpRequest sharedInstance] getDataWithUrl:url Parameter:param ResponseObject:^(NSDictionary *responseResult) {
        _isOpen = YES;
        sender.userInteractionEnabled = YES;
        NSLog(@"某个相馆的商品 -- %@",responseResult);
        if ([responseResult objectForKey:@"resError"]) {
            
        }else{
            if ([[responseResult objectForKey:@"result"] integerValue] == 1) {
                if ([responseResult objectForKey:@"data"]) {
                    NSArray *arr = [responseResult objectForKey:@"data"];
                    
                    if (arr.count > 0) {
                        for (NSDictionary *dic in arr) {
                            
                            SYProductListModel *model = [SYProductListModel productWithDictionary:dic];
                            [self.productArr addObject:model];
                        }
                    }
                    [self.tableView reloadData];
                }
            }else{
                if ([responseResult objectForKey:@"msg"]) {
                    [self showHint:[responseResult objectForKey:@"msg"]];
                }
            }
        }
    }];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{

    float a = scrollView.contentOffset.y / 125;
    if (a < 1.0) {
        _lineView.backgroundColor = [HexRGB(0xeaeaea) colorWithAlphaComponent:a];
        _customNaviBar.backgroundColor = [HexRGB(0xfaf9f9) colorWithAlphaComponent:a];

    }else{
        _lineView.backgroundColor = [HexRGB(0xeaeaea) colorWithAlphaComponent:1];
        _customNaviBar.backgroundColor = [HexRGB(0xfaf9f9) colorWithAlphaComponent:1];
    }
    if (scrollView.contentOffset.y > 1000.0) {
        if (_isAppear) {
            [self.view addSubview:self.fanhuiDingbu];
            [self.view bringSubviewToFront:self.fanhuiDingbu];
        }
        _isAppear = YES;
    }else{
        [self.fanhuiDingbu removeFromSuperview];
    }
}

#pragma mark - 隐藏系统导航条 使用自定义导航条
- (void)initCustomNavigationBar{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kNavigationBarHeightAndStatusBarHeight)];
    view.backgroundColor = [HexRGB(0xfaf9f9) colorWithAlphaComponent:0];
    _customNaviBar = view;
    [self.view addSubview:view];
    [self.view bringSubviewToFront:view];
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, view.frame.size.height - 1, kScreenWidth, 1)];
    lineView.backgroundColor = [HexRGB(0xeaeaea) colorWithAlphaComponent:0];
    _lineView = lineView;
    
    [view addSubview:lineView];
    
    UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftBtn setFrame:CGRectMake(10, [UIApplication sharedApplication].statusBarFrame.size.height, 44, 44)];
    [leftBtn setAdjustsImageWhenHighlighted:NO];
    [leftBtn setImage:[UIImage imageNamed:@"PhotoShop_headnav_-return_icon"] forState:UIControlStateNormal];
    [leftBtn addTarget:self action:@selector(popAction) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:leftBtn];
    
    UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightBtn setFrame:CGRectMake(kScreenWidth - 10 - 44, [UIApplication sharedApplication].statusBarFrame.size.height, 44, 44)];
    [rightBtn setImage:[UIImage imageNamed:@"PhotoShop_headnav_-stare_icon"] forState:UIControlStateNormal];
    [rightBtn setAdjustsImageWhenHighlighted:NO];
    [rightBtn addTarget:self action:@selector(shareAction:) forControlEvents:UIControlEventTouchUpInside];

    [view addSubview:rightBtn];
    
}

//有无用
#pragma mark - YouOrWu
- (void)youwuyongWithStr:(NSString *)str youwuID:(NSNumber *)youwuid IndexPath:(NSIndexPath *)indexpath{
    NSString *url = [NSString stringWithFormat:@"%@%@",BaseUrl,@"/store/ping.html"];
    
    NSDictionary *param = @{@"id":youwuid, @"ping":str};
    [[SYHttpRequest sharedInstance] getDataWithUrl:url Parameter:param ResponseObject:^(NSDictionary *responseResult) {

        NSLog(@"有无用-- %@",responseResult);
        if ([responseResult objectForKey:@"resError"]) {
            
        }else{
            if ([[responseResult objectForKey:@"result"] integerValue] == 1) {
                
                SYCommentModel *model = self.commentArr[indexpath.row];
                if ([model.isSelecteWu boolValue] || [model.isSelecteYou boolValue]) {
                    return ;
                }else{
                    
                    if ([str isEqualToString:@"you"]) {
                        model.isSelecteYou = @YES;
                        NSInteger you = [model.you integerValue] + 1;
                        model.you = [NSNumber numberWithInteger:you];
                    }else{
                        model.isSelecteWu = @YES;
                        NSInteger you = [model.wu integerValue] + 1;
                        model.wu = [NSNumber numberWithInteger:you];
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

- (void)getData{
    [SVProgressHUD show];

    NSString *url = [NSString stringWithFormat:@"%@%@",BaseUrl,@"/store/store.html"];
    NSDictionary *param = @{@"id":self.photoID};
    [[SYHttpRequest sharedInstance] getDataWithUrl:url Parameter:param ResponseObject:^(NSDictionary *responseResult) {
        if ([self.tableView.mj_header isRefreshing]) {
            [self.tableView.mj_header endRefreshing];
        }
        [SVProgressHUD dismiss];
        NSLog(@"某个相馆 -- %@",responseResult);
        if ([responseResult objectForKey:@"resError"]) {
            
        }else{
            if ([[responseResult objectForKey:@"result"] integerValue] == 1) {
                if ([responseResult objectForKey:@"data"]) {
                    NSDictionary *dic = [responseResult objectForKey:@"data"];
                    [self.photoNameArr removeAllObjects];
                    SYPhotoNameModel *model = [SYPhotoNameModel photoNameWithDictionary:dic];
                    [self.photoNameArr addObject:model];
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
//获取相馆里的商品列表
- (void)getShangpinList{
    
    NSString *url = [NSString stringWithFormat:@"%@%@",BaseUrl,@"/store/goods.html"];
    
    NSDictionary *param = @{@"id":self.photoID};
    [[SYHttpRequest sharedInstance] getDataWithUrl:url Parameter:param ResponseObject:^(NSDictionary *responseResult) {
        _productCount = 1;
        NSLog(@"某个相馆的商品 -- %@",responseResult);
        if ([responseResult objectForKey:@"resError"]) {
            
        }else{
            if ([[responseResult objectForKey:@"result"] integerValue] == 1) {
                self.productDic = responseResult;
                if ([responseResult objectForKey:@"data"]) {
                    NSArray *arr = [responseResult objectForKey:@"data"];
                    
                    if (arr.count > 0) {
                        
                        [self.productArr removeAllObjects];
                        for (NSDictionary *dic in arr) {
                            
                            SYProductListModel *model = [SYProductListModel productWithDictionary:dic];
                            [self.productArr addObject:model];
                        }
                    }
                    [self.tableView reloadData];
                }
            }else{
                if ([responseResult objectForKey:@"msg"]) {
                    [self showHint:[responseResult objectForKey:@"msg"]];
                }
            }
        }
    }];
}

- (void)getMoreShangpinList{
    _productCount ++;
    NSString *url = [NSString stringWithFormat:@"%@%@",BaseUrl,@"/store/goods.html"];
    NSDictionary *param = @{@"id":self.photoID, @"page":[NSNumber numberWithInteger:_productCount]};
    [[SYHttpRequest sharedInstance] getDataWithUrl:url Parameter:param ResponseObject:^(NSDictionary *responseResult) {

        NSLog(@"某个相馆的商品 -- %@",responseResult);
        if ([responseResult objectForKey:@"resError"]) {
            
        }else{
            if ([[responseResult objectForKey:@"result"] integerValue] == 1) {
                if ([responseResult objectForKey:@"data"]) {
                    NSArray *arr = [responseResult objectForKey:@"data"];
                    
                    if (arr.count > 0) {
                        for (NSDictionary *dic in arr) {
                            
                            SYProductListModel *model = [SYProductListModel productWithDictionary:dic];
                            [self.productArr addObject:model];
                        }
                    }
                    [self.tableView reloadData];
                }
            }else{
                if ([responseResult objectForKey:@"msg"]) {
                    [self showHint:[responseResult objectForKey:@"msg"]];
                }
            }
        }
    }];
}


- (void)getShangpinPinglun{

    NSString *url = [NSString stringWithFormat:@"%@%@",BaseUrl,@"/store/talk.html"];
    
    NSDictionary *param = @{ @"store":self.photoID};
    __weak typeof(self)weakself = self;
    [[SYHttpRequest sharedInstance] getDataWithUrl:url Parameter:param ResponseObject:^(NSDictionary *responseResult) {
        _pinglunCount = 1;

        NSLog(@"某个相馆的评论 -- %@",responseResult);
        if ([responseResult objectForKey:@"resError"]) {
            
        }else{
            if ([[responseResult objectForKey:@"result"] integerValue] == 1) {
                if ([responseResult objectForKey:@"data"]) {
                    NSArray *data = [responseResult objectForKey:@"data"];
                    if (data.count > 0) {
                        if (data.count < 10) {
                            [weakself.tableView.mj_footer endRefreshingWithNoMoreData];
                        }else{
                            [weakself.tableView.mj_footer resetNoMoreData];
                        }
                        
                        [self.commentArr removeAllObjects];
                        for (NSDictionary *dic in data) {
                            NSMutableDictionary *muDic = [NSMutableDictionary dictionaryWithDictionary:dic];
                            [muDic setObject:@NO forKey:@"isSelecteYou"];
                            [muDic setObject:@NO forKey:@"isSelecteWu"];
                            
                            SYCommentModel *model = [SYCommentModel commentWithDictionary:muDic];
                            [self.commentArr addObject:model];
                        }
                        _pinglunAllCount = [[responseResult objectForKey:@"count"] integerValue];
                    }
                    [self.tableView reloadData];
                }
            }else{
                if ([responseResult objectForKey:@"msg"]) {
                    [self showHint:[responseResult objectForKey:@"msg"]];
                }
            }
        }
    }];
}

- (void)getMoreShangpinPinglun{
    _pinglunCount++;
    NSString *url = [NSString stringWithFormat:@"%@%@",BaseUrl,@"/store/talk.html"];
    NSDictionary *param = @{ @"store":self.photoID, @"page":[NSNumber numberWithInteger:_pinglunCount]};
    __weak typeof(self)weakself = self;
    [[SYHttpRequest sharedInstance] getDataWithUrl:url Parameter:param ResponseObject:^(NSDictionary *responseResult) {
        if ([self.tableView.mj_footer isRefreshing]) {
            [self.tableView.mj_footer endRefreshing];
        }
        NSLog(@"某个相馆的评论 -- %@",responseResult);
        if ([responseResult objectForKey:@"resError"]) {
            
        }else{
            if ([[responseResult objectForKey:@"result"] integerValue] == 1) {
                if ([responseResult objectForKey:@"data"]) {
                    NSArray *data = [responseResult objectForKey:@"data"];
                    if (data.count > 0) {
                        if (data.count < 10) {
                            [weakself.tableView.mj_footer endRefreshingWithNoMoreData];
                        }
                        for (NSDictionary *dic in data) {
                            NSMutableDictionary *muDic = [NSMutableDictionary dictionaryWithDictionary:dic];
                            [muDic setObject:@NO forKey:@"isSelecteYou"];
                            [muDic setObject:@NO forKey:@"isSelecteWu"];
                            
                            SYCommentModel *model = [SYCommentModel commentWithDictionary:muDic];
                            [self.commentArr addObject:model];
                        }
                    }
                    [self.tableView reloadData];
                }
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
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight) style:UITableViewStyleGrouped];
        _tableView.backgroundColor = HexRGB(0xf3f3f3);
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        MJRefreshAutoStateFooter *footer = [MJRefreshAutoStateFooter footerWithRefreshingBlock:^{
            [self getMoreShangpinPinglun];
        }];
        
        [footer setTitle:@"已加载全部评论" forState:MJRefreshStateNoMoreData];
        _tableView.mj_footer = footer;
        
        _tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
            [self getData];
            [self getShangpinList];
            [self getShangpinPinglun];
        }];
    }
    return _tableView;
}

- (NSMutableArray *)photoNameArr{
    if (!_photoNameArr) {
        _photoNameArr = [NSMutableArray arrayWithCapacity:0];
    }
    return _photoNameArr;
}

- (NSMutableArray *)productArr{
    if (!_productArr) {
        _productArr = [NSMutableArray arrayWithCapacity:0];
    }
    return _productArr;
}

- (NSMutableArray *)commentArr{
    if (!_commentArr) {
        _commentArr = [NSMutableArray arrayWithCapacity:0];
    }
    return _commentArr;
}

- (UIButton *)fanhuiDingbu{
    if (!_fanhuiDingbu) {
        _fanhuiDingbu = [UIButton buttonWithType:UIButtonTypeCustom];
        _fanhuiDingbu.frame = CGRectMake(kScreenWidth - 48 - 15, kScreenHeight - 48 - 45 - kNavigationBarHeightAndStatusBarHeight, 48, 48);
        [_fanhuiDingbu setAdjustsImageWhenHighlighted:NO];
        [_fanhuiDingbu setImage:[UIImage imageNamed:@"Stick_icon"] forState:UIControlStateNormal];
        [_fanhuiDingbu addTarget:self action:@selector(fanhuidingbuAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _fanhuiDingbu;
}

- (void)fanhuidingbuAction:(UIButton *)sender{
    [self.tableView setContentOffset:CGPointMake(0, 0) animated:YES];
    
}

- (NSMutableArray *)availableMaps{
    if (!_availableMaps) {
        _availableMaps = [NSMutableArray arrayWithCapacity:0];
    }
    return _availableMaps;
}

@end
