//
//  SYTeacherAndGrapherInfosViewController.m
//  ShuoYing
//
//  Created by 硕影 on 2017/1/11.
//  Copyright © 2017年 硕影. All rights reserved.
//

#import "SYTeacherAndGrapherInfosViewController.h"

#import "SYTeacherAndGrapherCollectionViewCell.h"

#import "SYNewAlbumModel.h"

#import "XLPhotoBrowser.h"

#import "SYTeacherAndGrapherModel.h"

#import "SYPaymentInfosViewController.h"
#import "CircleProgressView.h"

#import "LXNetworking.h"
#import "ZLPhotoTool.h"
#import <Photos/Photos.h>
@interface SYTeacherAndGrapherInfosViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,XLPhotoBrowserDelegate,XLPhotoBrowserDatasource>
{
    NSInteger _count;
    UIButton *_rightBtn;
    UIView *_bottomView;
    UIButton *_deleteBtn;
    UIButton *_allBtn;
}

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, strong) UICollectionViewFlowLayout *flowLayout;

@property (nonatomic, strong) NSMutableArray *dataSourceArr;

@property (nonatomic, strong) NSMutableArray *dicsArr;

@property (nonatomic, strong) XLPhotoBrowser *photoBrowser;

@property (nonatomic, strong) CircleProgressView *progressView;

@end

static NSString *identifier = @"cell";

@implementation SYTeacherAndGrapherInfosViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self getData];

}

- (void)viewDidLoad {
    [super viewDidLoad];
    _count = 1;
    [self loadCollectionView];
    [self rightBarButtonItem];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.dataSourceArr.count;
}

- (void)rightBarButtonItem{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 0, 44, 44);
    [btn addTarget:self action:@selector(editAction:) forControlEvents:UIControlEventTouchUpInside];
    [btn setTitle:@"管理" forState:UIControlStateNormal];
    [btn setTitle:@"完成" forState:UIControlStateSelected];

    btn.titleLabel.font = [UIFont systemFontOfSize:16];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _rightBtn = btn;
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:btn];
    
    self.navigationItem.rightBarButtonItem = item;
}

- (void)editAction:(UIButton *)sender{
    sender.selected = !sender.selected;
    if (!sender.selected) {
        [_bottomView removeFromSuperview];
        self.collectionView.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight - kNavigationBarHeightAndStatusBarHeight);
    }else{
        [self initBottomView];
        self.collectionView.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight - kNavigationBarHeightAndStatusBarHeight - 50);

    }
    [self.collectionView reloadData];
}

- (void)initBottomView{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, kScreenHeight - kNavigationBarHeightAndStatusBarHeight - 50, kScreenWidth, 50)];
    view.backgroundColor = [UIColor whiteColor];
    _bottomView = view;
    [self.view addSubview:view];
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 1)];
    lineView.backgroundColor = HexRGB(0xeaeaea);
    [view addSubview:lineView];
    
    UIButton *allBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [allBtn setFrame:CGRectMake(12, 12, 100, 25)];
    [allBtn setImage:[UIImage imageNamed:@"unchecked"] forState:UIControlStateNormal];
    [allBtn setImage:[UIImage imageNamed:@"selected"] forState:UIControlStateSelected];
    [allBtn setTitle:@"全选" forState:UIControlStateNormal];
    [allBtn setTitleColor:HexRGB(0x434343) forState:UIControlStateNormal];
    allBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    allBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [allBtn setAdjustsImageWhenHighlighted:NO];
    [allBtn addTarget:self action:@selector(selecteAllAction:) forControlEvents:UIControlEventTouchUpInside];
    [allBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 10, 0, -10)];
    _allBtn = allBtn;
    [view addSubview:allBtn];
    
    UIButton *deleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [deleBtn setFrame:CGRectMake(kScreenWidth - 156, 1, 156, 49)];
    [deleBtn setBackgroundImage:[UIImage imageWithColor:NavigationColor Size:deleBtn.frame.size] forState:UIControlStateNormal];
    [deleBtn setTitle:@"删除" forState:UIControlStateNormal];
    [deleBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    deleBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    allBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    [deleBtn setAdjustsImageWhenHighlighted:NO];
    [deleBtn addTarget:self action:@selector(deleteAction:) forControlEvents:UIControlEventTouchUpInside];
    _deleteBtn = deleBtn;
    [view addSubview:deleBtn];
}

