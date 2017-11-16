//
//  SYUpdateMineViewController.m
//  ShuoYing
//
//  Created by 硕影 on 2016/12/29.
//  Copyright © 2016年 硕影. All rights reserved.
//

#import "SYUpdateMineViewController.h"

#import "SYUpdataMineCollectionViewCell.h"

#import "SYNewAlbumViewController.h"
#import "SYNewAlbumModel.h"

#import "SYMyAlbumInfosViewController.h"

#import "SYTeacherAndGrapherInfosViewController.h"

@interface SYUpdateMineViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate>

{
    NSURLSessionTask *_dataTask;
    
    BOOL _isOpenMineAlbum;
    BOOL _isOpenTeacherAlbum;
    BOOL _isOpenGrapherAlbum;
    BOOL _isOpenGroupAlbum;
    
    CGRect _mineOldFrame;
    CGRect _teacherOldFrame;
    CGRect _grapherOldFrame;
    CGRect _groupOldFrame;
    
    UIImageView *_mineArrowIMG;
    UIImageView *_teacherArrowIMG;
    UIImageView *_grapherArrowIMG;
    UIImageView *_groupArrowIMG;
    
    NSInteger _teacherCount;
    NSInteger _grapherCount;
    NSInteger _groupCount;
    
    CGFloat _contentOffsetY;
    
    CGFloat _oldContentOffsetY;
    
    CGFloat _newContentOffsetY;
}

@property (nonatomic, strong) UICollectionView *mineCollectionView;
@property (nonatomic, strong) UICollectionViewFlowLayout *mineCollectionFlowLayout;

@property (nonatomic, strong) UICollectionView *teacherCollectionView;
@property (nonatomic, strong) UICollectionViewFlowLayout *teacherCollectionFlowLayout;

@property (nonatomic, strong) UICollectionView *grapherCollectionView;
@property (nonatomic, strong) UICollectionViewFlowLayout *grapherCollectionFlowLayout;

@property (nonatomic, strong) UICollectionView *groupCollectionView;
@property (nonatomic, strong) UICollectionViewFlowLayout *groupCollectionFlowLayout;

@property (nonatomic, strong) UIView *mineView;

@property (nonatomic, strong) UIView *teacherView;

@property (nonatomic, strong) UIView *grapherView;

@property (nonatomic, strong) UIView *groupView;

@property (nonatomic, strong) NSMutableArray *myAlbumDataSource;

@property (nonatomic, strong) NSMutableArray *teacherDataSource;

@property (nonatomic, strong) NSMutableArray *grapherDataSource;

@property (nonatomic, strong) NSMutableArray *groupDataSource;

@end

@implementation SYUpdateMineViewController

static NSString *mineIdentifier = @"mineCell";
static NSString *teacherIdentifier = @"teacherCell";
static NSString *grapherIdentifier = @"grapherCell";
static NSString *groupIdentifier = @"groupCell";

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self getDataFromMine];
//    [self getDataFromTeacher];
//    [self getDateFromGrapher];
//    [self getDateFromGroup];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"云相册";
    _isOpenMineAlbum = YES;
    _isOpenTeacherAlbum = NO;
    _isOpenGrapherAlbum = NO;
    _isOpenGroupAlbum = NO;
    _teacherCount = 1;
    _grapherCount = 1;
    _groupCount = 1;
    [self setSubViews];
}

