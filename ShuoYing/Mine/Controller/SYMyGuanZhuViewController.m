//
//  SYMyGuanZhuViewController.m
//  ShuoYing
//
//  Created by 硕影 on 2017/7/7.
//  Copyright © 2017年 硕影. All rights reserved.
//

#import "SYMyGuanZhuViewController.h"
#import "SYCloudZanTableViewCell.h"
#import "SYChakanGrapherViewController.h"
@interface SYMyGuanZhuViewController ()<UITableViewDelegate, UITableViewDataSource>
{
    NSInteger _count;
}

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, copy) NSMutableArray *dataSourceArr;

@property (nonatomic, strong) UIView *noZanView;

@end

@implementation SYMyGuanZhuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"我的关注";
    _count = 1;
    [self.view addSubview:self.tableView];
    [self getData];
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.dataSourceArr.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"guanzhuCell";
    SYCloudZanTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[NSBundle mainBundle] loadNibNamed:@"SYCloudZanTableViewCell" owner:nil options:nil][0];
    }
    NSDictionary *dic = self.dataSourceArr[indexPath.section];
    
    [cell.headImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",ImgUrl, [dic objectForKey:@"head"]]] placeholderImage:NoPicture];
    cell.nicknameLabel.text = [dic objectForKey:@"nick"];
    cell.introLabel.text = [dic objectForKey:@"info"];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 97;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 14;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.0001f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
//    跳转作品集
    SYChakanGrapherViewController *chakan = [[SYChakanGrapherViewController alloc] init];
    chakan.isFromMyGuanZhu = YES;
    chakan.userDic = self.dataSourceArr[indexPath.section];
    chakan.title = [self.dataSourceArr[indexPath.section] objectForKey:@"nick"];
    [self.navigationController pushViewController:chakan animated:YES];
}

- (void)getData{
    
    [SVProgressHUD show];
    NSString *url = [NSString stringWithFormat:@"%@%@",BaseUrl,@"/my/follow_list.html"];
    NSDictionary *param = @{@"token":UserToken, @"page":@1};
    [[SYHttpRequest sharedInstance] getDataWithUrl:url Parameter:param ResponseObject:^(NSDictionary *responseResult) {
        [SVProgressHUD dismiss];
        _count = 1;
        if ([self.tableView.mj_header isRefreshing]) {
            [self.tableView.mj_header endRefreshing];
        }
        NSLog(@"关注列表 -- %@",responseResult);
        if ([responseResult objectForKey:@"resError"]) {
            [self showHint:@"服务器不给力，请稍后重试"];
        }else{
            if ([[responseResult objectForKey:@"result"] integerValue] == 1) {
                
                NSArray *data = [responseResult objectForKey:@"data"];
                
                if (data.count == 0) {
                    [self.view addSubview:self.noZanView];
                    self.tableView.hidden = YES;
                    
                }else{
                    if (self.noZanView) {
                        [self.noZanView removeFromSuperview];
                    }
                    self.tableView.hidden = NO;
                }
                if (data.count >= 10) {
                    [_tableView.mj_footer resetNoMoreData];
                }else{
                    [_tableView.mj_footer endRefreshingWithNoMoreData];
                }
                if (data.count > 0) {
                    [self.dataSourceArr removeAllObjects];
                    [self.dataSourceArr addObjectsFromArray:data];
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
    NSString *url = [NSString stringWithFormat:@"%@%@",BaseUrl,@"/my/follow_list.html"];
    NSDictionary *param = @{@"token":UserToken, @"page":[NSNumber numberWithInteger:_count]};
    [[SYHttpRequest sharedInstance] getDataWithUrl:url Parameter:param ResponseObject:^(NSDictionary *responseResult) {
        
        NSLog(@"关注列表 -- %@",responseResult);
        if ([responseResult objectForKey:@"resError"]) {
            [self showHint:@"服务器不给力，请稍后重试"];
            _count--;
        }else{
            if ([[responseResult objectForKey:@"result"] integerValue] == 1) {
                
                NSArray *data = [responseResult objectForKey:@"data"];
                if (data.count >= 10) {
                    [_tableView.mj_footer resetNoMoreData];
                }else{
                    [_tableView.mj_footer endRefreshingWithNoMoreData];
                }
                if (data.count > 0) {
                    NSArray *data = [responseResult objectForKey:@"data"];
                    [self.dataSourceArr addObjectsFromArray:data];
                }
                
                [self.tableView reloadData];
                
            }else{
                _count--;
                if ([responseResult objectForKey:@"msg"]) {
                    [self showHint:[responseResult objectForKey:@"msg"]];
                }
            }
        }
    }];
}


- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight - kNavigationBarHeightAndStatusBarHeight) style:UITableViewStyleGrouped];
        self.tableView.backgroundColor = RGB(234, 234, 234);
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.showsHorizontalScrollIndicator = NO;
        _tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
            [self getData];
        }];
        _tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
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

- (UIView *)noZanView{
    if (!_noZanView) {
        _noZanView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 300)];
        imageView.contentMode = UIViewContentModeCenter;
        imageView.image = [UIImage imageNamed:@"shouye_oneself_noattention"];
        [_noZanView addSubview:imageView];
    }
    return _noZanView;
}

@end
