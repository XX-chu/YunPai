//
//  SYUpdateYunPaiShiViewController.m
//  ShuoYing
//
//  Created by chu on 2017/11/14.
//  Copyright © 2017年 硕影. All rights reserved.
//

#import "SYUpdateYunPaiShiViewController.h"
#import "SYEditImageCollectionViewCell.h"
#import "ZLPhotoActionSheet.h"
#import "LSXAlertInputView.h"
@interface SYUpdateYunPaiShiViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, strong) NSMutableArray *dataSourceArr;

@property (nonatomic, strong) NSMutableArray *haveSelectedModelsArr;

@property (nonatomic, strong) NSMutableArray *imageDatasArr;

@property (nonatomic, strong) NSMutableArray *infosArr;

@property (nonatomic, strong) NSMutableArray *beizhuArr;
@end

static NSString *editCell = @"editCell";

@implementation SYUpdateYunPaiShiViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"上传作品";
    [self.view addSubview:self.collectionView];
    [self initRightBarItem];
}

- (void)initRightBarItem{
    UIButton *done = [UIButton buttonWithType:UIButtonTypeCustom];
    done.frame = CGRectMake(0, 0, 44, 44);
    [done setTitle:@"完成" forState:UIControlStateNormal];
    [done setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    done.titleLabel.font = [UIFont systemFontOfSize:16];
    [done addTarget:self action:@selector(shangchuanAction:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *right = [[UIBarButtonItem alloc] initWithCustomView:done];
    self.navigationItem.rightBarButtonItem = right;
}

- (void)shangchuanAction:(UIButton *)sender{
    
    if (self.dataSourceArr.count == 0) {
        return;
    }
    
    NSMutableArray *muDatas = [NSMutableArray arrayWithCapacity:0];
    [muDatas addObjectsFromArray:self.imageDatasArr];
    //一个一个上传 每次取第一个图片上传 成功后删除第一章图片
    NSData *data = muDatas[0];
    //判断图片类型
    NSString *mimaType = [[Tool sharedInstance] typeForImageData:data];
    NSInteger currentNum = self.haveSelectedModelsArr.count - muDatas.count + 1;
    
    NSString *url = [NSString stringWithFormat:@"%@%@",BaseUrl,@"/master/upworks.html"];
    NSDictionary *param = @{@"token":UserToken, @"id":@0, @"info":self.beizhuArr[0]};
    NSLog(@"param = %@",param);
    [[XBUpdatePhotoManager sharedInstance] updatePhotosWithFile:url param:param fileData:data name:@"img" fileName:[NSString stringWithFormat:@"img%lu.%@",(long)currentNum, [mimaType substringWithRange:NSMakeRange(6, mimaType.length - 6)]] mimeType:mimaType currentNumber:currentNum allNumber:self.haveSelectedModelsArr.count result:^(NSDictionary *dic) {
        NSLog(@"dic - %@",dic);
        if (![dic objectForKey:@"resError"]) {
            if ([dic objectForKey:@"result"] && [[dic objectForKey:@"result"] integerValue] == 0) {
                [self showHint:[dic objectForKey:@"msg"]];
                return ;
            }
            //成功
            if (muDatas.count > 1) {
                [self.imageDatasArr removeObjectAtIndex:0];
                [self.beizhuArr removeObjectAtIndex:0];
                [self shangchuanAction:sender];
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

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.item == 0) {
        ZLPhotoActionSheet *actionSheet = [[ZLPhotoActionSheet alloc] init];
        //设置照片最大选择数
        actionSheet.maxSelectCount = 15;
        //设置照片最大预览数
        actionSheet.maxPreviewCount = 8;
        __weak typeof(self)weakSelf = self;
        [actionSheet showPreviewPhotoWithSender:self animate:YES lastSelectPhotoModels:self.haveSelectedModelsArr completion:^(NSArray<UIImage *> * _Nonnull selectPhotos, NSArray<ZLSelectPhotoModel *> * _Nonnull selectPhotoModels, NSArray<NSData *> *imageDatas) {
            
            [weakSelf.dataSourceArr removeAllObjects];
            [weakSelf.haveSelectedModelsArr removeAllObjects];
            [weakSelf.imageDatasArr removeAllObjects];
            [weakSelf.beizhuArr removeAllObjects];
            
            [weakSelf.dataSourceArr addObjectsFromArray:selectPhotos];
            [weakSelf.haveSelectedModelsArr addObjectsFromArray:selectPhotoModels];
            [weakSelf.imageDatasArr addObjectsFromArray:imageDatas];
            for (int i = 0; i < selectPhotoModels.count; i++) {
                [weakSelf.beizhuArr addObject:@""];
            }
            
            [weakSelf.collectionView reloadData];
        }];

    }
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.dataSourceArr.count + 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    SYEditImageCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:editCell forIndexPath:indexPath];
    if (!cell) {
        cell = [[SYEditImageCollectionViewCell alloc] init];
    }
    if (indexPath.item == 0) {
        cell.headImageView.image = [UIImage imageNamed:@"zz_tj"];
        cell.deleBtn.hidden = YES;
        cell.editView.hidden = YES;
    }else{
        cell.deleBtn.hidden = NO;
        cell.editView.hidden = NO;
        cell.headImageView.image = self.dataSourceArr[indexPath.row - 1];
        __weak typeof(self)weakself = self;
        NSString *str = self.beizhuArr[indexPath.row - 1];
        if (str.length > 0) {
            [cell.editBtn setTitle:@"修改备注" forState:UIControlStateNormal];
        }else{
            [cell.editBtn setTitle:@"添加备注" forState:UIControlStateNormal];
        }
        cell.delBlock = ^{
            [weakself.dataSourceArr removeObjectAtIndex:indexPath.row - 1];
            [weakself.haveSelectedModelsArr removeObjectAtIndex:indexPath.row - 1];
            [weakself.imageDatasArr removeObjectAtIndex:indexPath.row - 1];
            [weakself.beizhuArr removeObjectAtIndex:indexPath.row - 1];
            [weakself.collectionView reloadData];
            
        };
        
        cell.editBlock = ^{
            NSString *str = self.beizhuArr[indexPath.row - 1];
            LSXAlertInputView * alert=[[LSXAlertInputView alloc]initWithTitle:@"" PlaceholderText:@"请在此输入照片备注..." WithKeybordType:LSXKeyboardTypeDefault CompleteBlock:^(NSString *contents) {
                NSLog(@"-----%@",contents);
                [weakself.beizhuArr replaceObjectAtIndex:indexPath.row - 1 withObject:contents];
                [weakself.collectionView reloadData];
            }];
            alert.num = 50;
            [alert show];
            alert.textViewText = str;
        };
    }
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake((kScreenWidth - 52) / 3, (kScreenWidth - 52) / 3);
}
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(13, 13, 13, 13);
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return 13;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return 13;
}


- (UICollectionView *)collectionView{
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight - kNavigationBarHeightAndStatusBarHeight) collectionViewLayout:layout];
        _collectionView.backgroundColor = [UIColor whiteColor];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        
        [_collectionView registerNib:[UINib nibWithNibName:@"SYEditImageCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:editCell];
    }
    return _collectionView;
}

- (NSMutableArray *)dataSourceArr{
    if (!_dataSourceArr) {
        _dataSourceArr = [NSMutableArray arrayWithCapacity:0];
    }
    return _dataSourceArr;
}

- (NSMutableArray *)haveSelectedModelsArr{
    if (!_haveSelectedModelsArr) {
        _haveSelectedModelsArr = [NSMutableArray arrayWithCapacity:0];
    }
    return _haveSelectedModelsArr;
}

- (NSMutableArray *)infosArr{
    if (!_infosArr) {
        _infosArr = [NSMutableArray arrayWithCapacity:0];
    }
    return _infosArr;
}

- (NSMutableArray *)imageDatasArr{
    if (!_imageDatasArr) {
        _imageDatasArr = [NSMutableArray arrayWithCapacity:0];
    }
    return _imageDatasArr;
}

- (NSMutableArray *)beizhuArr{
    if (!_beizhuArr) {
        _beizhuArr = [NSMutableArray arrayWithCapacity:0];
    }
    return _beizhuArr;
}
@end
