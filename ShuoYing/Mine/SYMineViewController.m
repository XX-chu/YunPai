//
//  SYMineViewController.m
//  ShuoYing
//
//  Created by 硕影 on 2016/12/26.
//  Copyright © 2016年 硕影. All rights reserved.
//

#import "SYMineViewController.h"
#import "SYMineTableViewCell.h"
#import "SYUserInfos.h"

#import "SYUserInfosViewController.h"
#import "SYMyWalletViewController.h" //我的钱包
#import "SYRecordsViewController.h" //交易记录
#import "SYAddressViewController.h" //收货地址
#import "SYSettingViewController.h" //设置
#import "SYIDViewController.h" //绑定身份证
#import "SYErWeiMaViewController.h"//分享二维码
#import "SYOrderViewController.h"//订单
#import "SYShopcartViewController.h"//购物车
#import "SYMyGuanZhuViewController.h"//我的关注
const static CGFloat totleOffset = 200;

@interface SYMineViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    UIImageView *_headImageView;
    UILabel *_nickNameLabel;
    UILabel *_phoneLabel;
    SYUserInfos *_userInfos;
}

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) UIImageView *upImageView;

@property (nonatomic, strong) NSMutableArray *cellDataSource;

@property (nonatomic, strong) NSMutableArray *cellImages;

// 记录起始总偏移量
@property (nonatomic, assign) CGFloat totalOffsetY;

@end

@implementation SYMineViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
//    self.tabBarController.navigationController.navigationBar.translucent = YES;
//    self.tabBarController.navigationItem.leftBarButtonItem = nil;
//    self.tabBarController.navigationItem.rightBarButtonItem = nil;
//    self.tabBarController.navigationItem.titleView = nil;
//    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
//    self.navigationController.navigationBar.shadowImage = [UIImage new];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    //取出用户信息
    if ([[Tool sharedInstance] getObjectWithPath:[NSString stringWithFormat:@"%@",Mobile]]) {
        _userInfos = [[Tool sharedInstance] getObjectWithPath:[NSString stringWithFormat:@"%@",Mobile]];
        _phoneLabel.text = _userInfos.info;
        _nickNameLabel.text = _userInfos.nick;
        [_headImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",ImgUrl,_userInfos.head]] placeholderImage:[UIImage imageNamed:@"shezhi_photo_photo"]];
        
        [self.tableView reloadData];
        [self loadUpImageViewSubViews];
    }
}

