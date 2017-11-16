//
//  SYPhotoListViewController.m
//  ShuoYing
//
//  Created by 硕影 on 2017/5/9.
//  Copyright © 2017年 硕影. All rights reserved.
//

#import "SYPhotoListViewController.h"
#import "SYPhotoListCollectionViewCell.h"
#import "SYNewAlbumModel.h"
#import "SYShopcartSelectePhotoTableViewCell.h"
#import "SYMyPhotoModel.h"
@interface SYPhotoListViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout,UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate>
{
    NSInteger _count;
    UIView *_backView;
    
    NSNumber *_currentPhotoID;
    NSInteger _currentSelecteAlbum;
    
    NSInteger _haveUpdataCount;
    UILabel *_kexuanLabel;
}

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, strong) NSMutableArray *myAlbumDataSource;

@property (nonatomic, strong) UIView *noDataView;

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSMutableDictionary *dataSourceDic;

@property (nonatomic, strong) NSMutableArray *currentDataSourceArr;//当前在页面上显示的数据源

@property (nonatomic, strong) NSMutableArray *haveSelectePhotoArr;//选中的照片

@property (nonatomic, strong) NSMutableArray *haveSelecteAlbumID;//选中的相册id

@end

static NSString *photoListCell = @"photoListCell";

@implementation SYPhotoListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"我的空间";
    _currentSelecteAlbum = 0;
    _count = 1;
    _currentPhotoID = nil;
    _haveUpdataCount = 0;
    [self initCollectionView];
    [self getDataFromMine];
    [self initBottomView];
    [self initRightBarButtonItem];
}

- (void)initRightBarButtonItem{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 0, 40, 40);
    [btn setTitle:@"完成" forState:UIControlStateNormal];
    [btn setAdjustsImageWhenHighlighted:NO];
    btn.titleLabel.font = [UIFont systemFontOfSize:15];
    [btn addTarget:self action:@selector(getData) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.currentDataSourceArr.count;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    SYPhotoListCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:photoListCell forIndexPath:indexPath];
    cell.myPhoto = self.currentDataSourceArr[indexPath.item];
    __weak typeof(self)weakself = self;
    cell.block = ^{
        //选择按钮
        SYMyPhotoModel *model = self.currentDataSourceArr[indexPath.item];
        if ([model.isSelected boolValue]) {
            model.isSelected = @NO;
            [weakself.haveSelectePhotoArr removeObject:model];
        }else{
            if (weakself.haveSelectePhotoArr.count >= weakself.canSelecteCount) {
                [weakself showHint:[NSString stringWithFormat:@"您最多可选%ld张照片",weakself.canSelecteCount]];
                _kexuanLabel.text = [NSString stringWithFormat:@"您还可选%ld张照片",(weakself.canSelecteCount - weakself.haveSelectePhotoArr.count)];
                return ;
            }
            model.isSelected = @YES;
            [weakself.haveSelectePhotoArr addObject:model];
        }
        _kexuanLabel.text = [NSString stringWithFormat:@"您还可选%ld张照片",(weakself.canSelecteCount - weakself.haveSelectePhotoArr.count)];
        
        SYNewAlbumModel *albumModel = self.myAlbumDataSource[_currentSelecteAlbum];
        NSArray *dataArr = [self.dataSourceDic objectForKey:[albumModel.albumId stringValue]];
        for (SYMyPhotoModel *model in dataArr) {
            if ([model.isSelected boolValue]) {
                albumModel.isSelected = @YES;
                break;
            }else{
                albumModel.isSelected = @NO;
            }
        }
        for (SYNewAlbumModel *model in self.myAlbumDataSource) {
            if ([model.isSelected boolValue]) {
                [self.haveSelecteAlbumID addObject:[model.albumId stringValue]];
            }else{
                [self.haveSelecteAlbumID removeObject:[model.albumId stringValue]];
            }
        }
        [weakself.collectionView reloadData];
    };
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{

}

