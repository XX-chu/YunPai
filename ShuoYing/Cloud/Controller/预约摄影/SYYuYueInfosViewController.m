//
//  SYYuYueInfosViewController.m
//  ShuoYing
//
//  Created by chu on 2017/11/15.
//  Copyright © 2017年 硕影. All rights reserved.
//

#import "SYYuYueInfosViewController.h"
#import "SYYuYueInfosTableViewCell.h"
#import "SYTitleAndImageTableViewCell.h"
#import "SYCustomTableViewCell.h"
#import "SYYunPaiShiInfos.h"
#import "SYLiJiYuYueViewController.h"
@interface SYYuYueInfosViewController ()<UITableViewDelegate, UITableViewDataSource>
{
    NSString *_info;
    NSInteger _count;
    
    NSDictionary *_dataSourceDic;
    SYYunPaiShiInfos *_infos;
    
}
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataSourceArr;
@end

@implementation SYYuYueInfosViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _count = 1;
    [self.view addSubview:self.tableView];
    [self getSet];
    [self getData];
    [self initBottomView];
}

- (void)initBottomView{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, kScreenHeight - kNavigationBarHeightAndStatusBarHeight - 50, kScreenWidth, 50);
    [btn setTitle:@"立即预约" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn setBackgroundColor:NavigationColor];
    btn.titleLabel.font = [UIFont systemFontOfSize:17];
    [btn addTarget:self action:@selector(lijiyuyue:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
}

- (void)lijiyuyue:(UIButton *)sender{
    if (!_infos || self.dataSourceArr.count == 0) {
        return;
    }
    __weak typeof(self)weakself = self;
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:_infos.user message:@"温馨提示：\n电话咨询摄影师会大大提升预约成功的几率哦。建议您先电话咨询后再选择预约" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"电话咨询" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSMutableString *str=[[NSMutableString alloc] initWithFormat:@"tel:%@",_infos.user];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
    }];
    UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"已咨询去预约" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        SYLiJiYuYueViewController *yuyue = [[SYLiJiYuYueViewController alloc] init];
        yuyue.yuyueID = self.yunpaiID;
        yuyue.sheyingshiName = _infos.nick;
        yuyue.sheyingshiPhone = _infos.user;
        [weakself.navigationController pushViewController:yuyue animated:YES];
    }];
    [alert addAction:action1];
    [alert addAction:action];
    [weakself presentViewController:alert animated:YES completion:nil];

}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0 || section == 1) {
        return 1;
    }
    return self.dataSourceArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        static NSString *identifier = @"infosCell";
        SYYuYueInfosTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (!cell) {
            cell = [[NSBundle mainBundle] loadNibNamed:@"SYYuYueInfosTableViewCell" owner:self options:nil][0];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        if (_infos) {
            cell.infos = _infos;
        }
        return cell;
    }else if (indexPath.section == 2){
        static NSString *identifier = @"titleAndImageCell";
        SYTitleAndImageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (!cell) {
            cell = [[NSBundle mainBundle] loadNibNamed:@"SYTitleAndImageTableViewCell" owner:self options:nil][0];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        cell.delBtn.hidden = YES;

        __weak typeof(self)weakself = self;
        NSDictionary *dic = self.dataSourceArr[indexPath.row];
        NSString *infos = [dic objectForKey:@"info"];
        if (infos.length > 0) {
            cell.contentLabelHeightConstraint.constant = [[Tool sharedInstance] heightForString:infos andWidth:kScreenWidth - 26 fontSize:16];
        }else{
            cell.contentLabelHeightConstraint.constant = 0;
            
        }
        cell.contentLabel.text = [dic objectForKey:@"info"];
        
        UIImage *image = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:[NSString stringWithFormat:@"%@%@",ImgUrl,[dic objectForKey:@"img_min"]]];
        if (image) {
            cell.headImageView.image = image;
        }else{
            [cell.headImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",ImgUrl,[dic objectForKey:@"img_min"]]] placeholderImage:[UIImage imageNamed:@"shangchuan_wode_wutupian"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                [weakself.tableView reloadData];
            }];
        }
        
        return cell;
    }else{
        static NSString *identifier = @"customCell";
        SYCustomTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (!cell) {
            cell = [[NSBundle mainBundle] loadNibNamed:@"SYCustomTableViewCell" owner:self options:nil][0];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        cell.contentLabel.text = _info;

        return cell;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        return 85;
    }
    if (indexPath.section == 1) {
        CGFloat height = [[Tool sharedInstance] heightForString:_info andWidth:kScreenWidth - 26 fontSize:16];
        return height + 30;
    }
    if (indexPath.section == 2) {
        NSDictionary *dic = self.dataSourceArr[indexPath.row];
        NSString *str = [dic objectForKey:@"info"];
        CGFloat strHeight = [[Tool sharedInstance] heightForString:str andWidth:kScreenWidth - 26 fontSize:16];
        UIImage *image = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:[NSString stringWithFormat:@"%@%@",ImgUrl,[dic objectForKey:@"img_min"]]];
        
        if (image) {
            return ((kScreenWidth - 26) * image.size.height) / image.size.width + 25 + strHeight + 15;
        }
    }
    
    return 200;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return 0.00001f;
    }
    
    return 50;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = HexRGB(0xeaeaea);
    if (section == 2 || section == 1) {
        UIView *view1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 49)];
        view1.backgroundColor = [UIColor whiteColor];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(13, 14, (kScreenWidth - 26) / 2, 20)];
        label.font = [UIFont systemFontOfSize:16];
        label.textColor = HexRGB(0x444444);
        if (section == 1) {
            label.text = @"摄影师自述：";
        }else if (section == 2){
            label.text = @"摄影师作品展示：";
        }
        [view1 addSubview:label];
        
        [view addSubview:view1];
        
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 49, kScreenWidth, 1)];
        lineView.backgroundColor = HexRGB(0xeaeaea);
        [view addSubview:lineView];
    }
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

