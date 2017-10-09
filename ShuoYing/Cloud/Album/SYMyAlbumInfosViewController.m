//
//  SYMyAlbumInfosViewController.m
//  ShuoYing
//
//  Created by 硕影 on 2016/12/30.
//  Copyright © 2016年 硕影. All rights reserved.
//

#import "SYMyAlbumInfosViewController.h"

#import "SYMyAlbumInfosCollectionViewCell.h"
#import "SYMyAlbumInfosHeaderCollectionReusableView.h"
#import "SYMyPhotoModel.h"

#import "SYPaymentInfosViewController.h"

#import "CircleProgressView.h"

#import "LXNetworking.h"

#import "ZLPhotoActionSheet.h"
#import "ZLDefine.h"
#import "ZLCollectionCell.h"
#import "ZLPhotoTool.h"

#import "SYFromTeacherOrGrapherCollectionViewCell.h"
#import "SYUpdatePreviewViewController.h"

@interface SYMyAlbumInfosViewController ()<UICollectionViewDelegate, UICollectionViewDataSource,XLPhotoBrowserDelegate, XLPhotoBrowserDatasource>
{
    UIButton *_updateImageBtn;
    UIButton *_photoNameBtn;
    UIImageView *_upImageView;
    
    NSURLSessionTask *_dataTask;
    UITextField *_progressText;

    NSIndexPath *_currentIndexPath;

    NSInteger _count;
}

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, strong) UICollectionViewFlowLayout *flowLayout;

@property (nonatomic, strong) UIView *upView;

@property (nonatomic, strong) NSMutableArray *imagesArr;

@property (nonatomic, strong) NSMutableArray *dataSourceArr;

@property (nonatomic, strong) CircleProgressView *progressView;

@property (nonatomic, strong) NSMutableArray *browserImagesArr;//查看当前分区的图片数组

@property (nonatomic, strong) XLPhotoBrowser *photoBrowser;


@end

@implementation SYMyAlbumInfosViewController
#pragma mark - Properties



static NSString *identifier = @"albumcell";
static NSString *identifier1 = @"albumcell1";
static NSString *headerIdentifier = @"albumheaderView";

const static CGFloat totleOffset = 250;

- (void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.translucent = YES;
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    if (!self.isNotFromMine) {
        [self setRightBarButtonItem];
    }
    [self getData];
}
- (void)viewWillDisappear:(BOOL)animated{
    self.navigationController.navigationBar.translucent = NO;
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageWithColor:NavigationColor Size:CGSizeMake(kScreenWidth, 64)] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage imageWithColor:NavigationColor Size:CGSizeMake(kScreenWidth, 1)];
    if (_dataTask) {
        [_dataTask cancel];
    }
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    _count = 1;
    [self loadCollectionView];
    [self.collectionView addSubview:self.upView];
    //从本地加载数据
    [self loadDataFromCache];
    
}

- (void)loadDataFromCache{
    [self.dataSourceArr removeAllObjects];
    
    NSDictionary *responseResult = [XHNetworkCache cacheJsonWithURL:[NSString stringWithFormat:@"%@%ld",Mobile,[self.photoID integerValue]]];
    
    NSArray *sections = [responseResult objectForKey:@"data"];
    if (sections.count > 0) {
        //遍历一共有多少个日期
        for (NSDictionary *dic in sections) {
            [self.dataSourceArr addObject:dic];

        }
    }
}

#pragma mark - PrivatyMethod

