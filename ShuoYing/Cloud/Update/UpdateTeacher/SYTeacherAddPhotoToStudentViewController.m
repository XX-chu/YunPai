//
//  SYTeacherAddPhotoToStudentViewController.m
//  ShuoYing
//
//  Created by 硕影 on 2017/1/7.
//  Copyright © 2017年 硕影. All rights reserved.
//

#import "SYTeacherAddPhotoToStudentViewController.h"

#import "SYUpdateToStudentCollectionViewCell.h"

#import "CircleProgressView.h"

#import "SYTeacherPhotoHistoryViewController.h"
#import "SYUpdatePreviewViewController.h"
#import "SYUpdateToStudentCollectionReusableView.h"
#import "SYTeacherPhotoHistoryCollectionViewCell.h"

@interface SYTeacherAddPhotoToStudentViewController ()<UICollectionViewDelegateFlowLayout, XLPhotoBrowserDelegate, XLPhotoBrowserDatasource>
{
    NSInteger _count;
    SYUpdateToStudentCollectionReusableView *_headerView;
    CGFloat _headerViewHeight;
    
    CGSize _labelSize;
}
#pragma mark - oldViewLayout
@property (weak, nonatomic) IBOutlet UIButton *updatePhotoBtn;
@property (weak, nonatomic) IBOutlet UILabel *historyLabel;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (weak, nonatomic) IBOutlet UICollectionViewFlowLayout *flowLayout;

#pragma makr - NewViewLayout

@property (weak, nonatomic) IBOutlet UICollectionView *upCollectionView;
@property (weak, nonatomic) IBOutlet UICollectionViewFlowLayout *upFlowLayout;


@property (nonatomic, strong) NSMutableArray *selectedImagesArr;

@property (nonatomic, strong) NSMutableArray *selectedPhotoDatasArr;

@property (nonatomic, strong) NSMutableArray *selectedPhotoModelsArr;


@property (nonatomic, strong) NSMutableArray *dataSourceArr;

@property (nonatomic, strong) XLPhotoBrowser *brower1;

@property (nonatomic, strong) XLPhotoBrowser *brower2;

@end
static NSString *identifier = @"collectionCell";
static NSString *studentheadIdentifier = @"studentheadIdentifier";

@implementation SYTeacherAddPhotoToStudentViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    _count = 1;
    _headerView = nil;
    [self getDataFromCache];
    [self setRightbarItem];
    [self loadNewSubViews];
    
    [self getData];
}

- (void)setRightbarItem{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 0, 44, 44);
    [btn setTitle:@"传送" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:15];
    [btn addTarget:self action:@selector(updatePhotosToStudent:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *right = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    right.width = -15;
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:btn];
    
    self.navigationItem.rightBarButtonItems = @[right, item];
}

