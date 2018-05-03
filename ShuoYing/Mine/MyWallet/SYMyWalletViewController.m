//
//  SYMyWalletViewController.m
//  ShuoYing
//
//  Created by 硕影 on 2016/12/26.
//  Copyright © 2016年 硕影. All rights reserved.
//

#import "SYMyWalletViewController.h"
#import "SYMyWalletTableViewCell.h"

#import "SYRechargeViewController.h"
#import "SYTixianViewController.h"
#import "SYChongZhiViewController.h"
#import "SYUserInfos.h"
#import "SYIDViewController.h"
#import "SYTiXianJiluViewController.h"
@interface SYMyWalletViewController ()<UITableViewDelegate,UITableViewDataSource>

{
    UILabel *_moneyLabel;
    SYUserInfos *_userInfos;
}

@property (nonatomic, strong) UIView *upView;

@property (nonatomic, strong) UITableView *tableView;

@end

static const CGFloat UpViewHeight = 150;;

@implementation SYMyWalletViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self getUserInfos];

}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = RGB(249, 249, 249);
    self.title = @"账户管理";
    [self.view addSubview:self.upView];
    [self.view addSubview:self.tableView];

    //取出用户信息
//    if ([[Tool sharedInstance] getObjectWithPath:[NSString stringWithFormat:@"%@",Mobile]]) {
//        _userInfos = [[Tool sharedInstance] getObjectWithPath:[NSString stringWithFormat:@"%@",Mobile]];
//        _moneyLabel.text = [NSString stringWithFormat:@"%.2f",[_userInfos.money floatValue] / 100];
//    }else{
//    }
    [self setrightItem];
}

- (void)setrightItem{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:@"提现记录" forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:15];
    [btn addTarget:self action:@selector(tixianAction:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:btn];
    self.navigationItem.rightBarButtonItem = item;
}

- (void)tixianAction:(UIButton *)sender{
    SYTiXianJiluViewController *tixian = [[SYTiXianJiluViewController alloc] init];
    [self.navigationController pushViewController:tixian animated:YES];
}

//获取用户信息
- (void)getUserInfos{
    
    NSString *url = [NSString stringWithFormat:@"%@%@",BaseUrl,@"/user/user.html"];
    NSDictionary *param = @{@"token":UserToken};
    [[SYHttpRequest sharedInstance] getDataWithUrl:url Parameter:param ResponseObject:^(NSDictionary *responseResult) {
        [SVProgressHUD dismiss];
        NSLog(@"获取用户信息 -- %@",responseResult);
        if ([responseResult objectForKey:@"resError"]) {
            [self showHint:@"服务器不给力，请稍后重试"];
        }else{
            if ([[responseResult objectForKey:@"result"] integerValue] == 1) {
                NSDictionary *data = [responseResult objectForKey:@"data"];
                SYUserInfos *userinfos = [SYUserInfos userinfosWithDictionry:data];
                _userInfos = userinfos;
                //归档
                [[Tool sharedInstance] saveObject:userinfos WithPath:[NSString stringWithFormat:@"%@",Mobile]];
                
                _moneyLabel.text = [NSString stringWithFormat:@"%.2f",[userinfos.money floatValue] / 100];
                
            }else{
                if ([responseResult objectForKey:@"msg"]) {
                    [self showHint:[responseResult objectForKey:@"msg"]];
                }
            }
        }
    }];
}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"cell";
    SYMyWalletTableViewCell *cell = [[NSBundle mainBundle] loadNibNamed:@"SYMyWalletTableViewCell" owner:nil options:nil][0];
    cell.backgroundColor = RGB(249, 249, 249);

    if (!cell) {
        cell = [[SYMyWalletTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];

    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    if (indexPath.row == 0) {
        cell.contentLabel.text = @"提现";
        cell.imageVIew.image = [UIImage imageNamed:@"zh_icon_tx"];
    }else{
        cell.contentLabel.text = @"充值";
        cell.imageVIew.image = [UIImage imageNamed:@"zh_icon_cz"];
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (!_userInfos) {
        return;
    }
    if ([_userInfos.idcard integerValue] == 0) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"亲爱的用户，为了您的资金安全，请先绑定身份证" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"去绑定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            SYIDViewController *idvc = [[SYIDViewController alloc] init];
            idvc.state = isFromYunPaiShi;
            [self.navigationController pushViewController:idvc animated:YES];
        }];
        
        [alert addAction:action];
        [alert addAction:action1];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    if (indexPath.row == 0) {
        SYTixianViewController *tixianVC = [[SYTixianViewController alloc] init];
        [self.navigationController pushViewController:tixianVC animated:YES];
    }else{
        SYChongZhiViewController *chongzhi = [[SYChongZhiViewController alloc] init];
        [self.navigationController pushViewController:chongzhi animated:YES];
    }
    
}


#pragma mark - layzLoad
- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, UpViewHeight, kScreenWidth, kTableViewHeight - UpViewHeight) style:UITableViewStylePlain];
        _tableView.backgroundColor = RGB(249, 249, 249);
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.showsVerticalScrollIndicator = NO;
    }
    return _tableView;
}

- (UIView *)upView{
    if (!_upView) {
        _upView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, UpViewHeight)];
        [_upView setBackgroundColor:NavigationColor];
        
        UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(15, 30, kScreenWidth - 30, 20)];
        label1.text = @"账户余额（元）";
        label1.textColor = [UIColor whiteColor];
        [_upView addSubview:label1];
        
        UILabel *moneyLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 80, kScreenWidth - 30, 42)];
        moneyLabel.text = @"0.00";
        moneyLabel.font = [UIFont systemFontOfSize:40];
        moneyLabel.textColor = [UIColor whiteColor];
        _moneyLabel = moneyLabel;
        [_upView addSubview:moneyLabel];
    }
    return _upView;
}


@end
