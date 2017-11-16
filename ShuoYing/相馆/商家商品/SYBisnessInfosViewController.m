//
//  SYBisnessInfosViewController.m
//  ShuoYing
//
//  Created by 硕影 on 2017/4/26.
//  Copyright © 2017年 硕影. All rights reserved.
//

#import "SYBisnessInfosViewController.h"

#import "SYBusnessInfosModel.h"
#import "SYBusnessInfosTableViewCell.h"

#import "SYCommentModel.h"
#import "SYPhotoStudioPinglunCell.h"

#import "DTAttributedTextCell.h"
#import "DTImageTextAttachment.h"

#import "SYOneModel.h"
#import "SYTwoModel.h"
#import "SYThreeModel.h"
#import "SYGuiGeView.h"

#import "SYLoginViewController.h"
#import "QTShareView.h"
#import "SYGouMaiOrderViewController.h"
#import "SYXXGouMaiOrderViewController.h"
#import "XFDialogOptionButton.h"

@interface SYBisnessInfosViewController ()<UITableViewDelegate, UITableViewDataSource, QTShareViewDelegate, UIWebViewDelegate>
{
    UIView *_customNaviBar;
    UIView *_lineView;
    
    NSInteger _pinglunCount;
    
    NSString *_htmlStr;
    CGFloat _cellHeight;
    NSAttributedString *_attStr;
    
    BOOL _useStaticRowHeight;
    BOOL _isAppear;
    
    SYGuiGeView *_guigeView;
    
    NSNumber *_shangjiaID;
    NSNumber *_shangpinID;
    IsFromXSorXXType _isFromType;
    
    BOOL _alreadyJoinShopcart;//是否已加入购物车
    NSDictionary *_alreadyJoinShopcartParam;//已加入购物车直接生成订单
    NSNumber *_alreadyJoinShopcartId;//已经加入购物车id
    SYOneModel *_oneModel;
    SYTwoModel *_twoModel;
    SYThreeModel *_threeModel;
    NSInteger _selecteCount;
    BOOL _seleteJoinShopcartOrBuy;
    
    NSInteger _allCommentCount;//所有的评论条数
}
@property (nonatomic, weak) XFDialogFrame *dialogView;

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *commentArr;

@property (nonatomic, strong) NSMutableArray *dataArr;

@property (nonatomic, strong) NSMutableArray *guigeDataSourceArr;

@property (nonatomic, strong) NSDictionary *guigeDataSourceDic;//规格数据

@property (nonatomic, strong) NSDictionary *bunessDataSourceDic;

@property (nonatomic, strong) UIButton *fanhuiDingbu;

@property (nonatomic, strong) UIWebView *webView;

@property (nonatomic, strong) NSMutableArray *availableMaps;

@end

NSString * const AttributedTextCellReuseIdentifier = @"AttributedTextCellReuseIdentifier";
#define kImageDisplayIdentifier @"imageDisplayIdentifier"
#define kContentDisplayIdentifier @"contentDisplayIdentifier"

@implementation SYBisnessInfosViewController

- (void)viewWillAppear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    self.navBarBgAlpha = @"0";
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    self.navBarBgAlpha = @"1";

    [super viewWillDisappear:animated];

    
}