- (void)loadNewSubViews{
    self.title = [self.dataSourceDic objectForKey:@"name"];

    self.historyLabel.textColor = NavigationColor;
    if (self.isFromGroupToMember) {
        self.upFlowLayout.itemSize = CGSizeMake((kScreenWidth - 70) / 3, (kScreenWidth - 70) / 3);
    }else{
        self.upFlowLayout.itemSize = CGSizeMake((kScreenWidth - 70) / 3, (kScreenWidth - 70) / 3 + 60);
    }
    
    self.upFlowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    self.upFlowLayout.minimumLineSpacing = 15;
    self.upFlowLayout.sectionInset = UIEdgeInsetsMake(10, 15, 10, 15);
    UILabel *label = [[UILabel alloc] init];
    label.text = @"温馨提示：为保证图片质量，将不对图片进行压缩处理，传送原图时间较长，单次上传不超过15张。";
    label.numberOfLines = 0;
    label.font = [UIFont systemFontOfSize:13];
    CGSize maxSize = CGSizeMake(kScreenWidth - 30, MAXFLOAT);
    CGSize aSize = [label sizeThatFits:maxSize];
    _labelSize = aSize;
    self.upFlowLayout.headerReferenceSize = CGSizeMake(kScreenWidth, 10 + aSize.height + 10 + 30 + 6 + 15 + 70 + 15 + 20);
    _headerViewHeight = 10 + aSize.height + 10 + 30 + 6 + 15 + 70 + 15 + 20;
    if (self.isFromGroupToMember) {
        [self.upCollectionView registerNib:[UINib nibWithNibName:@"SYTeacherPhotoHistoryCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:identifier];
    }else{
        [self.upCollectionView registerNib:[UINib nibWithNibName:@"SYUpdateToStudentCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:identifier];
    }
    
    [self.upCollectionView registerNib:[UINib nibWithNibName:@"SYUpdateToStudentCollectionReusableView" bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:studentheadIdentifier];
    self.upCollectionView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [self getData];
    }];
    self.upCollectionView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        [self getMoreData];
    }];
}

- (void)loadOldSubViews{
    self.title = [self.dataSourceDic objectForKey:@"name"];
    self.updatePhotoBtn.layer.masksToBounds = YES;
    self.updatePhotoBtn.layer.borderColor = NavigationColor.CGColor;
    self.updatePhotoBtn.layer.borderWidth = 1;
    [self.updatePhotoBtn setTitle:@"传送照片" forState:UIControlStateNormal];
    [self.updatePhotoBtn setTitleColor:NavigationColor forState:UIControlStateNormal];
    
    self.historyLabel.textColor = NavigationColor;
    self.flowLayout.itemSize = CGSizeMake((kScreenWidth - 70) / 3, (kScreenWidth - 70) / 3 + 60);
    self.flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    self.flowLayout.minimumLineSpacing = 15;
    self.flowLayout.sectionInset = UIEdgeInsetsMake(10, 15, 10, 15);
    
    [self.collectionView registerNib:[UINib nibWithNibName:@"SYUpdateToStudentCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:identifier];
    self.collectionView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [self getData];
    }];
    self.collectionView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        [self getMoreData];
    }];
}