//请求所有的相册
- (void)getDataFromMine{
    [SVProgressHUD show];
    NSString *url = [NSString stringWithFormat:@"%@%@",BaseUrl,@"/my/album.html"];
    NSDictionary *param = @{@"token":UserToken};
    [[SYHttpRequest sharedInstance] getDataWithUrl:url Parameter:param ResponseObject:^(NSDictionary *responseResult) {
        [SVProgressHUD dismiss];
        NSLog(@"获取上传-我的-所有相册目录 -- %@",responseResult);
        if ([responseResult objectForKey:@"resError"]) {
            [self showHint:@"服务器不给力，请稍后重试"];
        }else{
            if ([[responseResult objectForKey:@"result"] integerValue] == 1) {
                NSArray *data = [responseResult objectForKey:@"data"];
                if (data.count > 0) {
                    [self.myAlbumDataSource removeAllObjects];
                    for (NSDictionary *dic in data) {
                        NSMutableDictionary *muDic = [NSMutableDictionary dictionaryWithDictionary:dic];
                        [muDic setObject:@1 forKey:@"jiazaiCount"];
                        [muDic setObject:@NO forKey:@"isSelected"];
                        SYNewAlbumModel *model = [SYNewAlbumModel albumWithDictionary:dic];
                        [self.myAlbumDataSource addObject:model];
                        NSString *key = [model.albumId stringValue];
                        NSMutableArray *muArr = [NSMutableArray arrayWithCapacity:0];
                        [self.dataSourceDic setObject:muArr forKey:key];
                    }
                    NSDictionary *dic = data[0];
                    [self getDataWith:[dic objectForKey:@"id"]];
                }
            }else{
                [self.view addSubview:self.noDataView];
                if ([responseResult objectForKey:@"msg"]) {
                    [self showHint:[responseResult objectForKey:@"msg"]];
                }
            }
        }
    }];
}
//上传照片
- (void)getData{
    [SVProgressHUD show];
    NSMutableSet *muSet = [NSMutableSet setWithArray:self.haveSelecteAlbumID];
    NSArray *arr = [muSet allObjects];
    NSMutableDictionary *dataSourceDic = [NSMutableDictionary dictionaryWithCapacity:0];
    for (NSString *albumID in arr) {
        NSMutableArray *photos = [NSMutableArray arrayWithCapacity:0];
        NSArray *photoArr = [self.dataSourceDic objectForKey:albumID];
        for (SYMyPhotoModel *model in photoArr) {
            if ([model.isSelected boolValue]) {
                [photos addObject:[model.photoID stringValue]];
            }
        }
        NSString *photosStr = [photos componentsJoinedByString:@","];
        [dataSourceDic setObject:photosStr forKey:albumID];
    }
    NSLog(@"dataSourceDic - %@",dataSourceDic);
    
    NSString *url = [NSString stringWithFormat:@"%@%@",BaseUrl, @"/store/selimg.html"];
    
    NSDictionary *param = @{@"token":UserToken, @"cart":self.gouwucheID, @"ids":dataSourceDic};
    NSLog(@"param - %@",param);
    __weak typeof(self)weakself = self;
    [[SYHttpRequest sharedInstance] getDataWithUrl:url Parameter:param ResponseObject:^(NSDictionary *responseResult) {
        
        [SVProgressHUD dismiss];
        NSLog(@"上传已有照片 -- %@",responseResult);
        if ([responseResult objectForKey:@"resError"]) {
        }else{
            if ([[responseResult objectForKey:@"result"] integerValue] == 1) {
                [weakself showHint:[responseResult objectForKey:@"msg"]];
                [weakself.navigationController popViewControllerAnimated:YES];
            }else{
                if ([responseResult objectForKey:@"msg"]) {
                    [weakself showHint:[responseResult objectForKey:@"msg"]];
                }
            }
        }
    }];
}

