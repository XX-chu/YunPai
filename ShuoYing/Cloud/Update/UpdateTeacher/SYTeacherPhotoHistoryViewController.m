//
//  SYTeacherPhotoHistoryViewController.m
//  ShuoYing
//
//  Created by 硕影 on 2017/1/9.
//  Copyright © 2017年 硕影. All rights reserved.
//

#import "SYTeacherPhotoHistoryViewController.h"

#import "SYTeacherPhotoHistoryCollectionViewCell.h"

@interface SYTeacherPhotoHistoryViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,XLPhotoBrowserDelegate,XLPhotoBrowserDatasource>
{
    NSInteger _count;
    
    UIButton *_allBtn;
    UIButton *_deleteBtn;
    UIView *_editBottomView;
    UIView *_updateBottomView;
    UIButton *_rightBtn;
}

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, strong) UICollectionViewFlowLayout *flowLayout;

@property (nonatomic, strong) NSMutableArray *dataSourceArr;

@property (nonatomic, strong) NSMutableArray *browserImagesArr;

@property (nonatomic, strong) XLPhotoBrowser *photoBrowser;

@end

static NSString *identifier = @"teacherHistory";

@implementation SYTeacherPhotoHistoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _count = 1;
    self.title = self.time;
    [self loadCollectionView];
    [self rightBarButtonItem];
    [self getData];
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
        [_editBottomView removeFromSuperview];
        _updateBottomView.hidden = NO;
        self.collectionView.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight - kNavigationBarHeightAndStatusBarHeight);
    }else{
        [self initEditBottomView];
        _updateBottomView.hidden = YES;
        self.collectionView.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight - kNavigationBarHeightAndStatusBarHeight - 50);
        
    }
    [self.collectionView reloadData];
}

- (void)initEditBottomView{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, kScreenHeight - kNavigationBarHeightAndStatusBarHeight - 50, kScreenWidth, 50)];
    view.backgroundColor = [UIColor whiteColor];
    _editBottomView = view;
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
    
    for (int i = 0; i < self.dataSourceArr.count; i++) {
        NSDictionary *dic = self.dataSourceArr[i];
        NSMutableDictionary *muDic = [NSMutableDictionary dictionaryWithCapacity:0];
        [muDic setDictionary:dic];
        [muDic setObject:[NSNumber numberWithBool:sender.selected] forKey:@"isSelected"];
        [self.dataSourceArr replaceObjectAtIndex:i withObject:muDic];
    }
    [self jisuanHaveSelectePhoto];
    [self.collectionView reloadData];
}