- (void)getDataFromCache{
    if ([XHNetworkCache cacheJsonWithURL:[NSString stringWithFormat:@"%@%@%@",Mobile,@"teacherUpdateHistory",[[self.dataSourceDic objectForKey:@"id"] stringValue]]]) {
        NSDictionary *responseResult = [XHNetworkCache cacheJsonWithURL:[NSString stringWithFormat:@"%@%@%@",Mobile,@"teacherUpdateHistory",[[self.dataSourceDic objectForKey:@"id"] stringValue]]];
        [self.dataSourceArr removeAllObjects];
        
        if ([responseResult objectForKey:@"data"]) {
            NSArray *data = [responseResult objectForKey:@"data"];
            [self.dataSourceArr addObjectsFromArray:data];
            [self.upCollectionView reloadData];
        }
        
        if (self.dataSourceArr.count > 0) {
            self.historyLabel.text = [NSString stringWithFormat:@"传送历史（%ld）",self.dataSourceArr.count];
        }else{
            self.historyLabel.text = @"传送历史";
        }
    }else{
        [self getData];
        if (self.dataSourceArr.count > 0) {
            self.historyLabel.text = [NSString stringWithFormat:@"传送历史（%ld）",self.dataSourceArr.count];
        }else{
            self.historyLabel.text = @"传送历史";
        }
    }
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.dataSourceArr.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    if (self.isFromGroupToMember) {
        SYTeacherPhotoHistoryCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
        NSDictionary *dic = self.dataSourceArr[indexPath.item];
        [cell.headImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",ImgUrl,[dic objectForKey:@"img_200"]]] placeholderImage:[UIImage imageNamed:@"shangchuan_wode_wutupian"]];
        
        cell.headImageViewHeightConstraint.constant = cell.frame.size.width;
        return cell;
    }else{
        SYUpdateToStudentCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
        NSDictionary *dic = self.dataSourceArr[indexPath.item];
        [cell.contentImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",ImgUrl,[dic objectForKey:@"img"]]] placeholderImage:[UIImage imageNamed:@"shangchuan_wode_wutupian"]];
        cell.timeLabel.text = [dic objectForKey:@"time"];
        cell.infoLabel.text = [NSString stringWithFormat:@"共%@张",[[dic objectForKey:@"count"] stringValue]];
        cell.contentIMGHeightConstraint.constant = cell.frame.size.width;
        return cell;
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if (self.isFromGroupToMember) {
        XLPhotoBrowser *browser = [XLPhotoBrowser showPhotoBrowserWithCurrentImageIndex:indexPath.item imageCount:self.dataSourceArr.count datasource:self];
        self.brower2 = browser;
        browser.browserStyle = XLPhotoBrowserStyleIndexLabel;
    }else{
        SYTeacherPhotoHistoryViewController *historyVC = [[SYTeacherPhotoHistoryViewController alloc] init];
        historyVC.studentID = [self.dataSourceDic objectForKey:@"id"];
        historyVC.time = [self.dataSourceArr[indexPath.item] objectForKey:@"time"];
        [self.navigationController pushViewController:historyVC animated:YES];
    }
    
}


//头视图
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    __weak typeof(self)weakself = self;
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        SYUpdateToStudentCollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:studentheadIdentifier forIndexPath:indexPath];
        headerView.block = ^(){
            [weakself selectedPhotos];
        };
        if (weakself.dataSourceArr.count > 0) {
            headerView.historyLabel.text = [NSString stringWithFormat:@"传送历史（%ld）",self.dataSourceArr.count];
        }else{
            headerView.historyLabel.text = @"传送历史";
        }
        _headerView = headerView;

    }
    
    return _headerView;
    
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{
    return CGSizeMake(_labelSize.width, _headerViewHeight);
}

- (void)selectedPhotos{
    [_headerView.moneyTF resignFirstResponder];
    
    ZLPhotoActionSheet *actionSheet = [[ZLPhotoActionSheet alloc] init];
    //设置照片最大选择数
    actionSheet.maxSelectCount = 15;
    //设置照片最大预览数
    actionSheet.maxPreviewCount = 8;
    weakify(self);
    [actionSheet showPreviewPhotoWithSender:self animate:YES lastSelectPhotoModels:_selectedPhotoModelsArr completion:^(NSArray<UIImage *> * _Nonnull selectPhotos, NSArray<ZLSelectPhotoModel *> * _Nonnull selectPhotoModels, NSArray<NSData *> *imageDatas) {
        strongify(weakSelf);
        [weakSelf.selectedImagesArr removeAllObjects];
        [weakSelf.selectedPhotoDatasArr removeAllObjects];
        [weakSelf.selectedPhotoModelsArr removeAllObjects];
        
        [weakSelf.selectedImagesArr addObjectsFromArray:selectPhotos];
        [weakSelf.selectedPhotoDatasArr addObjectsFromArray:imageDatas];
        [weakSelf.selectedPhotoModelsArr addObjectsFromArray:selectPhotoModels];
        
        [strongSelf loadScrollViewSubViews];
        
    }];
}

- (void)loadScrollViewSubViews{
    for (id view in _headerView.subviews) {
        if ([view isKindOfClass:[UIImageView class]]) {
            [(UIImageView *)view removeFromSuperview];
        }
    }
    for (int i = 0; i < self.selectedPhotoDatasArr.count; i++) {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(15 + ((kScreenWidth - 70) / 3) * (i % 3) + 20 *(i % 3), CGRectGetMaxY(_headerView.addPhotoBtn.frame) + 10 + ((kScreenWidth - 70) / 3) * (i / 3) + 15 * (i / 3), (kScreenWidth - 70) / 3, (kScreenWidth - 70) / 3)];
        imageView.image = [UIImage imageWithData:self.selectedPhotoDatasArr[i]];
        imageView.tag = i;
        imageView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(photoBrowers:)];
        [imageView addGestureRecognizer:tap];
        [_headerView addSubview:imageView];
        
        UIButton *deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        deleteBtn.frame = CGRectMake(CGRectGetWidth(imageView.frame) - 20, 0, 20, 20);
        [deleteBtn setImage:[UIImage imageNamed:@"chuansong_shanchu"] forState:UIControlStateNormal];
        
        [deleteBtn addTarget:self action:@selector(deleteAction:) forControlEvents:UIControlEventTouchUpInside];
        deleteBtn.tag = i;
        [imageView addSubview:deleteBtn];
    }
        NSInteger count = self.selectedPhotoDatasArr.count;
        if (count % 3 == 0) {
//            self.scrollView.contentSize = CGSizeMake(kScreenWidth, ((kScreenWidth - 70) / 3 + 15) * (count / 3));
            _headerViewHeight = CGRectGetMaxY(_headerView.addPhotoBtn.frame) + 10 + ((kScreenWidth - 70) / 3 + 15) * (count / 3) + 20;
        }else{
//            self.scrollView.contentSize = CGSizeMake(kScreenWidth, ((kScreenWidth - 70) / 3 + 15) * (count / 3 + 1));
            _headerViewHeight = CGRectGetMaxY(_headerView.addPhotoBtn.frame) + 10 + ((kScreenWidth - 70) / 3 + 15) * (count / 3 + 1) + 20;
        }
    [self.upCollectionView reloadData];
}