- (void)setSubViews{
//    [self.view addSubview:self.mineView];
//    [self.view addSubview:self.teacherView];
//    [self.view addSubview:self.grapherView];
//    [self.view addSubview:self.groupView];
    [self loadMineCollectionView];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    _contentOffsetY = scrollView.contentOffset.y;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    _newContentOffsetY = scrollView.contentOffset.y;
    
    
    
    if (_newContentOffsetY > _oldContentOffsetY && _oldContentOffsetY > _contentOffsetY) {  // 向上滚动
        
        
        
        
        
        
        
    } else if (_newContentOffsetY < _oldContentOffsetY && _oldContentOffsetY < _contentOffsetY) { // 向下滚动
        
        
        
        
        
    } else {
        
        
        
        
        
    }
    
    
    
    if (scrollView.dragging) {  // 拖拽
        
        
        
        if ((scrollView.contentOffset.y - _contentOffsetY) > 5.0f) {  // 向上拖拽
            
            
            
            if (_isOpenMineAlbum) {
                
            }
            
            if (_isOpenTeacherAlbum) {
                
                [UIView animateWithDuration:.5 animations:^{
                    self.mineView.frame = CGRectMake(0, - 44, kScreenWidth, 44);
                    self.teacherView.frame = CGRectMake(0, 15, kScreenWidth, 44);
                    self.grapherView.frame = CGRectMake(0, kScreenHeight, kScreenWidth, 44);
                    self.groupView.frame = CGRectMake(0, kScreenHeight, kScreenWidth, 44);
                    
                    self.teacherCollectionView.frame = CGRectMake(0, CGRectGetMaxY(self.teacherView.frame), kScreenWidth, kScreenHeight - kNavigationBarHeightAndStatusBarHeight - 15 - 44);
                }];
                
            }
            
            if (_isOpenGrapherAlbum) {
                
                [UIView animateWithDuration:.5 animations:^{
                    self.mineView.frame = CGRectMake(0, - 44, kScreenWidth, 44);
                    self.teacherView.frame = CGRectMake(0, - 44, kScreenWidth, 44);
                    self.grapherView.frame = CGRectMake(0, 15, kScreenWidth, 44);
                    self.grapherCollectionView.frame = CGRectMake(0, CGRectGetMaxY(self.grapherView.frame), kScreenWidth, kScreenHeight - kNavigationBarHeightAndStatusBarHeight - 15 - 44);
                }];
            }
            
            if (_isOpenGroupAlbum) {
                
                [UIView animateWithDuration:.5 animations:^{
                    self.mineView.frame = CGRectMake(0, - 44, kScreenWidth, 44);
                    self.teacherView.frame = CGRectMake(0, - 44, kScreenWidth, 44);
                    self.grapherView.frame = CGRectMake(0, - 44, kScreenWidth, 44);
                    self.groupView.frame = CGRectMake(0, 15, kScreenWidth, 44);
                    
                    self.groupCollectionView.frame = CGRectMake(0, CGRectGetMaxY(self.groupView.frame), kScreenWidth, kScreenHeight - kNavigationBarHeightAndStatusBarHeight - 15 - 44);
                }];
                
            }
            
            
            
        } else if ((_contentOffsetY - scrollView.contentOffset.y) > 5.0f) {   // 向下拖拽
            
            
            if (_isOpenMineAlbum) {
                
            }
            
            if (_isOpenTeacherAlbum) {
                
                [UIView animateWithDuration:.5 animations:^{
                    self.mineView.frame = _mineOldFrame;
                    self.teacherView.frame = _teacherOldFrame;
                    self.grapherView.frame = CGRectMake(0, kScreenHeight - kNavigationBarHeightAndStatusBarHeight - 44 - 15 - 44, kScreenWidth, 44);;
                    self.groupView.frame = CGRectMake(0, kScreenHeight - kNavigationBarHeightAndStatusBarHeight - 44, kScreenWidth, 44);
                    self.teacherCollectionView.frame = CGRectMake(0, CGRectGetMaxY(self.teacherView.frame), kScreenWidth, kScreenHeight - kNavigationBarHeightAndStatusBarHeight - 44 * 4 - 15 * 3);
                }];
                
            }
            
            if (_isOpenGrapherAlbum) {
                
                [UIView animateWithDuration:.5 animations:^{
                    self.mineView.frame = _mineOldFrame;
                    self.teacherView.frame = _teacherOldFrame;
                    self.grapherView.frame = _grapherOldFrame;
                    self.groupView.frame = CGRectMake(0, kScreenHeight - kNavigationBarHeightAndStatusBarHeight - 44, kScreenWidth, 44);
                    self.grapherCollectionView.frame = CGRectMake(0, CGRectGetMaxY(self.grapherView.frame), kScreenWidth, kScreenHeight - kNavigationBarHeightAndStatusBarHeight - 44 * 4 - 15 * 3);
                }];
            }
            
            if (_isOpenGroupAlbum) {
                
                [UIView animateWithDuration:.5 animations:^{
                    self.mineView.frame = _mineOldFrame;
                    self.teacherView.frame = _teacherOldFrame;
                    self.grapherView.frame = _grapherOldFrame;
                    self.groupView.frame = _groupOldFrame;
                    self.groupCollectionView.frame = CGRectMake(0, CGRectGetMaxY(self.groupView.frame), kScreenWidth, kScreenHeight - kNavigationBarHeightAndStatusBarHeight - 44 * 4 - 15 * 3);
                }];
                
            }
            
            
            
        } else {
            
            
            
        }
        
    }
    

    
    
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate;
{
    
    _oldContentOffsetY = scrollView.contentOffset.y;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    
    _oldContentOffsetY = scrollView.contentOffset.y;
}

#pragma mark - PrivateMethod

- (void)tapMineViewAction:(UITapGestureRecognizer *)tap{
    if (_isOpenMineAlbum) {
        self.mineView.frame = _mineOldFrame;
        self.teacherView.frame = _teacherOldFrame;
        self.grapherView.frame = _grapherOldFrame;
        self.groupView.frame = _groupOldFrame;
        _mineArrowIMG.image = [UIImage imageNamed:@"shangchuan_icon_sanjiao-_nor"];
        [self.mineCollectionView removeFromSuperview];
    }else{
        self.teacherView.frame = CGRectMake(0, kScreenHeight - kNavigationBarHeightAndStatusBarHeight - 44 - 15 - 44 - 15 - 44, kScreenWidth, 44);
        self.grapherView.frame = CGRectMake(0, kScreenHeight - kNavigationBarHeightAndStatusBarHeight - 44 - 15 - 44, kScreenWidth, 44);
        self.groupView.frame = CGRectMake(0, kScreenHeight - kNavigationBarHeightAndStatusBarHeight - 44, kScreenWidth, 44);
        _mineArrowIMG.image = [UIImage imageNamed:@"shangchuan_icon_sanjiao_sel"];
        [self.teacherCollectionView removeFromSuperview];
        [self.grapherCollectionView removeFromSuperview];
        [self.groupCollectionView removeFromSuperview];
        [self.mineCollectionView removeFromSuperview];
        [self loadMineCollectionView];
    }
    _teacherArrowIMG.image = [UIImage imageNamed:@"shangchuan_icon_sanjiao-_nor"];
    _grapherArrowIMG.image = [UIImage imageNamed:@"shangchuan_icon_sanjiao-_nor"];
    _groupArrowIMG.image = [UIImage imageNamed:@"shangchuan_icon_sanjiao-_nor"];

    _isOpenGrapherAlbum = NO;
    _isOpenTeacherAlbum = NO;
    _isOpenGroupAlbum = NO;
    _isOpenMineAlbum = !_isOpenMineAlbum;
    
}

- (void)tapTeacherViewAction:(UITapGestureRecognizer *)tap{
    if (_isOpenTeacherAlbum) {
        self.mineView.frame = _mineOldFrame;
        self.teacherView.frame = _teacherOldFrame;
        self.grapherView.frame = _grapherOldFrame;
        self.groupView.frame = _groupOldFrame;
        _teacherArrowIMG.image = [UIImage imageNamed:@"shangchuan_icon_sanjiao-_nor"];
        [self.teacherCollectionView removeFromSuperview];
    }else{
        self.mineView.frame = _mineOldFrame;
        self.teacherView.frame = _teacherOldFrame;
        self.grapherView.frame = CGRectMake(0, kScreenHeight - kNavigationBarHeightAndStatusBarHeight - 44 - 15 - 44, kScreenWidth, 44);
        self.groupView.frame = CGRectMake(0, kScreenHeight - kNavigationBarHeightAndStatusBarHeight - 44, kScreenWidth, 44);
        _teacherArrowIMG.image = [UIImage imageNamed:@"shangchuan_icon_sanjiao_sel"];
        [self.mineCollectionView removeFromSuperview];
        [self.grapherCollectionView removeFromSuperview];
        [self.groupCollectionView removeFromSuperview];
        [self.teacherCollectionView removeFromSuperview];
        [self loadTeacherCollectionView];
    }
    _mineArrowIMG.image = [UIImage imageNamed:@"shangchuan_icon_sanjiao-_nor"];
    _grapherArrowIMG.image = [UIImage imageNamed:@"shangchuan_icon_sanjiao-_nor"];
    _groupArrowIMG.image = [UIImage imageNamed:@"shangchuan_icon_sanjiao-_nor"];

    _isOpenGrapherAlbum = NO;
    _isOpenMineAlbum = NO;
    _isOpenGroupAlbum = NO;
    _isOpenTeacherAlbum = !_isOpenTeacherAlbum;
}

- (void)tapGrapherViewAction:(UITapGestureRecognizer *)tap{
    if (_isOpenGrapherAlbum) {
        self.mineView.frame = _mineOldFrame;
        self.teacherView.frame = _teacherOldFrame;
        self.grapherView.frame = _grapherOldFrame;
        self.groupView.frame = _groupOldFrame;
        _grapherArrowIMG.image = [UIImage imageNamed:@"shangchuan_icon_sanjiao-_nor"];
        _isOpenGrapherAlbum = NO;
        [self.grapherCollectionView removeFromSuperview];
    }else{
        self.mineView.frame = _mineOldFrame;
        self.teacherView.frame = _teacherOldFrame;
        self.grapherView.frame = _grapherOldFrame;
        self.groupView.frame = CGRectMake(0, kScreenHeight - kNavigationBarHeightAndStatusBarHeight - 44, kScreenWidth, 44);
        
        _grapherArrowIMG.image = [UIImage imageNamed:@"shangchuan_icon_sanjiao_sel"];
        _isOpenGrapherAlbum = YES;
        [self.mineCollectionView removeFromSuperview];
        [self.teacherCollectionView removeFromSuperview];
        [self.grapherCollectionView removeFromSuperview];
        [self.groupCollectionView removeFromSuperview];
        [self loadGrapherCollectionView];
    }
    _mineArrowIMG.image = [UIImage imageNamed:@"shangchuan_icon_sanjiao-_nor"];
    _teacherArrowIMG.image = [UIImage imageNamed:@"shangchuan_icon_sanjiao-_nor"];
    _groupArrowIMG.image = [UIImage imageNamed:@"shangchuan_icon_sanjiao-_nor"];
    _isOpenTeacherAlbum = NO;
    _isOpenMineAlbum = NO;
    _isOpenGroupAlbum = NO;
}

- (void)tapGroupViewAction:(UITapGestureRecognizer *)tap{
    if (_isOpenGroupAlbum) {
        self.mineView.frame = _mineOldFrame;
        self.teacherView.frame = _teacherOldFrame;
        self.grapherView.frame = _grapherOldFrame;
        self.groupView.frame = _groupOldFrame;
        _groupArrowIMG.image = [UIImage imageNamed:@"shangchuan_icon_sanjiao-_nor"];
        [self.groupCollectionView removeFromSuperview];
    }else{
        self.mineView.frame = _mineOldFrame;
        self.teacherView.frame = _teacherOldFrame;
        self.grapherView.frame = _grapherOldFrame;
        self.groupView.frame = _groupOldFrame;
        _groupArrowIMG.image = [UIImage imageNamed:@"shangchuan_icon_sanjiao_sel"];
        [self.mineCollectionView removeFromSuperview];
        [self.teacherCollectionView removeFromSuperview];
        [self.grapherCollectionView removeFromSuperview];
        [self.groupCollectionView removeFromSuperview];
        [self loadGroupCollectionView];
        
    }
    _mineArrowIMG.image = [UIImage imageNamed:@"shangchuan_icon_sanjiao-_nor"];
    _grapherArrowIMG.image = [UIImage imageNamed:@"shangchuan_icon_sanjiao-_nor"];
    _teacherArrowIMG.image = [UIImage imageNamed:@"shangchuan_icon_sanjiao-_nor"];

    _isOpenGrapherAlbum = NO;
    _isOpenMineAlbum = NO;
    _isOpenTeacherAlbum = NO;
    _isOpenGroupAlbum = !_isOpenGroupAlbum;
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    if (collectionView == self.mineCollectionView) {
        return self.myAlbumDataSource.count + 1;
    }else if (collectionView == self.teacherCollectionView){
        return self.teacherDataSource.count;
    }else if (collectionView == self.grapherCollectionView){
        return self.grapherDataSource.count;
    }else{
        return self.groupDataSource.count;
    }
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    if (collectionView == self.mineCollectionView) {
        SYUpdataMineCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:mineIdentifier forIndexPath:indexPath];
        if (!cell) {
            cell = [[SYUpdataMineCollectionViewCell alloc] initWithFrame:CGRectMake(0, 0, (kScreenWidth - 40) / 3, (kScreenWidth - 40) / 3 + 40)];
            [cell.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        }
        if (indexPath.section == 0) {
            if (indexPath.item == 0) {
                
                cell.albumModel = nil;
                cell.oneLabel.text = @"";
                cell.twoLabel.text = @"";
                cell.imageView.image = [UIImage imageNamed:@"shangchaun_tianjia"];
            }else{
                cell.albumModel = self.myAlbumDataSource[indexPath.item - 1];
            }
        }
        return cell;
    }else if (collectionView == self.teacherCollectionView){
        SYUpdataMineCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:teacherIdentifier forIndexPath:indexPath];
        if (!cell) {
            cell = [[SYUpdataMineCollectionViewCell alloc] initWithFrame:CGRectMake(0, 0, (kScreenWidth - 40 ) / 3, (kScreenWidth - 40 ) / 3 + 40)];
            [cell.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        }
        cell.albumModel = self.teacherDataSource[indexPath.item];
        return cell;
    }else if (collectionView == self.grapherCollectionView){
        SYUpdataMineCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:grapherIdentifier forIndexPath:indexPath];
        if (!cell) {
            cell = [[SYUpdataMineCollectionViewCell alloc] initWithFrame:CGRectMake(0, 0, (kScreenWidth - 40) / 3, (kScreenWidth - 40) / 3 + 40)];
            [cell.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        }
        cell.albumModel = self.grapherDataSource[indexPath.item];
        return cell;
    }else{
        SYUpdataMineCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:groupIdentifier forIndexPath:indexPath];
        if (!cell) {
            cell = [[SYUpdataMineCollectionViewCell alloc] initWithFrame:CGRectMake(0, 0, (kScreenWidth - 40) / 3, (kScreenWidth - 40) / 3 + 40)];
            [cell.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        }
        cell.albumModel = self.groupDataSource[indexPath.item];
        return cell;
    }
    
    
}


#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if (collectionView == self.mineCollectionView) {
        if (indexPath.item == 0) {
            SYNewAlbumViewController *album = [[SYNewAlbumViewController alloc] init];
            [self.navigationController pushViewController:album animated:YES];
        }else{
            SYMyAlbumInfosViewController *infos = [[SYMyAlbumInfosViewController alloc] init];
            SYNewAlbumModel *model = self.myAlbumDataSource[indexPath.item - 1];
            infos.photoID = model.albumId;
            infos.photoName = model.file;
            if ([model.albumId integerValue] == -1 || [model.albumId integerValue] == -2 || [model.albumId integerValue] == -3) {
                infos.isNotFromMine = YES;

            }else{
                infos.isNotFromMine = NO;

            }
            [self.navigationController pushViewController:infos animated:YES];
        }
    }else if (collectionView == self.teacherCollectionView){
        SYTeacherAndGrapherInfosViewController *infos = [[SYTeacherAndGrapherInfosViewController alloc] init];
        infos.model = self.teacherDataSource[indexPath.item];
        infos.title = @"老师传送";
        [self.navigationController pushViewController:infos animated:YES];
    }else if (collectionView == self.grapherCollectionView){
        SYTeacherAndGrapherInfosViewController *infos = [[SYTeacherAndGrapherInfosViewController alloc] init];
        infos.model = self.grapherDataSource[indexPath.item];
        infos.title = @"摄影师传送";
        [self.navigationController pushViewController:infos animated:YES];
    }else{
        SYTeacherAndGrapherInfosViewController *infos = [[SYTeacherAndGrapherInfosViewController alloc] init];
        infos.model = self.groupDataSource[indexPath.item];
        infos.title = @"摄影家协会传送";
        [self.navigationController pushViewController:infos animated:YES];
    }
    
}