/**
 获取店铺设置
 */
- (void)getSet{
    
    [SVProgressHUD show];
    NSString *url = [NSString stringWithFormat:@"%@%@",BaseUrl,@"/masters/sel.html"];
    
    NSUserDefaults *us = [NSUserDefaults standardUserDefaults];
    NSNumber *jingdu = [us objectForKey:@"jingdu"];
    NSBundle *weidu = [us objectForKey:@"weidu"];
    NSDictionary *param = nil;
    if (jingdu && weidu) {
        param = @{@"lat":weidu, @"long":jingdu, @"id":self.yunpaiID};
    }else{
        param = @{@"id":self.yunpaiID};
    }
    
    [[SYHttpRequest sharedInstance] getDataWithUrl:url Parameter:param ResponseObject:^(NSDictionary *responseResult) {
        NSLog(@"获取云拍师设置 -- %@",responseResult);
        [SVProgressHUD dismiss];
        if ([responseResult objectForKey:@"resError"]) {
            [self showHint:@"服务器不给力，请稍后重试"];
        }else{
            if ([[responseResult objectForKey:@"result"] integerValue] == 1) {
                _dataSourceDic = [responseResult objectForKey:@"data"];
                SYYunPaiShiInfos *infos = [SYYunPaiShiInfos yunpaishiWithDicaionary:_dataSourceDic];
                _infos = infos;
                _info = [[responseResult objectForKey:@"data"] objectForKey:@"info"];

                [self.tableView reloadData];
                
            }else{
                if ([responseResult objectForKey:@"msg"] && ![[responseResult objectForKey:@"msg"] isKindOfClass:[NSNull class]]) {
                    [self showHint:[responseResult objectForKey:@"msg"]];
                }
            }
        }
    }];
}

/**
 获取数据
 */
- (void)getData{
    NSString *url = [NSString stringWithFormat:@"%@%@",BaseUrl,@"/masters/works.html"];
    NSDictionary *param = @{@"id":self.yunpaiID, @"page":@1};
    [[SYHttpRequest sharedInstance] getDataWithUrl:url Parameter:param ResponseObject:^(NSDictionary *responseResult) {
        NSLog(@"云拍师所有作品 -- %@",responseResult);
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
                [self.dataSourceArr addObjectsFromArray:data];
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
    NSString *url = [NSString stringWithFormat:@"%@%@",BaseUrl,@"/masters/works.html"];
    NSDictionary *param = @{@"id":self.yunpaiID, @"page":[NSNumber numberWithInteger:_count]};
    [[SYHttpRequest sharedInstance] getDataWithUrl:url Parameter:param ResponseObject:^(NSDictionary *responseResult) {
        NSLog(@"云拍师所有作品 -- %@",responseResult);
        if ([self.tableView.mj_footer isRefreshing]) {
            [self.tableView.mj_footer endRefreshing];
        }
        if ([responseResult objectForKey:@"resError"]) {
            _count --;
            [self showHint:@"服务器不给力，请稍后重试"];
        }else{
            if ([[responseResult objectForKey:@"result"] integerValue] == 1) {
                NSArray *data = [responseResult objectForKey:@"data"];
                [self.dataSourceArr addObjectsFromArray:data];
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
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight - kNavigationBarHeightAndStatusBarHeight - 50) style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.backgroundColor = HexRGB(0xeaeaea);
        _tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
            [self getSet];
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

@end
