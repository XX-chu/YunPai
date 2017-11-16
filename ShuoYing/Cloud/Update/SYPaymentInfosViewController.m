//
//  SYPaymentInfosViewController.m
//  ShuoYing
//
//  Created by 硕影 on 2017/1/16.
//  Copyright © 2017年 硕影. All rights reserved.
//

#import "SYPaymentInfosViewController.h"

#import "SYPayTypeView.h"
#import "CircleProgressView.h"

#import "LXNetworking.h"
#import "ZLPhotoTool.h"
#import "SYUserInfos.h"
#import <AlipaySDK/AlipaySDK.h>

@interface SYPaymentInfosViewController ()<UIWebViewDelegate>
{
    
    NSInteger _selectedTag;
    IsFrom _isFrom;
    
}

@property (weak, nonatomic) IBOutlet UILabel *payTypeLabel;
@property (weak, nonatomic) IBOutlet UIButton *selectePayTypeBtn;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UIButton *commitBtn;
@property (nonatomic, strong) CircleProgressView *progressView;

@end

@implementation SYPaymentInfosViewController

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
                if ([responseResult objectForKey:@"msg"]) {
                    [self showHint:[responseResult objectForKey:@"msg"]];
                }
            }
        }
    }];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self getUserInfos];
}

- (instancetype)initWithType:(IsFrom)isFrom{
    if (self = [super init]) {
        _isFrom = isFrom;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _selectedTag = 99;
    self.title = @"付款详情";
    [self.commitBtn setTitle:@"确认支付" forState:UIControlStateNormal];
    [self.commitBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.commitBtn setBackgroundImage:[UIImage imageWithColor:NavigationColor Size:self.commitBtn.frame.size] forState:UIControlStateNormal];
    self.commitBtn.layer.masksToBounds = YES;
    self.commitBtn.layer.cornerRadius = 5;
    [self.commitBtn setAdjustsImageWhenHighlighted:NO];
    
    self.payTypeLabel.text = @"";
    if (_isFrom == isFromYuYueGrapher) {
        self.priceLabel.text = [NSString stringWithFormat:@"%.2f元",[[self.dataSourceDic objectForKey:@"fee"] floatValue] / 100];

    }else{
        self.priceLabel.text = [NSString stringWithFormat:@"%.2f元",[[self.dataSourceDic objectForKey:@"money"] floatValue] / 100];

    }
}

- (IBAction)selectePayTypeAction:(UIButton *)sender {
    SYPayTypeView * view = [SYPayTypeView sharedInstance];
    
    [view showInView];
    __weak typeof(self)weakself = self;
    view.block = ^(NSInteger tag){
        _selectedTag = tag;
        switch (tag) {
            case 0:
            {
                weakself.payTypeLabel.text = @"微信";
            }
                break;
            case 1:
            {
                weakself.payTypeLabel.text = @"支付宝";

            }
                break;
            case 2:
            {
                weakself.payTypeLabel.text = @"钱包";

            }
                break;
                
            default:
                break;
        }
    };
}


- (IBAction)commitAction:(UIButton *)sender {
    self.commitBtn.enabled = NO;
    if (_selectedTag == 99) {
        [self showHint:@"请选择支付方式"];
        return;
    }
    if (_selectedTag == 2) {
        [self qianbaoAlipy];
    }else if (_selectedTag == 1){
        //支付宝
        [self alipay];
    }else{
        //微信
        [self payByWechat];
    }
    
}

//支付宝支付
- (void)alipay{

    NSString *url = @"";
    
    if (_isFrom == isFromTeacher) {
        url = [NSString stringWithFormat:@"%@%@?type=%@&token=%@&id=%@&paytype=longguo",BaseUrl,@"/alpay/pay.html",@2,UserToken,[self.dataSourceDic objectForKey:@"id"]];

    }else if (_isFrom == isFromGrapher){
        url = [NSString stringWithFormat:@"%@%@?type=%@&token=%@&id=%@&paytype=longguo",BaseUrl,@"/alpay/pay.html",@1,UserToken,[self.dataSourceDic objectForKey:@"id"]];
    }else if (_isFrom == isFromYuYueGrapher){
        url = [NSString stringWithFormat:@"%@%@?type=%@&token=%@&id=%@&paytype=longguo",BaseUrl,@"/alpay/pay.html",@5,UserToken,[self.dataSourceDic objectForKey:@"id"]];
    }else if (_isFrom == isFromGroup){
        url = [NSString stringWithFormat:@"%@%@?type=%@&token=%@&id=%@&paytype=longguo",BaseUrl,@"/alpay/pay.html",@7,UserToken,[self.dataSourceDic objectForKey:@"id"]];
    }else if (_isFrom == isFromShouYeXiaZai){
        url = [NSString stringWithFormat:@"%@%@?type=%@&token=%@&id=%@&paytype=longguo",BaseUrl,@"/alpay/pay.html",@8,UserToken,[self.dataSourceDic objectForKey:@"id"]];
    }else if (_isFrom == isFromXSorXX){
        url = [NSString stringWithFormat:@"%@%@?type=%@&token=%@&id=%@&paytype=longguo",BaseUrl,@"/alpay/pay.html",@910,UserToken,[self.dataSourceDic objectForKey:@"order"]];
    }
    UIWebView *webView = [[UIWebView alloc] init];
    webView.delegate = self;
    NSString *encodedString=[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:encodedString]];
    [SVProgressHUD show];
    [webView loadRequest:request];
    [self.view addSubview:webView];
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
    self.commitBtn.enabled = YES;
    [SVProgressHUD dismiss];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    self.commitBtn.enabled = YES;
    [SVProgressHUD dismiss];
}