#pragma mark - UICollectionViewDelegate
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(10, 10, 10, 10);
}

#pragma mark - GetNetWorkData
- (void)getDataFromMine{
    NSString *url = [NSString stringWithFormat:@"%@%@",BaseUrl,@"/my/album.html"];
    NSDictionary *param = @{@"token":UserToken};
    [[SYHttpRequest sharedInstance] getDataWithUrl:url Parameter:param ResponseObject:^(NSDictionary *responseResult) {
        if ([self.mineCollectionView.mj_header isRefreshing]) {
            [self.mineCollectionView.mj_header endRefreshing];
        }
        NSLog(@"获取上传-我的-所有相册目录 -- %@",responseResult);
        if ([responseResult objectForKey:@"resError"]) {
            [self showHint:@"服务器不给力，请稍后重试"];
        }else{
            if ([[responseResult objectForKey:@"result"] integerValue] == 1) {
                [self.myAlbumDataSource removeAllObjects];
                NSArray *data = [responseResult objectForKey:@"data"];
                if (data.count > 0) {
                    for (NSDictionary *dic in data) {
                        SYNewAlbumModel *model = [SYNewAlbumModel albumWithDictionary:dic];
                        [self.myAlbumDataSource addObject:model];
                    }
                }
                [self.mineCollectionView reloadData];
            }else{
                if ([responseResult objectForKey:@"msg"]) {
                    [self showHint:[responseResult objectForKey:@"msg"]];
                }
            }
        }
    }];
}

