//
//  SYShopcartPayOrderViewController.m
//  ShuoYing
//
//  Created by 硕影 on 2017/5/4.
//  Copyright © 2017年 硕影. All rights reserved.
//

#import "SYShopcartPayOrderViewController.h"
#import "SYShopcartPayOrderTableViewCell.h"
#import "SYShopcartShangjiaModel.h"
#import "SYShopcartShangpinModel.h"
#import "SYDefaultAddressTableViewCell.h"
#import "SYAddressModel.h"
#import "SYAddressViewController.h"
#import "SYSelectePhotoViewController.h"
#import "OrderPayTypeView.h"
#import "SYUserInfos.h"
#import "SYOrderInfosViewController.h"
@interface SYShopcartPayOrderViewController ()<UITableViewDelegate, UITableViewDataSource, SelectedAddressDelegate, UIWebViewDelegate>

{
    SYUserInfos *_userinfos;
}

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) SYAddressModel *addressModel;

@property (nonatomic, strong) NSMutableArray *dataSourceArr;

@property (nonatomic, strong) UITextField *liuyanTF;

@end

@implementation SYShopcartPayOrderViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self getData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"支付订单";
    _userinfos = [[Tool sharedInstance] getObjectWithPath:Mobile];
    //对传过来的数据进行处理
    [self.view addSubview:self.tableView];
    [self initBottomView];
}

- (void)initBottomView{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, kScreenHeight - kNavigationBarHeightAndStatusBarHeight - 55, kScreenWidth, 55)];
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setAdjustsImageWhenHighlighted:NO];
    btn.frame = CGRectMake(0, 0, kScreenWidth, 55);
    [btn setBackgroundImage:[UIImage imageWithColor:NavigationColor Size:btn.frame.size] forState:UIControlStateNormal];
    [btn setTitle:[NSString stringWithFormat:@"提交订单%@",self.allPrice] forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [view addSubview:btn];
    [btn addTarget:self action:@selector(creatOrderAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:view];
}

- (void)creatOrderAction:(UIButton *)sender{
    if (self.addressModel == nil) {
        [self showHint:@"请选择您的收货地址"];
        return;
    }
    //判断所有的照片是否都选择了
    for (SYShopcartShangjiaModel *shangjia in self.dataSourceArr) {
        NSArray *goods = shangjia.goods;
        for (SYShopcartShangpinModel *shangpin in goods) {
            if ([shangpin.upimg integerValue] * [shangpin.num integerValue] != [shangpin.c_img integerValue]) {
                NSInteger count = [shangpin.upimg integerValue] * [shangpin.num integerValue] - [shangpin.c_img integerValue];
                NSString *tishi = [NSString stringWithFormat:@"您在%@、%@还有%ld照片没选择，请先选择完照片再提交订单",shangjia.name,shangpin.title,count];
                LQPopUpView *popUpView = [[LQPopUpView alloc] initWithTitle:@"提示" message:tishi];
                popUpView.btnStyleDefaultTextColor = NavigationColor;
                popUpView.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight - kNavigationBarHeightAndStatusBarHeight);
                [popUpView addBtnWithTitle:@"好的" type:LQPopUpBtnStyleDefault handler:^{
                    
                }];
                [popUpView showInView:self.view preferredStyle:0];
                return;
            }
        }
    }
    
    //生成订单
    [self alipy];
}

