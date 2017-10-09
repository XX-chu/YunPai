//
//  SYGrapherUpdateHistoryViewController.m
//  ShuoYing
//
//  Created by 硕影 on 2017/1/12.
//  Copyright © 2017年 硕影. All rights reserved.
//

#import "SYGrapherUpdateHistoryViewController.h"
#import "SYTeacherPhotoHistoryCollectionViewCell.h"

#import "SYGrapherUpdataPhotoViewController.h"

@interface SYGrapherUpdateHistoryViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,XLPhotoBrowserDelegate,XLPhotoBrowserDatasource>
{
    NSInteger _count;
}

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, strong) UICollectionViewFlowLayout *flowLayout;

@property (nonatomic, strong) NSMutableArray *dataSourceArr;

@property (nonatomic, strong) NSMutableArray *browserImagesArr;

@property (nonatomic, strong) XLPhotoBrowser *photoBrowser;

@end

static NSString *identifier = @"teacherHistory";

@implementation SYGrapherUpdateHistoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _count = 1;
    self.title = [self.dataSourceDic objectForKey:@"nick"];
    [self loadCollectionView];
    [self initBottomView];
    [self getData];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.dataSourceArr.count;
}


- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    SYTeacherPhotoHistoryCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    
    [cell.headImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",ImgUrl,[self.dataSourceArr[indexPath.item] objectForKey:@"img_200"]]] placeholderImage:[UIImage imageNamed:@"shangchuan_wode_wutupian"]];
    cell.headImageViewHeightConstraint.constant = cell.frame.size.width;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    NSInteger count = self.dataSourceArr.count;
    [self.browserImagesArr removeAllObjects];
    [self.browserImagesArr addObjectsFromArray:self.dataSourceArr];
    // 快速创建并进入浏览模式
    XLPhotoBrowser *browser = [XLPhotoBrowser showPhotoBrowserWithCurrentImageIndex:indexPath.item imageCount:count datasource:self];
    self.photoBrowser = browser;
    browser.browserStyle = XLPhotoBrowserStyleIndexLabel;

}

#pragma mark    -   XLPhotoBrowserDatasource

/**
 *  返回指定位置的高清图片URL
 *
 *  @param browser 浏览器
 *  @param index   位置索引
 *
 *  @return 返回高清大图索引
 */
- (NSURL *)photoBrowser:(XLPhotoBrowser *)browser highQualityImageURLForIndex:(NSInteger)index
{
    NSString *imageUrl = [self.browserImagesArr[index] objectForKey:@"img_min"];
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",ImgUrl,imageUrl]];
}



- (void)getData{
    NSString *url = [NSString stringWithFormat:@"%@%@",BaseUrl,@"/pho/user.html"];
    NSDictionary *param = @{@"token":UserToken, @"page":@1, @"tel":[self.dataSourceDic objectForKey:@"tel"], @"time":self.time};
    [[SYHttpRequest sharedInstance] getDataWithUrl:url Parameter:param ResponseObject:^(NSDictionary *responseResult) {
        _count = 1;
        if ([self.collectionView.mj_header isRefreshing]) {
            [self.collectionView.mj_header endRefreshing];
        }
        NSLog(@"获取摄影师上传照片历史详情 -- %@",responseResult);
        if ([responseResult objectForKey:@"resError"]) {
            
        }else{
            if ([[responseResult objectForKey:@"result"] integerValue] == 1) {
                
                [self.dataSourceArr removeAllObjects];
                if ([responseResult objectForKey:@"data"]) {
                    NSArray *data = [responseResult objectForKey:@"data"];
                    [self.dataSourceArr addObjectsFromArray:data];
                    [self.collectionView reloadData];
                }
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
    NSString *url = [NSString stringWithFormat:@"%@%@",BaseUrl,@"/pho/user.html"];
    NSDictionary *param = @{@"token":UserToken, @"page":[NSNumber numberWithInteger:_count], @"tel":[self.dataSourceDic objectForKey:@"tel"], @"time":self.time};
    [[SYHttpRequest sharedInstance] getDataWithUrl:url Parameter:param ResponseObject:^(NSDictionary *responseResult) {
        if ([self.collectionView.mj_footer isRefreshing]) {
            [self.collectionView.mj_footer endRefreshing];
        }
        NSLog(@"获取摄影师上传照片历史详情 -- %@",responseResult);
        if ([responseResult objectForKey:@"resError"]) {
            _count --;
        }else{
            if ([[responseResult objectForKey:@"result"] integerValue] == 1) {
                
                if ([responseResult objectForKey:@"data"]) {
                    NSArray *data = [responseResult objectForKey:@"data"];
                    [self.dataSourceArr addObjectsFromArray:data];
                    [self.collectionView reloadData];
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


- (void)loadCollectionView{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    self.flowLayout = layout;
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    layout.itemSize = CGSizeMake((kScreenWidth - 70) / 3, (kScreenWidth - 70) / 3);
    layout.minimumLineSpacing = 15;
    //    layout.minimumInteritemSpacing = 20;
    layout.sectionInset = UIEdgeInsetsMake(10, 15, 10, 15);
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight - 64 - 80) collectionViewLayout:layout];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.backgroundColor = BackGroundColor;
    [self.collectionView registerNib:[UINib nibWithNibName:@"SYTeacherPhotoHistoryCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:identifier];
    self.collectionView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        [self getMoreData];
    }];
    self.collectionView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [self getData];
    }];
    [self.view addSubview:self.collectionView];
}

- (void)initBottomView{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, kScreenHeight - 80 - 64, kScreenWidth, 80)];
    view.backgroundColor = [UIColor clearColor];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setImage:[UIImage imageNamed:@"xuchuan"] forState:UIControlStateNormal];
    [btn setAdjustsImageWhenHighlighted:NO];
    [btn addTarget:self action:@selector(updatePhoto:) forControlEvents:UIControlEventTouchUpInside];
    btn.frame = CGRectMake(0, 0, 70, 70);
    btn.center = CGPointMake(kScreenWidth / 2, 35);
    [view addSubview:btn];
    
    [self.view addSubview:view];
}

- (void)updatePhoto:(UIButton *)sender{
    if (self.dataSourceArr.count <= 0 || self.dataSourceDic.count <= 0) {
        return;
    }
    
    SYGrapherUpdataPhotoViewController *update = [[SYGrapherUpdataPhotoViewController alloc] init];
    update.isFromHistory = YES;
    update.dataSourceDic = self.dataSourceDic;
    [self.navigationController pushViewController:update animated:YES];
        
}


- (NSMutableArray *)dataSourceArr{
    if (!_dataSourceArr) {
        _dataSourceArr = [NSMutableArray arrayWithCapacity:0];
    }
    return _dataSourceArr;
}

- (NSMutableArray *)browserImagesArr{
    if (!_browserImagesArr) {
        _browserImagesArr = [NSMutableArray arrayWithCapacity:0];
    }
    return _browserImagesArr;
}
@end