//钱包余额支付
- (void)qianbaoAlipy{
    
    NSString *url = [NSString stringWithFormat:@"%@%@",BaseUrl,@"/yepay/pay.html"];
    NSDictionary *param = nil;
    if (_isFrom == isFromYuYueGrapher) {
        param = @{@"token":UserToken, @"id":[self.dataSourceDic objectForKey:@"id"], @"type":@5};
    }else if (_isFrom == isFromTeacher){
        param = @{@"token":UserToken, @"id":[self.dataSourceDic objectForKey:@"id"], @"type":@2};

    }else if (_isFrom == isFromGrapher){
        param = @{@"token":UserToken, @"id":[self.dataSourceDic objectForKey:@"id"], @"type":@1};
    }else if (_isFrom == isFromGroup){
        param = @{@"token":UserToken, @"id":[self.dataSourceDic objectForKey:@"id"], @"type":@7};
    }else if (_isFrom == isFromShouYeXiaZai){
        param = @{@"token":UserToken, @"id":[self.dataSourceDic objectForKey:@"id"], @"type":@8};
    }else if (_isFrom == isFromXSorXX){
        param = @{@"token":UserToken, @"id":[self.dataSourceDic objectForKey:@"order"], @"type":@910};
    }
    
    
    [[SYHttpRequest sharedInstance] getDataWithUrl:url Parameter:param ResponseObject:^(NSDictionary *responseResult) {
        self.commitBtn.enabled = YES;
        NSLog(@"余额支付 -- %@",responseResult);
        
        if ([responseResult objectForKey:@"resError"]) {
            [self showHint:@"服务器不给力，请稍后重试"];
        }else{
            if ([[responseResult objectForKey:@"result"] integerValue] == 1) {
                if (_isFrom != isFromYuYueGrapher) {
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
                    [self showHint:@"预约成功！"];
                    [self.navigationController popToRootViewControllerAnimated:YES];
                }
            
            }else if ([[responseResult objectForKey:@"result"] integerValue] == 4){
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
                if ([responseResult objectForKey:@"msg"]) {
                    [self showHint:[responseResult objectForKey:@"msg"]];
                }
            }
        }
    }];
}