- (void)getDataFromTeacher{
    NSString *url = [NSString stringWithFormat:@"%@%@",BaseUrl,@"/my/teacherlist.html"];
    NSDictionary *param = @{@"token":UserToken, @"page":@1};
    [[SYHttpRequest sharedInstance] getDataWithUrl:url Parameter:param ResponseObject:^(NSDictionary *responseResult) {
        _teacherCount = 1;
        if ([self.teacherCollectionView.mj_header isRefreshing]) {
            [self.teacherCollectionView.mj_header endRefreshing];
        }
        NSLog(@"获取上传-老师-所有相册目录 -- %@",responseResult);
        if ([responseResult objectForKey:@"resError"]) {
            [self showHint:@"服务器不给力，请稍后重试"];
        }else{
            if ([[responseResult objectForKey:@"result"] integerValue] == 1) {
                NSArray *data = [responseResult objectForKey:@"data"];
                if (data.count > 0) {
                    [self.teacherDataSource removeAllObjects];

                    for (NSDictionary *dic in data) {
                        SYNewAlbumModel *model = [SYNewAlbumModel albumWithDictionary:dic];
                        [self.teacherDataSource addObject:model];
                    }
                }
                [self.teacherCollectionView reloadData];

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
        if ([self.teacherCollectionView.mj_footer isRefreshing]) {
            [self.teacherCollectionView.mj_footer endRefreshing];
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
                        [self.teacherDataSource addObject:model];
                    }
                }
                [self.teacherCollectionView reloadData];
            }else{
                _teacherCount --;
                if ([responseResult objectForKey:@"msg"]) {
                    [self showHint:[responseResult objectForKey:@"msg"]];
                }
            }
        }
    }];
}