//更换名字
- (void)changePhotoName:(UIButton *)sender{
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"重命名" message:nil preferredStyle:UIAlertControllerStyleAlert];
    _progressText = [UITextField new];
    _progressText.placeholder = @"请输入新的分组名称";
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = _progressText.placeholder;
        _progressText = textField;
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        return ;
    }];
    UIAlertAction *otherAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        NSString *url = [NSString stringWithFormat:@"%@%@",BaseUrl,@"/my/editfile.html"];
        NSDictionary *param = @{@"token":UserToken, @"id":self.photoID, @"file":_progressText.text};
        [[SYHttpRequest sharedInstance] getDataWithUrl:url Parameter:param ResponseObject:^(NSDictionary *responseResult) {
            
            NSLog(@"重命名相册 -- %@",responseResult);
            if ([responseResult objectForKey:@"resError"]) {
                [self showHint:@"服务器不给力，请稍后重试"];
            }else{
                if ([[responseResult objectForKey:@"result"] integerValue] == 1) {
                    [_photoNameBtn setTitle:_progressText.text forState:UIControlStateNormal];
                    self.photoName = _progressText.text;
                    
                }else{
                    if ([responseResult objectForKey:@"msg"]) {
                        [self showHint:[responseResult objectForKey:@"msg"]];
                    }
                }
            }
        }];

    }];
    
    [alertController addAction:cancelAction];
    [alertController addAction:otherAction];
    [self presentViewController:alertController animated:YES completion:nil];
    
}
//上传图片
- (void)updatePhotoAction:(UIButton *)sender{
    NSDictionary *param = @{@"token":UserToken, @"id":self.photoID};
    SYUpdatePreviewViewController *preview = [SYUpdatePreviewViewController updatePreviewWithUrl:[NSString stringWithFormat:@"%@%@",BaseUrl, @"/my/upimgsX.html"] Param:param];
    [self.navigationController pushViewController:preview animated:YES];
}

//加载rightbar
- (void)setRightBarButtonItem{
    UIButton *right = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [right setImage:[UIImage imageNamed:@"wdxc_icon_nav_sc"] forState:UIControlStateNormal];
    [right setImageEdgeInsets:UIEdgeInsetsMake(0, 20, 0, 0)];
    [right addTarget:self action:@selector(deletePhotoAction:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightbar = [[UIBarButtonItem alloc] initWithCustomView:right];
    self.navigationItem.rightBarButtonItem = rightbar;
}

//删除相册
- (void)deletePhotoAction:(UIButton *)sender{
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"删除相册" message:@"您相册所有的照片都将删除" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        return ;
    }];
    UIAlertAction *otherAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        NSString *url = [NSString stringWithFormat:@"%@%@",BaseUrl,@"/my/delfile.html"];
        NSDictionary *param = @{@"token":UserToken, @"id":self.photoID};
        _dataTask = [[SYHttpRequest sharedInstance] getDataWithUrl:url Parameter:param ResponseObject:^(NSDictionary *responseResult) {
            
            NSLog(@"删除相册 -- %@",responseResult);
            if ([responseResult objectForKey:@"resError"]) {
                [self showHint:@"服务器不给力，请稍后重试"];
            }else{
                if ([[responseResult objectForKey:@"result"] integerValue] == 1) {
                    [self.navigationController popViewControllerAnimated:YES];
                    [self showHint:[responseResult objectForKey:@"msg"]];
                    
                }else{
                    if ([responseResult objectForKey:@"msg"]) {
                        [self showHint:[responseResult objectForKey:@"msg"]];
                    }
                }
            }
        }];
        
    }];
    
    [alertController addAction:cancelAction];
    [alertController addAction:otherAction];
    [self presentViewController:alertController animated:YES completion:nil];
    
}

#pragma mark - UIScrollVIewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    /**
     * 处理头部视图
     */
    //获取滚动视图y值的偏移量
    CGFloat offsetY = self.collectionView.contentOffset.y;
    
    // 计算tabView滚动的偏移量
    CGFloat delta = offsetY - totleOffset;
    
    CGFloat height = totleOffset - delta;
    height = height < 0 ? 0 : height;
    
    if(offsetY < -totleOffset) {
        
        CGRect f = self.upView.frame;
        f.origin.y= offsetY ;
        f.size.height=  -offsetY;
        f.origin.y= offsetY;
        //改变头部视图的fram
        self.upView.frame= f;
        [self loadUpImageViewSubViews];
    }
}

