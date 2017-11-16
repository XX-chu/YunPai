//
//  SYUpdatePhotographerViewController.m
//  ShuoYing
//
//  Created by 硕影 on 2016/12/29.
//  Copyright © 2016年 硕影. All rights reserved.
//

#import "SYUpdatePhotographerViewController.h"

#import "SYUserInfos.h"
#import "SYPhotographerView.h"

#import "SYGrapherCertifiedViewController.h"

#import "SYGrapherUpdataPhotoViewController.h"

#import "SYGrapherUpdatePhotoToCloudViewController.h"

#import "SYIDViewController.h"

#import "SYPhotoGrapherSetPriceViewController.h"

#import "SYUpdateGrapherCollectionViewCell.h"
#import "SYUpdateGrapherHeaderCollectionReusableView.h"
#import "SYUpdateGrapherFooterCollectionReusableView.h"

#import "SYGrapherUpdateHistoryViewController.h"

@interface SYUpdatePhotographerViewController ()<UICollectionViewDelegate, UICollectionViewDataSource>
{
    SYUserInfos *_userInfos;
    UICollectionView *_collectionView;
    NSInteger _count;
}

@property (nonatomic, strong) NSMutableArray *dataSourceArr;

@property (nonatomic, strong) SYPhotographerView *grapherView;

@end

static NSString *identifier = @"cell";
static NSString *headerIdentifier = @"header";
static NSString *footerIdentifier = @"footer";

@implementation SYUpdatePhotographerViewController

- (void)loadView{
    [super loadView];
    [self.view.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    if ([[Tool sharedInstance] getObjectWithPath:Mobile]) {
        _userInfos = [[Tool sharedInstance] getObjectWithPath:Mobile];
        NSLog(@"_userInfos - %@",_userInfos);

        switch ([_userInfos.pho integerValue]) {
            case 0:
            {//禁用
                [self jinyong];
            }
                break;
            case 1:
            {//认证通过，是老师
                [self alreadyCertified];
                [self getDataFromCache];
                [self getDate];
            }
                break;
            case 2:
            {//认证位通过，重新申请
                [self notCertified];
            }
                break;
            case 3:
            {//认证中...
                [self beingCertified];
            }
                break;
                
            default:
                break;
        }
        
        
        
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = BackGroundColor;
    self.view.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight - kNavigationBarHeightAndStatusBarHeight - 40);
    
    _count = 1;
}

- (void)getDataFromCache{
    if ([XHNetworkCache cacheJsonWithURL:[NSString stringWithFormat:@"%@/%@",Mobile,@"GrapherHistory"]]) {
        NSDictionary *responseResult = [XHNetworkCache cacheJsonWithURL:[NSString stringWithFormat:@"%@/%@",Mobile,@"GrapherHistory"]];
        
        if ([responseResult objectForKey:@"data"]) {
            [self.dataSourceArr removeAllObjects];
            [self.dataSourceArr addObjectsFromArray:[responseResult objectForKey:@"data"]];
            
            self.grapherView.updateHistoryLabel.text = [NSString stringWithFormat:@"传送历史：(%d)",[[responseResult objectForKey:@"count"] intValue]];
        }
        [_collectionView reloadData];
    }
    
}

//禁用
- (void)jinyong{
    
    UIImageView *backImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 30, kScreenWidth, 200)];
    backImageView.contentMode = UIViewContentModeScaleAspectFit;
    backImageView.image = [UIImage imageNamed:@"shenfen_jinzhi"];
    [self.view addSubview:backImageView];
    
}

