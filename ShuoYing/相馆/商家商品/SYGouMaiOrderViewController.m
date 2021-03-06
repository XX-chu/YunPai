//
//  SYGouMaiOrderViewController.m
//  ShuoYing
//
//  Created by 硕影 on 2017/5/6.
//  Copyright © 2017年 硕影. All rights reserved.
//

#import "SYGouMaiOrderViewController.h"
#import "SYDefaultAddressTableViewCell.h"
#import "SYAddressModel.h"
#import "SYAddressViewController.h"
#import "SYLijiBuyTableViewCell.h"
#import "NoDataView.h"
#import "SYSelectePhotoViewController.h"

#import "SYOneModel.h"
#import "SYTwoModel.h"
#import "SYThreeModel.h"

#import "OrderPayTypeView.h"
#import "SYUserInfos.h"
#import "SYOrderInfosViewController.h"

#import "SYShopcartShangjiaModel.h"
#import "SYShopcartShangpinModel.h"
@interface SYGouMaiOrderViewController ()<UITableViewDelegate, UITableViewDataSource, SelectedAddressDelegate, UIWebViewDelegate>
{
    NSString *_imgUrl;
    NSString *_shangpinName;
    NSString *_shangpinShuxing;
    NSString *_danjia;
    NSString *_heji;
    NSString *_kuaidi;
    
    NSNumber *_upimg;
    NSNumber *_c_img;
    SYUserInfos *_userinfos;
    
    SYShopcartShangjiaModel *_shangjiaModel;
    
    UIButton *_bottomBtn;
}

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) SYAddressModel *addressModel;

@property (nonatomic, strong) UITextField *liuyanTF;

@end

@implementation SYGouMaiOrderViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self getData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"提交订单";
    _userinfos = [[Tool sharedInstance] getObjectWithPath:Mobile];
    _upimg = @0;
    _c_img = @0;
    //对传过来的数据进行处理
    [self getDefaultAddress];

    [self.view addSubview:self.tableView];
    [self initBottomView];
    
}

- (void)initDataSource{
    NSLog(@"self.dataSourceDic - %@", self.dataSourceDic);
    NSArray *data = [self.dataSourceDic objectForKey:@"data"];
    if (data.count > 0) {
        NSDictionary *dic = data[0];
        NSArray *goods = [dic objectForKey:@"goods"];
        if (goods.count > 0) {
            NSDictionary *goodDic = goods[0];
            
            _imgUrl = [NSString stringWithFormat:@"%@%@",ImgUrl, [goodDic objectForKey:@"img_200"]];
            _shangpinName = [goodDic objectForKey:@"title"];
            _danjia = [NSString stringWithFormat:@"%.2f",[(NSNumber *)[goodDic objectForKey:@"money"] floatValue] / 100];
            
            _shangpinShuxing = [goodDic objectForKey:@"spce"];
            
            float free = [(NSNumber *)[dic objectForKey:@"free"] floatValue] / 100;
            float express = [(NSNumber *)[dic objectForKey:@"express"] floatValue] / 100;
            if ([_danjia floatValue] * self.selecteCount >= free) {
                _heji = [NSString stringWithFormat:@"%.2f",[_danjia floatValue] * self.selecteCount];
                _kuaidi = @"0.00";
            }else{
                _heji = [NSString stringWithFormat:@"%.2f",[_danjia floatValue] * self.selecteCount + express];
                _kuaidi = [NSString stringWithFormat:@"%.2f",express];
            }
        }
        
    }
    
    [_bottomBtn setTitle:[NSString stringWithFormat:@"提交订单%@",_heji] forState:UIControlStateNormal];
    
    [self.tableView reloadData];
}

- (void)getDefaultAddress{
    SYAddressModel *model = [[Tool sharedInstance] getObjectWithPath:[NSString stringWithFormat:@"%@defaultAddress",Mobile]];
    if (model) {
        self.addressModel = model;
    }else{
        self.addressModel = nil;
    }
}

