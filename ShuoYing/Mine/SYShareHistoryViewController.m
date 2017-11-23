//
//  SYShareHistoryViewController.m
//  ShuoYing
//
//  Created by chu on 2017/11/1.
//  Copyright © 2017年 硕影. All rights reserved.
//

#import "SYShareHistoryViewController.h"
#import "SYShareHIstoryTableViewCell.h"
#import "SYGrapherUpdataPhotoViewController.h"
@interface SYShareHistoryViewController ()<UITableViewDelegate, UITableViewDataSource>
{
    NSInteger _page;
}
@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *dataSourceArr;

@end

@implementation SYShareHistoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _page = 1;
    self.title = @"分享记录";
    [self.view addSubview:self.tableView];
    [self.tableView.mj_header beginRefreshing];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.dataSourceArr.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"share";
    SYShareHIstoryTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[NSBundle mainBundle] loadNibNamed:@"SYShareHIstoryTableViewCell" owner:nil options:nil][0];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    NSDictionary *dic = self.dataSourceArr[indexPath.section];
    [cell.headImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",ImgUrl, [dic objectForKey:@"head"]]] placeholderImage:NoPicture];
    cell.nameLabel.text = [dic objectForKey:@"nick"];
    cell.phoneLabel.text = [dic objectForKey:@"user"];
    cell.block = ^{
        //传送照片
        SYGrapherUpdataPhotoViewController *update = [[SYGrapherUpdataPhotoViewController alloc] init];
        update.dataSourceDic = @{@"tel":[dic objectForKey:@"user"]};
        update.isFromHistory = YES;
        [self.navigationController pushViewController:update animated:YES];
    };
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 72;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.00001f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 15;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view = [[UIView alloc] init];
    return view;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *view = [[UIView alloc] init];
    return view;
}

- (void)getData{
    NSString *url = [NSString stringWithFormat:@"%@%@",BaseUrl, @"/user/share.html"];
    NSDictionary *param = @{@"token":UserToken};
    [[SYHttpRequest sharedInstance] getDataWithUrl:url Parameter:param ResponseObject:^(NSDictionary *responseResult) {
        NSLog(@"分享记录  -- %@",responseResult);
        _page = 1;
        if ([_tableView.mj_header isRefreshing]) {
            [_tableView.mj_header endRefreshing];
        }
        if ([[responseResult objectForKey:@"result"] integerValue] == 1) {
            [self.dataSourceArr removeAllObjects];
            NSArray *data = [responseResult objectForKey:@"data"];
            [self.dataSourceArr addObjectsFromArray:data];
            [self.tableView reloadData];
        }else{
            [self showHint:[responseResult objectForKey:@"msg"]];
        }
    }];
}

- (void)getMoreData{
    _page ++;
    NSString *url = [NSString stringWithFormat:@"%@%@",BaseUrl, @"/user/share.html"];
    NSDictionary *param = @{@"token":UserToken, @"page":[NSNumber numberWithInteger:_page]};
    [[SYHttpRequest sharedInstance] getDataWithUrl:url Parameter:param ResponseObject:^(NSDictionary *responseResult) {
        if ([_tableView.mj_footer isRefreshing]) {
            [_tableView.mj_footer endRefreshing];
        }

        NSLog(@"分享记录  -- %@",responseResult);
        if ([[responseResult objectForKey:@"result"] integerValue] == 1) {
            NSArray *data = [responseResult objectForKey:@"data"];
            [self.dataSourceArr addObjectsFromArray:data];
            [self.tableView reloadData];
        }else{
            _page --;
        }
    }];
}

- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight - kNavigationBarHeightAndStatusBarHeight) style:UITableViewStylePlain];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.backgroundColor = BackGroundColor;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
            [self getData];
        }];
        _tableView.mj_footer = [MJRefreshBackStateFooter footerWithRefreshingBlock:^{
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

@end