- (void)alipy{
    NSMutableArray *gouwuIDS = [NSMutableArray arrayWithCapacity:0];
    for (SYShopcartShangjiaModel *shangjia in self.dataSourceArr) {
        for (SYShopcartShangpinModel *shangpin in shangjia.goods) {
            [gouwuIDS addObject:[shangpin.shangpinid stringValue]];
        }
    }
    NSString *ids = [gouwuIDS componentsJoinedByString:@","];
    NSLog(@"gouwuIDS - %@",gouwuIDS);
    NSLog(@"ids - %@",ids);
    NSString *url = [NSString stringWithFormat:@"%@%@",BaseUrl,@"/store/createorder.html"];
    NSDictionary *param = @{@"token":UserToken, @"id":ids, @"addressid":self.addressModel.addressId, @"msg":self.liuyanTF.text};
    [SVProgressHUD show];
    [[SYHttpRequest sharedInstance] getDataWithUrl:url Parameter:param ResponseObject:^(NSDictionary *responseResult) {
        [SVProgressHUD dismiss];
        NSLog(@"线上生成订单 -- %@",responseResult);
        if ([responseResult objectForKey:@"resError"]) {
            
        }else{
            if ([[responseResult objectForKey:@"result"] integerValue] == 1) {
//                [self seletePaytypeWithOrderid:[responseResult objectForKey:@"order"]];
                SYOrderInfosViewController *orderInfos = [[SYOrderInfosViewController alloc] init];
                orderInfos.param = @{@"id":[responseResult objectForKey:@"order"], @"token":UserToken, @"state":@1};
                orderInfos.type = OrderTypeWeiFuKuan;
                [self.navigationController pushViewController:orderInfos animated:YES];
            }else{
                if ([responseResult objectForKey:@"msg"]) {
                    [self showHint:[responseResult objectForKey:@"msg"]];
                }
            }
        }
    }];
}

- (void)seletePaytypeWithOrderid:(NSNumber *)orderid{
    OrderPayTypeView *view = [[[NSBundle mainBundle] loadNibNamed:@"OrderPayTypeView" owner:self options:nil] lastObject];
    view.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
    view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.6f];
    if (_userinfos) {
        float money = [_userinfos.money floatValue] / 100;
        view.moneyLabel.text = [NSString stringWithFormat:@"余额：¥%.2f",money];
    }else{
        view.moneyLabel.text = @"";
    }
    __weak typeof(self)weakself = self;
    __weak typeof(view)weakView = view;
    view.weixin = ^{
        [weakView dismiss];
        [SVProgressHUD show];
        NSString *url = [NSString stringWithFormat:@"%@%@",BaseUrl,@"/wxpay/pay.html"];
        NSDictionary *param = @{};
        param = @{@"token":UserToken, @"id":orderid, @"type":@910,@"paytype":@"APP"};
        
        [[SYHttpRequest sharedInstance] getDataWithUrl:url Parameter:param ResponseObject:^(NSDictionary *responseResult) {
            [SVProgressHUD dismiss];
            NSLog(@"微信支付 -- %@",responseResult);
            
            if ([responseResult objectForKey:@"resError"]) {
                [weakself showHint:@"服务器不给力，请稍后重试"];
                
            }else{
                if (responseResult.count > 0) {
                    
                    if ([responseResult objectForKey:@"data"]) {
                        NSData *jsonData = [[responseResult objectForKey:@"data"] dataUsingEncoding:NSUTF8StringEncoding];
                        NSError *error;
                        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error];
                        if (error) {
                            NSLog(@"json解析失败：%@",error);
                        }else{
                            [self weixinWithResultDic:dic];
                        }
                        
                    }
                }
                
            }
        }];
        
    };
    view.zhifubao = ^{
        [weakView dismiss];
        NSString *url = @"";
        url = [NSString stringWithFormat:@"%@%@?type=%@&token=%@&id=%@&paytype=longguo",BaseUrl,@"/alpay/pay.html",@910,UserToken,orderid];
        UIWebView *webView = [[UIWebView alloc] init];
        webView.delegate = weakself;
        NSString *encodedString=[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:encodedString]];
        [SVProgressHUD show];
        [webView loadRequest:request];
        [weakself.view addSubview:webView];
    };
    view.yue = ^{
        [weakView dismiss];
        NSString *url = [NSString stringWithFormat:@"%@%@",BaseUrl,@"/yepay/pay.html"];
        NSDictionary *param = nil;
        param = @{@"token":UserToken, @"id":orderid, @"type":@910};
        [SVProgressHUD show];
        [[SYHttpRequest sharedInstance] getDataWithUrl:url Parameter:param ResponseObject:^(NSDictionary *responseResult) {
            NSLog(@"余额支付 -- %@",responseResult);
            [SVProgressHUD dismiss];
            if ([responseResult objectForKey:@"resError"]) {
                [weakself showHint:@"服务器不给力，请稍后重试"];
            }else{
                if ([[responseResult objectForKey:@"result"] integerValue] == 1) {
                    
                    
                }else{
                    if ([responseResult objectForKey:@"msg"]) {
                        [weakself showHint:[responseResult objectForKey:@"msg"]];
                    }
                }
            }
        }];
    };
    [view show];
    
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    // NOTE: ------  对alipays:相关的scheme处理 -------
    // NOTE: 若遇到支付宝相关scheme，则跳转到本地支付宝App
    NSString* reqUrl = request.URL.absoluteString;
    NSLog(@"reqUrl - %@",reqUrl);
    if ([reqUrl hasPrefix:@"alipays://"] || [reqUrl hasPrefix:@"alipay://"]) {
        // NOTE: 跳转支付宝App
        BOOL bSucc = [[UIApplication sharedApplication]openURL:request.URL];
        
        // NOTE: 如果跳转失败，则跳转itune下载支付宝App
        if (!bSucc) {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示"
                                                           message:@"未检测到支付宝客户端，请安装后重试。"
                                                          delegate:self
                                                 cancelButtonTitle:@"确定"
                                                 otherButtonTitles:nil];
            [alert show];
        }
        return NO;
    }
    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    [SVProgressHUD dismiss];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    [SVProgressHUD dismiss];
}

