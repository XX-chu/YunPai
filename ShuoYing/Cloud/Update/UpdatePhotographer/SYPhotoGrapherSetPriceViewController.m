//
//  SYPhotoGrapherSetPriceViewController.m
//  ShuoYing
//
//  Created by 硕影 on 2017/1/10.
//  Copyright © 2017年 硕影. All rights reserved.
//

#import "SYPhotoGrapherSetPriceViewController.h"
#import "SYGrapherSetPriceView.h"

@interface SYPhotoGrapherSetPriceViewController ()
{
    NSString *_money;
    NSString *_fee;
    NSString *_cash;
    UITextField *_yuePaiTF;
    UITextField *_danZhangTF;
    UITextField *_kehuTF;
}

@end

@implementation SYPhotoGrapherSetPriceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"价格管理";

    [self setRightbarItem];
    [self getData];
    [self loadSubView];
}

- (void)saveAction:(UIButton *)sender{
    if (_yuePaiTF.text.length == 0 || _danZhangTF.text.length == 0 || _kehuTF.text.length == 0) {
        [self.view endEditing:YES];
        
        [self showHint:@"请设置您的价格"];
        return;
    }
    
    NSString *url = [NSString stringWithFormat:@"%@%@",BaseUrl,@"/pho/setfee.html"];
    NSDictionary *param = @{@"token":UserToken, @"fee":_yuePaiTF.text, @"money":_kehuTF.text, @"cash":_danZhangTF.text};
    [SVProgressHUD show];
    [[SYHttpRequest sharedInstance] getDataWithUrl:url Parameter:param ResponseObject:^(NSDictionary *responseResult) {
        NSLog(@"摄影师保存价格 - %@",responseResult);
        [SVProgressHUD dismiss];
        if ([responseResult objectForKey:@"resError"]) {
            [self showHint:@"保存失败"];
            return ;
        }
        
        if ([responseResult objectForKey:@"result"]) {
            if ([[responseResult objectForKey:@"result"] integerValue] == 1) {
                [self showHint:[responseResult objectForKey:@"msg"]];
                [self.navigationController popViewControllerAnimated:YES];
            }else{
                [self showHint:[responseResult objectForKey:@"msg"]];
            }
        }
    }];
    
}

- (void)setRightbarItem{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 0, 44, 44);
    [btn setTitle:@"保存" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:15];
    [btn addTarget:self action:@selector(saveAction:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *right = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    right.width = -15;
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:btn];
    
    self.navigationItem.rightBarButtonItems = @[right, item];
}

- (void)loadSubView{
    SYGrapherSetPriceView *view = [[[NSBundle mainBundle] loadNibNamed:@"SYGrapherEditPriceView" owner:self options:nil] lastObject];
    view.frame = self.view.frame;
    [view.oldYuePaiTF becomeFirstResponder];
    NSLog(@"width - %f",view.frame.size.width);
    NSLog(@"height - %f",view.frame.size.height);
    _yuePaiTF = view.oldYuePaiTF;
    _danZhangTF = view.oldDanZhangTF;
    _kehuTF = view.oldKeHuDanZhangTF;
    [self.view addSubview:view];
}

- (void)getData{
    
    NSString *url = [NSString stringWithFormat:@"%@%@",BaseUrl,@"/pho/fee.html"];
    NSDictionary *param = @{@"token":UserToken};
    [[SYHttpRequest sharedInstance] getDataWithUrl:url Parameter:param ResponseObject:^(NSDictionary *responseResult) {
        
        NSLog(@"获取价格 -- %@",responseResult);
        if ([responseResult objectForKey:@"resError"]) {
            
        }else{
            if ([[responseResult objectForKey:@"result"] integerValue] == 1) {
                //单张照片价格
                _money = [NSString stringWithFormat:@"%.2f",[[responseResult objectForKey:@"money"] floatValue] / 100];
                //约拍价格
                _fee = [NSString stringWithFormat:@"%.2f",[[responseResult objectForKey:@"fee"] floatValue] / 100];
                //发布到首页价格
                _cash = [NSString stringWithFormat:@"%.2f",[[responseResult objectForKey:@"cash"] floatValue] / 100];
                _yuePaiTF.text = _fee;
                _danZhangTF.text = _cash;
                _kehuTF.text = _money;
            }else{
                if ([responseResult objectForKey:@"msg"]) {
                    [self showHint:[responseResult objectForKey:@"msg"]];
                }
            }
        }
    }];
    
}


@end
