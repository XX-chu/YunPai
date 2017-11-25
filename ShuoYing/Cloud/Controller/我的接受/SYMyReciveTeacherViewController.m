//
//  SYMyReciveTeacherViewController.m
//  ShuoYing
//
//  Created by chu on 2017/10/31.
//  Copyright © 2017年 硕影. All rights reserved.
//

#import "SYMyReciveTeacherViewController.h"
#import "SYUpdataMineCollectionViewCell.h"
#import "SYNewAlbumModel.h"
#import "SYTeacherAndGrapherInfosViewController.h"
@interface SYMyReciveTeacherViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
{
    NSInteger _teacherCount;
}
@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, strong) NSMutableArray *dataSourceArr;

@end

static NSString *teacherReciveIdentifier = @"teacherRecive";

@implementation SYMyReciveTeacherViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self getDataFromTeacher];

}

- (void)viewDidLoad {
    [super viewDidLoad];
    _teacherCount = 1;
    [self.view addSubview:self.collectionView];
    [self.collectionView.mj_header beginRefreshing];

}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.dataSourceArr.count;
    
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    SYUpdataMineCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:teacherReciveIdentifier forIndexPath:indexPath];
    if (!cell) {
        cell = [[SYUpdataMineCollectionViewCell alloc] init];
    }
    cell.albumModel = self.dataSourceArr[indexPath.item];
    return cell;

}

#pragma mark - UICollectionViewDelegate
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(10, 10, 10, 10);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    SYTeacherAndGrapherInfosViewController *infos = [[SYTeacherAndGrapherInfosViewController alloc] init];
    SYNewAlbumModel *model = self.dataSourceArr[indexPath.item];
    infos.model = model;
    infos.title = model.time;
    infos.type = UpdateHistoryTypeTeacher;
    [self.navigationController pushViewController:infos animated:YES];
}

- (void)getDataFromTeacher{
    NSString *url = [NSString stringWithFormat:@"%@%@",BaseUrl,@"/my/teacherlist.html"];
    NSDictionary *param = @{@"token":UserToken, @"page":@1};
    [[SYHttpRequest sharedInstance] getDataWithUrl:url Parameter:param ResponseObject:^(NSDictionary *responseResult) {
        _teacherCount = 1;
        if ([self.collectionView.mj_header isRefreshing]) {
            [self.collectionView.mj_header endRefreshing];
        }
        NSLog(@"获取上传-老师-所有相册目录 -- %@",responseResult);
        if ([responseResult objectForKey:@"resError"]) {
            [self showHint:@"服务器不给力，请稍后重试"];
        }else{
            if ([[responseResult objectForKey:@"result"] integerValue] == 1) {
                NSArray *data = [responseResult objectForKey:@"data"];
                if (data.count > 0) {
                    [self.dataSourceArr removeAllObjects];
                    
                    for (NSDictionary *dic in data) {
                        SYNewAlbumModel *model = [SYNewAlbumModel albumWithDictionary:dic];
                        [self.dataSourceArr addObject:model];
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

- (void)getMoreDataFromTeacher{
    _teacherCount ++;
    NSString *url = [NSString stringWithFormat:@"%@%@",BaseUrl,@"/my/teacherlist.html"];
    NSDictionary *param = @{@"token":UserToken, @"page":[NSNumber numberWithInteger:_teacherCount]};
    [[SYHttpRequest sharedInstance] getDataWithUrl:url Parameter:param ResponseObject:^(NSDictionary *responseResult) {
        if ([self.collectionView.mj_footer isRefreshing]) {
            [self.collectionView.mj_footer endRefreshing];
        }
        NSLog(@"获取上传-老师-所有相册目录 -- %@",responseResult);
        if ([responseResult objectForKey:@"resError"]) {
            _teacherCount --;
            [self showHint:@"服务器不给力，请稍后重试"];
        }else{
            if ([[responseResult objectForKey:@"result"] integerValue] == 1) {
                NSArray *data = [responseResult objectForKey:@"data"];
                if (data.count > 0) {
                    for (NSDictionary *dic in data) {
                        SYNewAlbumModel *model = [SYNewAlbumModel albumWithDictionary:dic];
                        [self.dataSourceArr addObject:model];
                    }
                }
                [self.collectionView reloadData];
            }else{
                _teacherCount --;
                if ([responseResult objectForKey:@"msg"]) {
                    [self showHint:[responseResult objectForKey:@"msg"]];
                }
            }
        }
    }];
}

- (UICollectionView *)collectionView{
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        layout.itemSize = CGSizeMake((kScreenWidth - 40 - 1) / 3, (kScreenWidth - 40 - 1) / 3 + 50);
        layout.minimumLineSpacing = 10;
        
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight - kNavigationBarHeightAndStatusBarHeight - 40) collectionViewLayout:layout];
        
        _collectionView.showsVerticalScrollIndicator = NO;
        [_collectionView registerNib:[UINib nibWithNibName:@"SYUpdataMineCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:teacherReciveIdentifier];
        _collectionView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
            [self getDataFromTeacher];
        }];
        _collectionView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
            [self getMoreDataFromTeacher];
        }];
        _collectionView.backgroundColor = BackGroundColor;
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        
    }
    return _collectionView;
}

- (NSMutableArray *)dataSourceArr{
    if (!_dataSourceArr) {
        _dataSourceArr = [NSMutableArray arrayWithCapacity:0];
    }
    return _dataSourceArr;
}

@end