- (void)weixinWithResultDic:(NSDictionary *)dic{
    //微信支付
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(weixinPayResp:) name:@"weixinPayResp" object:nil];
    
    PayReq *request = [[PayReq alloc] init];
    
    request.openID = @"wx3fa3352427c88e20";
    
    request.partnerId = [dic objectForKey:@"partnerid"];
    
    request.prepayId = [dic objectForKey:@"prepayid"];
    
    request.package = [dic objectForKey:@"package"];
    
    request.nonceStr = [dic objectForKey:@"noncestr"];
    
    request.timeStamp = [[dic objectForKey:@"timestamp"] unsignedIntValue];
    
    DataMD5 *md5 = [[DataMD5 alloc] init];
    
    request.sign = [md5 createMD5SingForPay:request.openID partnerid:request.partnerId prepayid:request.prepayId package:request.package noncestr:request.nonceStr timestamp:request.timeStamp];
    
    [WXApi sendReq:request];
}

//微信支付回调
- (void)weixinPayResp:(NSNotification *)notification {
    NSLog(@"notification - %@",notification.userInfo);
    //0代表成功; －1代表错误; －2代表用户取消.
    
    
    if ([notification.object intValue] == 0) {
        
        [self showHint:@"支付成功"];
        [self.navigationController popViewControllerAnimated:YES];
        
    }
    
    if ([notification.object intValue] == -1) {
        
        [self showHint:@"支付失败"];
    }
    
    if ([notification.object intValue] == -2) {
        
        [self showHint:@"取消支付"];
    }
    
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return 1;
    }else{
        SYShopcartShangjiaModel *shangjia = self.dataSourceArr[section - 1];
        NSArray *goods = shangjia.goods;
        
        return goods.count;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        static NSString *identifier = @"addressCell";
        SYDefaultAddressTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (!cell) {
            cell = [[NSBundle mainBundle] loadNibNamed:@"SYDefaultAddressTableViewCell" owner:nil options:nil][0];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        if (self.addressModel == nil) {
            cell.addressView.hidden = YES;
            cell.noAddressLabel.hidden = NO;
        }else{
            cell.addressView.hidden = NO;
            cell.noAddressLabel.hidden = YES;
            cell.shouhuorenLabel.text = self.addressModel.name;
            cell.phoneLabel.text = self.addressModel.tel;
            cell.addressLabel.text = [NSString stringWithFormat:@"%@%@",self.addressModel.zone, self.addressModel.address];
        }
        return cell;
    }else{
        static NSString *identifier = @"payorderCell";
        SYShopcartPayOrderTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (!cell) {
            cell = [[NSBundle mainBundle] loadNibNamed:@"SYShopcartPayOrderTableViewCell" owner:nil options:nil][0];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        SYShopcartShangjiaModel *shangjia = self.dataSourceArr[indexPath.section - 1];
        NSArray *goods = shangjia.goods;
        SYShopcartShangpinModel *shangpin = goods[indexPath.row];
        if (goods.count > 0) {
            cell.model = goods[indexPath.row];
        }
        __weak typeof(self)weakself = self;
        cell.block = ^{
            SYSelectePhotoViewController *selectePhoto = [[SYSelectePhotoViewController alloc] init];
            NSInteger num = [shangpin.num integerValue] * [shangpin.upimg integerValue];
            selectePhoto.upimg = [NSNumber numberWithInteger:num];
            selectePhoto.c_img = shangpin.c_img;
            selectePhoto.gouwucheID = shangpin.shangpinid;
            [weakself.navigationController pushViewController:selectePhoto animated:YES];
        };
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        SYAddressViewController *address = [[SYAddressViewController alloc] init];
        address.delegate = self;
        [self.navigationController pushViewController:address animated:YES];
    }
}
#pragma mark - SelectedAddressDelegate
- (void)selectedAddressWithAddressModel:(SYAddressModel *)model{
    self.addressModel = model;
    [self.tableView reloadData];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.dataSourceArr.count + 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        return 75;
    }
    SYShopcartShangjiaModel *shangjia = self.dataSourceArr[indexPath.section - 1];
    NSArray *goods = shangjia.goods;
    SYShopcartShangpinModel *shangpin = goods[indexPath.row];
    if ([shangpin.upimg integerValue] > 0) {
        return 105 + 46;
    }else{
        return 105;
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return 0.00001f;
    }else{
        return 46;
    }
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return nil;
    }
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor whiteColor];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(30, 12, kScreenWidth - 60, 20)];
    label.textColor = HexRGB(0x434343);
    label.font = [UIFont systemFontOfSize:17];
    SYShopcartShangjiaModel *shangjia = self.dataSourceArr[section - 1];
    label.text = shangjia.name;
    [view addSubview:label];
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 45, kScreenWidth, 1)];
    lineView.backgroundColor = HexRGB(0xeaeaea);
    [view addSubview:lineView];
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (section == 0) {
        return 14;
    }else{
        return 60 + 50;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    if (section == 0) {
        UIView *view = [[UIView alloc] init];
        view.backgroundColor = RGB(248, 248, 248);
        return view;
    }else{
        NSDictionary *dic = [self jisuanmeigefenquxinxiWithSection:section - 1];
        float kuaidi = [[dic objectForKey:@"kuaidi"] floatValue];
        NSInteger num = [[dic objectForKey:@"num"] integerValue];
        float heji = [[dic objectForKey:@"heji"] floatValue];
        UIView *view = [[UIView alloc] init];
        view.backgroundColor = RGB(248, 248, 248);
        
        UIView *view2 = [[UIView alloc] initWithFrame:CGRectMake(0, 1, kScreenWidth, 49)];
        view2.backgroundColor = [UIColor whiteColor];
        [view addSubview:view2];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(14, 0, 70, 49)];
        label.text = @"买家留言:";
        label.font = [UIFont systemFontOfSize:14];
        label.textColor = HexRGB(0x3f3f3f);
        [view2 addSubview:label];
        
        [view2 addSubview:self.liuyanTF];
        
        UIView *view1 = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(view2.frame) + 1, kScreenWidth, 46)];
        view1.backgroundColor = [UIColor whiteColor];
        
        UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(14, 14, (kScreenWidth - 28) / 3, 15)];
        label1.text = [NSString stringWithFormat:@"共%ld件商品",num];
        label1.font = [UIFont systemFontOfSize:14];
        label1.textColor = HexRGB(0x434343);
        label1.textAlignment = NSTextAlignmentLeft;
        [view1 addSubview:label1];
        
        UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(label1.frame), 14, (kScreenWidth - 28) / 3, 17)];
        label2.text = [NSString stringWithFormat:@"合计:¥%.2f",heji];
        label2.font = [UIFont systemFontOfSize:14];
        label2.textColor = HexRGB(0xff8501);
        label2.textAlignment = NSTextAlignmentCenter;
        [view1 addSubview:label2];
        
        
        UILabel *label3 = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(label2.frame), 14, (kScreenWidth - 28) / 3, 17)];
        label3.text = [NSString stringWithFormat:@"快递:¥%.2f",kuaidi];
        label3.font = [UIFont systemFontOfSize:12];
        label3.textColor = HexRGB(0x939393);
        label3.textAlignment = NSTextAlignmentRight;
        [view1 addSubview:label3];

        [view addSubview:view1];
        
        return view;
    }
}