- (void)popAction{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)shareAction:(UIButton *)sender{
    if (self.dataArr.count == 0) {
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
    SYBusnessInfosModel *model = self.dataArr[0];
    NSString *url = @"";
    if (_isFromType == isFromXS) {
        url = [NSString stringWithFormat:@"http://m.yunxiangguan.cn/photoShopGoods.html?store=%ld&id=%ld&app=app",(long)[_shangjiaID integerValue], [_shangpinID integerValue]];
    }else{
        url = [NSString stringWithFormat:@"http://m.yunxiangguan.cn/photoShopTaocan.html?store=%ld&id=%ld&app=app",(long)[_shangjiaID integerValue], [_shangpinID integerValue]];
    }
    NSString *title = [NSString stringWithFormat:@"来自%@【龙果云拍】的精彩分享",model.name];
    UIImage *image = [[SDImageCache sharedImageCache] imageFromCacheForKey:[NSString stringWithFormat:@"%@%@",ImgUrl,model.img_200]];
    //创建分享消息对象
    UMSocialMessageObject *messageObject = [UMSocialMessageObject messageObject];
    UMShareWebpageObject *shareObject = [UMShareWebpageObject shareObjectWithTitle:title descr:model.title thumImage:image];
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

- (instancetype)initWithIsFromXSorXXType:(IsFromXSorXXType)type shangpinID:(NSNumber *)shangpin shangjiaID:(NSNumber *)shangjia{
    if (self = [super init]) {
        _isFromType = type;
        _shangjiaID = shangjia;
        _shangpinID = shangpin;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    

    UIWebView *web = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 0)];
    web.delegate = self;
    web.backgroundColor = [UIColor clearColor];
    web.opaque = NO;
    web.scrollView.scrollEnabled = NO;
    self.webView = web;
    
    _oneModel = nil;
    _twoModel = nil;
    _threeModel = nil;
    _selecteCount = 1;
    _allCommentCount = 0;
    _isAppear = NO;
    _alreadyJoinShopcart = NO;
    _alreadyJoinShopcartParam = nil;
    _htmlStr = @"";
    _cellHeight = 1;
    _pinglunCount = 1;

    [self.view addSubview:self.tableView];
    [self initCustomNavigationBar];
    [self getData];
    [self getGuiGe];
    [self getShangpinPinglun];
    if (_isFromType == isFromXS) {
        [self initBottomView];
    }else{
        [self initXXBottonView];
    }
    
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    
    if ([keyPath isEqualToString:@"contentSize"]) {
        
        //通过JS代码获取webview的内容高度
        _cellHeight = [[self.webView stringByEvaluatingJavaScriptFromString:@"document.body.scrollHeight"] floatValue];
        
        //通过webview的contentSize获取内容高度
        
        //        self.webViewHeight = [self.showWebView.scrollView contentSize].height;
        
        CGRect newFrame = self.webView.frame;
        
        newFrame.size.height  = _cellHeight;
        
        NSLog(@"-document.body.scrollHeight-----%f",_cellHeight);
        
        NSLog(@"-contentSize-----%f",self.webView.scrollView.contentSize.height);
        
        self.webView.frame = CGRectMake(0, 0, kScreenWidth, _cellHeight);
        
        [self.tableView reloadData];
    }
}

- (void)initBottomView{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, kScreenHeight - 52, kScreenWidth, 52)];
    UIButton *gouwuche = [UIButton buttonWithType:UIButtonTypeCustom];
    gouwuche.frame = CGRectMake(0, 0, kScreenWidth / 2, 52);
    [gouwuche setAdjustsImageWhenHighlighted:NO];
    [gouwuche setTitle:@"加入购物车" forState:UIControlStateNormal];
    [gouwuche setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [gouwuche setBackgroundImage:[UIImage imageWithColor:NavigationColor Size:gouwuche.frame.size] forState:UIControlStateNormal];
    [gouwuche addTarget:self action:@selector(gouwucheAction:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:gouwuche];
    
    UIButton *goumai = [UIButton buttonWithType:UIButtonTypeCustom];
    goumai.frame = CGRectMake(kScreenWidth / 2, 0, kScreenWidth / 2, 52);
    [goumai setAdjustsImageWhenHighlighted:NO];
    [goumai setTitle:@"立即购买" forState:UIControlStateNormal];
    [goumai setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [goumai setBackgroundImage:[UIImage imageWithColor:HexRGB(0xff8402) Size:goumai.frame.size] forState:UIControlStateNormal];
    [goumai addTarget:self action:@selector(goumaiAction:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:goumai];
    
    [self.view addSubview:view];
}

- (void)initXXBottonView{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, kScreenHeight - 52, kScreenWidth, 52)];
    view.backgroundColor = HexRGB(0xfafafa);
    [view.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(kScreenWidth - 175, 7, 161, 38);
    [btn setTitle:@"立即购买" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn setBackgroundColor:NavigationColor];
    btn.titleLabel.font = [UIFont systemFontOfSize:17];
    btn.layer.cornerRadius = 5;
    btn.layer.masksToBounds = YES;
    [btn addTarget:self action:@selector(xianxiaGoumaiAction:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:btn];
    
    if (self.dataArr.count > 0) {
        SYBusnessInfosModel *model = self.dataArr[0];
        UILabel *price = [[UILabel alloc] initWithFrame:CGRectMake(17, 5, kScreenWidth - 175 - 20, 24)];
        [price setFont:[UIFont systemFontOfSize:23]];
        [price setTextColor:HexRGB(0xff5b01)];
        [price setText:[NSString stringWithFormat:@"¥%@",model.money_min]];
        [view addSubview:price];
        
        UILabel *yuanjia = [[UILabel alloc] initWithFrame:CGRectMake(17, CGRectGetMaxY(price.frame) + 7, kScreenWidth - 175 - 20, 13)];
        NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"门市价¥%@",model.fee_min]];
        [attStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:12] range:NSMakeRange(0, attStr.length)];
        [attStr addAttribute:NSForegroundColorAttributeName value:HexRGB(0x8b8a89) range:NSMakeRange(0, attStr.length)];
        [attStr addAttributes:@{NSStrikethroughStyleAttributeName:@(NSUnderlineStyleSingle),NSBaselineOffsetAttributeName:@(0)} range:NSMakeRange(0, attStr.length)];
        [attStr addAttribute:NSStrikethroughColorAttributeName value:HexRGB(0x8b8a89) range:NSMakeRange(0, attStr.length)];
        yuanjia.attributedText = attStr;
        [view addSubview:yuanjia];
        
    }else{
        btn.userInteractionEnabled = NO;
    }
    
    [self.view addSubview:view];
}
//线上加入购物车
#pragma mark - 线上加入购物车
- (void)gouwucheAction:(UIButton *)sender{
    if (!LoginStatus) {
        SYLoginViewController *login = [[SYLoginViewController alloc] initWithNibName:@"SYLoginViewController" bundle:nil];
        [self.navigationController pushViewController:login animated:YES];
        return;
    }
    _seleteJoinShopcartOrBuy = NO;
    NSString *imgUrl = @"";
    NSString *money = @"";
    if (self.dataArr.count > 0) {
        SYBusnessInfosModel *infos = self.dataArr[0];
        imgUrl = infos.img_200;
        money = infos.money_min;
    }
    SYGuiGeView *view = [[SYGuiGeView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight) WithDataSourceArr:self.guigeDataSourceArr WithDataSourceDic:self.guigeDataSourceDic WithOneModel:_oneModel WithTwoModel:_twoModel WithThreeModel:_threeModel WithSelecteCount:_selecteCount];
    _guigeView = view;

    view.imgUrl = imgUrl;
    view.money = money;
    __weak typeof(self)weakself = self;
    view.shopcartBlock = ^(SYOneModel *one, SYTwoModel *two, SYThreeModel *three, NSInteger count) {
        NSLog(@"SYOneModel - %@ SYTwoModel - %@ SYThreeModel - %@ count - %ld",one,two,three,count);
        _oneModel = one;
        _twoModel = two;
        _threeModel = three;
        _selecteCount = count;
        NSMutableDictionary *param = [NSMutableDictionary dictionaryWithCapacity:0];
        [param setObject:UserToken forKey:@"token"];
        [param setObject:_shangpinID forKey:@"id"];
        if (count && count != 0) {
            [param setObject:[NSNumber numberWithInteger:count] forKey:@"num"];
        }
        if (one && one != nil && ![one isKindOfClass:[NSNull class]]) {
            [param setObject:one.spceVal forKey:@"spce1"];
        }else{
            [param setObject:@"" forKey:@"spce1"];
        }
        
        if (two && two != nil && ![two isKindOfClass:[NSNull class]]) {
            [param setObject:two.spceVal forKey:@"spce2"];
        }else{
            [param setObject:@"" forKey:@"spce2"];
        }
        
        if (three && three != nil && ![three isKindOfClass:[NSNull class]]) {
            [param setObject:three.spceVal forKey:@"spce3"];
        }else{
            [param setObject:@"" forKey:@"spce3"];
        }
        
        [weakself jiaruGouWuCheRequestWithParam:param];
    };
    [view show];
}

