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
#import "SYMyFaBuViewController.h"//我的发布
#import "SYCertifieYunPaiShiViewController.h"//认证云拍师
#import "SYMyYunPaiShopViewController.h"//我的云拍店
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
    [self getUserInfos];
    
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
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    //取出用户信息
    

    if ([[Tool sharedInstance] getObjectWithPath:[NSString stringWithFormat:@"%@",Mobile]]) {
        _userInfos = [[Tool sharedInstance] getObjectWithPath:[NSString stringWithFormat:@"%@",Mobile]];
    }
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.totalOffsetY = -totleOffset;

    [self.view addSubview:self.tableView];
    [self.tableView addSubview:self.upImageView];
    
    
}


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.cellDataSource.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSArray *arr = self.cellDataSource[section];
    return arr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"cell";
    SYMineTableViewCell *cell = [[NSBundle mainBundle] loadNibNamed:@"SYMineTableViewCell" owner:nil options:nil][0];

    if (!cell) {
        cell = [[SYMineTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    NSArray *titleArr = self.cellDataSource[indexPath.section];
    NSArray *imageArr = self.cellImages[indexPath.section];
    
    cell.cellNameLabel.text = titleArr[indexPath.row];
    if (indexPath.section == 0 && indexPath.row == 2) {
        if ([_userInfos.master integerValue] == 1) {
            //认证通过
            cell.cellNameLabel.text = @"我的云拍店";
        }
    }
    cell.cellImageView.image = [UIImage imageNamed:imageArr[indexPath.row]];
    if (indexPath.row == titleArr.count - 1) {
        cell.lineView.hidden = YES;
    }
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 15;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = HexRGB(0xefefef);
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            //我的关注
            SYMyGuanZhuViewController *guanzhu = [[SYMyGuanZhuViewController alloc] init];
            [self.navigationController pushViewController:guanzhu animated:YES];
        }else if (indexPath.row == 1){
            //分享二维码
            SYErWeiMaViewController *erweima = [[SYErWeiMaViewController alloc] init];
            [self.navigationController pushViewController:erweima animated:YES];

        }else{
            //我的云拍店
            if ([_userInfos.master integerValue] == 1) {
                SYMyYunPaiShopViewController *shop = [[SYMyYunPaiShopViewController alloc] init];
                [self.navigationController pushViewController:shop animated:YES];
            }else{
                if ([_userInfos.idcard integerValue] == 1) {
                    SYCertifieYunPaiShiViewController *renzheng = [[SYCertifieYunPaiShiViewController alloc] init];
                    [self.navigationController pushViewController:renzheng animated:YES];
                }else{
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"您的账号还没有绑定身份证，请绑定身份证 后再认证云拍师" preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *action = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                        
                    }];
                    UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"去绑定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                        SYIDViewController *idvc = [[SYIDViewController alloc] init];
                        idvc.state = isFromYunPaiShi;
                        [self.navigationController pushViewController:idvc animated:YES];
                    }];
                    
                    [alert addAction:action];
                    [alert addAction:action1];
                    [self presentViewController:alert animated:YES completion:nil];
                    
                }
                
            }
        }
    }else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            //订单
            SYOrderViewController *order = [[SYOrderViewController alloc] init];
            [self.navigationController pushViewController:order animated:YES];
        }else if (indexPath.row == 1){
            //我的钱包
            SYMyWalletViewController *mywallet = [[SYMyWalletViewController alloc] init];
            [self.navigationController pushViewController:mywallet animated:YES];
        }else{
            //交易记录
            SYRecordsViewController *recordVC = [[SYRecordsViewController alloc] init];
            [self.navigationController pushViewController:recordVC animated:YES];
        }
    }else{
        if (indexPath.row == 0) {
            //地址管理
            SYAddressViewController *addressVC = [[SYAddressViewController alloc] init];
            [self.navigationController pushViewController:addressVC animated:YES];
        }else{
            //设置
            SYSettingViewController *set = [[SYSettingViewController alloc] init];
            [self.navigationController pushViewController:set animated:YES];
        }
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

    _phoneLabel.frame = CGRectMake(20, _upImageView.frame.size.height - 35, kScreenWidth - 40, 15);
    
    _nickNameLabel.frame = CGRectMake(0, CGRectGetMinY(_phoneLabel.frame) - 25, kScreenWidth, 20);
    
    
    _headImageView.frame = CGRectMake((kScreenWidth - 90) / 2, CGRectGetMinY(_nickNameLabel.frame) - 105, 90, 90);
    
}

- (void)userInfosAction:(UITapGestureRecognizer *)tap{
    SYUserInfosViewController *userinfo = [[SYUserInfosViewController alloc] initWithNibName:@"SYUserInfosViewController" bundle:nil];
    [self.navigationController pushViewController:userinfo animated:YES];
}

#pragma mark - 获取用户数据
- (void)getUserInfos{
    
    NSString *url = [NSString stringWithFormat:@"%@%@",BaseUrl,@"/user/user.html"];
    NSDictionary *param = @{@"token":UserToken};
    [[SYHttpRequest sharedInstance] getDataWithUrl:url Parameter:param ResponseObject:^(NSDictionary *responseResult) {
        [SVProgressHUD dismiss];
        NSLog(@"获取用户信息 -- %@",responseResult);
        if ([responseResult objectForKey:@"resError"]) {

        }else{
            if ([[responseResult objectForKey:@"result"] integerValue] == 1) {
                NSDictionary *data = [responseResult objectForKey:@"data"];
                SYUserInfos *userinfos = [SYUserInfos userinfosWithDictionry:data];
                _userInfos = userinfos;
                //归档
                [[Tool sharedInstance] saveObject:userinfos WithPath:[NSString stringWithFormat:@"%@",Mobile]];
                [self.tableView reloadData];
            }else{
                if ([responseResult objectForKey:@"msg"]) {

                }
            }
        }
    }];
}


#pragma mark - layzLoad
- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight - kTabbarHeight) style:UITableViewStylePlain];
        [_tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = HexRGB(0xefefef);
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
        NSArray *arr1 = @[@"我的关注", @"我的分享", @"认证云拍师"];
        NSArray *arr2 = @[@"我的订单", @"我的钱包", @"交易记录"];
        NSArray *arr3 = @[@"地址管理", @"设置"];
        [_cellDataSource addObject:arr1];
        [_cellDataSource addObject:arr2];
        [_cellDataSource addObject:arr3];

        
    }
    return _cellDataSource;
}

- (NSMutableArray *)cellImages{
    if (!_cellImages) {
        _cellImages = [NSMutableArray arrayWithCapacity:0];
        
        NSArray *arr1 = @[@"wode_icon_attention", @"wode_icon_fenxiang", @"yunpaishi"];
        NSArray *arr2 = @[@"wode_icon_dingdan", @"wode_icon_qianbao", @"wode_icon_jiaoyi"];
        NSArray *arr3 = @[@"wode_icon_dizhi", @"wode_icon_shezhi"];
        [_cellImages addObject:arr1];
        [_cellImages addObject:arr2];
        [_cellImages addObject:arr3];
        
    }
    return _cellImages;
}


@end