- (void)getDateFromGrapher{
    NSString *url = [NSString stringWithFormat:@"%@%@",BaseUrl,@"/my/pholist.html"];
    NSDictionary *param = @{@"token":UserToken, @"page":@1};
    _dataTask = [[SYHttpRequest sharedInstance] getDataWithUrl:url Parameter:param ResponseObject:^(NSDictionary *responseResult) {
        _grapherCount = 1;
        if ([self.grapherCollectionView.mj_header isRefreshing]) {
            [self.grapherCollectionView.mj_header endRefreshing];
        }
        NSLog(@"获取上传-摄影师-所有相册目录 -- %@",responseResult);
        if ([responseResult objectForKey:@"resError"]) {
            [self showHint:@"服务器不给力，请稍后重试"];
        }else{
            if ([[responseResult objectForKey:@"result"] integerValue] == 1) {
                NSArray *data = [responseResult objectForKey:@"data"];
                if (data.count > 0) {
                    [self.grapherDataSource removeAllObjects];

                    for (NSDictionary *dic in data) {
                        SYNewAlbumModel *model = [SYNewAlbumModel albumWithDictionary:dic];
                        [self.grapherDataSource addObject:model];
                    }
                }
                [self.grapherCollectionView reloadData];
            }else{
                if ([responseResult objectForKey:@"msg"]) {
                    [self showHint:[responseResult objectForKey:@"msg"]];
                }
            }
        }
    }];
}