- (void)updatePhotoWithAlbum:(NSNumber *)album photoId:(NSNumber *)photoid{
    if (self.haveSelectePhotoArr.count == 0) {
        [self showHint:@"请选择要上传的照片"];
        return;
    }
    [SVProgressHUD show];
    NSString *url = [NSString stringWithFormat:@"%@%@",BaseUrl,@"/store/selimg.html"];
    //对相册数组去重
    NSDictionary *param = @{@"cart":self.gouwucheID, @"token":UserToken, @"id":photoid, @"pid":album};
    NSLog(@"param - %@",param);
    [[SYHttpRequest sharedInstance] getDataWithUrl:url Parameter:param ResponseObject:^(NSDictionary *responseResult) {
        
        [SVProgressHUD dismiss];
        NSLog(@"上传已有照片 -- %@",responseResult);
        if ([responseResult objectForKey:@"resError"]) {
        }else{
            if ([[responseResult objectForKey:@"result"] integerValue] == 1) {
                [self showHint:[responseResult objectForKey:@"msg"]];
            }else{
                if ([responseResult objectForKey:@"msg"]) {
                    [self showHint:[responseResult objectForKey:@"msg"]];
                }
            }
        }
    }];
}

#pragma mark - 读取某个相册的数据
- (void)getDataWith:(NSNumber *)photoID{
    //获取图片
    _currentPhotoID = photoID;
    [SVProgressHUD show];
    NSString *url = [NSString stringWithFormat:@"%@%@",BaseUrl,@"/my/photos.html"];
    NSDictionary *param = @{@"token":UserToken, @"id":photoID, @"page":@1};
    [[SYHttpRequest sharedInstance] getDataWithUrl:url Parameter:param ResponseObject:^(NSDictionary *responseResult) {
        [SVProgressHUD dismiss];
        _count = 1;
        if ([self.collectionView.mj_header isRefreshing]) {
            [self.collectionView.mj_header endRefreshing];
        }
        NSLog(@"获取某个相册图片 -- %@",responseResult);
        if ([responseResult objectForKey:@"resError"]) {
            [self showHint:@"服务器不给力，请稍后重试"];
        }else{
            if ([[responseResult objectForKey:@"result"] integerValue] == 1) {
                NSArray *data = [responseResult objectForKey:@"data"];
                if (data.count > 0) {
                    [self jisuanCountWithPhotoID:photoID withCount:_count];
                    [self.currentDataSourceArr removeAllObjects];
                    for (NSDictionary *dic in data) {
                        NSMutableDictionary *muDic = [NSMutableDictionary dictionaryWithDictionary:dic];
                        [muDic setObject:@NO forKey:@"isSelected"];
                        SYMyPhotoModel *photo = [SYMyPhotoModel photoWithDictionary:muDic];
                        [self.currentDataSourceArr addObject:photo];
                    }
                    NSMutableArray *muArr = [NSMutableArray arrayWithArray:self.currentDataSourceArr];
                    [self.dataSourceDic setObject:muArr forKey:[photoID stringValue]];
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

- (void)getMoreDataWith:(NSNumber *)photoID{
    _currentPhotoID = photoID;
    //获取图片
    _count ++;
    [self jisuanCountWithPhotoID:photoID withCount:_count];
    
    NSString *url = [NSString stringWithFormat:@"%@%@",BaseUrl,@"/my/photos.html"];
    NSDictionary *param = @{@"token":UserToken, @"id":photoID, @"page":[NSNumber numberWithInteger:_count]};
    [[SYHttpRequest sharedInstance] getDataWithUrl:url Parameter:param ResponseObject:^(NSDictionary *responseResult) {
        if ([self.collectionView.mj_footer isRefreshing]) {
            [self.collectionView.mj_footer endRefreshing];
        }
        NSLog(@"获取相册图片 -- %@",responseResult);
        if ([responseResult objectForKey:@"resError"]) {
            _count --;
            [self showHint:@"服务器不给力，请稍后重试"];
        }else{
            if ([[responseResult objectForKey:@"result"] integerValue] == 1) {
                NSArray *data = [responseResult objectForKey:@"data"];
                if (data.count > 0) {
                    for (NSDictionary *dic in data) {
                        NSMutableDictionary *muDic = [NSMutableDictionary dictionaryWithDictionary:dic];
                        [muDic setObject:@NO forKey:@"isSelected"];
                        SYMyPhotoModel *photo = [SYMyPhotoModel photoWithDictionary:muDic];
                        [self.currentDataSourceArr addObject:photo];
                    }
                    NSMutableArray *muArr = [NSMutableArray arrayWithArray:self.currentDataSourceArr];
                    [self.dataSourceDic setObject:muArr forKey:[photoID stringValue]];
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

//计算每组数据源加载到几页
- (void)jisuanCountWithPhotoID:(NSNumber *)photoID withCount:(NSInteger)count{
    for (SYNewAlbumModel *album in self.myAlbumDataSource) {
        if (album.albumId == photoID) {
            album.jiazaiCount = [NSNumber numberWithInteger:count];
        }
    }
}

- (void)initCollectionView{
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.sectionInset = UIEdgeInsetsMake(20, 14, 20, 14);
    flowLayout.itemSize = CGSizeMake((kScreenWidth - 70) / 3, (kScreenWidth - 70) / 3);
    flowLayout.minimumLineSpacing = 20;
    flowLayout.minimumInteritemSpacing = 20;
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth , kScreenHeight - kNavigationBarHeightAndStatusBarHeight - 55) collectionViewLayout:flowLayout];
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    [self.collectionView registerNib:[UINib nibWithNibName:@"SYPhotoListCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:photoListCell];
//    self.collectionView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
//        [self getDataWith:_currentPhotoID];
//    }];
    self.collectionView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        [self getMoreDataWith:_currentPhotoID];
    }];
    
    [self.view addSubview:self.collectionView];
}

- (UIView *)noDataView{
    if (!_noDataView) {
        _noDataView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight - kNavigationBarHeightAndStatusBarHeight)];
        _noDataView.backgroundColor = RGB(235, 235, 235);
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 130, kScreenWidth, 20)];
        label.text = @"暂无照片";
        label.font = [UIFont systemFontOfSize:15];
        label.textColor = HexRGB(0x828282);
        [_noDataView addSubview:label];
    }
    return _noDataView;
}

- (void)initBottomView{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, kScreenHeight - kNavigationBarHeightAndStatusBarHeight - 55, kScreenWidth, 55)];
    view.backgroundColor = [UIColor whiteColor];
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 1)];
    lineView.backgroundColor = HexRGB(0xeaeaea);
    [view addSubview:lineView];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(14, 18, 76, 20)];
    label.text = @"所有相册";
    label.textColor = HexRGB(0x434343);
    label.font = [UIFont systemFontOfSize:17];
    [view addSubview:label];
    
    UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(100, 18, kScreenWidth - 100 - 14, 20)];
    label1.text = [NSString stringWithFormat:@"您还可选%ld张照片",self.canSelecteCount];
    label1.textColor = HexRGB(0x434343);
    label1.font = [UIFont systemFontOfSize:15];
    label1.textAlignment = NSTextAlignmentRight;
    [view addSubview:label1];
    _kexuanLabel = label1;
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 0, kScreenWidth, 55);
    [btn addTarget:self action:@selector(allPhotos:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:btn];
    [self.view addSubview:view];
}

