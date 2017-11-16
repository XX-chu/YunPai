//
//  SYMessageViewController.m
//  ShuoYing
//
//  Created by 硕影 on 2017/1/16.
//  Copyright © 2017年 硕影. All rights reserved.
//

#import "SYMessageViewController.h"
#import "SYMessageTableViewCell.h"
#import "SYMessageInfosViewController.h"
#import "SYMessageModel.h"

@interface SYMessageViewController ()<UITableViewDelegate, UITableViewDataSource>
{
    NSInteger _count;
}

@property (nonatomic, strong) NSMutableArray *dataSourceArr;

@property (nonatomic, strong) UITableView *tableView;

@end

@implementation SYMessageViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _count = 1;
    self.title = @"我的消息";
    [self getData];
    [self setRightBaritem];
}

- (void)setRightBaritem{
    UIButton *right = [UIButton buttonWithType:UIButtonTypeCustom];
    right.frame = CGRectMake(0, 0, 95, 40);
    [right setTitle:@"全部标记为已读" forState:UIControlStateNormal];
    [right setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    right.titleLabel.font = [UIFont systemFontOfSize:13];
    [right setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [right setTitleEdgeInsets:UIEdgeInsetsMake(0, 10, 0, -10)];
    [right addTarget:self action:@selector(allReadAction:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightbar = [[UIBarButtonItem alloc] initWithCustomView:right];
    self.navigationItem.rightBarButtonItem = rightbar;
}

- (void)allReadAction:(UIButton *)sender{
    NSString *url = [NSString stringWithFormat:@"%@%@",BaseUrl,@"/user/all.html"];
    NSDictionary *param = @{@"token":UserToken};
    [[SYHttpRequest sharedInstance] getDataWithUrl:url Parameter:param ResponseObject:^(NSDictionary *responseResult) {
        
        NSLog(@"全部设为已读 -- %@",responseResult);
        if ([responseResult objectForKey:@"resError"]) {
            [self showHint:@"服务器不给力，请稍后重试"];
        }else{
            if ([[responseResult objectForKey:@"result"] integerValue] == 1) {
                [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
                [self getData];
                
            }else{
                if ([responseResult objectForKey:@"msg"]) {
                    [self showHint:[responseResult objectForKey:@"msg"]];
                }
            }
        }
    }];

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"cell";
    SYMessageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[NSBundle mainBundle] loadNibNamed:@"SYMessageTableViewCell" owner:nil options:nil][0];
        cell.readLabel.text = @"";
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }

    cell.model = self.dataSourceArr[indexPath.section];
     
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.dataSourceArr.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 100;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 10;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    SYMessageInfosViewController *message = [[SYMessageInfosViewController alloc] init];
    SYMessageModel *model = self.dataSourceArr[indexPath.section];
    message.model = model;
    model.state = [NSNumber numberWithInteger:1];
    [self.dataSourceArr replaceObjectAtIndex:indexPath.section withObject:model];
    [self.navigationController pushViewController:message animated:YES];
}

- (void)getData{
    
    NSString *url = [NSString stringWithFormat:@"%@%@",BaseUrl,@"/user/msg.html"];
    NSDictionary *param = @{@"token":UserToken, @"page":@1};
    __weak typeof(self)weakself = self;
    [[SYHttpRequest sharedInstance] getDataWithUrl:url Parameter:param ResponseObject:^(NSDictionary *responseResult) {
        if ([_tableView.mj_header isRefreshing]) {
            [_tableView.mj_header endRefreshing];
        }
        NSLog(@"消息列表 -- %@",responseResult);
        if ([responseResult objectForKey:@"resError"]) {
            [weakself showHint:@"服务器不给力，请稍后重试"];
        }else{
            if ([[responseResult objectForKey:@"result"] integerValue] == 1) {
                [weakself.dataSourceArr removeAllObjects];

                if ([responseResult objectForKey:@"data"]) {
                    _count = 1;
                    NSArray *data = [responseResult objectForKey:@"data"];
                    if (data.count < 10) {
                        [_tableView.mj_footer endRefreshingWithNoMoreData];
                    }
                    if (data.count > 0) {
                        [weakself.view.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
                        for (NSDictionary *dic in data) {
                            SYMessageModel *model = [SYMessageModel messageWithDictionary:dic];
                            [weakself.dataSourceArr addObject:model];
                        }
                        [weakself.tableView removeFromSuperview];
                        [weakself.view addSubview:weakself.tableView];
                        [weakself.tableView reloadData];
                        
                    }else{
                        [weakself loadFaildView];
                    }
                }
                
            }else{
                if ([responseResult objectForKey:@"msg"]) {
                    [weakself showHint:[responseResult objectForKey:@"msg"]];
                }
            }
        }
    }];
}

- (void)getMoreData{
    _count ++;
    NSString *url = [NSString stringWithFormat:@"%@%@",BaseUrl,@"/user/msg.html"];
    NSDictionary *param = @{@"token":UserToken, @"page":[NSNumber numberWithInteger:_count]};
    [[SYHttpRequest sharedInstance] getDataWithUrl:url Parameter:param ResponseObject:^(NSDictionary *responseResult) {
        if ([_tableView.mj_footer isRefreshing]) {
            [_tableView.mj_footer endRefreshing];
        }
        NSLog(@"消息列表 -- %@",responseResult);
        if ([responseResult objectForKey:@"resError"]) {
            _count --;
            [self showHint:@"服务器不给力，请稍后重试"];
        }else{
            if ([[responseResult objectForKey:@"result"] integerValue] == 1) {
                NSArray *data = [responseResult objectForKey:@"data"];
                if (data.count < 10) {
                    [_tableView.mj_footer endRefreshingWithNoMoreData];
                    for (NSDictionary *dic in data) {
                        SYMessageModel *model = [SYMessageModel messageWithDictionary:dic];
                        [self.dataSourceArr addObject:model];
                    }
                    [self.tableView reloadData];
                    return ;
                }
                if (data.count > 0) {
                    
                    for (NSDictionary *dic in data) {
                        SYMessageModel *model = [SYMessageModel messageWithDictionary:dic];
                        [self.dataSourceArr addObject:model];
                    }
                }
                
                [self.tableView reloadData];
                
            }else{
                _count --;
                if ([responseResult objectForKey:@"msg"]) {
                    [self showHint:[responseResult objectForKey:@"msg"]];
                }
            }
        }
    }];
}


- (void)loadFaildView{
    [self.view.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    UIImageView *imageVIew = [[UIImageView alloc] initWithFrame:CGRectMake(0, 50, kScreenWidth, 260)];
    imageVIew.contentMode = UIViewContentModeScaleAspectFill;
    imageVIew.image = [UIImage imageNamed:@"message_no-message"];
    [self.view addSubview:imageVIew];
}

- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight - kNavigationBarHeightAndStatusBarHeight) style:UITableViewStyleGrouped];
        _tableView.backgroundColor = BackGroundColor;
        _tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
            [self getData];
        }];
        _tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
            [self getMoreData];
        }];
        _tableView.delegate = self;
        _tableView.dataSource = self;
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

@end
