//
//  SYTixianViewController.m
//  ShuoYing
//
//  Created by 硕影 on 2017/1/4.
//  Copyright © 2017年 硕影. All rights reserved.
//

#import "SYTixianViewController.h"

#import "SYRechargeTableViewCell.h"
#import "SYTixianMoneyTableViewCell.h"
#import "SYTixianTableViewCell.h"
#import "SelectAlert.h"
#import "SYUserInfos.h"
#import "SYTiXianTixingView.h"
#import "SYUpdateViewController.h"
@interface SYTixianViewController ()<UITableViewDelegate,UITableViewDataSource>

{
    BOOL _defaultSelected;
    UITextField *_moneyTF;
    
    UITextField *_nameTF;
    UITextField *_cardIDTF;
    NSString *_selecteValue;
    NSInteger _haveSelecteIndex;
    
    NSArray *_bankArr;
    NSDictionary *_resultDic;
    SYUserInfos *_userInfos;
}

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) UIButton *nextBtn;


@end

@implementation SYTixianViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self getUserInfos];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _defaultSelected = YES;
    _selecteValue = @"";
    _haveSelecteIndex = 9999;
    self.title = @"提现";
    [self.view addSubview:self.tableView];
    [self.tableView addSubview:self.nextBtn];
    [self getBank];
    
    
}

