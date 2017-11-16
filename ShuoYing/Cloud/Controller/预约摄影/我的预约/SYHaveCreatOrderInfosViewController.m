//
//  SYYunPaiOrderInfosViewController.m
//  ShuoYing
//
//  Created by chu on 2017/11/15.
//  Copyright © 2017年 硕影. All rights reserved.
//

#import "SYHaveCreatOrderInfosViewController.h"
#import "SYCustomTableViewCell.h"
#import "OrderPayTypeView.h"
#import "SYYuYueInfosViewController.h"
#import "SYMyYunPaiCommetViewController.h"
@interface SYHaveCreatOrderInfosViewController ()<UITableViewDelegate, UITableViewDataSource, UIWebViewDelegate>
{
    NSNumber *_money;
    
    NSString *_orderid;
    OrderState _orderState;
    SYYuYueOrderModel *_model;
    NSDictionary *_dataSourceDic;
}
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *dataSourceArr;
@end

@implementation SYHaveCreatOrderInfosViewController

- (instancetype)initWithOrderid:(NSString *)orderid OrderState:(OrderState)orderState OrderModel:(SYYuYueOrderModel *)orderModel{
    if (self = [super init]) {
        _orderid = orderid;
        _orderState = orderState;
        _model = orderModel;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"预约摄影";
    [self getData];
}


- (void)initBottomView{
    if (_orderState == OrderStateYuYueZhong) {
        return;
    }
    
    UIView *bottom = [[UIView alloc] initWithFrame:CGRectMake(0, kScreenHeight - kNavigationBarHeightAndStatusBarHeight - 50, kScreenWidth, 50)];
    bottom.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:bottom];
    if (_orderState == OrderStateYiWanCheng) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(0, 0, (bottom.frame.size.width - 1) / 2, bottom.frame.size.height);
        [btn setTitle:@"删除" forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btn setBackgroundColor:NavigationColor];
        btn.titleLabel.font = [UIFont systemFontOfSize:16];
        [btn addTarget:self action:@selector(delOrder:) forControlEvents:UIControlEventTouchUpInside];
        [bottom addSubview:btn];
        
        UIButton *btn1 = [UIButton buttonWithType:UIButtonTypeCustom];
        btn1.frame = CGRectMake(CGRectGetMaxX(btn.frame) + 1, 0, (bottom.frame.size.width - 1) / 2, bottom.frame.size.height);
        [btn1 setTitle:@"再次预约" forState:UIControlStateNormal];
        [btn1 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btn1 setBackgroundColor:NavigationColor];
        btn1.titleLabel.font = [UIFont systemFontOfSize:16];
        [btn1 addTarget:self action:@selector(zaiciyuyue:) forControlEvents:UIControlEventTouchUpInside];
        [bottom addSubview:btn1];
    }else if (_orderState == OrderStateDaiPaiShe){
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(0, 0, bottom.frame.size.width, bottom.frame.size.height);
        [btn setTitle:@"拍摄完成" forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btn setBackgroundColor:NavigationColor];
        btn.titleLabel.font = [UIFont systemFontOfSize:16];
        [btn addTarget:self action:@selector(paishewancheng:) forControlEvents:UIControlEventTouchUpInside];
        [bottom addSubview:btn];

    }else if (_orderState == OrderStateDaiPingJia){
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(0, 0, bottom.frame.size.width, bottom.frame.size.height);
        [btn setTitle:@"去评价" forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btn setBackgroundColor:NavigationColor];
        btn.titleLabel.font = [UIFont systemFontOfSize:16];
        [btn addTarget:self action:@selector(pingjia:) forControlEvents:UIControlEventTouchUpInside];
        [bottom addSubview:btn];
    }
    
}

