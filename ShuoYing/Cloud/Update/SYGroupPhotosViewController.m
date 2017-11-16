//
//  SYGroupPhotosViewController.m
//  ShuoYing
//
//  Created by 硕影 on 2017/3/6.
//  Copyright © 2017年 硕影. All rights reserved.
//

#import "SYGroupPhotosViewController.h"

#import "SYGroupPhotoCollectionViewCell.h"
#import "SYGroupDownloadPhotoViewController.h"

@interface SYGroupPhotosViewController ()<UICollectionViewDelegate,UICollectionViewDataSource>

{
    NSInteger _count;
}

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, strong) UICollectionViewFlowLayout *flowLayout;

@property (nonatomic, strong) NSMutableArray *dataSourceArr;

@property (nonatomic, strong) UIImageView *noImageView;

@end

static NSString *identifier = @"cell";

@implementation SYGroupPhotosViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"协会相册";
    _count = 1;
    [self getData];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.dataSourceArr.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    SYGroupPhotoCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    
    [cell.imageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",ImgUrl, [self.dataSourceArr[indexPath.item] objectForKey:@"img_200"]]] placeholderImage:[UIImage imageNamed:@"shangchuan_wode_wutupian"]];
    
    cell.oneLabel.text = [self.dataSourceArr[indexPath.item] objectForKey:@"time"];
    cell.twoLabel.text = [NSString stringWithFormat:@"共%@张",[[self.dataSourceArr[indexPath.item] objectForKey:@"count"] stringValue]];
    
    return cell;
}


- (void)loadCollectionView{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumLineSpacing = 10;
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    layout.itemSize = CGSizeMake((kScreenWidth - 50) / 3, (kScreenWidth - 50) / 3 + 50);
    layout.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
    self.flowLayout = layout;
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight - kNavigationBarHeightAndStatusBarHeight) collectionViewLayout:layout];
    self.collectionView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [self getData];
    }];
    self.collectionView.mj_footer = [MJRefreshAutoStateFooter footerWithRefreshingBlock:^{
        [self getMoreData];
    }];
    self.collectionView.backgroundColor = BackGroundColor;
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    [self.collectionView registerNib:[UINib nibWithNibName:@"SYGroupPhotoCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:identifier];
    [self.view addSubview:self.collectionView];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    SYGroupDownloadPhotoViewController *down = [[SYGroupDownloadPhotoViewController alloc] init];
    down.groupID = self.groupID;
    down.dataSourceDic = self.dataSourceArr[indexPath.item];
    [self.navigationController pushViewController:down animated:YES];
}

- (void)getData{
    NSString *url = [NSString stringWithFormat:@"%@%@",BaseUrl,@"/group/photogroup.html"];
    NSDictionary *param = @{@"token":UserToken, @"id":self.groupID, @"page":@1};
    
    [[SYHttpRequest sharedInstance] getDataWithUrl:url Parameter:param ResponseObject:^(NSDictionary *responseResult) {
        _count = 1;
        if ([self.collectionView.mj_header isRefreshing]) {
            [self.collectionView.mj_header endRefreshing];
        }
        NSLog(@"群相册 -- %@",responseResult);
        if ([responseResult objectForKey:@"resError"]) {
            [self showHint:@"服务器不给力，请稍后重试"];
        }else{
            if ([[responseResult objectForKey:@"result"] integerValue] == 1) {
                if ([responseResult objectForKey:@"data"]) {
                    NSArray *data = [responseResult objectForKey:@"data"];
                    [self.noImageView removeFromSuperview];
                    [self.collectionView removeFromSuperview];
                    
                    if (data.count == 0) {
                        [self.view addSubview:self.noImageView];
                    }else{
                        [self loadCollectionView];
                    }
                    if (data.count >= 10) {
                        [self.collectionView.mj_footer resetNoMoreData];
                    }
                    if (data.count < 10 && data.count > 0) {
                        [self.collectionView.mj_footer endRefreshingWithNoMoreData];
                    }
                    if (data.count > 0) {
                        [self.dataSourceArr removeAllObjects];
                        [self.dataSourceArr addObjectsFromArray:data];
                    }
                    
                }
                [self.collectionView reloadData];
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
    NSString *url = [NSString stringWithFormat:@"%@%@",BaseUrl,@"/group/photogroup.html"];
    NSDictionary *param = @{@"token":UserToken, @"id":self.groupID, @"page":[NSNumber numberWithInteger:_count]};
    
    [[SYHttpRequest sharedInstance] getDataWithUrl:url Parameter:param ResponseObject:^(NSDictionary *responseResult) {
        
        if ([self.collectionView.mj_footer isRefreshing]) {
            [self.collectionView.mj_footer endRefreshing];
        }
        NSLog(@"群相册更多 -- %@",responseResult);
        if ([responseResult objectForKey:@"resError"]) {
            [self showHint:@"服务器不给力，请稍后重试"];
        }else{
            if ([[responseResult objectForKey:@"result"] integerValue] == 1) {
                if ([responseResult objectForKey:@"data"]) {
                    NSArray *data = [responseResult objectForKey:@"data"];
                    if (data.count < 10) {
                        [self.collectionView.mj_footer endRefreshingWithNoMoreData];
                    }
                    if (data.count > 0) {
                        [self.dataSourceArr addObjectsFromArray:data];
                    }
                }
                [self.collectionView reloadData];
            }else{
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

- (UIImageView *)noImageView{
    if (!_noImageView) {
        _noImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight - kNavigationBarHeightAndStatusBarHeight)];
        _noImageView.image = [UIImage imageNamed:@"qunxiangce_nophoto"];
        _noImageView.contentMode = UIViewContentModeCenter;
    }
    return _noImageView;
}

@end