- (void)loadUpImageViewSubViews{

    if (!self.isNotFromMine) {
        _upImageView.frame = CGRectMake(0, 0, self.upView.frame.size.width, self.upView.frame.size.height - 50);
    }else{
        _upImageView.frame = CGRectMake(0, 0, self.upView.frame.size.width, self.upView.frame.size.height);
    }
    
    
    _photoNameBtn.frame = CGRectMake(0, 0, kScreenWidth, 30);
    _photoNameBtn.center = CGPointMake(_upImageView.frame.size.width / 2, _upImageView.frame.size.height / 2);
    
    
    _updateImageBtn.frame = CGRectMake(30, CGRectGetHeight(self.upView.frame) - 40, kScreenWidth - 60, 40);
    
    
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    NSArray *arr = [self.dataSourceArr[section] objectForKey:@"data"];
    return arr.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    if (!self.isNotFromMine) {
        SYMyAlbumInfosCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
        __weak typeof(cell)weakcell = cell;
        NSArray *arr = [self.dataSourceArr[indexPath.section] objectForKey:@"data"];
        NSDictionary *modelDic = arr[indexPath.item];
        cell.photoModel = [SYMyPhotoModel photoWithDictionary:modelDic];
        
        __weak typeof(self)weakSelf = self;
        cell.deleteImage = ^(SYMyAlbumInfosCollectionViewCell *cell){
            NSIndexPath *indexPath = [collectionView indexPathForCell:cell];
            NSLog(@"indexPath - %ld",(long)indexPath.section);
            NSLog(@"indexPath - %ld",(long)indexPath.item);
            [weakSelf deleteImageWithIndexPath:indexPath];
        };
        cell.downloadImage = ^(SYMyAlbumInfosCollectionViewCell *cell){
            
            [weakSelf downloadImage:weakcell];
        };
        return cell;
    }else{
        SYFromTeacherOrGrapherCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier1 forIndexPath:indexPath];
        __weak typeof(cell)weakcell1 = cell;
        NSArray *arr = [self.dataSourceArr[indexPath.section] objectForKey:@"data"];
        NSDictionary *modelDic = arr[indexPath.item];
        cell.photoModel = [SYMyPhotoModel photoWithDictionary:modelDic];
        
        __weak typeof(self)weakSelf = self;
    
        cell.downloadImage = ^(SYFromTeacherOrGrapherCollectionViewCell *cell){
            
            [weakSelf teacherDownloadImage:weakcell1];
        };
        return cell;
    }
    
}

//下载照片
- (void)downloadImage:(SYMyAlbumInfosCollectionViewCell *)cell {
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    
    UIView __block *view1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
    view1.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.6];
    [window addSubview:view1];
    [view1 addSubview:self.progressView];
    
    __weak typeof(self)weakself = self;
    
    [LXNetworking downloadWithUrl:[NSString stringWithFormat:@"%@%@",ImgUrl, cell.photoModel.img] saveToPath:nil progress:^(int64_t bytesProgress, int64_t totalBytesProgress) {
        //封装方法里已经回到主线程，所有这里不用再调主线程了
        _progressView.centerLabel.text = [NSString stringWithFormat:@"%.2f%@",1.0 * bytesProgress/totalBytesProgress,@"%"];
        [_progressView setPercent:1.0 * bytesProgress/totalBytesProgress];
        
    } success:^(id response) {
        NSLog(@"---------%@",response);
        [view1 removeFromSuperview];
        _progressView = nil;
        
        [weakself saveImageToPhoto:[NSURL URLWithString:(NSString *)response]];
        
    } failure:^(NSError *error) {
        [view1 removeFromSuperview];
        _progressView = nil;
    } showHUD:NO];

}

- (void)teacherDownloadImage:(SYFromTeacherOrGrapherCollectionViewCell *)cell {
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    
    UIView __block *view1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
    view1.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.6];
    [window addSubview:view1];
    [view1 addSubview:self.progressView];
    
    __weak typeof(self)weakself = self;
    
    [LXNetworking downloadWithUrl:[NSString stringWithFormat:@"%@%@",ImgUrl, cell.photoModel.img] saveToPath:nil progress:^(int64_t bytesProgress, int64_t totalBytesProgress) {
        //封装方法里已经回到主线程，所有这里不用再调主线程了
        _progressView.centerLabel.text = [NSString stringWithFormat:@"%.2f%@",1.0 * bytesProgress/totalBytesProgress,@"%"];
        [_progressView setPercent:1.0 * bytesProgress/totalBytesProgress];
        
    } success:^(id response) {
        NSLog(@"---------%@",response);
        [view1 removeFromSuperview];
        _progressView = nil;
        
        [weakself saveImageToPhoto:[NSURL URLWithString:(NSString *)response]];
        
    } failure:^(NSError *error) {
        [view1 removeFromSuperview];
        _progressView = nil;
    } showHUD:NO];
    
}