- (void)viewWillDisappear:(BOOL)animated{
    
//    self.tabBarController.navigationController.navigationBar.translucent = NO;
//    [self.tabBarController.navigationController.navigationBar setBackgroundImage:[UIImage imageWithColor:NavigationColor Size:CGSizeMake(kScreenWidth, 64)] forBarMetrics:UIBarMetricsDefault];
//    self.tabBarController.navigationController.navigationBar.shadowImage = [UIImage imageWithColor:NavigationColor Size:CGSizeMake(kScreenWidth, 1)];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    //取出用户信息
    

    if ([[Tool sharedInstance] getObjectWithPath:[NSString stringWithFormat:@"%@",Mobile]]) {
        _userInfos = [[Tool sharedInstance] getObjectWithPath:[NSString stringWithFormat:@"%@",Mobile]];
        NSLog(@"_userInfos.user - %@",_userInfos.user);
        NSLog(@"_userInfos.nick - %@",_userInfos.nick);
        NSLog(@"_userInfos.head - %@",_userInfos.head);
    }
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.totalOffsetY = -totleOffset;

    [self.view addSubview:self.tableView];
    [self.tableView addSubview:self.upImageView];
    
    
}


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.cellDataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"cell";
    SYMineTableViewCell *cell = [[NSBundle mainBundle] loadNibNamed:@"SYMineTableViewCell" owner:nil options:nil][0];

    if (!cell) {
        cell = [[SYMineTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    cell.cellNameLabel.text = self.cellDataSource[indexPath.row];
    cell.cellImageView.image = [UIImage imageNamed:self.cellImages[indexPath.row]];
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 3) {
        //我的钱包
        SYMyWalletViewController *mywallet = [[SYMyWalletViewController alloc] init];
        [self.navigationController pushViewController:mywallet animated:YES];
    }else if (indexPath.row == 4){
        //交易记录
        SYRecordsViewController *recordVC = [[SYRecordsViewController alloc] init];
        [self.navigationController pushViewController:recordVC animated:YES];
    }else if (indexPath.row == 5){
        //地址管理
        SYAddressViewController *addressVC = [[SYAddressViewController alloc] init];
        [self.navigationController pushViewController:addressVC animated:YES];
    }else if (indexPath.row == 9999){
        //绑定身份证
        SYIDViewController *ID = [[SYIDViewController alloc] initWithNibName:@"SYIDViewController" bundle:nil];
        [self.navigationController pushViewController:ID animated:YES];
    }else if (indexPath.row == 6){
        //分享二维码
        SYErWeiMaViewController *erweima = [[SYErWeiMaViewController alloc] init];
        [self.navigationController pushViewController:erweima animated:YES];
    }else if (indexPath.row == 7){
        //设置
        SYSettingViewController *set = [[SYSettingViewController alloc] init];
        [self.navigationController pushViewController:set animated:YES];
    }else if (indexPath.row == 1){
        //订单
        SYOrderViewController *order = [[SYOrderViewController alloc] init];
        [self.navigationController pushViewController:order animated:YES];
    }else if (indexPath.row == 2){
        SYShopcartViewController *shopcart = [[SYShopcartViewController alloc] init];
        [self.navigationController pushViewController:shopcart animated:YES];
    }else if(indexPath.row == 0){
        //我的关注
        SYMyGuanZhuViewController *guanzhu = [[SYMyGuanZhuViewController alloc] init];
        [self.navigationController pushViewController:guanzhu animated:YES];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    /**
     * 处理头部视图
     */
    //获取滚动视图y值的偏移量
    CGFloat offsetY = self.tableView.contentOffset.y;
    
    // 计算tabView滚动的偏移量
    CGFloat delta = offsetY - self.totalOffsetY;
    
    CGFloat height = totleOffset - delta;
    height = height < 0 ? 0 : height;
    
    if(offsetY < -totleOffset) {
        
        CGRect f = self.upImageView.frame;
        f.origin.y= offsetY ;
        f.size.height=  -offsetY;
        f.origin.y= offsetY;
        
        //改变头部视图的fram
        self.upImageView.frame= f;
        [self loadUpImageViewSubViews];
    }
}



- (void)loadUpImageViewSubViews{
    
    
//    NSArray *lines = [[Tool sharedInstance] getLinesArrayOfStringWithString:_phoneLabel.text Font:[UIFont systemFontOfSize:13] Rect:CGRectMake(0, 0, kScreenWidth - 40, 0)];
//    if (lines.count == 1 || lines.count == 0) {
//        
//    }else{
//        _phoneLabel.frame = CGRectMake(20, _upImageView.frame.size.height - 45, kScreenWidth - 40, 35);
//    }
    _phoneLabel.frame = CGRectMake(20, _upImageView.frame.size.height - 35, kScreenWidth - 40, 15);
    
    _nickNameLabel.frame = CGRectMake(0, CGRectGetMinY(_phoneLabel.frame) - 25, kScreenWidth, 20);
    
    
    _headImageView.frame = CGRectMake((kScreenWidth - 90) / 2, CGRectGetMinY(_nickNameLabel.frame) - 105, 90, 90);
    
}

- (void)userInfosAction:(UITapGestureRecognizer *)tap{
    SYUserInfosViewController *userinfo = [[SYUserInfosViewController alloc] initWithNibName:@"SYUserInfosViewController" bundle:nil];
    [self.navigationController pushViewController:userinfo animated:YES];
}

#pragma mark - layzLoad
- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight - 44)];
        [_tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = BackGroundColor;
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.contentOffset = CGPointMake(0, totleOffset);
        _tableView.contentInset = UIEdgeInsetsMake(totleOffset,0, 0, 0);
    }
    return _tableView;
}

