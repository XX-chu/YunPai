//
//  SYOrderPaymentViewController.m
//  ShuoYing
//
//  Created by 硕影 on 2017/4/5.
//  Copyright © 2017年 硕影. All rights reserved.
//

#import "SYOrderPaymentViewController.h"
#import "SYAddressModel.h"
#import "SYDefaultAddressTableViewCell.h"
#import "SYOrderPaymentTableViewCell.h"
#import "OrderPayTypeView.h"
#import "SYUserInfos.h"
#import "SYOrderModel.h"
#import "SYProductModel.h"
#import "SYBisnessInfosViewController.h"
@interface SYOrderPaymentViewController ()<UITableViewDataSource, UITableViewDelegate, UIWebViewDelegate>
{
    SYUserInfos *_userinfos;
}

@property (nonatomic, strong) SYAddressModel *addressModel;

@property (nonatomic, strong) UITableView *tableView;

@end

@implementation SYOrderPaymentViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self getUserInfos];
    
    if ([[Tool sharedInstance] getObjectWithPath:Mobile]) {
        _userinfos = [[Tool sharedInstance] getObjectWithPath:Mobile];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"支付订单";
    [self getDefaultAddress];
    [self.view addSubview:self.tableView];
    [self loadBottomView];
}

- (void)loadBottomView{
    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, kScreenHeight - kNavigationBarHeightAndStatusBarHeight - 55, kScreenWidth, 55)];
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = bottomView.bounds;
    [btn setAdjustsImageWhenHighlighted:NO];
    float money = [self.orderModel.money floatValue] / 100;
    [btn setTitle:[NSString stringWithFormat:@"确认支付¥%.2f",money] forState:UIControlStateNormal];
    [btn setBackgroundImage:[UIImage imageWithColor:NavigationColor Size:btn.frame.size] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(selectePayType:) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:btn];
    [self.view addSubview:bottomView];
}

