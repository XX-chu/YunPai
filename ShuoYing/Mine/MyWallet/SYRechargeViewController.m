//
//  SYRechargeViewController.m
//  ShuoYing
//
//  Created by 硕影 on 2017/1/4.
//  Copyright © 2017年 硕影. All rights reserved.
//

#import "SYRechargeViewController.h"

#import "SYRechargeTableViewCell.h"
#import "SYRechargeMoneyTableViewCell.h"

@interface SYRechargeViewController ()<UITableViewDelegate, UITableViewDataSource>
{
    BOOL _defaultSelected;
    UITextField *_moneyTF;
}

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) UIButton *nextBtn;

@end

@implementation SYRechargeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _defaultSelected = YES;
    self.title = @"充值";
    [self.view addSubview:self.tableView];
    [self.tableView addSubview:self.nextBtn];
}

#pragma mark - PrivateMethod
- (void)nextAction:(UIButton *)sender{
    //先去空格
    NSString *money = [_moneyTF.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    if (money.length == 0) {
        [self showHint:@"请输入您的金额" Offset: -kScreenHeight/2 + 80];
        return;
    }
    
    if ([[Tool sharedInstance] isPureInt:money] || [[Tool sharedInstance] isPureFloat:money]) {
        
    }else{
        [self showHint:@"请输入数字" Offset: -kScreenHeight/2 + 80];
        return;
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 1) {
        return 1;
    }
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        static NSString *identifier = @"rechargeCell";
        SYRechargeTableViewCell *cell = [[NSBundle mainBundle] loadNibNamed:@"SYRechargeTableViewCell" owner:nil options:nil][0];
        cell.backgroundColor = RGB(249, 249, 249);
        
        if (!cell) {
            cell = [[SYRechargeTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        if (indexPath.row == 0) {
            cell.RechargeLabel.text = @"支付宝";
            cell.RechargeImageView.image = [UIImage imageNamed:@"wodeqianbao_yue_zhifubaologo"];
            if (_defaultSelected) {
                cell.RechargeIsSelectedIMG.image = [UIImage imageNamed:@"wodeqianbao__icon_sel"];
            }else{
                cell.RechargeIsSelectedIMG.image = [UIImage imageNamed:@""];
            }
        }else{
            cell.RechargeLabel.text = @"微信";
            cell.RechargeImageView.image = [UIImage imageNamed:@"wodeqianbao_yue_weixinlogo"];
            if (!_defaultSelected) {
                cell.RechargeIsSelectedIMG.image = [UIImage imageNamed:@"wodeqianbao__icon_sel"];
            }else{
                cell.RechargeIsSelectedIMG.image = [UIImage imageNamed:@""];
            }
        }
        
        
        return cell;

    }else{
        static NSString *identifier = @"rechargeMoneyCell";
        SYRechargeMoneyTableViewCell *cell1 = [[NSBundle mainBundle] loadNibNamed:@"SYRechargeMoneyTableViewCell" owner:nil options:nil][0];
        cell1.backgroundColor = RGB(249, 249, 249);
        
        if (!cell1) {
            cell1 = [[SYRechargeMoneyTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        }
        cell1.selectionStyle = UITableViewCellSelectionStyleNone;
        _moneyTF = cell1.MoneyTF;
        
        return cell1;
    }

}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 1) {
        return 44;
    }
    return 50;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            _defaultSelected = YES;

        }else{
            _defaultSelected = NO;
        }
        NSIndexSet *set = [NSIndexSet indexSetWithIndex:0];
        [self.tableView reloadSections:set withRowAnimation:UITableViewRowAnimationNone];
    }
}


#pragma mark - layzLoad
- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kTableViewHeight) style:UITableViewStyleGrouped];
        _tableView.backgroundColor = RGB(249, 249, 249);
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.showsVerticalScrollIndicator = NO;
    }
    return _tableView;
}

- (UIButton *)nextBtn{
    if (!_nextBtn) {
        _nextBtn = [[UIButton alloc] initWithFrame:CGRectMake(15, 250, kScreenWidth - 30, 40)];
        [_nextBtn setTitle:@"下一步" forState:UIControlStateNormal];
        [_nextBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_nextBtn setBackgroundImage:[UIImage imageWithColor:NavigationColor Size:_nextBtn.frame.size] forState:UIControlStateNormal];
        [_nextBtn setShowsTouchWhenHighlighted:NO];
        _nextBtn.layer.cornerRadius = 5;
        _nextBtn.layer.masksToBounds = YES;
        [_nextBtn addTarget:self action:@selector(nextAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _nextBtn;
}

@end