- (void)initBottomView{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, kScreenHeight - kNavigationBarHeightAndStatusBarHeight - 55, kScreenWidth, 55)];
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setAdjustsImageWhenHighlighted:NO];
    btn.frame = CGRectMake(0, 0, kScreenWidth, 55);
    [btn setBackgroundImage:[UIImage imageWithColor:NavigationColor Size:btn.frame.size] forState:UIControlStateNormal];
    [btn setTitle:[NSString stringWithFormat:@"提交订单%@",_heji] forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [view addSubview:btn];
    [btn addTarget:self action:@selector(creatOrderAction:) forControlEvents:UIControlEventTouchUpInside];
    _bottomBtn = btn;
    [self.view addSubview:view];
}
//确认支付按钮
- (void)creatOrderAction:(UIButton *)sender{
    //先生成订单
    if (self.addressModel == nil) {
        [self showHint:@"请选择您的收货地址"];
        return;
    }
    
    SYShopcartShangpinModel *shangpin = nil;
    if (_shangjiaModel.goods > 0) {
        shangpin = [_shangjiaModel.goods firstObject];
    }
    
    if ([shangpin.upimg integerValue] * [shangpin.num integerValue] == [shangpin.c_img integerValue] || [shangpin.upimg integerValue] == [shangpin.c_img integerValue]) {
        if ([self.addressModel.zone rangeOfString:@"北京"].location !=NSNotFound) {
            NSString *message = @"亲爱的用户，因快递公司原因送至北京地区的商品可能会延期到达，给您带来的不便敬请谅解";
            __weak typeof(self)weakself = self;
            LQPopUpView *popUpView = [[LQPopUpView alloc] initWithTitle:@"温馨提示" message:message];
            popUpView.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight - kNavigationBarHeightAndStatusBarHeight);
            popUpView.btnStyleDefaultTextColor = NavigationColor;
            [popUpView addBtnWithTitle:@"取消订单" type:LQPopUpBtnStyleDefault handler:^{
                // do something...
                [weakself.navigationController popViewControllerAnimated:YES];
            }];
            [popUpView addBtnWithTitle:@"继续购买" type:LQPopUpBtnStyleDefault handler:^{
                // do something...
                [self creatOrder];
                
            }];
            
            [popUpView showInView:self.view preferredStyle:0];
        }else{
            [self creatOrder];

        }

    }else {
        
        NSInteger num = [shangpin.num integerValue];
        NSInteger maxCount = [shangpin.num integerValue] * [shangpin.upimg integerValue];
        NSInteger minCount = [shangpin.upimg integerValue];
        NSString *message = [NSString stringWithFormat:@"您在“%@”相馆里的“%@”商品已选%ld张照片，您可以选择%ld张定制%ld个相同的产品，还可以选择%ld张制作%ld个不同的产品，请根据您的需求上传照片数量",_shangjiaModel.name, shangpin.title, (long)[_c_img integerValue], (long)minCount, (long)num, (long)maxCount, (long)num];
        
        LQPopUpView *popUpView = [[LQPopUpView alloc] initWithTitle:@"提示" message:message];
        popUpView.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight - kNavigationBarHeightAndStatusBarHeight);
        popUpView.btnStyleDefaultTextColor = NavigationColor;
        [popUpView addBtnWithTitle:@"好的" type:LQPopUpBtnStyleDefault handler:^{
            // do something...
            
        }];
        
        [popUpView showInView:self.view preferredStyle:0];
    }
}