//未认证
- (void)notCertified{
    UIImageView *backImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 200)];
    backImageView.contentMode = UIViewContentModeScaleAspectFit;
    backImageView.image = [UIImage imageNamed:@"renzheng"];
    [self.view addSubview:backImageView];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(backImageView.frame) + 20, kScreenWidth, 20)];
    label.font = [UIFont systemFontOfSize:16];
    label.textColor = [UIColor darkGrayColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = @"亲爱哒摄影师，请先认证您的身份哟！";
    [self.view addSubview:label];
    
    UIButton *certifierBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    certifierBtn.frame = CGRectMake(kScreenWidth / 3, CGRectGetMaxY(label.frame) + 20, kScreenWidth / 3, 50);
    [certifierBtn setTitle:@"去认证" forState:UIControlStateNormal];
    [certifierBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [certifierBtn setBackgroundImage:[UIImage imageWithColor:NavigationColor Size:certifierBtn.frame.size] forState:UIControlStateNormal];
    certifierBtn.layer.cornerRadius = 5;
    certifierBtn.layer.masksToBounds = YES;
    [certifierBtn setAdjustsImageWhenHighlighted:NO];
    [certifierBtn addTarget:self action:@selector(gotoCertifierAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:certifierBtn];
    
}


//已认证
- (void)alreadyCertified{
    SYPhotographerView *view = [[[NSBundle mainBundle] loadNibNamed:@"SYPhotographerView" owner:self options:nil] lastObject];
    self.grapherView = view;
    
    [self.grapherView.updatePhotoBtn addTarget:self action:@selector(updatePhotoAction:) forControlEvents:UIControlEventTouchUpInside];

    if ([_userInfos.pholv integerValue] == 1) {
        view.xingjiImageView.image = [UIImage imageNamed:@"xingji-one"];
    }else if ([_userInfos.pholv integerValue] == 2){
        view.xingjiImageView.image = [UIImage imageNamed:@"xingji-two"];
    }else{
        view.xingjiImageView.image = [UIImage imageNamed:@"xingji-three"];
    }
    view.collectionView.delegate = self;
    view.collectionView.dataSource = self;
    [view.collectionView registerNib:[UINib nibWithNibName:@"SYUpdateGrapherCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:identifier];
    [view.collectionView registerClass:[SYUpdateGrapherHeaderCollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:headerIdentifier];
    [view.collectionView registerClass:[SYUpdateGrapherFooterCollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:footerIdentifier];
    
    view.collectionView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [self getDate];
    }];
    view.collectionView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        [self getMoreData];
    }];
    _collectionView = view.collectionView;
    self.view = view;
    
}


//认证中
- (void)beingCertified{
    UIImageView *backImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 200)];
    backImageView.contentMode = UIViewContentModeScaleAspectFit;
    backImageView.image = [UIImage imageNamed:@"shenhe"];
    [self.view addSubview:backImageView];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(backImageView.frame) + 20, kScreenWidth, 20)];
    label.font = [UIFont systemFontOfSize:16];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor darkGrayColor];
    label.text = @"审核中，请耐心等待......";
    [self.view addSubview:label];
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    NSArray *items = [self.dataSourceArr[section] objectForKey:@"data"];
    return items.count;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return self.dataSourceArr.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    SYUpdateGrapherCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    NSArray *items = [self.dataSourceArr[indexPath.section] objectForKey:@"data"];
    [cell.headImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",ImgUrl,[items[indexPath.item] objectForKey:@"img_200"]]] placeholderImage:[UIImage imageNamed:@"shangchuan_wode_wutupian"]];
    cell.phoneLabel.text = [items[indexPath.item] objectForKey:@"tel"];
    cell.nameLabel.text = [items[indexPath.item] objectForKey:@"nick"];
    
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    UICollectionReusableView *reusableview = nil;
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        SYUpdateGrapherHeaderCollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:headerIdentifier forIndexPath:indexPath];
        
        NSString *time = [self.dataSourceArr[indexPath.section] objectForKey:@"time"];
        if (time) {
            headerView.timeLable.text = time;
        }else{
            headerView.timeLable.text = @"";
        }
        reusableview = headerView;
        
    }
    
    if ([kind isEqualToString:UICollectionElementKindSectionFooter]) {
        SYUpdateGrapherFooterCollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:footerIdentifier forIndexPath:indexPath];
        reusableview = headerView;
    }
    
    return reusableview;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    SYGrapherUpdateHistoryViewController *history = [[SYGrapherUpdateHistoryViewController alloc] init];
    NSArray *data = [self.dataSourceArr[indexPath.section] objectForKey:@"data"];
    history.dataSourceDic = data[indexPath.item];
    history.time = [self.dataSourceArr[indexPath.section] objectForKey:@"time"];
    [self.navigationController pushViewController:history animated:YES];
}