- (void)selectePayType:(UIButton *)btn{
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
        param = @{@"token":UserToken, @"id":self.orderModel.orderId, @"type":@910,@"paytype":@"APP"};
        
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
        url = [NSString stringWithFormat:@"%@%@?type=%@&token=%@&id=%@&paytype=longguo",BaseUrl,@"/alpay/pay.html",@910,UserToken,self.orderModel.orderId];
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
        param = @{@"token":UserToken, @"id":self.orderModel.orderId, @"type":@910};
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



- (void)getDefaultAddress{
   SYAddressModel *model = [[Tool sharedInstance] getObjectWithPath:[NSString stringWithFormat:@"%@defaultAddress",Mobile]];
    if (model) {
        self.addressModel = model;
    }else{
        self.addressModel = nil;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (self.isFromXX) {
        return 1;
    }
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (self.isFromXX) {
        NSArray *productArr = self.orderModel.product;
        return productArr.count;
    }else{
        if (section == 0) {
            return 1;
        }else{
            NSArray *productArr = self.orderModel.product;
            return productArr.count;
        }
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.isFromXX) {
        static NSString *identifier = @"shangpinCell";
        SYOrderPaymentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (!cell) {
            cell = [[NSBundle mainBundle] loadNibNamed:@"SYOrderPaymentTableViewCell" owner:nil options:nil][0];
            cell.backgroundColor = [UIColor whiteColor];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        NSArray *product = self.orderModel.product;
        if (product.count > 0) {
            SYProductModel *productModel = product[indexPath.row];
            [cell.headImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",ImgUrl,productModel.img_200]] placeholderImage:[UIImage imageNamed:@"shangchuan_wode_wutupian"]];
            cell.contentLabel.text = productModel.name;
            cell.shangpinShuxingLabel.text = [NSString stringWithFormat:@"商品属性：%@",productModel.attr];
            float price = [productModel.money floatValue] / 100;
            cell.priceLabel.text = [NSString stringWithFormat:@"¥%.2f",price];
            cell.countLabel.text = [NSString stringWithFormat:@"x%@",[productModel.num stringValue]];
        }
        
        return cell;
    }else{
        if (indexPath.section == 0) {
            static NSString *identifier = @"addressCell";
            SYDefaultAddressTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
            if (!cell) {
                cell = [[NSBundle mainBundle] loadNibNamed:@"SYDefaultAddressTableViewCell" owner:nil options:nil][0];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.arrowImageView.hidden = YES;
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
            static NSString *identifier = @"shangpinCell";
            SYOrderPaymentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
            if (!cell) {
                cell = [[NSBundle mainBundle] loadNibNamed:@"SYOrderPaymentTableViewCell" owner:nil options:nil][0];
                cell.backgroundColor = [UIColor whiteColor];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            NSArray *product = self.orderModel.product;
            if (product.count > 0) {
                SYProductModel *productModel = product[indexPath.row];
                [cell.headImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",ImgUrl,productModel.img_200]] placeholderImage:[UIImage imageNamed:@"shangchuan_wode_wutupian"]];
                cell.contentLabel.text = productModel.name;
                cell.shangpinShuxingLabel.text = [NSString stringWithFormat:@"商品属性：%@",productModel.attr];
                float price = [productModel.money floatValue] / 100;
                cell.priceLabel.text = [NSString stringWithFormat:@"¥%.2f",price];
                cell.countLabel.text = [NSString stringWithFormat:@"x%@",[productModel.num stringValue]];
            }
            
            return cell;
        }

    }
}

//获取用户信息
- (void)getUserInfos{
    
    NSString *url = [NSString stringWithFormat:@"%@%@",BaseUrl,@"/user/user.html"];
    NSDictionary *param = @{@"token":UserToken};
    [[SYHttpRequest sharedInstance] getDataWithUrl:url Parameter:param ResponseObject:^(NSDictionary *responseResult) {
       
        NSLog(@"获取用户信息 -- %@",responseResult);
        if ([responseResult objectForKey:@"resError"]) {
            
        }else{
            if ([[responseResult objectForKey:@"result"] integerValue] == 1) {
                NSDictionary *data = [responseResult objectForKey:@"data"];
                SYUserInfos *userinfos = [SYUserInfos userinfosWithDictionry:data];
                //归档
                [[Tool sharedInstance] saveObject:userinfos WithPath:[NSString stringWithFormat:@"%@",Mobile]];
                
                
            }else{
                
            }
        }
    }];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section != 0) {
        NSArray *product = self.orderModel.product;
        SYProductModel *productModel = product[indexPath.row];
        SYBisnessInfosViewController *infos = [[SYBisnessInfosViewController alloc] initWithIsFromXSorXXType:isFromXS shangpinID:productModel.productId shangjiaID:self.orderModel.pid];
        [self.navigationController pushViewController:infos animated:YES];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.isFromXX) {
        return 127;
    }else{
        if (indexPath.section == 0) {
            return 70;
        }
        return 127;
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (self.isFromXX) {
        return 44 + 14;
    }else{
        if (section == 0) {
            return 0.00001f;
        }
        return 44 + 14;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (self.isFromXX) {
        return 45;
    }else{
        if (section == 0) {
            return 0.00001f;
        }
        return 45;
    }
    
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (self.isFromXX) {
        UIView *view = [[UIView alloc] init];
        view.backgroundColor = BackGroundColor;
        
        UIView *view1 = [[UIView alloc] initWithFrame:CGRectMake(0, 14, kScreenWidth, 44)];
        view1.backgroundColor = [UIColor whiteColor];
        [view addSubview:view1];
        
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, 12, kScreenWidth - 100 - 40, 20)];
        label.text = self.orderModel.name;
        label.textColor = HexRGB(0x434343);
        label.font = [UIFont systemFontOfSize:17];
        [view1 addSubview:label];
        
        UIView *lineview = [[UIView alloc] initWithFrame:CGRectMake(0, 44, kScreenWidth, 1)];
        lineview.backgroundColor = RGB(238, 238, 238);
        [view1 addSubview:lineview];
        
        return view;
    }else{
        if (section == 0) {
            return nil;
        }
        UIView *view = [[UIView alloc] init];
        view.backgroundColor = BackGroundColor;
        
        UIView *view1 = [[UIView alloc] initWithFrame:CGRectMake(0, 14, kScreenWidth, 44)];
        view1.backgroundColor = [UIColor whiteColor];
        [view addSubview:view1];
        
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, 12, kScreenWidth - 100 - 40, 20)];
        label.text = self.orderModel.name;
        label.textColor = HexRGB(0x434343);
        label.font = [UIFont systemFontOfSize:17];
        [view1 addSubview:label];
        
        UIView *lineview = [[UIView alloc] initWithFrame:CGRectMake(0, 44, kScreenWidth, 1)];
        lineview.backgroundColor = RGB(238, 238, 238);
        [view1 addSubview:lineview];
        
        return view;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    if (self.isFromXX) {
        UIView *view = [[UIView alloc] init];
        view.backgroundColor = [UIColor whiteColor];
        
        UILabel *shangpinLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 12, 80, 20)];
        shangpinLabel.text = [NSString stringWithFormat:@"共%@件商品",[self.orderModel.count stringValue]];
        shangpinLabel.font = [UIFont systemFontOfSize:14];
        shangpinLabel.textAlignment = NSTextAlignmentLeft;
        shangpinLabel.textColor = HexRGB(0x434343);
        [view addSubview:shangpinLabel];
        
        
        UILabel *moneyLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(shangpinLabel.frame), 12, (kScreenWidth - 30) / 3 * 2, 20)];
        moneyLabel.textAlignment = NSTextAlignmentRight;
        float money = [self.orderModel.money floatValue] / 100;
        NSString *moneyStr = [NSString stringWithFormat:@"合计：¥%.2f",money];
        float fee = [self.orderModel.fee floatValue] / 100;
        NSString *feeStr = [NSString stringWithFormat:@"(含快递：¥%.2f)",fee];
        NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@%@",moneyStr,feeStr]];
        [attStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:16] range:NSMakeRange(0, moneyStr.length)];
        [attStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:12] range:NSMakeRange(moneyStr.length, feeStr.length)];
        [attStr addAttribute:NSForegroundColorAttributeName value:HexRGB(0xff8401) range:NSMakeRange(0, moneyStr.length)];
        [attStr addAttribute:NSForegroundColorAttributeName value:HexRGB(0x939393) range:NSMakeRange(moneyStr.length, feeStr.length)];
        moneyLabel.attributedText = attStr;
        [view addSubview:moneyLabel];
        
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 44, kScreenWidth, 1)];
        lineView.backgroundColor = BackGroundColor;
        [view addSubview:lineView];
        
        
        return view;

    }else{
        if (section == 0) {
            return nil;
        }
        
        UIView *view = [[UIView alloc] init];
        view.backgroundColor = [UIColor whiteColor];
        
        UILabel *shangpinLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 12, 80, 20)];
        shangpinLabel.text = [NSString stringWithFormat:@"共%@件商品",[self.orderModel.count stringValue]];
        shangpinLabel.font = [UIFont systemFontOfSize:14];
        shangpinLabel.textAlignment = NSTextAlignmentLeft;
        shangpinLabel.textColor = HexRGB(0x434343);
        [view addSubview:shangpinLabel];
        
        
        UILabel *moneyLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(shangpinLabel.frame), 12, (kScreenWidth - 30) / 3 * 2, 20)];
        moneyLabel.textAlignment = NSTextAlignmentRight;
        float money = [self.orderModel.money floatValue] / 100;
        NSString *moneyStr = [NSString stringWithFormat:@"合计：¥%.2f",money];
        float fee = [self.orderModel.fee floatValue] / 100;
        NSString *feeStr = [NSString stringWithFormat:@"(含快递：¥%.2f)",fee];
        NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@%@",moneyStr,feeStr]];
        [attStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:16] range:NSMakeRange(0, moneyStr.length)];
        [attStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:12] range:NSMakeRange(moneyStr.length, feeStr.length)];
        [attStr addAttribute:NSForegroundColorAttributeName value:HexRGB(0xff8401) range:NSMakeRange(0, moneyStr.length)];
        [attStr addAttribute:NSForegroundColorAttributeName value:HexRGB(0x939393) range:NSMakeRange(moneyStr.length, feeStr.length)];
        moneyLabel.attributedText = attStr;
        [view addSubview:moneyLabel];
        
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 44, kScreenWidth, 1)];
        lineView.backgroundColor = BackGroundColor;
        [view addSubview:lineView];
        
        return view;
    }
}

- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight - kNavigationBarHeightAndStatusBarHeight - 55) style:UITableViewStyleGrouped];
        _tableView.backgroundColor = BackGroundColor;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSelectionStyleNone;
        
    }
    return _tableView;
}

@end