- (void)getMoreDataFromGrapher{
    _grapherCount ++;
    NSString *url = [NSString stringWithFormat:@"%@%@",BaseUrl,@"/my/pholist.html"];
    NSDictionary *param = @{@"token":UserToken, @"page":[NSNumber numberWithInteger:_grapherCount]};
    _dataTask = [[SYHttpRequest sharedInstance] getDataWithUrl:url Parameter:param ResponseObject:^(NSDictionary *responseResult) {
        if ([self.grapherCollectionView.mj_footer isRefreshing]) {
            [self.grapherCollectionView.mj_footer endRefreshing];
        }
        NSLog(@"获取上传-摄影师-所有相册目录 -- %@",responseResult);
        if ([responseResult objectForKey:@"resError"]) {
            _grapherCount --;
            [self showHint:@"服务器不给力，请稍后重试"];
        }else{
            if ([[responseResult objectForKey:@"result"] integerValue] == 1) {
                NSArray *data = [responseResult objectForKey:@"data"];
                if (data.count > 0) {
                    for (NSDictionary *dic in data) {
                        SYNewAlbumModel *model = [SYNewAlbumModel albumWithDictionary:dic];
                        [self.grapherDataSource addObject:model];
                    }
                }
                [self.grapherCollectionView reloadData];
            }else{
                _grapherCount --;
                if ([responseResult objectForKey:@"msg"]) {
                    [self showHint:[responseResult objectForKey:@"msg"]];
                }
            }
        }
    }];
}

- (void)getDateFromGroup{
    NSString *url = [NSString stringWithFormat:@"%@%@",BaseUrl,@"/my/grouplist.html"];
    NSDictionary *param = @{@"token":UserToken, @"page":@1};
    _dataTask = [[SYHttpRequest sharedInstance] getDataWithUrl:url Parameter:param ResponseObject:^(NSDictionary *responseResult) {
        _groupCount = 1;
        if ([self.groupCollectionView.mj_header isRefreshing]) {
            [self.groupCollectionView.mj_header endRefreshing];
        }
        NSLog(@"获取上传-云拍群-所有相册目录 -- %@",responseResult);
        if ([responseResult objectForKey:@"resError"]) {
            [self showHint:@"服务器不给力，请稍后重试"];
        }else{
            if ([[responseResult objectForKey:@"result"] integerValue] == 1) {
                NSArray *data = [responseResult objectForKey:@"data"];
                if (data.count > 0) {
                    [self.groupDataSource removeAllObjects];
                    
                    for (NSDictionary *dic in data) {
                        SYNewAlbumModel *model = [SYNewAlbumModel albumWithDictionary:dic];
                        [self.groupDataSource addObject:model];
                    }
                }
                [self.groupCollectionView reloadData];
            }else{
                if ([responseResult objectForKey:@"msg"]) {
                    [self showHint:[responseResult objectForKey:@"msg"]];
                }
            }
        }
    }];
}

- (void)getMoreDataFromGroup{
    _groupCount ++;
    NSString *url = [NSString stringWithFormat:@"%@%@",BaseUrl,@"/my/pholist.html"];
    NSDictionary *param = @{@"token":UserToken, @"page":[NSNumber numberWithInteger:_groupCount]};
    _dataTask = [[SYHttpRequest sharedInstance] getDataWithUrl:url Parameter:param ResponseObject:^(NSDictionary *responseResult) {
        if ([self.groupCollectionView.mj_footer isRefreshing]) {
            [self.groupCollectionView.mj_footer endRefreshing];
        }
        NSLog(@"获取上传-云拍群-所有相册目录 -- %@",responseResult);
        if ([responseResult objectForKey:@"resError"]) {
            _groupCount --;
            [self showHint:@"服务器不给力，请稍后重试"];
        }else{
            if ([[responseResult objectForKey:@"result"] integerValue] == 1) {
                NSArray *data = [responseResult objectForKey:@"data"];
                if (data.count > 0) {
                    for (NSDictionary *dic in data) {
                        SYNewAlbumModel *model = [SYNewAlbumModel albumWithDictionary:dic];
                        [self.groupDataSource addObject:model];
                    }
                }
                [self.groupCollectionView reloadData];
            }else{
                _groupCount --;
                if ([responseResult objectForKey:@"msg"]) {
                    [self showHint:[responseResult objectForKey:@"msg"]];
                }
            }
        }
    }];
}

#pragma mark - loadCollectionView
- (void)loadMineCollectionView{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    
    self.mineCollectionFlowLayout = layout;
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    layout.itemSize = CGSizeMake((kScreenWidth - 40) / 3, (kScreenWidth - 40) / 3 + 50);
    layout.minimumLineSpacing = 10;
    
//    self.mineCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.mineView.frame), kScreenWidth, kScreenHeight - 64 - 44 * 4 - 15 * 3) collectionViewLayout:layout];
    self.mineCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight - kNavigationBarHeightAndStatusBarHeight) collectionViewLayout:layout];

    self.mineCollectionView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [self getDataFromMine];
    }];
    self.mineCollectionView.showsVerticalScrollIndicator = NO;
    [self.mineCollectionView registerNib:[UINib nibWithNibName:@"SYUpdataMineCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:mineIdentifier];
    
    self.mineCollectionView.backgroundColor = BackGroundColor;
    self.mineCollectionView.delegate = self;
    self.mineCollectionView.dataSource = self;
    [self.view addSubview:self.mineCollectionView];
}

- (void)loadTeacherCollectionView{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    
    self.teacherCollectionFlowLayout = layout;
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    layout.itemSize = CGSizeMake((kScreenWidth - 40 - 1) / 3, (kScreenWidth - 40 - 1) / 3 + 50);
    layout.minimumLineSpacing = 10;
    
    self.teacherCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.teacherView.frame), kScreenWidth, kScreenHeight - kNavigationBarHeightAndStatusBarHeight - 44 * 4 - 15 * 3) collectionViewLayout:layout];
    
    self.teacherCollectionView.showsVerticalScrollIndicator = NO;
    [self.teacherCollectionView registerNib:[UINib nibWithNibName:@"SYUpdataMineCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:teacherIdentifier];
    self.teacherCollectionView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [self getDataFromTeacher];
    }];
    self.teacherCollectionView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        [self getMoreDataFromTeacher];
    }];
    self.teacherCollectionView.backgroundColor = BackGroundColor;
    self.teacherCollectionView.delegate = self;
    self.teacherCollectionView.dataSource = self;
    [self.view addSubview:self.teacherCollectionView];
}