- (NSDictionary *)jisuanmeigefenquxinxiWithSection:(NSInteger)section{
    SYShopcartShangjiaModel *shangjia = self.dataSourceArr[section];
    
    //遍历所有的商品模型 如果选中就把费用相加
    float express = [shangjia.express floatValue] / 100;//运费
    float free = [shangjia.free floatValue] / 100;//满多少免运费
    float shangjiaYunfei = 0.00f;//商家运费
    float shangjiaFee = 0.00f;//一个上家的价格
    NSInteger shangjiaNum = 0;//数量
    for (SYShopcartShangpinModel *shangpin in shangjia.goods) {
        float shangpinFee = 0.00f;
        float shangpinYunfei = 0.00f;
        shangjiaNum += [shangpin.num integerValue];
        shangpinFee = ([shangpin.money floatValue] / 100) * [shangpin.num integerValue];
        if (shangpinFee >= free) {
            shangpinYunfei = 0.00f;
        }else{
            shangpinYunfei = express;
        }
        NSLog(@"shangjiaYunfei - %f",shangjiaYunfei);
        NSLog(@"shangpinFee - %f",shangpinFee);
        
        //该商家的运费 费用
        shangjiaFee += shangpinFee;
        shangjiaYunfei = shangpinYunfei;
        
        NSLog(@"shangjiaFee - %f",shangjiaFee);
        if (shangjiaFee >= free) {
            shangjiaYunfei = 0.00f;
        }
    }
    shangjiaFee += shangjiaYunfei;
    NSDictionary *dic = @{@"kuaidi":[NSNumber numberWithFloat:shangjiaYunfei] , @"num":[NSNumber numberWithInteger:shangjiaNum], @"heji":[NSNumber numberWithFloat:shangjiaFee]};
    return dic;
}