//保存到相册
- (void)saveImageToPhoto:(NSURL *)url{
    // 将相片添加到相册
    [[ZLPhotoTool sharePhotoTool] saveImageToAblumWithUrl:url completion:^(BOOL suc, PHAsset *asset) {
        if (suc) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self showHint:@"成功保存图片到相册！"];
                
            });
            NSLog(@"保存成功！");
        }else{
            NSLog(@"保存失败");
        }
    }];
}
//微信支付
- (void)payByWechat{
    [SVProgressHUD show];
    NSString *url = [NSString stringWithFormat:@"%@%@",BaseUrl,@"/wxpay/pay.html"];
    NSDictionary *param = @{};
    if (_isFrom == isFromYuYueGrapher) {
        param = @{@"id":[self.dataSourceDic objectForKey:@"id"], @"type":@5, @"token":UserToken, @"paytype":@"APP"};
    }else if(_isFrom == isFromTeacher){
        param = @{@"id":[self.dataSourceDic objectForKey:@"id"], @"type":@2,@"paytype":@"APP"};


    }else if(_isFrom == isFromGrapher){
        param = @{@"id":[self.dataSourceDic objectForKey:@"id"], @"type":@1,@"paytype":@"APP"};

    }else if (_isFrom == isFromGroup){
        param = @{@"token":UserToken, @"id":[self.dataSourceDic objectForKey:@"id"], @"type":@7,@"paytype":@"APP"};
    }else if (_isFrom == isFromShouYeXiaZai){
        param = @{@"token":UserToken, @"id":[self.dataSourceDic objectForKey:@"id"], @"type":@8,@"paytype":@"APP"};
    }else if (_isFrom == isFromXSorXX){
        param = @{@"token":UserToken, @"id":[self.dataSourceDic objectForKey:@"order"], @"type":@910,@"paytype":@"APP"};
    }
    
    [[SYHttpRequest sharedInstance] getDataWithUrl:url Parameter:param ResponseObject:^(NSDictionary *responseResult) {
        [SVProgressHUD dismiss];
        self.commitBtn.enabled = YES;
        NSLog(@"微信支付 -- %@",responseResult);
        
        if ([responseResult objectForKey:@"resError"]) {
            [self showHint:@"服务器不给力，请稍后重试"];
            
        }else{
            if (responseResult.count > 0) {
                if ([[responseResult objectForKey:@"result"] integerValue] == 4) {
                    [self.navigationController popViewControllerAnimated:YES];
                    [self showHint:@"支付成功，请下载!"];
                    return ;
                }
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
        if (_isFrom == isFromYuYueGrapher) {
            [self showHint:@"预约成功！"];
            [self.navigationController popToRootViewControllerAnimated:YES];
        }else{
            
            [self.navigationController popViewControllerAnimated:YES];

        }
    }
    
    if ([notification.object intValue] == -1) {
        
        [self showHint:@"支付失败"];
    }
    
    if ([notification.object intValue] == -2) {
        
        [self showHint:@"取消支付"];
    }
    
}

//支付宝支付
- (void)alipayWithOrderStr:(NSString *)orderStr{
    
    NSString *appScheme = @"LongGuoYunPai";
    //支付宝支付
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(alipayResp:) name:@"payResule" object:nil];
    //支付宝支付
    [[AlipaySDK defaultService] payOrder:orderStr fromScheme:appScheme callback:^(NSDictionary *resultDic) {
        NSLog(@"resultDic -- %@",resultDic);
        
    }];
}

//支付宝支付回调
- (void)alipayResp:(NSNotification *)notif{
    NSDictionary *respResult = notif.userInfo;
    NSLog(@"respResult -- %@",[respResult objectForKey:@"payStatus"]);
    if ([[respResult objectForKey:@"payStatus"] integerValue] == 9000) {
        [self showHint:@"支付成功"];
        [self.navigationController popViewControllerAnimated:YES];
        
    }
    if ([[respResult objectForKey:@"payStatus"] integerValue] == 4000){
        [self showHint:@"支付失败"];
    }
    if ([[respResult objectForKey:@"payStatus"] integerValue] == 6001){
        [self showHint:@"中途取消"];
    }
}

//在当前window添加进度条
- (CircleProgressView *)progressView{
    if (!_progressView) {
        _progressView = [[CircleProgressView alloc] initWithFrame:CGRectMake(0, 0, 80, 80)];
        _progressView.center = CGPointMake(kScreenWidth / 2, kScreenHeight / 2);
        _progressView.backgroundColor = [UIColor clearColor];
        _progressView.progressColor = NavigationColor;
        _progressView.progressBackgroundColor = BackGroundColor;
        _progressView.clockwise = YES;
        _progressView.textColor = NavigationColor;
    }
    return _progressView;
}

@end