- (void)allPhotos:(UIButton *)sender{
    if (self.myAlbumDataSource.count > 0) {
        [self tableViewShow];
    }
}

- (NSMutableArray *)myAlbumDataSource{
    if (!_myAlbumDataSource) {
        _myAlbumDataSource = [NSMutableArray arrayWithCapacity:0];
    }
    return _myAlbumDataSource;
}

- (NSMutableDictionary *)dataSourceDic{
    if (!_dataSourceDic) {
        _dataSourceDic = [NSMutableDictionary dictionaryWithCapacity:0];
    }
    return _dataSourceDic;
}

- (NSMutableArray *)currentDataSourceArr{
    if (!_currentDataSourceArr) {
        _currentDataSourceArr = [NSMutableArray arrayWithCapacity:0];
    }
    return _currentDataSourceArr;
}

- (NSMutableArray *)haveSelectePhotoArr{
    if (!_haveSelectePhotoArr) {
        _haveSelectePhotoArr = [NSMutableArray arrayWithCapacity:0];
    }
    return _haveSelectePhotoArr;
}

- (NSMutableArray *)haveSelecteAlbumID{
    if (!_haveSelecteAlbumID) {
        _haveSelecteAlbumID = [NSMutableArray arrayWithCapacity:0];
    }
    return _haveSelecteAlbumID;
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.myAlbumDataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    SYShopcartSelectePhotoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ShopcartSelectePhotoTableViewCell"];
    if (!cell) {
        cell = [[NSBundle mainBundle] loadNibNamed:@"SYShopcartSelectePhotoTableViewCell" owner:nil options:nil][0];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    SYNewAlbumModel *model = self.myAlbumDataSource[indexPath.row];
    [cell.headImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",ImgUrl,model.img]] placeholderImage:NoPicture];
    cell.nameLabel.text = model.file;
    cell.countLabel.text = [NSString stringWithFormat:@"共%ld张",[model.count integerValue]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    _currentSelecteAlbum = indexPath.row;
    SYNewAlbumModel *model = self.myAlbumDataSource[indexPath.row];
    
    NSArray *arr = [self.dataSourceDic objectForKey:[model.albumId stringValue]];
    _currentPhotoID = model.albumId;
    if (arr.count > 0) {
        [self.currentDataSourceArr removeAllObjects];
        [self.currentDataSourceArr addObjectsFromArray:arr];
        NSLog(@"self.currentDataSourceArr - %@",self.currentDataSourceArr);
        [self.collectionView reloadData];
        [self tableViewDismiss];
        return;
    }
    
    [self getDataWith:model.albumId];
    [self tableViewDismiss];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    CGPoint point = [touch locationInView:_backView];
    if (point.x > 14 && point.x < kScreenWidth - 14 && point.y > kScreenHeight - 55 - 16 - 259 && point.y < kScreenHeight - 55 - 16) {
        return NO;
    }

    return YES;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 64;
}

- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth - 28, 259) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
    }
    return _tableView;
}

