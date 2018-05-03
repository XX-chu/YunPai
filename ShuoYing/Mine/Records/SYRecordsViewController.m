//
//  SYRecordsViewController.m
//  ShuoYing
//
//  Created by 硕影 on 2016/12/26.
//  Copyright © 2016年 硕影. All rights reserved.
//

#import "SYRecordsViewController.h"
#import "SYRecordsTableViewCell.h"

@interface SYRecordsViewController ()<UITableViewDelegate,UITableViewDataSource>

{
    NSInteger _count;
}

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) UILabel *getDataFaildLabel;

@property (nonatomic, strong) NSMutableArray *dataSourceArr;

@end

@implementation SYRecordsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _count = 1;
    self.title = @"交易记录";
    self.view.backgroundColor = BackGroundColor;
    [self.view addSubview:self.tableView];
    [self.tableView.mj_header beginRefreshing];
}

#pragma mark - NetworkRequest
- (void)getData{
    NSString *url = [NSString stringWithFormat:@"%@%@",BaseUrl,@"/my/trade.html"];
    NSDictionary *param = @{@"token":UserToken, @"page":@1};
    [[SYHttpRequest sharedInstance] getDataWithUrl:url Parameter:param ResponseObject:^(NSDictionary *responseResult) {
        if ([self.tableView.mj_header isRefreshing]) {
            [self.tableView.mj_header endRefreshing];
        }
        _count = 1;
        NSLog(@"交易记录 -- %@",responseResult);
        if ([responseResult objectForKey:@"resError"]) {
            [self showHint:@"服务器不给力，请稍后重试"];
        }else{
            if ([[responseResult objectForKey:@"result"] integerValue] == 1) {
                
                //把数据保存在本地
                if ([responseResult objectForKey:@"data"]) {
                    [self.dataSourceArr removeAllObjects];
                    NSArray *data = [responseResult objectForKey:@"data"];
                    if (data.count < 10) {
                        [self.tableView.mj_footer endRefreshingWithNoMoreData];
                    }
                    [self.dataSourceArr addObjectsFromArray:data];
                    if (self.dataSourceArr.count > 0) {
//                        [self.tableView removeFromSuperview];
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
    NSString *url = [NSString stringWithFormat:@"%@%@",BaseUrl,@"/my/trade.html"];
    NSDictionary *param = @{@"token":UserToken, @"page":[NSNumber numberWithInteger:_count]};
    [[SYHttpRequest sharedInstance] getDataWithUrl:url Parameter:param ResponseObject:^(NSDictionary *responseResult) {
        if ([self.tableView.mj_footer isRefreshing]) {
            [self.tableView.mj_footer endRefreshing];
        }
        NSLog(@"交易记录 -- %@",responseResult);
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
    SYRecordsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (!cell) {

        cell = [[NSBundle mainBundle] loadNibNamed:@"SYRecordsTableViewCell" owner:nil options:nil][0];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.recordTypeLabel.text = [self.dataSourceArr[indexPath.row] objectForKey:@"method"];
    cell.timeLabel.text = [self.dataSourceArr[indexPath.row] objectForKey:@"addtime"];
    if ([[self.dataSourceArr[indexPath.row] objectForKey:@"type"] isEqualToString:@"-"]) {
        cell.moneyLabel.text = [NSString stringWithFormat:@"-%.2f",[[self.dataSourceArr[indexPath.row] objectForKey:@"money"] floatValue] / 100];
    }else{
        cell.moneyLabel.text = [NSString stringWithFormat:@"+%.2f",[[self.dataSourceArr[indexPath.row] objectForKey:@"money"] floatValue] / 100];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 65;
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
        _getDataFaildLabel.text = @"暂无任何交易记录哟!";
        _getDataFaildLabel.textAlignment = NSTextAlignmentCenter;
        _getDataFaildLabel.textColor = RGB(153, 153, 153);
    }
    return _getDataFaildLabel;
}

@end
