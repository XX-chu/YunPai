//
//  SYSelectePhotoViewController.m
//  ShuoYing
//
//  Created by 硕影 on 2017/5/9.
//  Copyright © 2017年 硕影. All rights reserved.
//

#import "SYSelectePhotoViewController.h"
#import "SYSelectePhotoCollectionViewCell.h"
#import "SYSelectePhotoHeaderCollectionReusableView.h"
#import "SYPhotoListViewController.h"
@interface SYSelectePhotoViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout,XLPhotoBrowserDelegate,XLPhotoBrowserDatasource>

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, strong) NSMutableArray *haveSelectePhotoArr;

@property (nonatomic, copy) NSMutableArray *selectedImagesArr;

@property (nonatomic, copy) NSMutableArray *selectedImageDatasArr;

@property (nonatomic, copy) NSMutableArray *selectedPhotoModelsArr;

@property (nonatomic, copy) NSMutableArray *allImageViewArr;//存放所有imageview的数组

@end

static NSString *ShopcartSelectePhotoCell = @"ShopcartSelectePhotoCell";
static NSString *ShopcartSelectePhotoHeaderView = @"ShopcartSelectePhotoHeaderView";


@implementation SYSelectePhotoViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self getData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"选择照片";
    [self initCollectionView];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.haveSelectePhotoArr.count;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    SYSelectePhotoCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:ShopcartSelectePhotoCell forIndexPath:indexPath];
    NSDictionary *dic = self.haveSelectePhotoArr[indexPath.item];
    [cell.contentImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",ImgUrl,[dic objectForKey:@"img_200"]]] placeholderImage:NoPicture];
    __weak typeof(self)weakself = self;
    cell.deletePhoto = ^{
        [weakself deletePhotoWithid:[dic objectForKey:@"id"]];
    };
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if (self.haveSelectePhotoArr.count > 0) {
        [XLPhotoBrowser showPhotoBrowserWithCurrentImageIndex:indexPath.item imageCount:self.haveSelectePhotoArr.count datasource:self];
    }
    
}

- (NSURL *)photoBrowser:(XLPhotoBrowser *)browser highQualityImageURLForIndex:(NSInteger)index{
    NSDictionary *dic = self.haveSelectePhotoArr[index];
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",ImgUrl,[dic objectForKey:@"img_200"]]];
}

- (void)deletePhotoWithid:(NSNumber *)photoid{
    [SVProgressHUD show];
    NSString *url = [NSString stringWithFormat:@"%@%@",BaseUrl,@"/store/delimg.html"];
    NSDictionary *param = @{@"id":photoid, @"token":UserToken};
    NSLog(@"param - %@",param);
    [[SYHttpRequest sharedInstance] getDataWithUrl:url Parameter:param ResponseObject:^(NSDictionary *responseResult) {
        
        [SVProgressHUD dismiss];
        NSLog(@"删除已上传照片 -- %@",responseResult);
        if ([responseResult objectForKey:@"resError"]) {
        }else{
            if ([[responseResult objectForKey:@"result"] integerValue] == 1) {
                [self getData];
            }else{
                if ([responseResult objectForKey:@"msg"]) {
                    [self showHint:[responseResult objectForKey:@"msg"]];
                }
            }
        }
    }];
}

//头视图
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    UICollectionReusableView *reusableview = nil;
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        SYSelectePhotoHeaderCollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:ShopcartSelectePhotoHeaderView forIndexPath:indexPath];
        headerView.canSelecteLabel.text = [NSString stringWithFormat:@"温馨提示：最多还可选择%ld张",([self.upimg integerValue] - self.haveSelectePhotoArr.count)];
        [headerView.wodeKongjianBtn addTarget:self action:@selector(wodeKongJianAction:) forControlEvents:UIControlEventTouchUpInside];
        [headerView.bendiTukuBtn addTarget:self action:@selector(bendiTuKuAction:) forControlEvents:UIControlEventTouchUpInside];
        reusableview = headerView;
    }
    
    return reusableview;
}

- (void)wodeKongJianAction:(UIButton *)sender{
    SYPhotoListViewController *list = [[SYPhotoListViewController alloc] init];
    list.fromType = isFromMineKongjian;
    list.gouwucheID = self.gouwucheID;
    list.canSelecteCount = [self.upimg integerValue] - self.haveSelectePhotoArr.count;
    [self.navigationController pushViewController:list animated:YES];
}
//上传本地照片
- (void)bendiTuKuAction:(UIButton *)sender{
    ZLPhotoActionSheet *actionSheet = [[ZLPhotoActionSheet alloc] init];
    //设置照片最大选择数
    actionSheet.maxSelectCount = [_upimg integerValue] - [_c_img integerValue];
    //设置照片最大预览数
    actionSheet.maxPreviewCount = 8;
    __weak typeof(self)weakself = self;
    [actionSheet showPreviewPhotoWithSender:self animate:YES lastSelectPhotoModels:nil completion:^(NSArray<UIImage *> * _Nonnull selectPhotos, NSArray<ZLSelectPhotoModel *> * _Nonnull selectPhotoModels, NSArray<NSData *> *imageDatas) {
        
        [weakself.selectedImagesArr removeAllObjects];
        [weakself.selectedImageDatasArr removeAllObjects];
        [weakself.selectedPhotoModelsArr removeAllObjects];
        
        [weakself.selectedImagesArr addObjectsFromArray:selectPhotos];
        [weakself.selectedImageDatasArr addObjectsFromArray:imageDatas];
        [weakself.selectedPhotoModelsArr addObjectsFromArray:selectPhotoModels];
        
        [weakself updataePhotos];
        
    }];
}