- (void)loadGrapherCollectionView{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    
    self.grapherCollectionFlowLayout = layout;
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    layout.itemSize = CGSizeMake((kScreenWidth - 40 - 1) / 3, (kScreenWidth - 40 - 1) / 3 + 50);
    layout.minimumLineSpacing = 10;
    
    self.grapherCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.grapherView.frame), kScreenWidth, kScreenHeight - kNavigationBarHeightAndStatusBarHeight - 44 * 4 - 15 * 3) collectionViewLayout:layout];
    
    self.grapherCollectionView.showsVerticalScrollIndicator = NO;
    [self.grapherCollectionView registerNib:[UINib nibWithNibName:@"SYUpdataMineCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:grapherIdentifier];
    self.grapherCollectionView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [self getDateFromGrapher];
    }];
    self.grapherCollectionView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        [self getMoreDataFromGrapher];
    }];
    self.grapherCollectionView.backgroundColor = BackGroundColor;
    self.grapherCollectionView.delegate = self;
    self.grapherCollectionView.dataSource = self;
    [self.view addSubview:self.grapherCollectionView];
}

- (void)loadGroupCollectionView{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    
    self.groupCollectionFlowLayout = layout;
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    layout.itemSize = CGSizeMake((kScreenWidth - 40 - 1) / 3, (kScreenWidth - 40 - 1) / 3 + 50);
    layout.minimumLineSpacing = 10;
    
    self.groupCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.groupView.frame), kScreenWidth, kScreenHeight - kNavigationBarHeightAndStatusBarHeight - 44 * 4 - 15 * 3) collectionViewLayout:layout];
    self.groupCollectionView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [self getDateFromGroup];
    }];
    self.groupCollectionView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        [self getMoreDataFromGroup];
    }];
    self.groupCollectionView.showsVerticalScrollIndicator = NO;
    [self.groupCollectionView registerNib:[UINib nibWithNibName:@"SYUpdataMineCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:groupIdentifier];
    
    self.groupCollectionView.backgroundColor = BackGroundColor;
    self.groupCollectionView.delegate = self;
    self.groupCollectionView.dataSource = self;
    [self.view addSubview:self.groupCollectionView];
}



#pragma mark - layzLoad
- (NSMutableArray *)myAlbumDataSource{
    if (!_myAlbumDataSource) {
        _myAlbumDataSource = [NSMutableArray arrayWithCapacity:0];
    }
    return _myAlbumDataSource;
}

- (NSMutableArray *)teacherDataSource{
    if (!_teacherDataSource) {
        _teacherDataSource = [NSMutableArray arrayWithCapacity:0];
    }
    return _teacherDataSource;
}

- (NSMutableArray *)grapherDataSource{
    if (!_grapherDataSource) {
        _grapherDataSource = [NSMutableArray arrayWithCapacity:0];
    }
    return _grapherDataSource;
}

- (NSMutableArray *)groupDataSource{
    if (!_groupDataSource) {
        _groupDataSource = [NSMutableArray arrayWithCapacity:0];
    }
    return _groupDataSource;
}

- (UIView *)mineView{
    if (!_mineView) {
        _mineView = [[UIView alloc] initWithFrame:CGRectMake(0, 15, kScreenWidth, 44)];
        _mineOldFrame = _mineView.frame;
        _mineView.userInteractionEnabled = YES;
        _mineView.backgroundColor = [UIColor whiteColor];
        UIView *upLineview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 1)];
        upLineview.backgroundColor = RGB(242, 242, 242);
        [_mineView addSubview:upLineview];
        UIView *downLineview = [[UIView alloc] initWithFrame:CGRectMake(0, 43, kScreenWidth, 1)];
        downLineview.backgroundColor = RGB(242, 242, 242);
        [_mineView addSubview:downLineview];
        
        UIImageView *mineArrow = [[UIImageView alloc] initWithFrame:CGRectMake(15, (44 - 15) / 2, 15, 15)];
        mineArrow.image = [UIImage imageNamed:@"shangchuan_icon_sanjiao_sel"];
        _mineArrowIMG = mineArrow;
        [_mineView addSubview:mineArrow];
        
        UILabel *mineLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(mineArrow.frame) + 5, 12, kScreenWidth - 50, 20)];
        mineLabel.text = @"我的空间";
        mineLabel.font = [UIFont systemFontOfSize:15];
        [_mineView addSubview:mineLabel];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapMineViewAction:)];
        [_mineView addGestureRecognizer:tap];
        
    }
    return _mineView;
}