//保存到相册
- (void)saveImageToPhoto:(NSURL *)url{
    // 将相片添加到相册
    [[ZLPhotoTool sharePhotoTool] saveImageToAblumWithUrl:url completion:^(BOOL suc, PHAsset *asset) {
        if (suc) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self showHint:@"成功保存图片到相册！"];
                
            });
            NSLog(@"保存成功！");
        }else{
            NSLog(@"保存失败");
        }
    }];
}

//删除照片
- (void)deleteImageWithIndexPath:(NSIndexPath *)indexPath{
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"删除照片" message:@"您确定要删除这张照片吗？" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        return ;
    }];
    UIAlertAction *otherAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        //选中的分区的数据
        NSMutableDictionary *sectionDic = [NSMutableDictionary dictionaryWithCapacity:0];
        [sectionDic setDictionary:self.dataSourceArr[indexPath.section]];
        //获取图片
        NSString *url = [NSString stringWithFormat:@"%@%@",BaseUrl,@"/my/delimg.html"];
        NSDictionary *param = @{@"token":UserToken, @"id":[[sectionDic objectForKey:@"data"][indexPath.item]   objectForKey:@"id"]};
        _dataTask = [[SYHttpRequest sharedInstance] getDataWithUrl:url Parameter:param ResponseObject:^(NSDictionary *responseResult) {
            
            NSLog(@"删除图片 -- %@",responseResult);
            if ([responseResult objectForKey:@"resError"]) {
                [self showHint:@"服务器不给力，请稍后重试"];
            }else{
                if ([[responseResult objectForKey:@"result"] integerValue] == 1) {
                    [self showHint:[responseResult objectForKey:@"msg"]];
                    //选中分区的数据
                    NSMutableArray *dateArr = [NSMutableArray arrayWithCapacity:0];
                    [dateArr addObjectsFromArray:[self.dataSourceArr[indexPath.section] objectForKey:@"data"]];
                    [dateArr removeObjectAtIndex:indexPath.item];
                    [sectionDic setObject:dateArr forKey:@"data"];
                    [self.dataSourceArr replaceObjectAtIndex:indexPath.section withObject:sectionDic];
                    
                    [self.collectionView deleteItemsAtIndexPaths:@[indexPath]];
                    if ([[sectionDic objectForKey:@"data"] count] == 0) {
                        [self.dataSourceArr removeObjectAtIndex:indexPath.section];
                        NSIndexSet *set = [NSIndexSet indexSetWithIndex:indexPath.section];
                        [self.collectionView deleteSections:set];
                        
                    }
                    [self.collectionView reloadData];
                }else{
                    if ([responseResult objectForKey:@"msg"]) {
                        [self showHint:[responseResult objectForKey:@"msg"]];
                    }
                }
            }
        }];
        
    }];
    
    [alertController addAction:cancelAction];
    [alertController addAction:otherAction];
    [self presentViewController:alertController animated:YES completion:nil];

}


- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return self.dataSourceArr.count;
}

//头视图
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    UICollectionReusableView *reusableview = nil;
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        SYMyAlbumInfosHeaderCollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:headerIdentifier forIndexPath:indexPath];
        headerView.timeLabel.text = [self.dataSourceArr[indexPath.section] objectForKey:@"time"];
        reusableview = headerView;
    }
    
    return reusableview;
}


#pragma mark - UICollectionViewDelegate
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0, 10, 0, 10);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    _currentIndexPath = indexPath;
    NSInteger count = [(NSArray *)[self.dataSourceArr[indexPath.section] objectForKey:@"data"] count];
    [self.browserImagesArr removeAllObjects];
    [self.browserImagesArr addObjectsFromArray:(NSArray *)[self.dataSourceArr[indexPath.section] objectForKey:@"data"]];
    // 快速创建并进入浏览模式
    XLPhotoBrowser *browser = [XLPhotoBrowser showPhotoBrowserWithCurrentImageIndex:indexPath.item imageCount:count datasource:self];
    self.photoBrowser = browser;
 
    browser.browserStyle = XLPhotoBrowserStyleIndexLabel;///< 修改底部pagecontrol的样式为系统样式,默认是弹性动画的样式
    
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

#pragma mark    -   XLPhotoBrowserDelegate