- (void)deleteAction:(UIButton *)sender{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"此操作将会同时删除您和传送人传送历史中的此照片，您确定要删除吗？" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSString *url = [NSString stringWithFormat:@"%@%@",BaseUrl, @"/my/img_del.html"];
        NSMutableArray *muArr = [NSMutableArray arrayWithCapacity:0];
        for (NSDictionary *dic in self.dataSourceArr) {
            if ([[dic objectForKey:@"isSelected"] boolValue]) {
                NSString *ids = [dic objectForKey:@"id"];
                [muArr addObject:ids];
            }
        }
        NSDictionary *param = @{@"token":UserToken, @"type":@"teacher", @"id":[muArr componentsJoinedByString:@","]};
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
    for (NSDictionary *dic in self.dataSourceArr) {
        if ([[dic objectForKey:@"isSelected"] boolValue]) {
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
    
    __weak typeof(self)weakself = self;
    NSDictionary *dic = self.dataSourceArr[indexPath.item];
    if (_rightBtn.selected) {
        cell.editBtn.hidden = NO;
        
    }else{
        cell.editBtn.hidden = YES;
    }
    if ([[dic objectForKey:@"isSelected"] boolValue]) {
        [cell.editBtn setImage:[UIImage imageNamed:@"selected"] forState:UIControlStateNormal];
        
    }else{
        [cell.editBtn setImage:[UIImage imageNamed:@"unchecked"] forState:UIControlStateNormal];
        
    }
    NSMutableDictionary *muDic = [NSMutableDictionary dictionaryWithCapacity:0];
    [muDic setDictionary:dic];
    cell.editBlock = ^{
        BOOL value = [[dic objectForKey:@"isSelected"] boolValue];
        [muDic setObject:[NSNumber numberWithBool:!value] forKey:@"isSelected"];
        [weakself.dataSourceArr replaceObjectAtIndex:indexPath.item withObject:muDic];
        [weakself jisuanHaveSelectePhoto];
        
        [weakself.collectionView reloadData];
    };
    
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
    _count = 1;
    NSString *url = [NSString stringWithFormat:@"%@%@",BaseUrl,@"/teacher/getimg.html"];
    NSDictionary *param = @{@"token":UserToken, @"id":self.studentID, @"page":@1, @"time":self.time};
    [[SYHttpRequest sharedInstance] getDataWithUrl:url Parameter:param ResponseObject:^(NSDictionary *responseResult) {
        _count = 1;
        if ([self.collectionView.mj_header isRefreshing]) {
            [self.collectionView.mj_header endRefreshing];
        }
        NSLog(@"获取老师上传照片历史详情 -- %@",responseResult);
        if ([responseResult objectForKey:@"resError"]) {
            
        }else{
            if ([[responseResult objectForKey:@"result"] integerValue] == 1) {
                
                [self.dataSourceArr removeAllObjects];
                if ([responseResult objectForKey:@"data"]) {
                    NSArray *data = [responseResult objectForKey:@"data"];
                    NSMutableArray *muArr = [NSMutableArray arrayWithCapacity:0];
                    for (NSDictionary *dic in data) {
                        NSMutableDictionary *muDic = [NSMutableDictionary dictionaryWithCapacity:0];
                        
                        [muDic setDictionary:dic];
                        [muDic setObject:[NSNumber numberWithBool:NO] forKey:@"isSelected"];
                        [muArr addObject:muDic];
                    }
                    [self.dataSourceArr addObjectsFromArray:muArr];

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
    NSString *url = [NSString stringWithFormat:@"%@%@",BaseUrl,@"/teacher/getimg.html"];
    NSDictionary *param = @{@"token":UserToken, @"id":self.studentID, @"page":[NSNumber numberWithInteger:_count], @"time":self.time};
    [[SYHttpRequest sharedInstance] getDataWithUrl:url Parameter:param ResponseObject:^(NSDictionary *responseResult) {
        
        if ([self.collectionView.mj_footer isRefreshing]) {
            [self.collectionView.mj_footer endRefreshing];
        }
        NSLog(@"获取老师上传照片历史详情 -- %@",responseResult);
        if ([responseResult objectForKey:@"resError"]) {
            _count --;
        }else{
            if ([[responseResult objectForKey:@"result"] integerValue] == 1) {
                
                if ([responseResult objectForKey:@"data"]) {
                    NSArray *data = [responseResult objectForKey:@"data"];
                    NSMutableArray *muArr = [NSMutableArray arrayWithCapacity:0];
                    for (NSDictionary *dic in data) {
                        NSMutableDictionary *muDic = [NSMutableDictionary dictionaryWithCapacity:0];
                        
                        [muDic setDictionary:dic];
                        [muDic setObject:[NSNumber numberWithBool:NO] forKey:@"isSelected"];
                        [muArr addObject:muDic];
                    }
                    [self.dataSourceArr addObjectsFromArray:muArr];
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
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight - kNavigationBarHeightAndStatusBarHeight) collectionViewLayout:layout];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.backgroundColor = BackGroundColor;
    [self.collectionView registerNib:[UINib nibWithNibName:@"SYTeacherPhotoHistoryCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:identifier];
    self.collectionView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [self getData];
    }];
    self.collectionView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        [self getMoreData];
    }];
    [self.view addSubview:self.collectionView];
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
