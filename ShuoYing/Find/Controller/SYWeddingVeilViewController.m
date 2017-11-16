//
//  SYPeopleViewController.m
//  ShuoYing
//
//  Created by 硕影 on 2016/12/31.
//  Copyright © 2016年 硕影. All rights reserved.
//

#import "SYWeddingVeilViewController.h"
#import "SYCloudModel.h"
#import "SYCloudTableViewCell.h"
#import "SYGrapherInfosViewController.h"
#import "SYNoNetworkView.h"
@interface SYWeddingVeilViewController ()<UITableViewDelegate, UITableViewDataSource>
{
    NSString *_keywords;
}

@property (nonatomic, strong) NSMutableArray *dataSoucreArr;

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, assign) NSInteger page;

@property (nonatomic, strong) UITableView *searchTableView;

@property (nonatomic, strong) NSMutableArray *searchDataSourceArr;

@property (nonatomic, assign) NSInteger searchPage;

@property (nonatomic, strong) SYNoNetworkView *noNetWorkView;

@end

@implementation SYWeddingVeilViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(searchAction:) name:@"FindSearchResult" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cancleAction:) name:@"FindSearchResultCancle" object:nil];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"FindSearchResult" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"FindSearchResultCancle" object:nil];
}

- (void)loadFaildView{
    UIImageView *imageview = [[UIImageView alloc] initWithFrame:CGRectMake(0, 40, kScreenWidth, 260)];
    imageview.image = [UIImage imageNamed:@"sousuo_nothing"];
    imageview.contentMode = UIViewContentModeScaleAspectFit;
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(imageview.frame) + 10, kScreenWidth, 20)];
    label.text = @"不开森，没有亲想要的图片";
    label.textColor = [UIColor darkGrayColor];
    label.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:label];
    
    [self.view addSubview:imageview];
}