- (void)getData{
    NSString *url = [NSString stringWithFormat:@"%@%@",BaseUrl,@"/store/waitorder.html"];
    __weak typeof(self)weakself = self;
    [SVProgressHUD show];
    [[SYHttpRequest sharedInstance] getDataWithUrl:url Parameter:self.param ResponseObject:^(NSDictionary *responseResult) {
        [SVProgressHUD dismiss];
        NSLog(@"等待支付的购物车商品 -- %@",responseResult);
        if ([responseResult objectForKey:@"resError"]) {
            
        }else{
            if ([[responseResult objectForKey:@"result"] integerValue] == 1) {
                NSArray *data = [responseResult objectForKey:@"data"];
                if (data.count > 0) {
                    [weakself.dataSourceArr removeAllObjects];
                    for (NSDictionary *dic in data) {
                        SYShopcartShangjiaModel *shangjiaModel = [SYShopcartShangjiaModel cartShangJiaWithDictionary:dic];
                        [weakself.dataSourceArr addObject:shangjiaModel];
                    }
                }
                if (self.addressModel == nil) {
                    NSDictionary *address = [responseResult objectForKey:@"address"];
                    self.addressModel = [SYAddressModel addressWithDictionary:address];
                }
                [weakself.tableView reloadData];
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
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight - kNavigationBarHeightAndStatusBarHeight - 55) style:UITableViewStyleGrouped];
        _tableView.backgroundColor = RGB(248, 248, 248);
        _tableView.delegate = self;
        _tableView.dataSource = self;
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

- (UITextField *)liuyanTF{
    if (!_liuyanTF) {
        _liuyanTF = [[UITextField alloc] initWithFrame:CGRectMake(89, 10, kScreenWidth - 98, 30)];
        _liuyanTF.placeholder = @"对卖家有什么想说的写在这里吧";
        _liuyanTF.font = [UIFont systemFontOfSize:14];
    }
    return _liuyanTF;
}

@end
