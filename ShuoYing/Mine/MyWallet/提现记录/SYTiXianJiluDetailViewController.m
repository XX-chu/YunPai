//
//  SYRecordsViewController.m
//  ShuoYing
//
//  Created by 硕影 on 2016/12/26.
//  Copyright © 2016年 硕影. All rights reserved.
//

#import "SYTiXianJiluDetailViewController.h"
#import "SYTiXianJiLuStateTableViewCell.h"
#import "SYLeftRightTextTableViewCell.h"

@interface SYTiXianJiluDetailViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) UILabel *getDataFaildLabel;

@property (nonatomic, strong) NSMutableArray *dataSourceArr;

@end

@implementation SYTiXianJiluDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"提现详情";
    self.view.backgroundColor = BackGroundColor;
    [self.view addSubview:self.tableView];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return 2;
    }
    return 3;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        static NSString *identifier = @"statecell";
        SYTiXianJiLuStateTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        
        if (!cell) {
            cell = [[NSBundle mainBundle] loadNibNamed:@"SYTiXianJiLuStateTableViewCell" owner:nil options:nil][0];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        NSInteger state = [[self.dataDic objectForKey:@"state"] integerValue];
        if (state == 0) {
            if (indexPath.row == 0) {
                cell.upView.hidden = YES;
                cell.downView.hidden = NO;
                cell.downView.backgroundColor = HexRGB(0x3dcfbc);
                cell.stateImageView.image = [UIImage imageNamed:@"tx-chenggong"];
                cell.stateLabel.text = @"提现审核中";
                cell.stateLabel.textColor = HexRGB(0x3dcfbc);
                cell.miaoshuLabel.text = @"";
                cell.lineView.hidden = YES;
            }else{
                cell.upView.hidden = NO;
                cell.downView.hidden = YES;
                cell.upView.backgroundColor = HexRGB(0xc9c9c9);
                cell.stateImageView.image = [UIImage imageNamed:@"tx-moren"];
                cell.stateLabel.text = @"预计24小时到账";
                cell.stateLabel.textColor = HexRGB(0x999999);
                cell.miaoshuLabel.text = @"";
            }
        }else if (state == 1){
            if (indexPath.row == 0) {
                cell.upView.hidden = YES;
                cell.downView.hidden = NO;
                cell.downView.backgroundColor = HexRGB(0x3dcfbc);
                cell.stateImageView.image = [UIImage imageNamed:@"tx-chenggong"];
                cell.stateLabel.text = @"提现审核中";
                cell.stateLabel.textColor = HexRGB(0x3dcfbc);
                cell.miaoshuLabel.text = @"";
                cell.lineView.hidden = YES;
            }else{
                cell.upView.hidden = NO;
                cell.downView.hidden = YES;
                cell.upView.backgroundColor = HexRGB(0x3dcfbc);
                cell.stateImageView.image = [UIImage imageNamed:@"tx-chenggong"];
                cell.stateLabel.text = @"提现成功";
                cell.stateLabel.textColor = HexRGB(0x3dcfbc);
                cell.miaoshuLabel.text = @"";
            }
        }else{
            if (indexPath.row == 0) {
                cell.upView.hidden = YES;
                cell.downView.hidden = NO;
                cell.downView.backgroundColor = HexRGB(0x3dcfbc);
                cell.stateImageView.image = [UIImage imageNamed:@"tx-chenggong"];
                cell.stateLabel.text = @"提现审核中";
                cell.stateLabel.textColor = HexRGB(0x3dcfbc);
                cell.miaoshuLabel.text = @"";
                cell.lineView.hidden = YES;
            }else{
                cell.upView.hidden = NO;
                cell.downView.hidden = YES;
                cell.upView.backgroundColor = HexRGB(0x3dcfbc);
                cell.stateImageView.image = [UIImage imageNamed:@"tx-tuihui"];
                cell.stateLabel.text = @"提现申请退回";
                cell.stateLabel.textColor = HexRGB(0x3dcfbc);
                cell.miaoshuLabel.text = @"姓名或银行卡号不正确";
            }
        }
        
        return cell;
    }else{
        static NSString *identifier = @"leftrightCell";
        SYLeftRightTextTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        
        if (!cell) {
            cell = [[NSBundle mainBundle] loadNibNamed:@"SYLeftRightTextTableViewCell" owner:nil options:nil][0];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        NSString *money = [NSString stringWithFormat:@"%.2f",[[self.dataDic objectForKey:@"money"] floatValue] / 100];
        NSString *card = [self.dataDic objectForKey:@"card"];
        NSString *bank = [NSString stringWithFormat:@"%@(%@)%@",[self.dataDic objectForKey:@"bankname"], [card substringFromIndex:card.length - 4], [self.dataDic objectForKey:@"name"]];
        NSString *time = [self.dataDic objectForKey:@"addtime"];
        
        if (indexPath.row == 0) {
            cell.leftLabel.text = @"提现金额";
            cell.rightLabel.text = money;
        }else if (indexPath.row == 1){
            cell.leftLabel.text = @"提现到";
            cell.rightLabel.text = bank;
        }else{
            cell.leftLabel.text = @"提现创建时间";
            cell.rightLabel.text = time;
        }
        return cell;
    }

    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        NSInteger state = [[self.dataDic objectForKey:@"state"] integerValue];
        if (state == 2) {
            CGFloat height = [[Tool sharedInstance] heightForString:@"姓名或银行卡号不正确" andWidth:kScreenWidth - 69 fontSize:12];
            return height + 51;
        }else{
            return 55;
        }
    }
    return 50;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return 26;
    }
    return 0.0001f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor whiteColor];
    if (section == 0) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, kScreenWidth - 20, 16)];
        label.text = @"提现进度";
        label.textColor = HexRGB(0x434343);
        label.font = [UIFont systemFontOfSize:15];
        
        [view addSubview:label];
    }
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.00001f;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *view = [[UIView alloc] init];
    return view;
}

#pragma mark - layzLoad
- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight - kNavigationBarHeightAndStatusBarHeight) style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.backgroundColor = BackGroundColor;
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

- (UILabel *)getDataFaildLabel{
    if (!_getDataFaildLabel) {
        _getDataFaildLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 170)];
        _getDataFaildLabel.text = @"暂无任何提现记录哟!";
        _getDataFaildLabel.textAlignment = NSTextAlignmentCenter;
        _getDataFaildLabel.textColor = RGB(153, 153, 153);
    }
    return _getDataFaildLabel;
}

@end