-(UIImageView *)upImageView
{
    if (_upImageView == nil)
    {
        _upImageView= [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"wode_bg"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
        _upImageView.frame=CGRectMake(0, -totleOffset ,kScreenWidth,totleOffset);
        _upImageView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userInfosAction:)];
        [_upImageView addGestureRecognizer:tap];
        
        _phoneLabel = [[UILabel alloc] init];
        _phoneLabel.textAlignment = NSTextAlignmentCenter;
        if (_userInfos.info == nil || [_userInfos.info isEqualToString:@""] || [_userInfos.info isKindOfClass:[NSNull class]]) {
            _phoneLabel.text = @"";
        }else{
            _phoneLabel.text = _userInfos.info;
        }
        
        _phoneLabel.font = [UIFont systemFontOfSize:13];
        _phoneLabel.frame = CGRectMake(20, _upImageView.frame.size.height - 35, kScreenWidth - 40, 15);
//        NSArray *lines = [[Tool sharedInstance] getLinesArrayOfStringWithString:_phoneLabel.text Font:[UIFont systemFontOfSize:13] Rect:CGRectMake(0, 0, kScreenWidth - 40, 0)];
//        if (lines.count == 1 || lines.count == 0) {
//            
//        }else{
//            _phoneLabel.frame = CGRectMake(20, _upImageView.frame.size.height - 45, kScreenWidth - 40, 35);
//        }
        [_upImageView addSubview:_phoneLabel];
        
        _nickNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMinY(_phoneLabel.frame) - 25, kScreenWidth, 20)];
        _nickNameLabel.textAlignment = NSTextAlignmentCenter;
        _nickNameLabel.text = _userInfos.nick;
        _nickNameLabel.font = [UIFont systemFontOfSize:17];
        [_upImageView addSubview:_nickNameLabel];
        
        _headImageView = [[UIImageView alloc] initWithFrame:CGRectMake((kScreenWidth - 90) / 2, CGRectGetMinY(_nickNameLabel.frame) - 105, 90, 90)];
        _headImageView.layer.cornerRadius = 45;
        _headImageView.layer.masksToBounds = YES;
        [_headImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",ImgUrl,_userInfos.head]] placeholderImage:[UIImage imageNamed:@"shezhi_photo_photo"]];
        [_upImageView addSubview:_headImageView];
        
    }
    return _upImageView;
}

- (NSMutableArray *)cellDataSource{
    if (!_cellDataSource) {
        _cellDataSource = [NSMutableArray arrayWithCapacity:0];
        [_cellDataSource addObject:@"我的关注"];
        [_cellDataSource addObject:@"我的订单"];
        [_cellDataSource addObject:@"购物车"];
        [_cellDataSource addObject:@"我的钱包"];
        [_cellDataSource addObject:@"交易记录"];
        [_cellDataSource addObject:@"地址管理"];
        [_cellDataSource addObject:@"分享二维码"];
        [_cellDataSource addObject:@"设置"];
        
    }
    return _cellDataSource;
}

- (NSMutableArray *)cellImages{
    if (!_cellImages) {
        _cellImages = [NSMutableArray arrayWithCapacity:0];
        [_cellImages addObject:@"wode_icon_attention"];
        [_cellImages addObject:@"wode_icon_dingdan"];
        [_cellImages addObject:@"wode_icon_gouwuche"];
        [_cellImages addObject:@"wode_icon_qianbao"];
        [_cellImages addObject:@"wode_icon_jiaoyi"];
        [_cellImages addObject:@"wode_icon_dizhi"];
        [_cellImages addObject:@"wode_icon_fenxiang"];
        [_cellImages addObject:@"wode_icon_shezhi"];
        
    }
    return _cellImages;
}


@end