- (void)creatOrder{
    __weak typeof(self)weakself = self;
    if (_danjia) {
        float price = [_danjia floatValue] * self.selecteCount;

        if (price < 10.0) {
            NSString *message = @"亲！新会员前三个订单免运费。加入购物车一起支付，每单超过10元还免运费哦！";
            LQPopUpView *popUpView = [[LQPopUpView alloc] initWithTitle:@"温馨提示" message:message];
            popUpView.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight - kNavigationBarHeightAndStatusBarHeight);
            popUpView.btnStyleDefaultTextColor = NavigationColor;
            [popUpView addBtnWithTitle:@"加入购物车" type:LQPopUpBtnStyleDefault handler:^{
                // do something...
                [weakself showHint:@"加入购物车成功"];
            }];
            [popUpView addBtnWithTitle:@"现在支付" type:LQPopUpBtnStyleDefault handler:^{
                // do something...
                //生成订单
                [SVProgressHUD show];
                NSString *url = [NSString stringWithFormat:@"%@%@",BaseUrl,@"/store/createorder.html"];
                
                NSDictionary *param = @{@"token":UserToken, @"id":self.gouwucheID, @"addressid":self.addressModel.addressId, @"msg":self.liuyanTF.text};
                [[SYHttpRequest sharedInstance] getDataWithUrl:url Parameter:param ResponseObject:^(NSDictionary *responseResult) {
                    [SVProgressHUD dismiss];
                    NSLog(@"生成订单 -- %@",responseResult);
                    if ([responseResult objectForKey:@"resError"]) {
                        
                    }else{
                        if ([[responseResult objectForKey:@"result"] integerValue] == 1) {
                            
                            SYOrderInfosViewController *orderInfos = [[SYOrderInfosViewController alloc] init];
                            orderInfos.param = @{@"id":[responseResult objectForKey:@"order"], @"token":UserToken, @"state":@1};
                            orderInfos.type = OrderTypeWeiFuKuan;
                            [weakself.navigationController pushViewController:orderInfos animated:YES];
                        }else{
                            if ([responseResult objectForKey:@"msg"]) {
                                [weakself showHint:[responseResult objectForKey:@"msg"]];
                            }
                        }
                    }
                }];
            }];
            
            [popUpView showInView:self.view preferredStyle:0];
        }else{
            //生成订单
            [SVProgressHUD show];
            NSString *url = [NSString stringWithFormat:@"%@%@",BaseUrl,@"/store/createorder.html"];
            
            NSDictionary *param = @{@"token":UserToken, @"id":self.gouwucheID, @"addressid":self.addressModel.addressId, @"msg":self.liuyanTF.text};
            [[SYHttpRequest sharedInstance] getDataWithUrl:url Parameter:param ResponseObject:^(NSDictionary *responseResult) {
                [SVProgressHUD dismiss];
                NSLog(@"生成订单 -- %@",responseResult);
                if ([responseResult objectForKey:@"resError"]) {
                    
                }else{
                    if ([[responseResult objectForKey:@"result"] integerValue] == 1) {
                        
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
    }
    
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


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    if (indexPath.section == 0) {
        //线上
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
        static NSString *identifier = @"cell";
        SYLijiBuyTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (!cell) {
            cell = [[NSBundle mainBundle] loadNibNamed:@"SYLijiBuyTableViewCell" owner:nil options:nil][0];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        if ([_upimg integerValue] == 0) {
            cell.selectePhotoView.hidden = YES;
        }else{
            cell.selectePhotoView.hidden = NO;
        }
        [cell.headImageView sd_setImageWithURL:[NSURL URLWithString:_imgUrl] placeholderImage:NoPicture];
        cell.shangpinName.text = _shangpinName;
        
        cell.priceLabel.text = _danjia;

        cell.numLabel.text = [NSString stringWithFormat:@"x%ld",self.selecteCount];
        
        cell.shangpinShuxingLabel.text = _shangpinShuxing;
        

        //选择照片按钮的事件方法
        [cell.selectePhotoBtn addTarget:self action:@selector(selectePhotoAction:) forControlEvents:UIControlEventTouchUpInside];
        
        SYShopcartShangpinModel *shangpin = nil;
        if (_shangjiaModel.goods.count > 0) {
            shangpin = [[_shangjiaModel goods] firstObject];
            if ([shangpin.upimg integerValue] * [shangpin.num integerValue] == [shangpin.c_img integerValue] || [shangpin.upimg integerValue] == [shangpin.c_img integerValue]) {
                cell.haveSelectePhotoCountLabel.text = @"已选好";
                cell.haveSelectePhotoCountLabel.textColor = [UIColor lightGrayColor];
            }else{
                NSInteger maxCount = [shangpin.upimg integerValue] * [shangpin.num integerValue];
                NSInteger minCount = [shangpin.upimg integerValue];
                cell.haveSelectePhotoCountLabel.text = [NSString stringWithFormat:@"您可以选择%ld张或%ld张照片,您已选择%ld张照片",(long)minCount, (long)maxCount, [shangpin.c_img integerValue]];
                cell.haveSelectePhotoCountLabel.textColor = NavigationColor;
            }
        }
        
        
        return cell;
    }
    
}
//选择照片
- (void)selectePhotoAction:(UIButton *)sender{
    SYSelectePhotoViewController *selecte = [[    SYSelectePhotoViewController alloc] init];
    selecte.upimg = _upimg;
    selecte.c_img = _c_img;
    selecte.gouwucheID = self.gouwucheID;
    [self.navigationController pushViewController:selecte animated:YES];
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
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{

    if (self.dataSourceDic.count > 0) {
        //线上
        if (indexPath.section == 0) {
            return 75;
        }
        if ([_upimg integerValue] == 0) {
            return 105;
        }
        return 151;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{

    if (self.dataSourceDic.count > 0) {
        //线上
        if (section == 0) {
            return 0.00001f;
        }else{
            return 57;
        }
    }
    return 0.00001f;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (self.dataSourceDic.count > 0) {
        
        if (section == 0) {
            return nil;
        }
        UIView *view = [[UIView alloc] init];
        view.backgroundColor = HexRGB(0xf3f3f3);
        
        UIView *view1 = [[UIView alloc] initWithFrame:CGRectMake(0, 14, kScreenWidth, 43)];
        view1.backgroundColor = [UIColor whiteColor];
        [view addSubview:view1];
        
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 42, kScreenWidth, 1)];
        lineView.backgroundColor = RGB(238, 238, 238);
        [view1 addSubview:lineView];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(14, 13, kScreenWidth - 30, 17)];
        NSArray *data = [self.dataSourceDic objectForKey:@"data"];
        if (data.count > 0) {
            NSDictionary *dic = [data firstObject];
            label.text = [dic objectForKey:@"name"];
        }
        label.textColor = RGB(43, 43, 43);
        label.font = [UIFont systemFontOfSize:17];
        [view1 addSubview:label];
        
        return view;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (section == 1) {
        return 130;
    }
    return 0.00001f;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor whiteColor];
    if (section == 1) {
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 1)];
        lineView.backgroundColor = HexRGB(0xeaeaea);
        [view addSubview:lineView];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(14, 1, 70, 49)];
        label.text = @"买家留言:";
        label.font = [UIFont systemFontOfSize:14];
        label.textColor = HexRGB(0x3f3f3f);
        [view addSubview:label];
        [view addSubview:self.liuyanTF];
        
        UIView *lineView1 = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(label.frame), kScreenWidth, 1)];
        lineView1.backgroundColor = HexRGB(0xeaeaea);
        [view addSubview:lineView1];
        //设置商品总价 运费 合计
        
        NSArray *data = [self.dataSourceDic objectForKey:@"data"];
        NSDictionary *dic = nil;
        if (data.count > 0) {
            dic = data[0];
        }
        
        UIView *downView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(lineView1.frame), kScreenWidth, 80)];
        
        UILabel *allPrice = [[UILabel alloc] initWithFrame:CGRectMake(14, 9.5, 55, 13)];
        allPrice.text = @"商品总价";
        allPrice.textColor = HexRGB(0x999999);
        allPrice.textAlignment = NSTextAlignmentLeft;
        allPrice.font = [UIFont systemFontOfSize:12];
        [downView addSubview:allPrice];
        
        UILabel *allPriceRight = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(allPrice.frame), 9.5, kScreenWidth - 28 - allPrice.frame.size.width, 13)];
        if (_danjia) {
            allPriceRight.text = [NSString stringWithFormat:@"¥%.2f",[_danjia floatValue] * self.selecteCount];
        }else{
            allPriceRight.text = @"";
        }
        allPriceRight.textColor = HexRGB(0x999999);
        allPriceRight.textAlignment = NSTextAlignmentRight;
        allPriceRight.font = [UIFont systemFontOfSize:12];
        [downView addSubview:allPriceRight];
        
        UILabel *yunfei = [[UILabel alloc] initWithFrame:CGRectMake(14, 9.5 + CGRectGetMaxY(allPrice.frame), 55, 13)];
        yunfei.text = @"运费";
        yunfei.textColor = HexRGB(0x999999);
        yunfei.textAlignment = NSTextAlignmentLeft;
        yunfei.font = [UIFont systemFontOfSize:12];
        [downView addSubview:yunfei];
        
        UILabel *yunfeiRight = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(yunfei.frame), 9.5 + CGRectGetMaxY(allPriceRight.frame), kScreenWidth - 28 - allPrice.frame.size.width, 13)];
        if (_danjia) {
            float free = [(NSNumber *)[dic objectForKey:@"free"] floatValue] / 100;
            float express = [(NSNumber *)[dic objectForKey:@"express"] floatValue] / 100;
            if ([_danjia floatValue] * self.selecteCount >= free) {
                yunfeiRight.text = @"¥0.00";
            }else{
                yunfeiRight.text = [NSString stringWithFormat:@"¥%.2f",express];
            }
        }else{
            yunfeiRight.text = @"";
        }
        
        
        yunfeiRight.textColor = HexRGB(0x999999);
        yunfeiRight.textAlignment = NSTextAlignmentRight;
        yunfeiRight.font = [UIFont systemFontOfSize:12];
        [downView addSubview:yunfeiRight];
        
        UILabel *heji = [[UILabel alloc] initWithFrame:CGRectMake(14, 9.5 + CGRectGetMaxY(yunfei.frame), 55, 16)];
        heji.text = @"合计";
        heji.textColor = HexRGB(0xff6b00);
        heji.textAlignment = NSTextAlignmentLeft;
        heji.font = [UIFont systemFontOfSize:15];
        [downView addSubview:heji];
        
        
        UILabel *hejiRight = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(heji.frame), 9.5 + CGRectGetMaxY(yunfeiRight.frame), kScreenWidth - 28 - heji.frame.size.width, 13)];
        if (_heji && _kuaidi) {
            float free = [(NSNumber *)[dic objectForKey:@"free"] floatValue] / 100;
            float express = [(NSNumber *)[dic objectForKey:@"express"] floatValue] / 100;
            if ([_danjia floatValue] * self.selecteCount >= free) {
                hejiRight.text = [NSString stringWithFormat:@"¥%.2f",[_danjia floatValue] * self.selecteCount];
            }else{
                hejiRight.text = [NSString stringWithFormat:@"¥%.2f",[_danjia floatValue] * self.selecteCount + express];
            }
        }else{
            hejiRight.text = @"";
        }
        hejiRight.textColor = HexRGB(0xff6b00);
        hejiRight.textAlignment = NSTextAlignmentRight;
        hejiRight.font = [UIFont systemFontOfSize:15];
        [downView addSubview:hejiRight];
        
        [view addSubview:downView];
    }
    return view;
}