- (UIView *)teacherView{
    if (!_teacherView) {
//        _teacherView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.mineView.frame) + 15, kScreenWidth, 44)];
        _teacherView = [[UIView alloc] initWithFrame:CGRectMake(0, kScreenHeight - kNavigationBarHeightAndStatusBarHeight - 44 - 15 - 44 - 15 - 44, kScreenWidth, 44)];
        _teacherOldFrame = CGRectMake(0, CGRectGetMaxY(self.mineView.frame) + 15, kScreenWidth, 44);
        _teacherView.backgroundColor = [UIColor whiteColor];
        UIView *upLineview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 1)];
        upLineview.backgroundColor = RGB(242, 242, 242);
        [_teacherView addSubview:upLineview];
        UIView *downLineview = [[UIView alloc] initWithFrame:CGRectMake(0, 43, kScreenWidth, 1)];
        downLineview.backgroundColor = RGB(242, 242, 242);
        [_teacherView addSubview:downLineview];
        
        UIImageView *mineArrow = [[UIImageView alloc] initWithFrame:CGRectMake(15, (44 - 15) / 2, 15, 15)];
        mineArrow.image = [UIImage imageNamed:@"shangchuan_icon_sanjiao-_nor"];
        _teacherArrowIMG = mineArrow;
        [_teacherView addSubview:mineArrow];
        
        UILabel *mineLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(mineArrow.frame) + 5, 12, kScreenWidth - 50, 20)];
        mineLabel.text = @"老师传送";
        mineLabel.font = [UIFont systemFontOfSize:15];
        [_teacherView addSubview:mineLabel];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapTeacherViewAction:)];
        _teacherView.userInteractionEnabled = YES;
        [_teacherView addGestureRecognizer:tap];
    }
    return _teacherView;
}

- (UIView *)grapherView{
    if (!_grapherView) {
//        _grapherView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.teacherView.frame) + 15, kScreenWidth, 44)];
        _grapherView = [[UIView alloc] initWithFrame:CGRectMake(0, kScreenHeight - kNavigationBarHeightAndStatusBarHeight - 44 - 15 - 44, kScreenWidth, 44)];
        _grapherOldFrame = CGRectMake(0, CGRectGetMaxY(_teacherOldFrame) + 15, kScreenWidth, 44);
        _grapherView.backgroundColor = [UIColor whiteColor];
        UIView *upLineview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 1)];
        upLineview.backgroundColor = RGB(242, 242, 242);
        [_grapherView addSubview:upLineview];
        UIView *downLineview = [[UIView alloc] initWithFrame:CGRectMake(0, 43, kScreenWidth, 1)];
        downLineview.backgroundColor = RGB(242, 242, 242);
        [_grapherView addSubview:downLineview];
        
        UIImageView *mineArrow = [[UIImageView alloc] initWithFrame:CGRectMake(15, (44 - 15) / 2, 15, 15)];
        mineArrow.image = [UIImage imageNamed:@"shangchuan_icon_sanjiao-_nor"];
        _grapherArrowIMG = mineArrow;
        [_grapherView addSubview:mineArrow];
        
        UILabel *mineLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(mineArrow.frame) + 5, 12, kScreenWidth - 50, 20)];
        mineLabel.text = @"摄影师传送";
        mineLabel.font = [UIFont systemFontOfSize:15];
        [_grapherView addSubview:mineLabel];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGrapherViewAction:)];
        _grapherView.userInteractionEnabled = YES;
        [_grapherView addGestureRecognizer:tap];
    }
    return _grapherView;
}

- (UIView *)groupView{
    if (!_groupView) {
//        _groupView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.grapherView.frame) + 15, kScreenWidth, 44)];
        _groupView = [[UIView alloc] initWithFrame:CGRectMake(0, kScreenHeight - kNavigationBarHeightAndStatusBarHeight - 44, kScreenWidth, 44)];
        _groupOldFrame = CGRectMake(0, CGRectGetMaxY(_grapherOldFrame) + 15, kScreenWidth, 44);
        _groupView.backgroundColor = [UIColor whiteColor];
        UIView *upLineview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 1)];
        upLineview.backgroundColor = RGB(242, 242, 242);
        [_groupView addSubview:upLineview];
        UIView *downLineview = [[UIView alloc] initWithFrame:CGRectMake(0, 43, kScreenWidth, 1)];
        downLineview.backgroundColor = RGB(242, 242, 242);
        [_groupView addSubview:downLineview];
        
        UIImageView *mineArrow = [[UIImageView alloc] initWithFrame:CGRectMake(15, (44 - 15) / 2, 15, 15)];
        mineArrow.image = [UIImage imageNamed:@"shangchuan_icon_sanjiao-_nor"];
        _groupArrowIMG = mineArrow;
        [_groupView addSubview:mineArrow];
        
        UILabel *mineLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(mineArrow.frame) + 5, 12, kScreenWidth - 50, 20)];
        mineLabel.text = @"摄影家协会传送";
        mineLabel.font = [UIFont systemFontOfSize:15];
        [_groupView addSubview:mineLabel];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGroupViewAction:)];
        _groupView.userInteractionEnabled = YES;
        [_groupView addGestureRecognizer:tap];
    }
    return _groupView;
}

@end