- (void)selecteAllAction:(UIButton *)sender{
    sender.selected = !sender.selected;
    for (SYTeacherAndGrapherModel *model in self.dataSourceArr) {
        model.isSelected = [NSNumber numberWithBool:sender.selected];
    }
    [self jisuanHaveSelectePhoto];
    [self.collectionView reloadData];
}

- (void)deleteAction:(UIButton *)sender{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"此操作将会同时删除您和传送人传送历史中的此照片，您确定要删除吗？" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSString *url = [NSString stringWithFormat:@"%@%@",BaseUrl, @"/my/img_del.html"];
        NSDictionary *param = nil;
        NSMutableArray *muArr = [NSMutableArray arrayWithCapacity:0];
        for (SYTeacherAndGrapherModel *model in self.dataSourceArr) {
            if ([model.isSelected boolValue]) {
                NSString *ids = [model.ID stringValue];
                [muArr addObject:ids];
            }
        }
        if ([self.title isEqualToString:@"老师传送"]) {
            param = @{@"token":UserToken, @"type":@"teacher", @"id":[muArr componentsJoinedByString:@","]};
        }else if ([self.title isEqualToString:@"摄影师传送"]){
            param = @{@"token":UserToken, @"type":@"pho", @"id":[muArr componentsJoinedByString:@","]};
        }
        NSLog(@"param - %@",param);
        [[SYHttpRequest sharedInstance] getDataWithUrl:url Parameter:param ResponseObject:^(NSDictionary *responseResult) {
            NSLog(@"responseResult - %@",responseResult);
            if ([responseResult objectForKey:@"resError"]) {
                [self showHint:@"请检查您的网络"];
            }else{
                if ([[responseResult objectForKey:@"result"] integerValue] == 1) {
                    [self editAction:_rightBtn];
                    [self getData];

                }else{
                    [self showHint:[responseResult objectForKey:@"msg"]];
                }
            }
        }];

    }];
    UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alert addAction:action];
    [alert addAction:action1];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)jisuanHaveSelectePhoto{
    NSInteger count = 0;
    for (SYTeacherAndGrapherModel *model in self.dataSourceArr) {
        if ([model.isSelected boolValue]) {
            count ++;
        }
    }
    if (count == self.dataSourceArr.count) {
        _allBtn.selected = YES;
    }else{
        _allBtn.selected = NO;
    }
    [_deleteBtn setTitle:[NSString stringWithFormat:@"删除(%ld)",count] forState:UIControlStateNormal];
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    SYTeacherAndGrapherCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    
    SYTeacherAndGrapherModel *model = self.dataSourceArr[indexPath.item];
    cell.model = model;
    cell.isEdit = _rightBtn.selected;
    __weak typeof(self)weakself = self;
    cell.editBlock = ^{
        BOOL value = [model.isSelected boolValue];
        model.isSelected = value?@NO:@YES;
        [weakself jisuanHaveSelectePhoto];

        [weakself.collectionView reloadData];
    };
    
    cell.alipyBlock = ^(SYTeacherAndGrapherCollectionViewCell *cell){
        if ([self.title isEqualToString:@"老师传送"]) {
            [self shifou0YuanWithPhotoId:[model.ID stringValue] type:@2 indexPath:indexPath];
        }else if ([self.title isEqualToString:@"摄影师传送"]){
            [self shifou0YuanWithPhotoId:[model.ID stringValue] type:@1 indexPath:indexPath];
        }else{
            [self shifou0YuanWithPhotoId:[model.ID stringValue] type:@7 indexPath:indexPath];
        }
        
    };
    
    cell.downloadBlock = ^(SYTeacherAndGrapherCollectionViewCell *cell){
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        
        UIView __block *view1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
        view1.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.6];
        [window addSubview:view1];
        [view1 addSubview:self.progressView];
        
        
        [LXNetworking downloadWithUrl:[NSString stringWithFormat:@"%@%@",ImgUrl, cell.model.img] saveToPath:nil progress:^(int64_t bytesProgress, int64_t totalBytesProgress) {
            //封装方法里已经回到主线程，所有这里不用再调主线程了
            _progressView.centerLabel.text = [NSString stringWithFormat:@"%.2f%@",1.0 * bytesProgress/totalBytesProgress,@"%"];
            [_progressView setPercent:1.0 * bytesProgress/totalBytesProgress];
            
        } success:^(id response) {
            NSLog(@"---------%@",response);
            [view1 removeFromSuperview];
            _progressView = nil;
            [self saveImageToPhoto:[NSURL URLWithString:(NSString *)response]];

        } failure:^(NSError *error) {
            
        } showHUD:NO];
        
    };
    return cell;
}