#pragma mark - PrivateMethod
- (void)gotoCertifierAction:(UIButton *)sender{
    
    //根据teacher字段加载不同的view
    if ([_userInfos.idcard integerValue] == 0) {
        //未验证身份证
        SYIDViewController *idcard = [[SYIDViewController alloc] initWithNibName:@"SYIDViewController" bundle:nil];
        idcard.state = isFromGrapher;
        [self.navigationController pushViewController:idcard animated:YES];
    }else{
        SYGrapherCertifiedViewController *grapher = [[SYGrapherCertifiedViewController alloc] initWithNibName:@"SYGrapherCertifiedViewController" bundle:nil];
        [self.navigationController pushViewController:grapher animated:YES];
        
    }
    
    
}

//设置价格
- (void)setPriceAction:(UIButton *)sender{
//    SYPhotoGrapherSetPriceViewController *setPrice = [[SYPhotoGrapherSetPriceViewController alloc] init];
//    [self.navigationController pushViewController:setPrice animated:YES];
}

//传送照片
- (void)updatePhotoAction:(UIButton *)sender{
    SYGrapherUpdataPhotoViewController *update = [[SYGrapherUpdataPhotoViewController alloc] init];
    
    [self.navigationController pushViewController:update animated:YES];
}


- (void)getDate{
    //获取图片
    NSString *url = [NSString stringWithFormat:@"%@%@",BaseUrl,@"/pho/history.html"];
    NSDictionary *param = @{@"token":UserToken, @"page":@1};
    __weak typeof(self)weakself = self;
    [[SYHttpRequest sharedInstance] getDataWithUrl:url Parameter:param ResponseObject:^(NSDictionary *responseResult) {
        if ([_collectionView.mj_header isRefreshing]) {
            [_collectionView.mj_header endRefreshing];
        }
        NSLog(@"获取摄影师上传历史 -- %@",responseResult);
        if ([responseResult objectForKey:@"resError"]) {
            [self showHint:@"请检查您的网络！"];
        }else{
            _count = 1;
            if ([[responseResult objectForKey:@"result"] integerValue] == 1) {
                [XHNetworkCache saveJsonResponseToCacheFile:responseResult andURL:[NSString stringWithFormat:@"%@/%@",Mobile,@"GrapherHistory"]];
                if ([responseResult objectForKey:@"data"]) {
                    [weakself.dataSourceArr removeAllObjects];
                    [weakself.dataSourceArr addObjectsFromArray:[responseResult objectForKey:@"data"]];
                    
                    weakself.grapherView.updateHistoryLabel.text = [NSString stringWithFormat:@"传送历史：(%d)",[[responseResult objectForKey:@"count"] intValue]];
                }
                [_collectionView reloadData];
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
    NSString *url = [NSString stringWithFormat:@"%@%@",BaseUrl,@"/pho/history.html"];
    NSDictionary *param = @{@"token":UserToken, @"page":[NSNumber numberWithInteger:_count]};
    [[SYHttpRequest sharedInstance] getDataWithUrl:url Parameter:param ResponseObject:^(NSDictionary *responseResult) {
        if ([_collectionView.mj_footer isRefreshing]) {
            [_collectionView.mj_footer endRefreshing];
        }
        NSLog(@"获取摄影师上传历史 -- %@",responseResult);
        if ([responseResult objectForKey:@"resError"]) {
            _count --;
        }else{
            if ([[responseResult objectForKey:@"result"] integerValue] == 1) {
                if ([responseResult objectForKey:@"data"]) {
                    [self.dataSourceArr addObjectsFromArray:[responseResult objectForKey:@"data"]];
                }
                [_collectionView reloadData];
            }else{
                _count --;
                if ([responseResult objectForKey:@"msg"]) {
                    [self showHint:[responseResult objectForKey:@"msg"]];
                }
            }
        }
    }];
}

- (NSMutableArray *)dataSourceArr{
    if (!_dataSourceArr) {
        _dataSourceArr = [NSMutableArray arrayWithCapacity:0];
    }
    return _dataSourceArr;
}

@end