#pragma mark - 删除订单
- (void)delOrder:(UIButton *)sender{
    [SVProgressHUD show];
    NSString *url = [NSString stringWithFormat:@"%@%@",BaseUrl,@"/masters/del.html"];
    NSDictionary *param = @{@"id":_orderid, @"token":UserToken};
    [[SYHttpRequest sharedInstance] getDataWithUrl:url Parameter:param ResponseObject:^(NSDictionary *responseResult) {
        [SVProgressHUD dismiss];
        NSLog(@"拍摄完成 -- %@",responseResult);
        if ([self.tableView.mj_header isRefreshing]) {
            [self.tableView.mj_header endRefreshing];
        }
        if ([responseResult objectForKey:@"resError"]) {
            [self showHint:@"服务器不给力，请稍后重试"];
        }else{
            if ([[responseResult objectForKey:@"result"] integerValue] == 1) {
                [self.navigationController popViewControllerAnimated:YES];
            }else{
                if ([responseResult objectForKey:@"msg"] && ![[responseResult objectForKey:@"msg"] isKindOfClass:[NSNull class]]) {
                    [self showHint:[responseResult objectForKey:@"msg"]];
                }
            }
        }
    }];
}
#pragma mark - 再次预约
- (void)zaiciyuyue:(UIButton *)sender{
    SYYuYueInfosViewController *infos = [[SYYuYueInfosViewController alloc] init];
    infos.yunpaiID = _model.mid;
    [self.navigationController pushViewController:infos animated:YES];
}
#pragma mark - 拍摄完成
- (void)paishewancheng:(UIButton *)sender{
    [SVProgressHUD show];
    NSString *url = [NSString stringWithFormat:@"%@%@",BaseUrl,@"/masters/done.html"];
    NSDictionary *param = @{@"id":_orderid, @"token":UserToken};
    [[SYHttpRequest sharedInstance] getDataWithUrl:url Parameter:param ResponseObject:^(NSDictionary *responseResult) {
        [SVProgressHUD dismiss];
        NSLog(@"拍摄完成 -- %@",responseResult);
        if ([self.tableView.mj_header isRefreshing]) {
            [self.tableView.mj_header endRefreshing];
        }
        if ([responseResult objectForKey:@"resError"]) {
            [self showHint:@"服务器不给力，请稍后重试"];
        }else{
            if ([[responseResult objectForKey:@"result"] integerValue] == 1) {
                [self.navigationController popViewControllerAnimated:YES];
            }else{
                if ([responseResult objectForKey:@"msg"] && ![[responseResult objectForKey:@"msg"] isKindOfClass:[NSNull class]]) {
                    [self showHint:[responseResult objectForKey:@"msg"]];
                }
            }
        }
    }];
}
#pragma mark - 去评价
- (void)pingjia:(UIButton *)sender{
    //去评价
    SYMyYunPaiCommetViewController *comment = [[SYMyYunPaiCommetViewController alloc] init];
    comment.model = _model;
    [self.navigationController pushViewController:comment animated:YES];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 7;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"customCell";
    SYCustomTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[NSBundle mainBundle] loadNibNamed:@"SYCustomTableViewCell" owner:self options:nil][0];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    cell.contentLabel.text = self.dataSourceArr[indexPath.section];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *str = self.dataSourceArr[indexPath.section];
    CGFloat height = [[Tool sharedInstance] heightForString:str andWidth:kScreenWidth - 26 fontSize:16];
    return height + 30;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.00001f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = HexRGB(0xeaeaea);
    return view;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 10;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = HexRGB(0xeaeaea);
    return view;
}

- (void)getData{
    [SVProgressHUD show];
    NSString *url = [NSString stringWithFormat:@"%@%@",BaseUrl,@"/masters/order.html"];
    NSDictionary *param = @{@"id":_orderid, @"token":UserToken};
    [[SYHttpRequest sharedInstance] getDataWithUrl:url Parameter:param ResponseObject:^(NSDictionary *responseResult) {
        NSLog(@"订单详情 -- %@",responseResult);
        [SVProgressHUD dismiss];
        if ([responseResult objectForKey:@"resError"]) {
            [self showHint:@"服务器不给力，请稍后重试"];
        }else{
            if ([[responseResult objectForKey:@"result"] integerValue] == 1) {
                _dataSourceDic = [responseResult objectForKey:@"data"];
                self.dataSourceArr = @[[NSString stringWithFormat:@"摄影师：%@",[_dataSourceDic objectForKey:@"nick"]],
                  [NSString stringWithFormat:@"摄影师电话：%@",[_dataSourceDic objectForKey:@"tel"]],
                  [NSString stringWithFormat:@"拍摄地址：%@",[_dataSourceDic objectForKey:@"address"]],
                  [NSString stringWithFormat:@"拍摄时间：%@",[_dataSourceDic objectForKey:@"addtime"]],
                  [NSString stringWithFormat:@"拍摄主题：%@",[_dataSourceDic objectForKey:@"msg"]],
                  [NSString stringWithFormat:@"联系人姓名：%@",[_dataSourceDic objectForKey:@"link"]],
                  [NSString stringWithFormat:@"联系人电话：%@",[_dataSourceDic objectForKey:@"link_tel"]],
                                       ];
                [self initBottomView];

                [self.view addSubview:self.tableView];
                [self.tableView reloadData];
            }else{
                if ([responseResult objectForKey:@"msg"] && ![[responseResult objectForKey:@"msg"] isKindOfClass:[NSNull class]]) {
                    [self showHint:[responseResult objectForKey:@"msg"]];
                }
            }
        }
    }];
}

- (UITableView *)tableView{
    if (!_tableView) {
        if (_orderState == OrderStateYuYueZhong) {
            _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight - kNavigationBarHeightAndStatusBarHeight) style:UITableViewStyleGrouped];
        }else{
            _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight - kNavigationBarHeightAndStatusBarHeight - 50) style:UITableViewStyleGrouped];

        }
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.backgroundColor = HexRGB(0xeaeaea);
    }
    return _tableView;
}

@end