#pragma mark - PrivateMethod
- (void)nextAction:(UIButton *)sender{
    SYTiXianTixingView *view = [[[NSBundle mainBundle] loadNibNamed:@"SYTiXianTixingView" owner:self options:nil] lastObject];
    view.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
    if ([_userInfos.pho integerValue] == 0 || [_userInfos.pho integerValue] == 2) {
        __weak typeof(self)weakself = self;
        view.block = ^(){
            SYUpdateViewController *gra = [[SYUpdateViewController alloc] init];
            [weakself.navigationController pushViewController:gra animated:YES];
        };
        [view show];
        return;
    }else if ([_userInfos.pho integerValue] == 1){
    
    }else{
        [self showHint:@"摄影师认证中，请您耐心等待审核！"];
        [view disMiss];
        return;
    }
    
    
    //先去空格
    if (_selecteValue.length == 0) {
        [self showHint:@"请选择银行" Offset: -kScreenHeight/2 + 80];
        return;
    }
    
    if (_cardIDTF.text.length == 0) {
        [self showHint:@"请输入您的卡号" Offset: -kScreenHeight/2 + 80];
        return;
    }
    
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
    
    
    NSString *url = [NSString stringWithFormat:@"%@%@",BaseUrl,@"/my/take.html"];
    NSDictionary *param = @{@"token":UserToken, @"bank":[_bankArr[_haveSelecteIndex] objectForKey:@"id"], @"card":_cardIDTF.text, @"money":_moneyTF.text};
    [[SYHttpRequest sharedInstance] getDataWithUrl:url Parameter:param ResponseObject:^(NSDictionary *responseResult) {
        [SVProgressHUD dismiss];
        NSLog(@"提现  -- %@",responseResult);
        if ([responseResult objectForKey:@"resError"]) {
            [self showHint:@"服务器不给力，请稍后重试"];
        }else{
            if ([[responseResult objectForKey:@"result"] integerValue] == 1) {
                
                
            }else{
                if ([responseResult objectForKey:@"msg"]) {
                    [self showHint:[responseResult objectForKey:@"msg"]];
                }
            }
        }
    }];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 1) {
        return 2;
    }
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        static NSString *identifier = @"rechargeCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        cell.textLabel.text = @"请选择银行卡";
        cell.textLabel.font = [UIFont systemFontOfSize:15];
        cell.detailTextLabel.text = _selecteValue;
        cell.detailTextLabel.font = [UIFont systemFontOfSize:15];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        return cell;
        
    }else if (indexPath.section == 1){
        static NSString *identifier = @"cell1";
        SYTixianTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (!cell) {
            cell = [[NSBundle mainBundle] loadNibNamed:@"SYTixianTableViewCell" owner:nil options:nil][0];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        if (indexPath.row == 0) {
            cell.leftLabel.text = @"持卡人";
            _nameTF = cell.rightTF;
            if ([_resultDic objectForKey:@"name"]) {
                _nameTF.text = [_resultDic objectForKey:@"name"];
            }else{
                _nameTF.text = @"";
            }
        }else{
            cell.leftLabel.text = @"卡号";
            _cardIDTF = cell.rightTF;
        }
        return cell;
    }else{
        static NSString *identifier = @"rechargeMoneyCell";
        SYTixianMoneyTableViewCell *cell1 = [[NSBundle mainBundle] loadNibNamed:@"SYTixianMoneyTableViewCell" owner:nil options:nil][0];
        cell1.backgroundColor = RGB(249, 249, 249);
        
        if (!cell1) {
            cell1 = [[SYTixianMoneyTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        }
        cell1.selectionStyle = UITableViewCellSelectionStyleNone;

        _moneyTF = cell1.TixianMoneyTF;
        if (_userInfos.money) {
            cell1.TixianMoneyLabel.text = [NSString stringWithFormat:@"%.2f元",[_userInfos.money floatValue] / 100];
        }else{
            cell1.TixianMoneyLabel.text = @"0.00元";
        }
        
        
        return cell1;
    }
    
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 2) {
        UILabel *label = [[UILabel alloc] init];
        label.text = @"提现说明: 提现额度最低50元，仅开放摄影师提现。为保证资金安全，每周三当天可提现一次，其他时间提现或者重复提交提现可能会被锁定账号。";
        label.font = [UIFont systemFontOfSize:13];
        label.numberOfLines = 0;
        CGSize max = [label sizeThatFits:CGSizeMake(kScreenWidth - 30, MAXFLOAT)];
        
        return max.height + 93;
    }
    return 50;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 2) {
        return 30;
    }
    return 20;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (section == 2) {
        return 30;
    }
    return 0.0001f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (section == 2) {
        UIView *view = [[UIView alloc] init];
        view.backgroundColor = BackGroundColor;
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, 7, kScreenWidth - 30, 15)];
        label.text = @"为保证账户资金安全，只能填写用户本人的银行卡";
        label.font = [UIFont systemFontOfSize:11];
        label.textColor = [UIColor darkGrayColor];
        [view addSubview:label];
        
        return view;
    }
    
    return nil;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    if (section == 2) {
        UIView *view = [[UIView alloc] init];
        view.backgroundColor = BackGroundColor;
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, 7, kScreenWidth - 30, 15)];
        label.text = @"友情提示：24小时内到账";
        label.font = [UIFont systemFontOfSize:11];
        label.textColor = [UIColor redColor];
        [view addSubview:label];
        
        return view;
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        NSMutableArray *arr = [NSMutableArray arrayWithCapacity:0];
        if (_bankArr.count > 0) {
            for (NSDictionary *dic in _bankArr) {
                NSString *bankname = [dic objectForKey:@"name"];
                [arr addObject:bankname];
            }
        }
        
        SelectAlert *alert = [SelectAlert showWithTitle:@"请选择银行卡" titles:arr selectIndex:^(NSInteger selectIndex) {
            _haveSelecteIndex = selectIndex;
        } selectValue:^(NSString *selectValue) {
            _selecteValue = selectValue;
            NSIndexSet *set = [NSIndexSet indexSetWithIndex:0];
            [self.tableView reloadSections:set withRowAnimation:UITableViewRowAnimationNone];
            
        } showCloseButton:NO];
        alert.haveSeletedIndex = _haveSelecteIndex;
    }
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
                //归档
                [[Tool sharedInstance] saveObject:userinfos WithPath:[NSString stringWithFormat:@"%@",Mobile]];
                
                _userInfos = [[Tool sharedInstance] getObjectWithPath:[NSString stringWithFormat:@"%@",Mobile]];
                [self.tableView reloadData];
            }else{
                if ([responseResult objectForKey:@"msg"]) {
                    [self showHint:[responseResult objectForKey:@"msg"]];
                }
            }
        }
    }];
}


- (void)getBank{
    NSString *url = [NSString stringWithFormat:@"%@%@",BaseUrl,@"/my/bank.html"];
    NSDictionary *param = @{@"token":UserToken};
    [[SYHttpRequest sharedInstance] getDataWithUrl:url Parameter:param ResponseObject:^(NSDictionary *responseResult) {
        [SVProgressHUD dismiss];
        NSLog(@"获取  -- %@",responseResult);
        if ([responseResult objectForKey:@"resError"]) {
            [self showHint:@"服务器不给力，请稍后重试"];
        }else{
            if ([[responseResult objectForKey:@"result"] integerValue] == 1) {
                _bankArr = [responseResult objectForKey:@"data"];
                _resultDic = responseResult;
                [self.tableView reloadData];
            }else{
                if ([responseResult objectForKey:@"msg"]) {
                    [self showHint:[responseResult objectForKey:@"msg"]];
                }
            }
        }
    }];
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
        _nextBtn = [[UIButton alloc] initWithFrame:CGRectMake(15, 410, kScreenWidth - 30, 44)];
        [_nextBtn setTitle:@"确认转出" forState:UIControlStateNormal];
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