- (void)jiaruGouWuCheRequestWithParam:(NSDictionary *)param{
    [SVProgressHUD show];
    NSString *url = [NSString stringWithFormat:@"%@%@",BaseUrl,@"/store/addcart.html"];
    __weak typeof(self)weakself = self;
    [[SYHttpRequest sharedInstance] getDataWithUrl:url Parameter:param ResponseObject:^(NSDictionary *responseResult) {
        [SVProgressHUD dismiss];
        NSLog(@"加入购物车 -- %@",responseResult);
        if ([responseResult objectForKey:@"resError"]) {
            
        }else{
            if ([[responseResult objectForKey:@"result"] integerValue] == 1) {
                
                [_guigeView dismiss];
                if (_seleteJoinShopcartOrBuy) {
                    SYGouMaiOrderViewController *order = [[SYGouMaiOrderViewController alloc] init];
                    order.dataSourceDic = weakself.bunessDataSourceDic;
                    order.selecteCount = _selecteCount;
                    order.shangpinShuxing = [NSString stringWithFormat:@"%@%@%@",_oneModel.spceName,_twoModel.spceName,_threeModel.spceName];
                    order.oneModel = _oneModel;
                    order.twoModel = _twoModel;
                    order.threeModel = _threeModel;
                    order.gouwucheID = [responseResult objectForKey:@"id"];
                    [weakself.navigationController pushViewController:order animated:YES];
                }else{
                    _alreadyJoinShopcart = YES;
                    _alreadyJoinShopcartParam = param;
                    _alreadyJoinShopcartId = [responseResult objectForKey:@"id"];
                    if ([responseResult objectForKey:@"msg"]) {
                        [self showHint:[responseResult objectForKey:@"msg"]];
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
//线上立即购买按钮
#pragma mark - 线上立刻购买按钮
- (void)goumaiAction:(UIButton *)sender{
    
    if (!LoginStatus) {
        SYLoginViewController *login = [[SYLoginViewController alloc] initWithNibName:@"SYLoginViewController" bundle:nil];
        [self.navigationController pushViewController:login animated:YES];
        return;
    }
    //如果已经加入购物车
    if (_alreadyJoinShopcart) {
        SYGouMaiOrderViewController *order = [[SYGouMaiOrderViewController alloc] init];
        order.dataSourceDic = self.bunessDataSourceDic;
        order.selecteCount = _selecteCount;
        order.shangpinShuxing = [NSString stringWithFormat:@"%@%@%@",_oneModel.spceName,_twoModel.spceName,_threeModel.spceName];
        order.oneModel = _oneModel;
        order.twoModel = _twoModel;
        order.threeModel = _threeModel;
        order.gouwucheID = _alreadyJoinShopcartId;
        [self.navigationController pushViewController:order animated:YES];
        return;
    }
    _seleteJoinShopcartOrBuy = YES;
    NSString *imgUrl = @"";
    NSString *money = @"";
    if (self.dataArr.count > 0) {
        SYBusnessInfosModel *infos = self.dataArr[0];
        imgUrl = infos.img_200;
        money = infos.money_min;
    }
    
    SYGuiGeView *view = [[SYGuiGeView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight) WithDataSourceArr:self.guigeDataSourceArr WithDataSourceDic:self.guigeDataSourceDic WithOneModel:_oneModel WithTwoModel:_twoModel WithThreeModel:_threeModel WithSelecteCount:_selecteCount];
    _guigeView = view;

    view.imgUrl = imgUrl;
    view.money = money;
    __weak typeof(self)weakself = self;
    view.shopcartBlock = ^(SYOneModel *one, SYTwoModel *two, SYThreeModel *three, NSInteger count) {
        NSLog(@"SYOneModel - %@ SYTwoModel - %@ SYThreeModel - %@ count - %ld",one,two,three,count);
        _oneModel = one;
        _twoModel = two;
        _threeModel = three;
        _selecteCount = count;
        NSMutableDictionary *param = [NSMutableDictionary dictionaryWithCapacity:0];
        [param setObject:UserToken forKey:@"token"];
        [param setObject:_shangpinID forKey:@"id"];
        if (count && count != 0) {
            [param setObject:[NSNumber numberWithInteger:count] forKey:@"num"];
        }
        if (one && one != nil && ![one isKindOfClass:[NSNull class]]) {
            [param setObject:one.spceVal forKey:@"spce1"];
        }else{
            [param setObject:@"" forKey:@"spce1"];
        }
        
        if (two && two != nil && ![two isKindOfClass:[NSNull class]]) {
            [param setObject:two.spceVal forKey:@"spce2"];
        }else{
            [param setObject:@"" forKey:@"spce2"];
        }
        
        if (three && three != nil && ![three isKindOfClass:[NSNull class]]) {
            [param setObject:three.spceVal forKey:@"spce3"];
        }else{
            [param setObject:@"" forKey:@"spce3"];
        }
        
        [_guigeView dismiss];
        [weakself jiaruGouWuCheRequestWithParam:param];
    };
    [view show];
}
//线下立即购买按钮
#pragma mark - 线下购买按钮
- (void)xianxiaGoumaiAction:(UIButton *)sender{
    if (!LoginStatus) {
        SYLoginViewController *login = [[SYLoginViewController alloc] initWithNibName:@"SYLoginViewController" bundle:nil];
        [self.navigationController pushViewController:login animated:YES];
        return;
    }
    NSString *imgUrl = @"";
    NSString *money = @"";
    if (self.dataArr.count > 0) {
        SYBusnessInfosModel *infos = self.dataArr[0];
        imgUrl = infos.img_200;
        money = infos.money_min;
    }
    SYGuiGeView *view = [[SYGuiGeView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight) WithDataSourceArr:self.guigeDataSourceArr WithDataSourceDic:self.guigeDataSourceDic WithOneModel:_oneModel WithTwoModel:_twoModel WithThreeModel:_threeModel WithSelecteCount:_selecteCount];
    _guigeView = view;

    view.imgUrl = imgUrl;
    view.money = money;
    __weak typeof(self)weakself = self;
    view.shopcartBlock = ^(SYOneModel *one, SYTwoModel *two, SYThreeModel *three, NSInteger count) {
        NSLog(@"SYOneModel - %@ SYTwoModel - %@ SYThreeModel - %@ count - %ld",one,two,three,count);
        _oneModel = one;
        _twoModel = two;
        _threeModel = three;
        _selecteCount = count;
        NSMutableDictionary *param = [NSMutableDictionary dictionaryWithCapacity:0];
        [param setObject:UserToken forKey:@"token"];
        [param setObject:_shangpinID forKey:@"id"];
        if (count && count != 0) {
            [param setObject:[NSNumber numberWithInteger:count] forKey:@"num"];
        }
        if (one && one != nil && ![one isKindOfClass:[NSNull class]]) {
            [param setObject:one.spceVal forKey:@"spce1"];
        }else{
            [param setObject:@"" forKey:@"spce1"];
        }
        
        if (two && two != nil && ![two isKindOfClass:[NSNull class]]) {
            [param setObject:two.spceVal forKey:@"spce2"];
        }else{
            [param setObject:@"" forKey:@"spce2"];
        }
        
        if (three && three != nil && ![three isKindOfClass:[NSNull class]]) {
            [param setObject:three.spceVal forKey:@"spce3"];
        }else{
            [param setObject:@"" forKey:@"spce3"];
        }
        
        [_guigeView dismiss];
        [weakself creatOrderWithParam:param];
    };
    [view show];
}

//如果是线下立刻购买按钮 直接生成订单
- (void)creatOrderWithParam:(NSDictionary *)param{
    //生成订单
    [SVProgressHUD show];
    NSString *url = [NSString stringWithFormat:@"%@%@",BaseUrl,@"/store/create.html"];
    __weak typeof(self)weakself = self;
    [[SYHttpRequest sharedInstance] getDataWithUrl:url Parameter:param ResponseObject:^(NSDictionary *responseResult) {
        [SVProgressHUD dismiss];
        NSLog(@"生成线下订单 -- %@",responseResult);
        if ([responseResult objectForKey:@"resError"]) {
            
        }else{
            if ([[responseResult objectForKey:@"result"] integerValue] == 1) {
                SYXXGouMaiOrderViewController *order = [[SYXXGouMaiOrderViewController alloc] init];
                order.dataSourceDic = weakself.bunessDataSourceDic;
                order.selecteCount = _selecteCount;

                order.orderid = [responseResult objectForKey:@"order"];
                [weakself.navigationController pushViewController:order animated:YES];
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
    if (a <= 1.0) {
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


#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (_isFromType == isFromXS) {
        if (section == 2) {
            return self.commentArr.count;
        }
        if (section == 1) {
            
            return 0;
        }
        return 1;
    }else{
        if (section == 3) {
            return self.commentArr.count;
        }
        if (section == 1) {
            
            return 0;
        }
        if (section == 2) {
            return 2;
        }
        return 1;
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (_isFromType == isFromXS) {
        if (indexPath.section == 0) {
            static NSString *identifier = @"nameCell";
            SYBusnessInfosTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
            if (!cell) {
                cell = [[NSBundle mainBundle] loadNibNamed:@"SYBusnessInfosTableViewCell" owner:nil options:nil][0];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.addressView.hidden = YES;
            }
            SYBusnessInfosModel *model = nil;
            if (self.dataArr.count > 0) {
                cell.infosModel = self.dataArr[0];
                model = self.dataArr[0];
            }

            __weak typeof(self)weakself = self;
            cell.callBlock = ^{
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
            return cell;
        }else if (indexPath.section == 1){
            
            static NSString *identifier = @"webviewcell";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            return cell;
            
        }else{
            static NSString *identifier = @"pinglunCell";
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

    }else{
        if (indexPath.section == 0) {
            static NSString *identifier = @"nameCell";
            SYBusnessInfosTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
            if (!cell) {
                cell = [[NSBundle mainBundle] loadNibNamed:@"SYBusnessInfosTableViewCell" owner:nil options:nil][0];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            SYBusnessInfosModel *model = nil;
            if (self.dataArr.count > 0) {
                cell.infosModel = self.dataArr[0];
                model = self.dataArr[0];
            }
            __weak typeof(self)weakself = self;
            cell.callBlock = ^{
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

            cell.addressBlock = ^{
                [weakself openMap];
            };
            
            return cell;
        }else if (indexPath.section == 1){
            
            static NSString *identifier = @"webviewcell";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            return cell;
            
        }else if (indexPath.section == 2){
            static NSString *identifier = @"webviewcell";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.textLabel.font = [UIFont systemFontOfSize:15];
                cell.textLabel.textColor = HexRGB(0xa4a4a4);
            }
            if (self.dataArr.count > 0) {
                SYBusnessInfosModel *model = self.dataArr[0];
                if (indexPath.row == 0) {
                    cell.textLabel.text = [NSString stringWithFormat:@"有效期：%@",model.time];
                    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 37, kScreenWidth, 1)];
                    lineView.backgroundColor = HexRGB(0xeaeaea);
                    [cell.contentView addSubview:lineView];
                }else{
                    cell.textLabel.text = [NSString stringWithFormat:@"使用规则：%@",model.rule];
                }
            }
            
            return cell;
        }else{
            static NSString *identifier = @"pinglunCell";
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
    
    SYBusnessInfosModel *model = nil;
    if (self.dataArr.count > 0) {
        model = self.dataArr[0];
        endJingdu = [model.jingdu doubleValue];
        endweidu = [model.weidu doubleValue];
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


- (void)webViewDidFinishLoad:(UIWebView *)webView{
    [SVProgressHUD dismiss];
    
    NSString *str = [NSString stringWithFormat:@"var script = document.createElement('script');"
                     "script.type = 'text/javascript';"
                     "script.text = \"function ResizeImages() { "
                     "var myimg,oldwidth,oldheight;"
                     "var maxwidth=%f;"// 图片宽度
                     "for(i=0;i <document.images.length;i++){"
                     "myimg = document.images[i];"
                     "if(myimg.width > maxwidth){"
                     "myimg.width = maxwidth;"
                     "}"
                     "}"
                     "}\";"
                     "document.getElementsByTagName('head')[0].appendChild(script);",(kScreenWidth - 20)];
    
    [webView stringByEvaluatingJavaScriptFromString:
     str];
    
    [webView stringByEvaluatingJavaScriptFromString:@"ResizeImages();"];
    //方法1
    //HTML5的高度
    NSString *htmlHeight = [self.webView stringByEvaluatingJavaScriptFromString:@"document.body.scrollHeight"];
    //HTML5的宽度
    NSString *htmlWidth = [self.webView stringByEvaluatingJavaScriptFromString:@"document.body.scrollWidth"];
    //宽高比
    float i = [htmlWidth floatValue]/[htmlHeight floatValue];
    
    //webview控件的最终高度
    float height = kScreenWidth/i;
    NSLog(@" - %f",height);
    _cellHeight = height;
    [self.tableView reloadData];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (_isFromType == isFromXX) {
        return 4;
    }
    return 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (_isFromType == isFromXS) {
        if (indexPath.section == 0 ) {
            return 257;
        }else if (indexPath.section == 1){
            return 0;
        }else{
            SYCommentModel *model = self.commentArr[indexPath.row];
            NSString *info = model.info;
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth - 79, 0)];
            label.text = info;
            label.font = [UIFont systemFontOfSize:14];
            label.numberOfLines = 0;
            CGSize maxSize = [label sizeThatFits:CGSizeMake(label.frame.size.width, MAXFLOAT)];
            CGFloat pictureHeight = (kScreenWidth - 65 - 14 - 26) / 3;
            if (model.img_200.count > 0) {
                return 130 + pictureHeight + maxSize.height;
            }else{
                return 130 + maxSize.height;
            }
        }
    }else{
        if (indexPath.section == 0 ) {
            return 257 + 40;
        }else if (indexPath.section == 1){
            return 0;
        }else if (indexPath.section == 2){
            return 38;
        }else{
            SYCommentModel *model = self.commentArr[indexPath.row];
            NSString *info = model.info;
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth - 79, 0)];
            label.text = info;
            label.font = [UIFont systemFontOfSize:14];
            label.numberOfLines = 0;
            CGSize maxSize = [label sizeThatFits:CGSizeMake(label.frame.size.width, MAXFLOAT)];
            CGFloat pictureHeight = (kScreenWidth - 65 - 14 - 26) / 3;
            if (model.img_200.count > 0) {
                return 130 + pictureHeight + maxSize.height;
            }else{
                return 130 + maxSize.height;
            }
        }
    }
    
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (_isFromType == isFromXS) {
        if (section == 0) {
            return 0.000001f;
        }
        if (section == 1) {
            return 52;
        }
        return 59;
    }else{
        if (section == 0) {
            return 0.000001f;
        }
        if (section == 1) {
            return 52;
        }
        if (section == 2) {
            return 52;
        }
        return 59;
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (_isFromType == isFromXS) {
        if (section == 1) {

            return _cellHeight;
        }
        return 0.00001f;
    }else{
        if (section == 1) {

            return _cellHeight;
        }
        
        return 0.00001f;
    }
    
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (_isFromType == isFromXS) {
        if (section == 0) {
            return nil;
        }
        else if (section == 1) {
            UIView *view = [[UIView alloc] init];
            view.backgroundColor = HexRGB(0xf3f3f3);
            
            UIView *view1 = [[UIView alloc] initWithFrame:CGRectMake(0, 14, kScreenWidth, 38)];
            view1.backgroundColor = [UIColor whiteColor];
            [view addSubview:view1];
            
            
            UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 37, kScreenWidth, 1)];
            lineView.backgroundColor = RGB(238, 238, 238);
            [view1 addSubview:lineView];
            
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(14, 10, kScreenWidth - 30, 17)];
            label.text = @"商品详情";
            label.textColor = RGB(43, 43, 43);
            label.font = [UIFont systemFontOfSize:17];
            [view1 addSubview:label];
            
            return view;
        }
        else  {
            UIView *view = [[UIView alloc] init];
            view.backgroundColor = HexRGB(0xf3f3f3);
            
            UIView *view1 = [[UIView alloc] initWithFrame:CGRectMake(0, 14, kScreenWidth, 45)];
            view1.backgroundColor = [UIColor whiteColor];
            [view addSubview:view1];
            
            
            UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 44, kScreenWidth, 1)];
            lineView.backgroundColor = RGB(238, 238, 238);
            [view1 addSubview:lineView];
            
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(14, 14, kScreenWidth - 30, 16)];
            label.text = [NSString stringWithFormat:@"评价（%ld）",(long)_allCommentCount];
            label.textColor = NavigationColor;
            label.font = [UIFont systemFontOfSize:16];
            [view1 addSubview:label];
            
            return view;
        }

    }else{
        if (section == 0) {
            return nil;
        }
        else if (section == 1) {
            UIView *view = [[UIView alloc] init];
            view.backgroundColor = HexRGB(0xf3f3f3);
            
            UIView *view1 = [[UIView alloc] initWithFrame:CGRectMake(0, 14, kScreenWidth, 38)];
            view1.backgroundColor = [UIColor whiteColor];
            [view addSubview:view1];
            
            
            UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 37, kScreenWidth, 1)];
            lineView.backgroundColor = RGB(238, 238, 238);
            [view1 addSubview:lineView];
            
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(14, 10, kScreenWidth - 30, 17)];
            label.text = @"套餐详情";
            label.textColor = RGB(43, 43, 43);
            label.font = [UIFont systemFontOfSize:17];
            [view1 addSubview:label];
            
            return view;
        }else if (section == 2){
            UIView *view = [[UIView alloc] init];
            view.backgroundColor = HexRGB(0xf3f3f3);
            
            UIView *view1 = [[UIView alloc] initWithFrame:CGRectMake(0, 14, kScreenWidth, 38)];
            view1.backgroundColor = [UIColor whiteColor];
            [view addSubview:view1];
            
            
            UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 37, kScreenWidth, 1)];
            lineView.backgroundColor = RGB(238, 238, 238);
            [view1 addSubview:lineView];
            
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(14, 10, kScreenWidth - 30, 17)];
            label.text = @"消费提示";
            label.textColor = RGB(43, 43, 43);
            label.font = [UIFont systemFontOfSize:17];
            [view1 addSubview:label];
            
            return view;
        }
        else  {
            UIView *view = [[UIView alloc] init];
            view.backgroundColor = HexRGB(0xf3f3f3);
            
            UIView *view1 = [[UIView alloc] initWithFrame:CGRectMake(0, 14, kScreenWidth, 45)];
            view1.backgroundColor = [UIColor whiteColor];
            [view addSubview:view1];
            
            
            UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 44, kScreenWidth, 1)];
            lineView.backgroundColor = RGB(238, 238, 238);
            [view1 addSubview:lineView];
            
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(14, 14, kScreenWidth - 30, 16)];
            label.text = [NSString stringWithFormat:@"评价（%ld）",_allCommentCount];
            label.textColor = NavigationColor;
            label.font = [UIFont systemFontOfSize:16];
            [view1 addSubview:label];
            return view;
        }
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    if (_isFromType == isFromXS) {
        if (section == 1) {
            UIView *view = [[UIView alloc] init];
            view.backgroundColor = [UIColor whiteColor];
            self.webView.frame = CGRectMake(0, 0, kScreenWidth, _cellHeight);
            if (_cellHeight > 1) {
                [view addSubview:self.webView];
            }
            return view;
        }
        return nil;
    }else{
        if (section == 1) {
            UIView *view = [[UIView alloc] init];
            view.backgroundColor = [UIColor whiteColor];
            self.webView.frame = CGRectMake(0, 0, kScreenWidth, _cellHeight);
            if (_cellHeight > 1) {
                [view addSubview:self.webView];
            }
            return view;
        }
        return nil;
    }
    
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
    NSString *url = [NSString stringWithFormat:@"%@%@",BaseUrl,@"/store/good.html"];
    NSDictionary *param = @{@"id":_shangpinID};
    [[SYHttpRequest sharedInstance] getDataWithUrl:url Parameter:param ResponseObject:^(NSDictionary *responseResult) {
        if ([self.tableView.mj_header isRefreshing]) {
            [self.tableView.mj_header endRefreshing];
        }
        [SVProgressHUD dismiss];
        NSLog(@"某个商品信息 -- %@",responseResult);
        if ([responseResult objectForKey:@"resError"]) {
            
        }else{
            if ([[responseResult objectForKey:@"result"] integerValue] == 1) {
                if ([responseResult objectForKey:@"data"]) {
                    NSDictionary *data = [responseResult objectForKey:@"data"];
                    self.bunessDataSourceDic = data;
                    SYBusnessInfosModel *infosModel = [SYBusnessInfosModel busnessInfosWithDictionary:data];
                    [self.dataArr removeAllObjects];
                    [self.dataArr addObject:infosModel];
                }
                if (_isFromType == isFromXX) {
                    [self initXXBottonView];
                }
                
                _htmlStr = [[responseResult objectForKey:@"data"] objectForKey:@"content"];
                __weak typeof(self)weakself = self;
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    [weakself.webView loadHTMLString:_htmlStr baseURL:[NSURL URLWithString:ImgUrl]];

                    //异步返回主线程
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [weakself.tableView reloadData];
                    });
                });
                
                [self.tableView reloadData];
                
                
            }else{
                if ([responseResult objectForKey:@"msg"]) {
                    [self showHint:[responseResult objectForKey:@"msg"]];
                }
            }
        }
    }];
}