- (void)getData{
    NSString *url = [NSString stringWithFormat:@"%@%@",BaseUrl,@"/store/waitorder.html"];
    NSDictionary *param = @{@"id":self.gouwucheID, @"token":UserToken};
    [[SYHttpRequest sharedInstance] getDataWithUrl:url Parameter:param ResponseObject:^(NSDictionary *responseResult) {
        
        NSLog(@"等待支付的购物车商品 -- %@",responseResult);
        if ([responseResult objectForKey:@"resError"]) {
            
        }else{
            if ([[responseResult objectForKey:@"result"] integerValue] == 1) {
                self.dataSourceDic = responseResult;
                [self initDataSource];
                NSArray *data = [responseResult objectForKey:@"data"];
                if (data.count > 0) {
                    NSDictionary *dic = [data firstObject];
                    SYShopcartShangjiaModel *shangjia = [SYShopcartShangjiaModel cartShangJiaWithDictionary:dic];
                    _shangjiaModel = shangjia;
                    
                    NSArray *goods = [dic objectForKey:@"goods"];
                    if (goods.count > 0) {
                        NSDictionary *dic = goods[0];
                        NSInteger num = [(NSNumber *)[dic objectForKey:@"upimg"] integerValue] * [(NSNumber *)[dic objectForKey:@"num"] integerValue];
                        _upimg = [NSNumber numberWithInteger:num];
                        _c_img = [dic objectForKey:@"c_img"];
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

- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight - kNavigationBarHeightAndStatusBarHeight - 55) style:UITableViewStyleGrouped];
        _tableView.backgroundColor = HexRGB(0xf3f3f3);
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return _tableView;
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