- (void)cancleAction:(NSNotification *)noti{
    if (noti.object) {
        if ([noti.object isKindOfClass:[NSNumber class]]) {
            NSNumber *index = (NSNumber *)noti.object;
            if ([index integerValue] == 100) {
                [self.view.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
                [self.view addSubview:self.tableView];
                [self.tableView reloadData];
            }
        }
    }
}

- (void)searchAction:(NSNotification *)noti{
    if (noti.object) {
        if ([noti.object isKindOfClass:[NSNumber class]]) {
            NSNumber *index = (NSNumber *)noti.object;
            if ([index integerValue] == 100) {
                _keywords = [noti.userInfo objectForKey:@"keywords"];
                [self searchDataWith:[noti.userInfo objectForKey:@"keywords"]];
            }
        }
    }
}

- (void)searchDataWith:(NSString *)text{
    self.searchPage = 1;
    NSString *url = [NSString stringWithFormat:@"%@%@",BaseUrl,@"/get/index.html"];
    NSDictionary *param = nil;
    if (_keywords.length == 0) {
        param = @{@"type":@4, @"page":@1};
    }else{
        param = @{@"type":@4, @"page":@1, @"keywords":_keywords};
    }
    [[SYHttpRequest sharedInstance] getDataWithUrl:url Parameter:param ResponseObject:^(NSDictionary *responseResult) {
        if ([_searchTableView.mj_header isRefreshing]) {
            [_searchTableView.mj_header endRefreshing];
        }
        NSLog(@"全部 -- %@",responseResult);
        if ([responseResult objectForKey:@"resError"]) {
            [self showHint:@"服务器不给力，请稍后重试"];
        }else{
            if ([[responseResult objectForKey:@"result"] integerValue] == 1) {
                
                NSArray *data = [responseResult objectForKey:@"data"];
                if (data.count == 0) {
                    [self.tableView removeFromSuperview];
                    [self.searchTableView removeFromSuperview];
                    [self loadFaildView];
                    return ;
                }
                if (data.count >= 10) {
                    [_searchTableView.mj_footer resetNoMoreData];
                }
                if (data.count < 10) {
                    [_searchTableView.mj_footer endRefreshingWithNoMoreData];
                }
                if (data.count > 0) {
                    [self.searchDataSourceArr removeAllObjects];
                    for (NSDictionary *dic in data) {
                        SYCloudModel *model = [SYCloudModel cloudWithDictionary:dic];
                        [self.searchDataSourceArr addObject:model];
                    }
                }
                [self.view.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
                
                [self.view addSubview:self.searchTableView];
                [self.searchTableView reloadData];
                
                
                
            }else{
                if ([responseResult objectForKey:@"msg"]) {
                    [self showHint:[responseResult objectForKey:@"msg"]];
                }
            }
        }
    }];
}

- (void)searchMoreDataWith:(NSString *)text{
    self.searchPage++;
    NSString *url = [NSString stringWithFormat:@"%@%@",BaseUrl,@"/get/index.html"];
    
    NSDictionary *param = nil;
    if (_keywords.length == 0) {
        param = @{@"type":@4, @"page":[NSNumber numberWithInteger:self.searchPage]};
    }else{
        param = @{@"type":@4, @"page":[NSNumber numberWithInteger:self.searchPage], @"keywords":_keywords};
    }
    [[SYHttpRequest sharedInstance] getDataWithUrl:url Parameter:param ResponseObject:^(NSDictionary *responseResult) {
        if ([_searchTableView.mj_footer isRefreshing]) {
            [_searchTableView.mj_footer endRefreshing];
        }
        NSLog(@"全部 -- %@",responseResult);
        if ([responseResult objectForKey:@"resError"]) {
            self.searchPage--;
            [self showHint:@"服务器不给力，请稍后重试"];
        }else{
            if ([[responseResult objectForKey:@"result"] integerValue] == 1) {
                
                NSArray *data = [responseResult objectForKey:@"data"];
                
                if (data.count < 10) {
                    self.searchPage--;
                    [_searchTableView.mj_footer endRefreshingWithNoMoreData];
                }
                if (data.count > 0) {
                    for (NSDictionary *dic in data) {
                        SYCloudModel *model = [SYCloudModel cloudWithDictionary:dic];
                        [self.searchDataSourceArr addObject:model];
                    }
                }
                
                
                [self.searchTableView reloadData];
                
                
            }else{
                self.searchPage--;
                if ([responseResult objectForKey:@"msg"]) {
                    [self showHint:[responseResult objectForKey:@"msg"]];
                }
            }
        }
    }];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.page = 1;
    self.searchPage = 1;
    self.title = @"详情";
    [self.view addSubview:self.tableView];
    [self.tableView.mj_header beginRefreshing];

    [self getData];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (tableView == self.searchTableView) {
        return self.searchDataSourceArr.count;
    }else{
        return self.dataSoucreArr.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView == self.searchTableView) {
        static NSString *indentifier = @"searchCell";
        SYCloudTableViewCell *cell = [[NSBundle mainBundle] loadNibNamed:@"SYCloudTableViewCell" owner:nil options:nil][0];
        if (!cell) {
            cell = [[SYCloudTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:indentifier];
            
        }
        
        cell.cloudModel = self.searchDataSourceArr[indexPath.row];
        
        return cell;
    }else{
        static NSString *indentifier = @"cloudCell";
        SYCloudTableViewCell *cell = [[NSBundle mainBundle] loadNibNamed:@"SYCloudTableViewCell" owner:nil options:nil][0];
        if (!cell) {
            cell = [[SYCloudTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:indentifier];
            
        }
        
        cell.cloudModel = self.dataSoucreArr[indexPath.row];
        
        return cell;
    }
    
    
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 90 + (kScreenWidth - 50) / 3 + 20;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView == self.searchTableView) {
        if (self.searchDataSourceArr.count > 0) {
            SYGrapherInfosViewController *grapherinfos = [[SYGrapherInfosViewController alloc] init];
            
            SYCloudModel *model = self.dataSoucreArr[indexPath.row];
            grapherinfos.grapherID = model.ID;
            [self.navigationController pushViewController:grapherinfos animated:YES];
        }
    }else{
        if (self.dataSoucreArr.count > 0) {
            SYGrapherInfosViewController *grapherinfos = [[SYGrapherInfosViewController alloc] init];
            
            SYCloudModel *model = self.dataSoucreArr[indexPath.row];
            grapherinfos.grapherID = model.ID;
            [self.navigationController pushViewController:grapherinfos animated:YES];
        }
    }
    
}

- (void)getData{
    self.page = 1;
    NSString *url = [NSString stringWithFormat:@"%@%@",BaseUrl,@"/get/index.html"];
    NSDictionary *param = nil;
    if (_keywords.length == 0) {
        param = @{@"type":@4, @"page":@1};
    }else{
        param = @{@"type":@4, @"page":@1, @"keywords":_keywords};
    }
    [[SYHttpRequest sharedInstance] getDataWithUrl:url Parameter:param ResponseObject:^(NSDictionary *responseResult) {
        if ([self.tableView.mj_header isRefreshing]) {
            [self.tableView.mj_header endRefreshing];
        }
        [self.noNetWorkView removeFromSuperview];
        NSLog(@"人物 -- %@",responseResult);
        if ([responseResult objectForKey:@"resError"]) {
            [self showHint:@"服务器不给力，请稍后重试"];
            if (self.dataSoucreArr.count == 0) {
                [self.view addSubview:self.noNetWorkView];
            }
        }else{
            if ([[responseResult objectForKey:@"result"] integerValue] == 1) {
                
                [XHNetworkCache saveJsonResponseToCacheFile:responseResult andURL:[NSString stringWithFormat:@"%@/%@",Mobile,@"renwu"]];
                
                NSArray *data = [responseResult objectForKey:@"data"];
                if (data.count >= 10) {
                    [self.tableView.mj_footer resetNoMoreData];
                }
                if (data.count < 10) {
                    [self.tableView.mj_footer endRefreshingWithNoMoreData];
                }
                if (data.count > 0) {
                    [self.dataSoucreArr removeAllObjects];
                    for (NSDictionary *dic in data) {
                        SYCloudModel *model = [SYCloudModel cloudWithDictionary:dic];
                        [self.dataSoucreArr addObject:model];
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
    self.page ++;
    NSString *url = [NSString stringWithFormat:@"%@%@",BaseUrl,@"/get/index.html"];

    NSDictionary *param = nil;
    if (_keywords.length == 0) {
        param = @{@"type":@4, @"page":[NSNumber numberWithInteger:self.page]};
    }else{
        param = @{@"type":@4, @"page":[NSNumber numberWithInteger:self.page], @"keywords":_keywords};
    }
    
    [[SYHttpRequest sharedInstance] getDataWithUrl:url Parameter:param ResponseObject:^(NSDictionary *responseResult) {
        [_tableView.mj_footer endRefreshing];
        NSLog(@"renwu -- %@",responseResult);
        if ([responseResult objectForKey:@"resError"]) {
            self.page --;
            [self showHint:@"服务器不给力，请稍后重试"];
        }else{
            if ([[responseResult objectForKey:@"result"] integerValue] == 1) {
                
                NSArray *data = [responseResult objectForKey:@"data"];
                if (data.count < 10) {
                    [self.tableView.mj_footer endRefreshingWithNoMoreData];
                    for (NSDictionary *dic in data) {
                        SYCloudModel *model = [SYCloudModel cloudWithDictionary:dic];
                        [self.dataSoucreArr addObject:model];
                    }
                    [self.tableView reloadData];
                    return ;
                }
                if (data.count > 0) {
                    
                    for (NSDictionary *dic in data) {
                        SYCloudModel *model = [SYCloudModel cloudWithDictionary:dic];
                        [self.dataSoucreArr addObject:model];
                    }
                }
                
                [self.tableView reloadData];
                
            }else{
                self.page --;
                if ([responseResult objectForKey:@"msg"]) {
                    [self showHint:[responseResult objectForKey:@"msg"]];
                }
            }
        }
    }];
}


- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight - kNavigationBarHeightAndStatusBarHeight - self.tabBarController.tabBar.frame.size.height - 40) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = BackGroundColor;
        _tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
            [self getData];
        }];
        _tableView.mj_footer = [MJRefreshAutoStateFooter footerWithRefreshingBlock:^{
            [self getMoreData];
        }];
        _tableView.mj_footer.automaticallyHidden = YES;
        [_tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
        
    }
    return _tableView;
}

- (UITableView *)searchTableView{
    if (!_searchTableView) {
        _searchTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight - kNavigationBarHeightAndStatusBarHeight - self.tabBarController.tabBar.frame.size.height - 40) style:UITableViewStylePlain];
        _searchTableView.delegate = self;
        _searchTableView.dataSource = self;
        _searchTableView.backgroundColor = BackGroundColor;
        _searchTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
            [self searchDataWith:_keywords];
        }];
        _searchTableView.mj_footer = [MJRefreshAutoStateFooter footerWithRefreshingBlock:^{
            [self searchMoreDataWith:_keywords];
        }];
        _searchTableView.mj_footer.automaticallyHidden = YES;
        [_searchTableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
        
    }
    return _searchTableView;
}

- (NSMutableArray *)searchDataSourceArr{
    if (!_searchDataSourceArr) {
        _searchDataSourceArr = [NSMutableArray arrayWithCapacity:0];
    }
    return _searchDataSourceArr;
}

- (NSMutableArray *)dataSoucreArr{
    if (!_dataSoucreArr) {
        _dataSoucreArr = [NSMutableArray arrayWithCapacity:0];
    }
    return _dataSoucreArr;
}

- (SYNoNetworkView *)noNetWorkView{
    if (!_noNetWorkView) {
        _noNetWorkView = [[[NSBundle mainBundle] loadNibNamed:@"SYNoNetworkView" owner:self options:nil] lastObject];
        _noNetWorkView.frame = self.view.bounds;
        __weak typeof(self)weakself = self;
        _noNetWorkView.block = ^(){
            [weakself getData];
        };
    }
    return _noNetWorkView;
}

@end