- (void)updataePhotos{
    if (self.selectedImageDatasArr.count == 0) {
        [self showHint:@"上传成功！"];
        [self getData];
        return;
    }
    NSMutableArray *muDatas = [NSMutableArray arrayWithCapacity:0];
    [muDatas addObjectsFromArray:self.selectedImageDatasArr];
    //一个一个上传 每次取第一个图片上传 成功后删除第一章图片
    NSData *data = muDatas[0];
    //判断图片类型
    NSString *mimaType = [[Tool sharedInstance] typeForImageData:data];
    NSInteger currentNum = self.selectedPhotoModelsArr.count - muDatas.count + 1;
    
    NSString *url = [NSString stringWithFormat:@"%@%@",BaseUrl,@"/store/upimg.html"];
    NSDictionary *param = @{@"token":UserToken, @"cart":self.gouwucheID};
    NSLog(@"param = %@",param);
    [[XBUpdatePhotoManager sharedInstance] updatePhotosWithFile:url param:param fileData:data name:@"img" fileName:[NSString stringWithFormat:@"img%lu.%@",(long)currentNum, [mimaType substringWithRange:NSMakeRange(6, mimaType.length - 6)]] mimeType:mimaType currentNumber:currentNum allNumber:self.selectedPhotoModelsArr.count result:^(NSDictionary *dic) {
        NSLog(@"dic - %@",dic);
        if (![dic objectForKey:@"resError"]) {
            if ([dic objectForKey:@"result"] && [[dic objectForKey:@"result"] integerValue] == 0) {
                [self showHint:[dic objectForKey:@"msg"]];
                return ;
            }
            //成功
            [self.selectedImageDatasArr removeObjectAtIndex:0];
            [self updataePhotos];
            
        }else{
            [self showHint:@"请检查您的网络！"];
        }
    }];

}

- (void)initCollectionView{
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.sectionInset = UIEdgeInsetsMake(20, 14, 20, 14);
    flowLayout.itemSize = CGSizeMake((kScreenWidth - 70) / 3, (kScreenWidth - 70) / 3);
    flowLayout.minimumLineSpacing = 20;
    flowLayout.minimumInteritemSpacing = 20;
    flowLayout.headerReferenceSize = CGSizeMake(kScreenWidth, 115 + 56);
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth , kScreenHeight - kNavigationBarHeightAndStatusBarHeight) collectionViewLayout:flowLayout];
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    [self.collectionView registerNib:[UINib nibWithNibName:@"SYSelectePhotoCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:ShopcartSelectePhotoCell];
    [self.collectionView registerNib:[UINib nibWithNibName:@"SYSelectePhotoHeaderCollectionReusableView" bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:ShopcartSelectePhotoHeaderView];
    
    [self.view addSubview:self.collectionView];
}

- (void)getData{
    [SVProgressHUD show];
    NSString *url = [NSString stringWithFormat:@"%@%@",BaseUrl,@"/store/upimgs.html"];
    NSDictionary *param = @{@"id":self.gouwucheID, @"token":UserToken};
    NSLog(@"param - %@",param);
    [[SYHttpRequest sharedInstance] getDataWithUrl:url Parameter:param ResponseObject:^(NSDictionary *responseResult) {
        [SVProgressHUD dismiss];
        NSLog(@"获取已上传照片 -- %@",responseResult);
        if ([responseResult objectForKey:@"resError"]) {
        }else{
            if ([[responseResult objectForKey:@"result"] integerValue] == 1) {
                [self.haveSelectePhotoArr removeAllObjects];
                NSArray *data = [responseResult objectForKey:@"data"];
                if (data.count > 0) {
                    [self.haveSelectePhotoArr addObjectsFromArray:data];
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

- (NSMutableArray *)haveSelectePhotoArr{
    if (!_haveSelectePhotoArr) {
        _haveSelectePhotoArr = [NSMutableArray arrayWithCapacity:0];
    }
    return _haveSelectePhotoArr;
}

- (NSMutableArray *)selectedImagesArr{
    if (!_selectedImagesArr) {
        _selectedImagesArr = [NSMutableArray arrayWithCapacity:0];
    }
    return _selectedImagesArr;
}

- (NSMutableArray *)selectedImageDatasArr{
    if (!_selectedImageDatasArr) {
        _selectedImageDatasArr = [NSMutableArray arrayWithCapacity:0];
    }
    return _selectedImageDatasArr;
}

- (NSMutableArray *)selectedPhotoModelsArr{
    if (!_selectedPhotoModelsArr) {
        _selectedPhotoModelsArr = [NSMutableArray arrayWithCapacity:0];
    }
    return _selectedPhotoModelsArr;
}

- (NSMutableArray *)allImageViewArr{
    if (!_allImageViewArr) {
        _allImageViewArr = [NSMutableArray arrayWithCapacity:0];
    }
    return _allImageViewArr;
}

@end
