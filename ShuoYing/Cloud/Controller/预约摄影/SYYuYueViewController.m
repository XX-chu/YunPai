//
//  SYYuYueViewController.m
//  ShuoYing
//
//  Created by chu on 2017/11/14.
//  Copyright © 2017年 硕影. All rights reserved.
//

#import "SYYuYueViewController.h"
#import "JSDropDownMenu.h"
#import "SYYuYueModel.h"
#import "SYYuYueTableViewCell.h"
#import "SYYuYueInfosViewController.h"
#import "SYMyYuYueViewController.h"
@interface SYYuYueViewController ()<JSDropDownMenuDelegate, JSDropDownMenuDataSource, UITableViewDataSource, UITableViewDelegate>
{
    NSInteger _currentIndex;
    NSInteger _count;
}

@property (nonatomic, strong) JSDropDownMenu *menu;
@property (nonatomic, strong) NSMutableArray *menuArr;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataSourceArr;

@end

@implementation SYYuYueViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"预约摄影";
    _currentIndex = 0;
    _count = 1;
    [self.view addSubview:self.menu];
    [self.view addSubview:self.tableView];
    [self.tableView.mj_header beginRefreshing];
    [self initRightBarItem];
}

- (void)initRightBarItem{
    UIButton *done = [UIButton buttonWithType:UIButtonTypeCustom];
    done.frame = CGRectMake(0, 0, 70, 44);
    [done setTitle:@"我的预约" forState:UIControlStateNormal];
    [done setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    done.titleLabel.font = [UIFont systemFontOfSize:16];
    [done addTarget:self action:@selector(myYuYueAction:) forControlEvents:UIControlEventTouchUpInside];
    [done setTitleEdgeInsets:UIEdgeInsetsMake(0, 10, 0, -10)];
    UIBarButtonItem *right = [[UIBarButtonItem alloc] initWithCustomView:done];
    self.navigationItem.rightBarButtonItem = right;
}

- (void)myYuYueAction:(UIButton *)sender{
    SYMyYuYueViewController *yuyue = [[SYMyYuYueViewController alloc] init];
    [self.navigationController pushViewController:yuyue animated:YES];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    SYYuYueModel *model = self.dataSourceArr[indexPath.section];
    SYYuYueInfosViewController *infos = [[SYYuYueInfosViewController alloc] init];
    infos.title = [NSString stringWithFormat:@"%@的云拍店",model.nick];
    infos.yunpaiID = model.yuyueID;
    [self.navigationController pushViewController:infos animated:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.dataSourceArr.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"yuyueCell";
    SYYuYueTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[NSBundle mainBundle] loadNibNamed:@"SYYuYueTableViewCell" owner:nil options:nil][0];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    cell.model = self.dataSourceArr[indexPath.section];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return (kScreenWidth - 118) * 62 / 227 + 140;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 10;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = HexRGB(0xefefef);
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.00001f;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = HexRGB(0xefefef);
    return view;
}

#pragma mark - pullViewDelegate
- (NSInteger)numberOfColumnsInMenu:(JSDropDownMenu *)menu {
    
    return 1;
}

-(BOOL)displayByCollectionViewInColumn:(NSInteger)column{
    
    return NO;
}

-(BOOL)haveRightTableViewInColumn:(NSInteger)column{
    
    return NO;
}

-(CGFloat)widthRatioOfLeftColumn:(NSInteger)column{
    
    return 1;
}

-(NSInteger)currentLeftSelectedRow:(NSInteger)column{
    return self.menuArr.count;
}

- (NSInteger)menu:(JSDropDownMenu *)menu numberOfRowsInColumn:(NSInteger)column leftOrRight:(NSInteger)leftOrRight leftRow:(NSInteger)leftRow{
    
    return self.menuArr.count;
}

- (NSString *)menu:(JSDropDownMenu *)menu titleForColumn:(NSInteger)column{
    
    return self.menuArr[_currentIndex];
}

- (NSString *)menu:(JSDropDownMenu *)menu titleForRowAtIndexPath:(JSIndexPath *)indexPath {
    
    return self.menuArr[indexPath.row];
}

- (void)menu:(JSDropDownMenu *)menu didSelectRowAtIndexPath:(JSIndexPath *)indexPath {
    _currentIndex = indexPath.row;
    [self getData];
}

- (void)getData{
    NSString *url = [NSString stringWithFormat:@"%@%@",BaseUrl,@"/masters/select.html"];
    NSUserDefaults *us = [NSUserDefaults standardUserDefaults];
    NSNumber *jingdu = [us objectForKey:@"jingdu"];
    NSBundle *weidu = [us objectForKey:@"weidu"];
    NSDictionary *param = nil;
    if (jingdu && weidu) {
        param = @{@"lat":weidu, @"long":jingdu, @"page":@1, @"order":self.menuArr[_currentIndex]};
    }else{
        param = @{@"page":@1, @"order":self.menuArr[_currentIndex]};
    }
    [[SYHttpRequest sharedInstance] getDataWithUrl:url Parameter:param ResponseObject:^(NSDictionary *responseResult) {
        NSLog(@"云拍店列表 -- %@",responseResult);
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
                    SYYuYueModel *model = [SYYuYueModel yuyueWithDicaionary:dic];
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
    NSString *url = [NSString stringWithFormat:@"%@%@",BaseUrl,@"/masters/select.html"];
    NSUserDefaults *us = [NSUserDefaults standardUserDefaults];
    NSNumber *jingdu = [us objectForKey:@"jingdu"];
    NSBundle *weidu = [us objectForKey:@"weidu"];
    NSDictionary *param = nil;
    if (jingdu && weidu) {
        param = @{@"lat":weidu, @"long":jingdu, @"page":[NSNumber numberWithInteger:_count], @"order":self.menuArr[_currentIndex]};
    }else{
        param = @{@"page":[NSNumber numberWithInteger:_count], @"order":self.menuArr[_currentIndex]};
    }
    [[SYHttpRequest sharedInstance] getDataWithUrl:url Parameter:param ResponseObject:^(NSDictionary *responseResult) {
        NSLog(@"云拍店列表 -- %@",responseResult);
        if ([self.tableView.mj_footer isRefreshing]) {
            [self.tableView.mj_footer endRefreshing];
        }
        if ([responseResult objectForKey:@"resError"]) {
            [self showHint:@"服务器不给力，请稍后重试"];
            _count --;
        }else{
            if ([[responseResult objectForKey:@"result"] integerValue] == 1) {
                NSArray *data = [responseResult objectForKey:@"data"];
                for (NSDictionary *dic in data) {
                    SYYuYueModel *model = [SYYuYueModel yuyueWithDicaionary:dic];
                    [self.dataSourceArr addObject:model];
                }
                [self.tableView reloadData];
            }else{
                if ([responseResult objectForKey:@"msg"] && ![[responseResult objectForKey:@"msg"] isKindOfClass:[NSNull class]]) {
                    _count--;
                    [self showHint:[responseResult objectForKey:@"msg"]];
                }
            }
        }
    }];
}



- (JSDropDownMenu *)menu{
    if (!_menu) {
        _menu = [[JSDropDownMenu alloc] initWithOrigin:CGPointMake(0, 0) andHeight:47];
        _menu.indicatorColor = [UIColor colorWithRed:175.0f/255.0f green:175.0f/255.0f blue:175.0f/255.0f alpha:1.0];
        _menu.separatorColor = [UIColor colorWithRed:241.0f/255.0f green:241.0f/255.0f blue:241.0f/255.0f alpha:1.0];
        _menu.textColor = [UIColor colorWithRed:83.f/255.0f green:83.f/255.0f blue:83.f/255.0f alpha:1.0f];
        _menu.dataSourceArr = @[self.menuArr];
        _menu.dataSource = self;
        _menu.delegate = self;
    }
    return _menu;
}

- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 47, kScreenWidth, kScreenHeight - kNavigationBarHeightAndStatusBarHeight - 47) style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.backgroundColor = HexRGB(0xefefef);
        _tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
            [self getData];
        }];
        _tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
            [self getMoreData];
            
        }];
    }
    return _tableView;
}

- (NSMutableArray *)menuArr{
    if (!_menuArr) {
        _menuArr = [NSMutableArray arrayWithCapacity:0];
        [_menuArr addObject:@"离我最近"];
        [_menuArr addObject:@"好评优先"];
        [_menuArr addObject:@"价格从低到高"];
        [_menuArr addObject:@"价格从高到低"];

    }
    return _menuArr;
}

- (NSMutableArray *)dataSourceArr{
    if (!_dataSourceArr) {
        _dataSourceArr = [NSMutableArray arrayWithCapacity:0];
    }
    return _dataSourceArr;
}

@end