//预览图片
- (void)photoBrowers:(UITapGestureRecognizer *)tap{
    NSLog(@"%lu",tap.view.tag);
    // 快速创建并进入浏览模式
    XLPhotoBrowser *browser = [XLPhotoBrowser showPhotoBrowserWithCurrentImageIndex:tap.view.tag imageCount:self.selectedImagesArr.count datasource:self];
    self.brower1 = browser;
    browser.browserStyle = XLPhotoBrowserStyleIndexLabel;
}

- (UIImage *)photoBrowser:(XLPhotoBrowser *)browser placeholderImageForIndex:(NSInteger)index{
    if (browser == self.brower1) {
        return self.selectedImagesArr[index];
    }
    return nil;
}

- (NSURL *)photoBrowser:(XLPhotoBrowser *)browser highQualityImageURLForIndex:(NSInteger)index{
    if (self.brower2 == browser) {
        return [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",ImgUrl,[self.dataSourceArr[index] objectForKey:@"img_min"]]];
    }
    return nil;
}

- (void)deleteAction:(UIButton *)sender{
    [self.selectedImagesArr removeObjectAtIndex:sender.tag];
    [self.selectedPhotoModelsArr removeObjectAtIndex:sender.tag];
    [self.selectedPhotoDatasArr removeObjectAtIndex:sender.tag];
    [self loadScrollViewSubViews];
}

- (IBAction)updatePhotoAction:(UIButton *)sender {
    SYUpdatePreviewViewController *updateVC = [SYUpdatePreviewViewController updatePreviewWithUrl:[NSString stringWithFormat:@"%@%@",BaseUrl,@"/teacher/addphotoX.html"] Param:@{@"token":UserToken, @"id":[self.dataSourceDic objectForKey:@"id"]}];
    [self.navigationController pushViewController:updateVC animated:YES];
}
//上传图片

- (void)updatePhotosToStudent:(UIButton *)sender{
    
    
    if (_headerView.moneyTF.text.length == 0) {
        [self showHint:@"请输入您上传图片的价格"];
        return;
    }
    
    if (self.selectedPhotoModelsArr.count == 0) {
        [self showHint:@"请选择要上传的照片"];
        return;
    }
    
    NSMutableArray *muDatas = [NSMutableArray arrayWithCapacity:0];
    [muDatas addObjectsFromArray:self.selectedPhotoDatasArr];
    //一个一个上传 每次取第一个图片上传 成功后删除第一章图片
    NSData *data = muDatas[0];
    //判断图片类型
    NSString *mimaType = [[Tool sharedInstance] typeForImageData:data];
    NSInteger currentNum = self.selectedPhotoModelsArr.count - muDatas.count + 1;
    
    NSString *url = @"";
    NSDictionary *param = nil;
    if (self.isFromGroupToMember) {
        url = [NSString stringWithFormat:@"%@%@",BaseUrl, @"/pho/upimgsX.html"];
        param = @{@"token":UserToken, @"tel":[self.dataSourceDic objectForKey:@"user"], @"money":_headerView.moneyTF.text};
    }else{
        url = [NSString stringWithFormat:@"%@%@",BaseUrl,@"/teacher/addphotoX.html"];
        param = @{@"token":UserToken, @"id":[self.dataSourceDic objectForKey:@"id"], @"money":_headerView.moneyTF.text};
    }
    
    
    [[XBUpdatePhotoManager sharedInstance] updatePhotosWithFile:url param:param fileData:data name:@"img" fileName:[NSString stringWithFormat:@"img%lu.%@",currentNum, [mimaType substringWithRange:NSMakeRange(6, mimaType.length - 6)]] mimeType:mimaType currentNumber:currentNum allNumber:self.selectedPhotoModelsArr.count result:^(NSDictionary *dic) {
        NSLog(@"dic - %@",dic);
        if (![dic objectForKey:@"resError"]) {
            if ([dic objectForKey:@"result"] && [[dic objectForKey:@"result"] integerValue] == 0) {
                [self showHint:[dic objectForKey:@"msg"]];
                return ;
            }
            //成功
            if (muDatas.count > 1) {
                [self.selectedPhotoDatasArr removeObjectAtIndex:0];
                [self updatePhotosToStudent:sender];
            }else{
                if ([dic objectForKey:@"msg"]) {
                    [self showHint:[dic objectForKey:@"msg"]];
                }
                [self.navigationController popViewControllerAnimated:YES];
            }
            
        }else{

            [self showHint:@"请检查您的网络！"];
        }
    }];
    
}

- (void)getData{
    //获取图片
    NSString *url = @"";
    NSDictionary *param = nil;
    if (self.isFromGroupToMember) {
        url = [NSString stringWithFormat:@"%@%@",BaseUrl,@"/pho/user.html"];
        param = @{@"token":UserToken, @"tel":[self.dataSourceDic objectForKey:@"user"], @"page":@1};
    }else{
        url = [NSString stringWithFormat:@"%@%@",BaseUrl,@"/teacher/history.html"];
        param = @{@"token":UserToken, @"id":[self.dataSourceDic objectForKey:@"id"], @"page":@1};
    }
    
    
    [[SYHttpRequest sharedInstance] getDataWithUrl:url Parameter:param ResponseObject:^(NSDictionary *responseResult) {
        _count = 1;
        if ([self.upCollectionView.mj_header isRefreshing]) {
            [self.upCollectionView.mj_header endRefreshing];
        }
        NSLog(@"获取老师上传照片历史记录 -- %@",responseResult);
        if ([responseResult objectForKey:@"resError"]) {
            
        }else{
            if ([[responseResult objectForKey:@"result"] integerValue] == 1) {
                [XHNetworkCache saveJsonResponseToCacheFile:responseResult andURL:[NSString stringWithFormat:@"%@%@%@",Mobile,@"teacherUpdateHistory",[[self.dataSourceDic objectForKey:@"id"] stringValue]]];
                [self.dataSourceArr removeAllObjects];
                if ([responseResult objectForKey:@"data"]) {
                    NSArray *data = [responseResult objectForKey:@"data"];
                    [self.dataSourceArr addObjectsFromArray:data];
                    [self.upCollectionView reloadData];
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
    //获取图片
    _count ++;
    NSString *url = @"";
    NSDictionary *param = nil;
    if (self.isFromGroupToMember) {
        url = [NSString stringWithFormat:@"%@%@",BaseUrl,@"/pho/user.html"];
        param = @{@"token":UserToken, @"tel":[self.dataSourceDic objectForKey:@"user"], @"page":[NSNumber numberWithInteger:_count]};
    }else{
        url = [NSString stringWithFormat:@"%@%@",BaseUrl,@"/teacher/history.html"];
        param = @{@"token":UserToken, @"id":[self.dataSourceDic objectForKey:@"id"], @"page":[NSNumber numberWithInteger:_count]};
    }
    
    [[SYHttpRequest sharedInstance] getDataWithUrl:url Parameter:param ResponseObject:^(NSDictionary *responseResult) {
        
        if ([self.upCollectionView.mj_footer isRefreshing]) {
            [self.upCollectionView.mj_footer endRefreshing];
        }
        NSLog(@"获取更多上传照片历史记录 -- %@",responseResult);
        if ([responseResult objectForKey:@"resError"]) {
            _count --;
        }else{
            if ([[responseResult objectForKey:@"result"] integerValue] == 1) {
                
                    
                if ([responseResult objectForKey:@"data"]) {
                    NSArray *data = [responseResult objectForKey:@"data"];
                    
                    [self.dataSourceArr addObjectsFromArray:data];
                    [self.upCollectionView reloadData];
                }
            }else{
                _count--;
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


- (NSMutableArray *)selectedImagesArr{
    if (!_selectedImagesArr) {
        _selectedImagesArr = [NSMutableArray arrayWithCapacity:0];
    }
    return _selectedImagesArr;
}

- (NSMutableArray *)selectedPhotoDatasArr{
    if (!_selectedPhotoDatasArr) {
        _selectedPhotoDatasArr = [NSMutableArray arrayWithCapacity:0];
    }
    return _selectedPhotoDatasArr;
}

- (NSMutableArray *)selectedPhotoModelsArr{
    if (!_selectedPhotoModelsArr) {
        _selectedPhotoModelsArr = [NSMutableArray arrayWithCapacity:0];
    }
    return _selectedPhotoModelsArr;
}

@end
