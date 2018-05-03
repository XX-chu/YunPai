//
//  SYRecordsViewController.m
//  ShuoYing
//
//  Created by 硕影 on 2016/12/26.
//  Copyright © 2016年 硕影. All rights reserved.
//

#import "SYTiXianJiluViewController.h"
#import "SYTiXianJiLuTableViewCell.h"
#import "SYTiXianJiluDetailViewController.h"
@interface SYTiXianJiluViewController ()<UITableViewDelegate,UITableViewDataSource>

{
    NSInteger _count;
    NSDictionary *_user;
    NSArray *_bank;
}

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) UILabel *getDataFaildLabel;

@property (nonatomic, strong) NSMutableArray *dataSourceArr;

@end

@implementation SYTiXianJiluViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _count = 1;
    self.title = @"提现记录";
    self.view.backgroundColor = BackGroundColor;
    [self.view addSubview:self.tableView];
    [self.tableView.mj_header beginRefreshing];
}

#pragma mark - getDataFaildLoadView

#pragma mark - NetworkRequest
- (void)getData{
    NSString *url = [NSString stringWithFormat:@"%@%@",BaseUrl,@"/my/take_log.html"];
    NSDictionary *param = @{@"token":UserToken, @"page":@1};
    [[SYHttpRequest sharedInstance] getDataWithUrl:url Parameter:param ResponseObject:^(NSDictionary *responseResult) {
        if ([self.tableView.mj_header isRefreshing]) {
            [self.tableView.mj_header endRefreshing];
        }
        _count = 1;
        NSLog(@"提现记录 -- %@",responseResult);
        if ([responseResult objectForKey:@"resError"]) {
            [self showHint:@"服务器不给力，请稍后重试"];
        }else{
            if ([[responseResult objectForKey:@"result"] integerValue] == 1) {
                _user = [responseResult objectForKey:@"user"];
                _bank = [responseResult objectForKey:@"bank"];
                //把数据保存在本地
                if ([responseResult objectForKey:@"data"]) {
                    [self.dataSourceArr removeAllObjects];
                    NSArray *data = [responseResult objectForKey:@"data"];
                    if (data.count < 10) {
                        [self.tableView.mj_footer endRefreshingWithNoMoreData];
                    }
                    [self.dataSourceArr addObjectsFromArray:data];
                    if (self.dataSourceArr.count > 0) {
                        [self.getDataFaildLabel removeFromSuperview];
                    }else{
                        [self.view addSubview:self.getDataFaildLabel];
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

- (void)getMoreData{
    _count ++;
    NSString *url = [NSString stringWithFormat:@"%@%@",BaseUrl,@"/my/take_log.html"];
    NSDictionary *param = @{@"token":UserToken, @"page":[NSNumber numberWithInteger:_count]};
    [[SYHttpRequest sharedInstance] getDataWithUrl:url Parameter:param ResponseObject:^(NSDictionary *responseResult) {
        if ([self.tableView.mj_footer isRefreshing]) {
            [self.tableView.mj_footer endRefreshing];
        }
        NSLog(@"提现记录 -- %@",responseResult);
        if ([responseResult objectForKey:@"resError"]) {
            
            _count --;
            [self showHint:@"服务器不给力，请稍后重试"];
        }else{
            if ([[responseResult objectForKey:@"result"] integerValue] == 1) {
                //把数据保存在本地
                if ([responseResult objectForKey:@"data"]) {
                    NSArray *data = [responseResult objectForKey:@"data"];
                    if (data.count < 10) {
                        [self.tableView.mj_footer endRefreshingWithNoMoreData];
                    }
                    [self.dataSourceArr addObjectsFromArray:data];
                    [self.getDataFaildLabel removeFromSuperview];
                    [self.tableView reloadData];
                }
                
            }else{
                _count --;
                if ([responseResult objectForKey:@"msg"]) {
                    [self showHint:[responseResult objectForKey:@"msg"]];
                }
            }
        }
    }];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataSourceArr.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"cell";
    SYTiXianJiLuTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (!cell) {
        
        cell = [[NSBundle mainBundle] loadNibNamed:@"SYTiXianJiLuTableViewCell" owner:nil options:nil][0];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    NSDictionary *dic = self.dataSourceArr[indexPath.row];
    
    [cell.headImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",ImgUrl, [_user objectForKey:@"head"]]] placeholderImage:NoPicture];
    
    cell.titleLabel.text = @"余额提现";
    float money = [[dic objectForKey:@"money"] floatValue] / 100;
    cell.priceLabel.text = [NSString stringWithFormat:@"%.2f",money];
    cell.timeLabel.text = [dic objectForKey:@"addtime"];
    NSInteger state = [[dic objectForKey:@"state"] integerValue];
    if (state == 1) {
        cell.tixianState.text = @"提现成功";
    }else if (state == 2){
        cell.tixianState.text = @"提现退回";
    }else{
        cell.tixianState.text = @"提现审核中";
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 72;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.0001f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view = [[UIView alloc] init];
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.00001f;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *view = [[UIView alloc] init];
    return view;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSMutableDictionary *muDic = [NSMutableDictionary dictionaryWithCapacity:0];
    NSDictionary *dic = self.dataSourceArr[indexPath.row];
    [muDic setDictionary:dic];
    [muDic setObject:[_user objectForKey:@"name"] forKey:@"name"];
    NSInteger bank = [[dic objectForKey:@"bank"] integerValue];
    for (NSDictionary *bankDic in _bank) {
        if (bank == [[bankDic objectForKey:@"id"] integerValue]) {
            [muDic setObject:[bankDic objectForKey:@"name"] forKey:@"bankname"];
            break;
        }
    }
    
    SYTiXianJiluDetailViewController *detail = [[SYTiXianJiluDetailViewController alloc] init];
    detail.dataDic = muDic;
    [self.navigationController pushViewController:detail animated:YES];
}

#pragma mark - layzLoad
- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight - kNavigationBarHeightAndStatusBarHeight) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.backgroundColor = BackGroundColor;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
            [self getData];
        }];
        _tableView.mj_footer = [MJRefreshAutoStateFooter footerWithRefreshingBlock:^{
            [self getMoreData];
        }];
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

