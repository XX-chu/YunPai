//
//  SYMyYuYueZhongViewController.m
//  ShuoYing
//
//  Created by chu on 2017/11/15.
//  Copyright © 2017年 硕影. All rights reserved.
//

#import "SYMyDaiPingJiaViewController.h"
#import "SYYuYueOrderModel.h"
#import "SYMyYuYueZhongTableViewCell.h"
#import "SYHaveCreatOrderInfosViewController.h"
#import "SYMyYunPaiCommetViewController.h"
@interface SYMyDaiPingJiaViewController ()<UITableViewDelegate, UITableViewDataSource>
{
    NSInteger _count;
}
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataSourceArr;
@property (nonatomic, strong) UIView *noDataView;
@end

@implementation SYMyDaiPingJiaViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.tableView.mj_header beginRefreshing];

}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _count = 1;
    [self.view addSubview:self.tableView];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    SYYuYueOrderModel *model = self.dataSourceArr[indexPath.section];
    
    SYHaveCreatOrderInfosViewController *infos = [[SYHaveCreatOrderInfosViewController alloc] initWithOrderid:model.orderid OrderState:OrderStateDaiPingJia OrderModel:model];
    [self.navigationController pushViewController:infos animated:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.dataSourceArr.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"yuyuezhongCell";
    SYMyYuYueZhongTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[NSBundle mainBundle] loadNibNamed:@"SYMyYuYueZhongTableViewCell" owner:self options:nil][0];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    SYYuYueOrderModel *model = self.dataSourceArr[indexPath.section];
    cell.model = model;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 85;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return 10;
    }
    return 0.00001f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = HexRGB(0xeaeaea);
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 10 + 50;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = HexRGB(0xeaeaea);
    
    UIView *view1 = [[UIView alloc] initWithFrame:CGRectMake(0, 1, kScreenWidth, 49)];
    view1.backgroundColor = [UIColor whiteColor];
    [view addSubview:view1];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:@"去评价" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:16];
    btn.frame = CGRectMake(kScreenWidth - 105 - 13, 10, 105, 30);
    [btn setBackgroundColor:NavigationColor];
    btn.layer.cornerRadius = 5;
    btn.layer.masksToBounds = YES;
    [view1 addSubview:btn];
    btn.tag = section;
    [btn addTarget:self action:@selector(gotopingjia:) forControlEvents:UIControlEventTouchUpInside];
    
    return view;
}

- (void)gotopingjia:(UIButton *)sender{
    //去评价
    SYYuYueOrderModel *model = self.dataSourceArr[sender.tag];
    SYMyYunPaiCommetViewController *comment = [[SYMyYunPaiCommetViewController alloc] init];
    comment.model = model;
    [self.navigationController pushViewController:comment animated:YES];
}

/**
 获取数据
 */
- (void)getData{
    NSString *url = [NSString stringWithFormat:@"%@%@",BaseUrl,@"/masters/orders.html"];
    NSDictionary *param = @{@"state":@4, @"page":@1, @"token":UserToken};
    [[SYHttpRequest sharedInstance] getDataWithUrl:url Parameter:param ResponseObject:^(NSDictionary *responseResult) {
        NSLog(@"预约中 -- %@",responseResult);
        if ([self.tableView.mj_header isRefreshing]) {
            [self.tableView.mj_header endRefreshing];
        }
        if ([responseResult objectForKey:@"resError"]) {
            [self showHint:@"服务器不给力，请稍后重试"];
        }else{
            if ([[responseResult objectForKey:@"result"] integerValue] == 1) {
                _count = 1;
                NSArray *data = [responseResult objectForKey:@"data"];
                
                [self.dataSourceArr removeAllObjects];
                for (NSDictionary *dic in data) {
                    SYYuYueOrderModel *model = [SYYuYueOrderModel yunpaiorderWithDicaionary:dic];
                    [self.dataSourceArr addObject:model];
                }
                [self.tableView reloadData];
            }else{
                if ([responseResult objectForKey:@"msg"] && ![[responseResult objectForKey:@"msg"] isKindOfClass:[NSNull class]]) {
                    [self showHint:[responseResult objectForKey:@"msg"]];
                }
            }
        }
    }];
}

- (void)getMoreData{
    _count ++;
    NSString *url = [NSString stringWithFormat:@"%@%@",BaseUrl,@"/masters/orders.html"];
    NSDictionary *param = @{@"state":@4, @"page":[NSNumber numberWithInteger:_count], @"token":UserToken};
    [[SYHttpRequest sharedInstance] getDataWithUrl:url Parameter:param ResponseObject:^(NSDictionary *responseResult) {
        NSLog(@"预约中 -- %@",responseResult);
        if ([self.tableView.mj_header isRefreshing]) {
            [self.tableView.mj_header endRefreshing];
        }
        if ([responseResult objectForKey:@"resError"]) {
            [self showHint:@"服务器不给力，请稍后重试"];
            _count --;
        }else{
            if ([[responseResult objectForKey:@"result"] integerValue] == 1) {
                NSArray *data = [responseResult objectForKey:@"data"];
                for (NSDictionary *dic in data) {
                    SYYuYueOrderModel *model = [SYYuYueOrderModel yunpaiorderWithDicaionary:dic];
                    [self.dataSourceArr addObject:model];
                }
                [self.tableView reloadData];
                
            }else{
                if ([responseResult objectForKey:@"msg"] && ![[responseResult objectForKey:@"msg"] isKindOfClass:[NSNull class]]) {
                    _count --;
                    [self showHint:[responseResult objectForKey:@"msg"]];
                }
            }
        }
    }];
}


- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight - kNavigationBarHeightAndStatusBarHeight - 46) style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.backgroundColor = HexRGB(0xeaeaea);
        _tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
            [self getData];
        }];
        _tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
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

- (UIView *)noDataView{
    if (!_noDataView) {
        _noDataView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 20)];
        label.center = _noDataView.center;
        label.text = @"您还没有订单哦！赶快去约拍吧！";
        label.textColor = HexRGB(0x999999);
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont systemFontOfSize:14];
        [_noDataView addSubview:label];
        [self.view bringSubviewToFront:_noDataView];
    }
    return _noDataView;
}
@end


