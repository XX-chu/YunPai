//
//  SYSearchViewController.m
//  ShuoYing
//
//  Created by 硕影 on 2017/1/17.
//  Copyright © 2017年 硕影. All rights reserved.
//

#import "SYSearchViewController.h"
#import "QTSearchBar.h"
#import "SYCloudTableViewCell.h"
#import "SYCloudModel.h"
#import "SYGrapherInfosViewController.h"
@interface SYSearchViewController ()<QTSearchBarDelegate,UITableViewDelegate,UITableViewDataSource>

{
    QTSearchBar *_searchBar;
    UIButton *_cancleBtn;
    
    NSInteger _count;
}

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *dataSourceArr;

@end

@implementation SYSearchViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (_cancleBtn == nil || _searchBar == nil) {
        [self loadSearchBar];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _count = 1;
    [self loadSearchBar];

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataSourceArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"cell1";
    SYCloudTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[NSBundle mainBundle] loadNibNamed:@"SYCloudTableViewCell" owner:nil options:nil][0];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    cell.cloudModel = self.dataSourceArr[indexPath.row];

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 90 + (kScreenWidth - 50) / 3 + 20;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        if (self.dataSourceArr.count > 0) {
            SYGrapherInfosViewController *grapherinfos = [[SYGrapherInfosViewController alloc] init];
            
            SYCloudModel *model = self.dataSourceArr[indexPath.row];
            grapherinfos.grapherID = model.ID;
            [self.navigationController pushViewController:grapherinfos animated:YES];
        }
    }
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

//加载搜索条
- (void)loadSearchBar{
    //添加取消返回按钮
    _cancleBtn = [[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth - 60, 5, 40, 30)];
    [_cancleBtn setTitle:@"取消" forState:UIControlStateNormal];
    [_cancleBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _cancleBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [_cancleBtn addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationController.navigationBar addSubview:_cancleBtn];
    
    _searchBar = [QTSearchBar searchBarWith:CGRectMake(15, 5, kScreenWidth - 80, 30)];
    _searchBar.returnKeyType = UIReturnKeySearch;
//    [_searchBar becomeFirstResponder];
    
    _searchBar.searchDelegate = self;
    self.navigationItem.leftBarButtonItem = nil;
    [self.navigationController.navigationBar addSubview:_searchBar];
    
}

- (void)keyBoardSearchWithText:(NSString *)text{
    if (text.length == 0) {
        return;
    }
    
    [self getDataWith:text];
}

- (void)getDataWith:(NSString *)text{
    NSString *url = [NSString stringWithFormat:@"%@%@",BaseUrl,@"/get/index.html"];
    NSDictionary *param = @{@"page":@1, @"keywords":text, @"type":@0};
    [[SYHttpRequest sharedInstance] getDataWithUrl:url Parameter:param ResponseObject:^(NSDictionary *responseResult) {
        [_searchBar resignFirstResponder];
        if ([_tableView.mj_header isRefreshing]) {
            [_tableView.mj_header endRefreshing];
        }
        NSLog(@"搜素结果 -- %@",responseResult);
        if ([responseResult objectForKey:@"resError"]) {
            
        }else{
            if ([[responseResult objectForKey:@"result"] integerValue] == 1) {
                _count = 1;
                if ([responseResult objectForKey:@"data"]) {
                    NSArray *data = [responseResult objectForKey:@"data"];
                    [self.tableView.mj_footer resetNoMoreData];
                    if (data.count > 0) {
                        [self.dataSourceArr removeAllObjects];
                        for (NSDictionary *dic in data) {
                            SYCloudModel *model = [SYCloudModel cloudWithDictionary:dic];
                            [self.dataSourceArr addObject:model];
                        }
                        [self.tableView removeFromSuperview];
                        [self.view addSubview:self.tableView];
                        [self.tableView reloadData];
                    }else{
                        [self.tableView removeFromSuperview];
                        [self loadFaildView];
                    }
                }
                
            }else{
                if ([responseResult objectForKey:@"msg"]) {
                    [self showHint:[responseResult objectForKey:@"msg"]];
                }
            }
        }
    }];
}

- (void)getMoreDataWith:(NSString *)text{
    _count ++;
    NSString *url = [NSString stringWithFormat:@"%@%@",BaseUrl,@"/get/index.html"];
    NSDictionary *param = @{@"page":[NSNumber numberWithInteger:_count], @"keywords":text, @"type":@0};
    [[SYHttpRequest sharedInstance] getDataWithUrl:url Parameter:param ResponseObject:^(NSDictionary *responseResult) {
        [_searchBar resignFirstResponder];
        NSLog(@"搜素结果 -- %@",responseResult);
        if ([responseResult objectForKey:@"resError"]) {
            _count --;
        }else{
            if ([[responseResult objectForKey:@"result"] integerValue] == 1) {
                if ([responseResult objectForKey:@"data"]) {
                    NSArray *data = [responseResult objectForKey:@"data"];
                    if (data.count < 10) {
                        _count --;
                        [_tableView.mj_footer endRefreshingWithNoMoreData];
                        for (NSDictionary *dic in data) {
                            SYCloudModel *model = [SYCloudModel cloudWithDictionary:dic];
                            [self.dataSourceArr addObject:model];
                        }
                        [self.tableView reloadData];
                        return ;
                    }
                    if (data.count > 0) {
                        
                        for (NSDictionary *dic in data) {
                            SYCloudModel *model = [SYCloudModel cloudWithDictionary:dic];
                            [self.dataSourceArr addObject:model];
                        }
                    }
                    
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

- (void)back:(UIButton *)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [_searchBar removeFromSuperview];
    [_cancleBtn removeFromSuperview];
    _searchBar = nil;
    _cancleBtn = nil;
}

- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight - kNavigationBarHeightAndStatusBarHeight) style:UITableViewStyleGrouped];
        _tableView.backgroundColor = BackGroundColor;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
            [self getDataWith:_searchBar.text];
        }];
        _tableView.mj_footer = [MJRefreshAutoStateFooter footerWithRefreshingBlock:^{
            [self getMoreDataWith:_searchBar.text];
        }];
        _tableView.mj_footer.automaticallyHidden = YES;
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