- (void)photoBrowser:(XLPhotoBrowser *)browser clickActionSheetIndex:(NSInteger)actionSheetindex currentImageIndex:(NSInteger)currentImageIndex
{
    // do something yourself
    switch (actionSheetindex) {
        case 1: // 删除
        {
            NSLog(@"点击了actionSheet索引是:%zd , 当前展示的图片索引是:%zd",actionSheetindex,currentImageIndex);
            NSIndexPath *index = [NSIndexPath indexPathForItem:currentImageIndex inSection:_currentIndexPath.section];
            [self deleteImageWithIndexPath:index];
            
        }
            break;
//        case 1: // 保存
//        {
//            NSLog(@"点击了actionSheet索引是:%zd , 当前展示的图片索引是:%zd",actionSheetindex,currentImageIndex);
//            [browser saveCurrentShowImage];
//        }
//            break;
        default:
        {
            NSLog(@"点击了actionSheet索引是:%zd , 当前展示的图片索引是:%zd",actionSheetindex,currentImageIndex);
        }
            break;
    }
}


#pragma mark - getData
- (void)getData{
    //获取图片
    NSString *url = [NSString stringWithFormat:@"%@%@",BaseUrl,@"/my/photo.html"];
    NSDictionary *param = @{@"token":UserToken, @"id":self.photoID, @"page":@1};
    _dataTask = [[SYHttpRequest sharedInstance] getDataWithUrl:url Parameter:param ResponseObject:^(NSDictionary *responseResult) {
        _count = 1;
        NSLog(@"获取相册图片 -- %@",responseResult);
        if ([responseResult objectForKey:@"resError"]) {
            [self showHint:@"服务器不给力，请稍后重试"];
        }else{
            if ([[responseResult objectForKey:@"result"] integerValue] == 1) {
                [self.dataSourceArr removeAllObjects];
                [XHNetworkCache saveJsonResponseToCacheFile:responseResult andURL:[NSString stringWithFormat:@"%@%ld",Mobile,[self.photoID integerValue]]];
                NSArray *sections = [responseResult objectForKey:@"data"];
                if (sections.count > 0) {
                    //遍历一共有多少个日期
                    for (NSDictionary *dic in sections) {
                        [self.dataSourceArr addObject:dic];
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
    //获取图片
    _count ++;
    NSString *url = [NSString stringWithFormat:@"%@%@",BaseUrl,@"/my/photo.html"];
    NSDictionary *param = @{@"token":UserToken, @"id":self.photoID, @"page":[NSNumber numberWithInteger:_count]};
    _dataTask = [[SYHttpRequest sharedInstance] getDataWithUrl:url Parameter:param ResponseObject:^(NSDictionary *responseResult) {
        if ([self.collectionView.mj_footer isRefreshing]) {
            [self.collectionView.mj_footer endRefreshing];
        }
        NSLog(@"获取相册图片 -- %@",responseResult);
        if ([responseResult objectForKey:@"resError"]) {
            _count --;
            [self showHint:@"服务器不给力，请稍后重试"];
        }else{
            if ([[responseResult objectForKey:@"result"] integerValue] == 1) {
                
                NSArray *sections = [responseResult objectForKey:@"data"];
                if (sections.count > 0) {
                    //遍历一共有多少个日期
                    for (NSDictionary *dic in sections) {
                        [self.dataSourceArr addObject:dic];
                    }
                }
                
                [self.collectionView reloadData];
            }else{
                _count --;
                if ([responseResult objectForKey:@"msg"]) {
                    [self showHint:[responseResult objectForKey:@"msg"]];
                }
            }
        }
    }];
    
}

- (void)deleteImageWithPhotoId:(NSNumber *)photoid{
    //删除图片
    NSString *url = [NSString stringWithFormat:@"%@%@",BaseUrl,@"/my/delimg.html"];
    NSDictionary *param = @{@"token":UserToken, @"id":photoid};
    _dataTask = [[SYHttpRequest sharedInstance] getDataWithUrl:url Parameter:param ResponseObject:^(NSDictionary *responseResult) {
        
        NSLog(@"删除相册图片 -- %@",responseResult);
        if ([responseResult objectForKey:@"resError"]) {
            [self showHint:@"服务器不给力，请稍后重试"];
        }else{
            if ([[responseResult objectForKey:@"result"] integerValue] == 1) {
                
            }else{
                if ([responseResult objectForKey:@"msg"]) {
                    [self showHint:[responseResult objectForKey:@"msg"]];
                }
            }
        }
    }];
}

#pragma mark - loadCollectionView
- (void)loadCollectionView{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    
    self.flowLayout = layout;
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    layout.itemSize = CGSizeMake((kScreenWidth - 60) / 3, (kScreenWidth - 60) / 3);
    layout.minimumLineSpacing = 10;
    layout.headerReferenceSize = CGSizeMake(kScreenWidth, 40);
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight) collectionViewLayout:layout];
    self.collectionView.contentOffset = CGPointMake(0, totleOffset);
    self.collectionView.contentInset = UIEdgeInsetsMake(totleOffset, 0, 0, 0);
    self.collectionView.showsVerticalScrollIndicator = NO;
    [self.collectionView registerNib:[UINib nibWithNibName:@"SYMyAlbumInfosCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:identifier];
    [self.collectionView registerNib:[UINib nibWithNibName:@"SYFromTeacherOrGrapherCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:identifier1];
    
    [self.collectionView registerNib:[UINib nibWithNibName:@"SYMyAlbumInfosHeaderCollectionReusableView" bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:headerIdentifier];
    
    self.collectionView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        [self getMoreData];
    }];
    self.collectionView.backgroundColor = BackGroundColor;
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    [self.view addSubview:self.collectionView];
}

#pragma mark - layzload
- (UIView *)upView{
    if (!_upView) {
        _upView = [[UIView alloc] initWithFrame:CGRectMake(0, -totleOffset, kScreenWidth, totleOffset)];
        
        
        _upImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"wdxc_bg"]];
        _upImageView.contentMode = UIViewContentModeScaleAspectFill;
        if (!self.isNotFromMine) {
            _upImageView.frame=CGRectMake(0, 0 , kScreenWidth, totleOffset - 50);
        }else{
            _upImageView.frame=CGRectMake(0, 0 , kScreenWidth, totleOffset);
        }
        
        _upImageView.userInteractionEnabled = YES;
        [_upView addSubview:_upImageView];
        
        _photoNameBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _photoNameBtn.frame = CGRectMake(0, 0, kScreenWidth, 30);
        _photoNameBtn.center = CGPointMake(_upImageView.frame.size.width / 2, _upImageView.frame.size.height / 2);
        [_photoNameBtn setTitle:self.photoName forState:UIControlStateNormal];
        [_photoNameBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        if (!self.isNotFromMine) {
            [_photoNameBtn addTarget:self action:@selector(changePhotoName:) forControlEvents:UIControlEventTouchUpInside];
        }
        [_upView addSubview:_photoNameBtn];
        
        if (!self.isNotFromMine) {
            _updateImageBtn = [[UIButton alloc] initWithFrame:CGRectMake(30, CGRectGetHeight(_upView.frame) - 40, kScreenWidth - 60, 40)];
            [_updateImageBtn setTitle:@"本地上传" forState:UIControlStateNormal];
            [_updateImageBtn setTitleColor:NavigationColor forState:UIControlStateNormal];
            _updateImageBtn.titleLabel.font = [UIFont systemFontOfSize:15];
            _updateImageBtn.layer.masksToBounds = YES;
            _updateImageBtn.layer.borderColor = NavigationColor.CGColor;
            _updateImageBtn.layer.borderWidth = 1;
            [_updateImageBtn addTarget:self action:@selector(updatePhotoAction:) forControlEvents:UIControlEventTouchUpInside];
            [_upView addSubview:_updateImageBtn];
        }
        
    }
    return _upView;
}

- (NSMutableArray *)selectedPhotos{
    if (!_selectedPhotos) {
        _selectedPhotos = [NSMutableArray arrayWithCapacity:0];
    }
    return _selectedPhotos;
}

- (NSMutableArray *)imagesArr{
    if (!_imagesArr) {
        _imagesArr = [NSMutableArray arrayWithCapacity:0];
    }
    return _imagesArr;
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
//在当前window添加进度条
- (CircleProgressView *)progressView{
    if (!_progressView) {
        _progressView = [[CircleProgressView alloc] initWithFrame:CGRectMake(0, 0, 80, 80)];
        _progressView.center = CGPointMake(kScreenWidth / 2, kScreenHeight / 2);

    }
    return _progressView;
}
@end