#pragma mark - 下载时候调用接口判断是不是0元，0元直接下载
- (void)shifou0YuanWithPhotoId:(NSString *)photoId type:(NSNumber *)type indexPath:(NSIndexPath *)indepath{
    [SVProgressHUD show];

    NSString *url = [NSString stringWithFormat:@"%@%@",BaseUrl,@"/alpay/pay.html"];
    NSDictionary *param = @{@"type":type, @"token":UserToken, @"id":photoId, @"paytype":@"APP"};
    __weak typeof(self)weakself = self;
    [[SYHttpRequest sharedInstance] getDataWithUrl:url Parameter:param ResponseObject:^(NSDictionary *responseResult) {
        [SVProgressHUD dismiss];
        NSLog(@"是否0元 -- %@",responseResult);
        if ([responseResult objectForKey:@"resError"]) {
            [self showHint:@"服务器不给力，请稍后重试"];
            return ;
        }else{
            if ([[responseResult objectForKey:@"result"] integerValue] == 1) {
                SYPaymentInfosViewController *payment = nil;

                if ([type  isEqual: @1]) {
                    payment = [[SYPaymentInfosViewController alloc] initWithType:isFromGrapher];
                }else if ([type  isEqual: @2]){
                    payment = [[SYPaymentInfosViewController alloc] initWithType:isFromTeacher];
                }else{
                    payment = [[SYPaymentInfosViewController alloc] initWithType:isFromGroup];
                }
                
                payment.dataSourceDic = weakself.dicsArr[indepath.item];
                
                [weakself.navigationController pushViewController:payment animated:YES];
                
            }else if([[responseResult objectForKey:@"result"] integerValue] == 4){
                
                UIWindow *window = [UIApplication sharedApplication].keyWindow;
                
                UIView __block *view1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
                view1.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.6];
                [window addSubview:view1];
                [view1 addSubview:self.progressView];
                
                
                [LXNetworking downloadWithUrl:[NSString stringWithFormat:@"%@%@",ImgUrl, [responseResult objectForKey:@"img"]] saveToPath:nil progress:^(int64_t bytesProgress, int64_t totalBytesProgress) {
                    //封装方法里已经回到主线程，所有这里不用再调主线程了
                    _progressView.centerLabel.text = [NSString stringWithFormat:@"%.2f%@",1.0 * bytesProgress/totalBytesProgress,@"%"];
                    [_progressView setPercent:1.0 * bytesProgress/totalBytesProgress];
                    
                } success:^(id response) {
                    NSLog(@"---------%@",response);
                    [view1 removeFromSuperview];
                    _progressView = nil;
                    [self saveImageToPhoto:[NSURL URLWithString:(NSString *)response]];
                    
                } failure:^(NSError *error) {
                    
                } showHUD:NO];
                
            }else{
                if ([responseResult objectForKey:@"msg"]) {
                    [self showHint:[responseResult objectForKey:@"msg"]];
                }
            }
        }
    }];

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

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    // 快速创建并进入浏览模式
    XLPhotoBrowser *browser = [XLPhotoBrowser showPhotoBrowserWithCurrentImageIndex:indexPath.item imageCount:self.dataSourceArr.count datasource:self];
    self.photoBrowser = browser;
    browser.browserStyle = XLPhotoBrowserStyleIndexLabel;
    
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
    [self.collectionView registerNib:[UINib nibWithNibName:@"SYTeacherAndGrapherCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:identifier];
    [self.view addSubview:self.collectionView];
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
    SYTeacherAndGrapherModel *model = self.dataSourceArr[index];

    NSString *imageUrl = model.img_min;
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",ImgUrl,imageUrl]];
}


- (void)getData{
    NSString *url = @"";
    if ([self.title isEqualToString:@"老师传送"]) {
        url = [NSString stringWithFormat:@"%@%@",BaseUrl,@"/my/teacherphoto.html"];
    }else if ([self.title isEqualToString:@"摄影师传送"]){
        url = [NSString stringWithFormat:@"%@%@",BaseUrl,@"/my/phophoto.html"];
    }else{
        url = [NSString stringWithFormat:@"%@%@",BaseUrl,@"/my/groupphoto.html"];
    }
    NSDictionary *param = @{@"token":UserToken, @"page":@1, @"time":self.model.time};
    [[SYHttpRequest sharedInstance] getDataWithUrl:url Parameter:param ResponseObject:^(NSDictionary *responseResult) {
        _count = 1;
        if ([self.collectionView.mj_header isRefreshing]) {
            [self.collectionView.mj_header endRefreshing];
        }
        NSLog(@"获取上传-摄影师-相册详情 -- %@",responseResult);
        if ([responseResult objectForKey:@"resError"]) {
            [self showHint:@"服务器不给力，请稍后重试"];
        }else{
            if ([[responseResult objectForKey:@"result"] integerValue] == 1) {
                if ([responseResult objectForKey:@"data"]) {
                    NSArray *data = [responseResult objectForKey:@"data"];
                    if (data.count == 0) {
                        [self.navigationController popViewControllerAnimated:YES];
                        return ;
                    }
                    if (data.count >= 10) {
                        [self.collectionView.mj_footer resetNoMoreData];
                    }
                    if (data.count < 10 || data.count == 0) {
                        [self.collectionView.mj_footer endRefreshingWithNoMoreData];
                    }
                    if (data.count >= 0) {
                        [self.dicsArr removeAllObjects];
                        [self.dicsArr addObjectsFromArray:data];
                        [self.dataSourceArr removeAllObjects];
                        for (NSDictionary *dic in data) {
                            NSMutableDictionary *muDic = [NSMutableDictionary dictionaryWithCapacity:0];
                            [muDic setDictionary:dic];
                            [muDic setObject:[NSNumber numberWithBool:NO] forKey:@"isSelected"];
                            SYTeacherAndGrapherModel *model = [SYTeacherAndGrapherModel modelWithDictionary:muDic];
                            [self.dataSourceArr addObject:model];
                        }
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
    NSString *url = @"";
    if ([self.title isEqualToString:@"老师传送"]) {
        url = [NSString stringWithFormat:@"%@%@",BaseUrl,@"/my/teacherphoto.html"];
    }else if ([self.title isEqualToString:@"摄影师传送"]){
        url = [NSString stringWithFormat:@"%@%@",BaseUrl,@"/my/phophoto.html"];
    }else{
        url = [NSString stringWithFormat:@"%@%@",BaseUrl,@"/my/groupphoto.html"];
    }
    NSDictionary *param = @{@"token":UserToken, @"page":[NSNumber numberWithInteger:_count], @"time":self.model.time};
    [[SYHttpRequest sharedInstance] getDataWithUrl:url Parameter:param ResponseObject:^(NSDictionary *responseResult) {
        
        if ([self.collectionView.mj_footer isRefreshing]) {
            [self.collectionView.mj_footer endRefreshing];
        }
        NSLog(@"获取上传-摄影师-相册详情 -- %@",responseResult);
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
                        [self.dicsArr addObjectsFromArray:data];

                        for (NSDictionary *dic in data) {
                            NSMutableDictionary *muDic = [NSMutableDictionary dictionaryWithCapacity:0];
                            [muDic setDictionary:dic];
                            [muDic setObject:[NSNumber numberWithBool:NO] forKey:@"isSelected"];
                            SYTeacherAndGrapherModel *model = [SYTeacherAndGrapherModel modelWithDictionary:muDic];
                            [self.dataSourceArr addObject:model];
                        }
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

//在当前window添加进度条
- (CircleProgressView *)progressView{
    if (!_progressView) {
        _progressView = [[CircleProgressView alloc] initWithFrame:CGRectMake(0, 0, 80, 80)];
        _progressView.center = CGPointMake(kScreenWidth / 2, kScreenHeight / 2);

    }
    return _progressView;
}

- (NSMutableArray *)dicsArr{
    if (!_dicsArr) {
        _dicsArr = [NSMutableArray arrayWithCapacity:0];
    }
    return _dicsArr;
}

@end