- (void)getGuiGe{
    NSString *url = [NSString stringWithFormat:@"%@%@",BaseUrl,@"/store/spce.html"];
    
    NSDictionary *param = @{@"id":_shangpinID};
    [[SYHttpRequest sharedInstance] getDataWithUrl:url Parameter:param ResponseObject:^(NSDictionary *responseResult) {

        NSLog(@"某个商品规格 -- %@",responseResult);
        if ([responseResult objectForKey:@"resError"]) {
            
        }else{
            if ([[responseResult objectForKey:@"result"] integerValue] == 1) {
                self.guigeDataSourceDic = responseResult;
                if ([responseResult objectForKey:@"data"]) {
                    NSArray *spces = [[responseResult objectForKey:@"data"]objectForKey:@"spces"];
                    for (NSDictionary *dic in spces) {
                        SYOneModel *one = [SYOneModel oneWithDictionary:dic];
                        [self.guigeDataSourceArr addObject:one];
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


- (void)getShangpinPinglun{
    NSString *url = [NSString stringWithFormat:@"%@%@",BaseUrl,@"/store/talk.html"];
    
    NSDictionary *param = @{@"id":_shangpinID, @"store":_shangjiaID};
    [[SYHttpRequest sharedInstance] getDataWithUrl:url Parameter:param ResponseObject:^(NSDictionary *responseResult) {
        _pinglunCount = 1;
        
        NSLog(@"某个相馆的评论 -- %@",responseResult);
        __weak typeof(self)weakself = self;
        if ([responseResult objectForKey:@"resError"]) {
            
        }else{
            if ([[responseResult objectForKey:@"result"] integerValue] == 1) {
                if ([responseResult objectForKey:@"data"]) {
                    NSArray *data = [responseResult objectForKey:@"data"];
                    if (data.count > 0) {
                        _allCommentCount = [(NSNumber *)[responseResult objectForKey:@"count"] integerValue];
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
    NSDictionary *param = @{@"id":_shangpinID, @"store":_shangjiaID, @"page":[NSNumber numberWithInteger:_pinglunCount]};
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
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight - 52) style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.backgroundColor = HexRGB(0xf3f3f3);
        _tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
            [self getData];
            [self getGuiGe];
            [self getShangpinPinglun];
        }];

        MJRefreshAutoStateFooter *footer = [MJRefreshAutoStateFooter footerWithRefreshingBlock:^{
            [self getMoreShangpinPinglun];
        }];
        
        [footer setTitle:@"已加载全部评论" forState:MJRefreshStateNoMoreData];
        _tableView.mj_footer = footer;
    }
    return _tableView;
}

- (NSMutableArray *)commentArr{
    if (!_commentArr) {
        _commentArr = [NSMutableArray arrayWithCapacity:0];
    }
    return _commentArr;
}

- (NSMutableArray *)dataArr{
    if (!_dataArr) {
        _dataArr = [NSMutableArray arrayWithCapacity:0];
    }
    return _dataArr;
}

- (NSMutableArray *)guigeDataSourceArr{
    if (!_guigeDataSourceArr) {
        _guigeDataSourceArr = [NSMutableArray arrayWithCapacity:0];
    }
    return _guigeDataSourceArr;
}

- (UIButton *)fanhuiDingbu{
    if (!_fanhuiDingbu) {
        _fanhuiDingbu = [UIButton buttonWithType:UIButtonTypeCustom];
        _fanhuiDingbu.frame = CGRectMake(kScreenWidth - 48 - 15, kScreenHeight - 48 - 45 - kNavigationBarHeightAndStatusBarHeight - 52, 48, 48);
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