- (void)tableViewShow{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tableViewDismiss)];
    [view addGestureRecognizer:tap];
    view.userInteractionEnabled = YES;
    tap.delegate = self;
    _backView = view;
    view.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.0];
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    [window addSubview:view];
    
    UIView *view1 = [[UIView alloc] initWithFrame:CGRectMake(14, kScreenHeight, kScreenWidth - 28, 259)];
    view1.backgroundColor = [UIColor whiteColor];

    view1.userInteractionEnabled = YES;
    [view1 addSubview:self.tableView];
    view1.layer.cornerRadius = 5;
//    view1.layer.masksToBounds = YES;
    view1.layer.shadowColor = [UIColor blackColor].CGColor;
    view1.layer.shadowOpacity = .4;
    view1.layer.shadowRadius = 5;
    view1.layer.shadowOffset = CGSizeMake(2,2);
    [view addSubview:view1];
    [UIView animateWithDuration:.5 animations:^{
        view1.frame = CGRectMake(14, kScreenHeight - 55 - 16 - 259, kScreenWidth - 28, 259);
    }];
}

-(void)tableViewDismiss{
    [UIView animateWithDuration:.5 animations:^{
        _backView.frame = CGRectMake(0, kScreenHeight, kScreenWidth, kScreenHeight);
    }completion:^(BOOL finished) {
        
        [_backView removeFromSuperview];
    }];
}

@end
