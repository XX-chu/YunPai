//
//  SYUpdatePreviewViewController.m
//  ShuoYing
//
//  Created by 硕影 on 2017/2/21.
//  Copyright © 2017年 硕影. All rights reserved.
//

#import "SYUpdatePreviewViewController.h"

@interface SYUpdatePreviewViewController ()<XLPhotoBrowserDelegate,XLPhotoBrowserDatasource>
{
    NSString *_url;
    NSDictionary *_param;
}

@property (nonatomic, strong) UILabel *prompLabel;

@property (nonatomic, strong) UIView *backView;

@property (nonatomic, strong) NSMutableArray *selectedImagesArr;

@property (nonatomic, strong) NSMutableArray *selectedPhotoDatasArr;

@property (nonatomic, strong) NSMutableArray *selectedPhotoModelsArr;

@property (nonatomic, strong) UIScrollView *scrollView;

@end

@implementation SYUpdatePreviewViewController

+ (instancetype)updatePreviewWithUrl:(NSString *)url
                               Param:(NSDictionary *)param{
    SYUpdatePreviewViewController *update = [[SYUpdatePreviewViewController alloc] initWithUrl:url Param:param];
    
    return update;
}

- (instancetype)initWithUrl:(NSString *)url
                      Param:(NSDictionary *)param{
    if (self = [super init]) {
        _url = url;
        _param = param;
    }
    
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"上传图片";
    [self initUI];
    [self setRightbarItem];
    
}

#pragma mark - PrivateMethod
- (void)selectPhotoAction:(UIButton *)sender{
    
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
        
        [strongSelf updateImagesToServerWithImages:selectPhotos withImageDatas:imageDatas];
        
    }];
    
}

- (void)updateImagesToServerWithImages:(NSArray *)imagesArr withImageDatas:(NSArray<NSData *> *)datas{
    
    [self loadScrollViewSubViews];
}

- (void)loadScrollViewSubViews{
    [self.scrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    for (int i = 0; i < self.selectedPhotoDatasArr.count; i++) {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(15 + ((kScreenWidth - 70) / 3) * (i % 3) + 20 *(i % 3), ((kScreenWidth - 70) / 3) * (i / 3) + 15 * (i / 3), (kScreenWidth - 70) / 3, (kScreenWidth - 70) / 3)];
        imageView.image = [UIImage imageWithData:self.selectedPhotoDatasArr[i]];
        imageView.tag = i;
        imageView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(photoBrowers:)];
        [imageView addGestureRecognizer:tap];
        [self.scrollView addSubview:imageView];
        
        UIButton *deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        deleteBtn.frame = CGRectMake(CGRectGetWidth(imageView.frame) - 20, 0, 20, 20);
        [deleteBtn setImage:[UIImage imageNamed:@"chuansong_shanchu"] forState:UIControlStateNormal];
        
        [deleteBtn addTarget:self action:@selector(deleteAction:) forControlEvents:UIControlEventTouchUpInside];
        deleteBtn.tag = i;
        [imageView addSubview:deleteBtn];
    }
//    NSInteger count = self.selectedPhotoDatasArr.count;
//    if (count % 3 == 0) {
//        self.scrollView.contentSize = CGSizeMake(kScreenWidth, ((kScreenWidth - 70) / 3 + 15) * (count / 3));
//    }else{
//        self.scrollView.contentSize = CGSizeMake(kScreenWidth, ((kScreenWidth - 70) / 3 + 15) * (count / 3 + 1));
//    }
    
}
//预览图片
- (void)photoBrowers:(UITapGestureRecognizer *)tap{
    NSLog(@"%lu",tap.view.tag);
    // 快速创建并进入浏览模式
    XLPhotoBrowser *browser = [XLPhotoBrowser showPhotoBrowserWithCurrentImageIndex:tap.view.tag imageCount:self.selectedImagesArr.count datasource:self];
    browser.browserStyle = XLPhotoBrowserStyleIndexLabel;
}

- (UIImage *)photoBrowser:(XLPhotoBrowser *)browser placeholderImageForIndex:(NSInteger)index{
    return self.selectedImagesArr[index];
}

- (void)deleteAction:(UIButton *)sender{
    [self.selectedImagesArr removeObjectAtIndex:sender.tag];
    [self.selectedPhotoModelsArr removeObjectAtIndex:sender.tag];
    [self.selectedPhotoDatasArr removeObjectAtIndex:sender.tag];
    [self loadScrollViewSubViews];
}

#pragma mark - 上传图片
- (void)updatePhotos:(UIButton *)sender{
    
    [self.view endEditing:YES];
    //文件上传
    if (self.selectedImagesArr.count == 0) {
        return;
    }
    NSMutableArray *muDatas = [NSMutableArray arrayWithCapacity:0];
    [muDatas addObjectsFromArray:self.selectedPhotoDatasArr];
    //一个一个上传 每次取第一个图片上传 成功后删除第一章图片
    NSData *data = muDatas[0];
    //判断图片类型
    NSString *mimaType = [[Tool sharedInstance] typeForImageData:data];
    NSInteger currentNum = self.selectedImagesArr.count - muDatas.count + 1;
    
    [[XBUpdatePhotoManager sharedInstance] updatePhotosWithFile:_url param:_param fileData:data name:@"img" fileName:[NSString stringWithFormat:@"img%lu.%@",(long)currentNum, [mimaType substringWithRange:NSMakeRange(6, mimaType.length - 6)]] mimeType:mimaType currentNumber:currentNum allNumber:self.selectedPhotoModelsArr.count result:^(NSDictionary *dic) {
        
        NSLog(@"dic - %@",dic);
        if (![dic objectForKey:@"resError"]) {
            if ([dic objectForKey:@"result"] && [[dic objectForKey:@"result"] integerValue] == 0) {
                [self showHint:[dic objectForKey:@"msg"]];
                return ;
            }
            //成功
            if (muDatas.count > 1) {
                [self.selectedPhotoDatasArr removeObjectAtIndex:0];
                [self updatePhotos:sender];
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

- (void)initUI{
    [self.view addSubview:self.prompLabel];
    [self.view addSubview:self.backView];
    
    UIButton *selectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    selectBtn.frame = CGRectMake(15, 15, 75, 75);
    [selectBtn setImage:[UIImage imageNamed:@"chuansong_xiangji-"] forState:UIControlStateNormal];
    
    [selectBtn setAdjustsImageWhenHighlighted:NO];
    [selectBtn addTarget:self action:@selector(selectPhotoAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.backView addSubview:selectBtn];
    
    
    UIScrollView *scroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(selectBtn.frame) + 15, kScreenWidth, kScreenHeight - kNavigationBarHeightAndStatusBarHeight - CGRectGetMaxY(selectBtn.frame) - 15)];
    scroll.showsVerticalScrollIndicator = NO;
    scroll.contentSize = CGSizeMake(kScreenWidth, self.backView.frame.size.height - 105);
    [self.backView addSubview:scroll];
    self.scrollView = scroll;
    
}

- (void)setRightbarItem{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 0, 44, 44);
    [btn setTitle:@"传送" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:15];
    [btn addTarget:self action:@selector(updatePhotos:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *right = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    right.width = -15;
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:btn];
    
    self.navigationItem.rightBarButtonItems = @[right, item];
}

- (UILabel *)prompLabel{
    if (!_prompLabel) {
        _prompLabel = [[UILabel alloc] init];
        _prompLabel.font = [UIFont systemFontOfSize:13];
        _prompLabel.text = @"温馨提示：为保证图片质量，将不对图片进行压缩处理，传送原图时间较长，单次上传不超过15张。";
        _prompLabel.numberOfLines = 0;
        _prompLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        CGSize maximumLabelSize = CGSizeMake(kScreenWidth - 30, 9999);
        
        CGSize expectSize = [_prompLabel sizeThatFits:maximumLabelSize];
        _prompLabel.frame = CGRectMake(15, 15, kScreenWidth - 30, expectSize.height);
        
    }
    return _prompLabel;
}

- (UIView *)backView{
    if (!_backView) {
        _backView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.prompLabel.frame) + 15, kScreenWidth, kScreenHeight - kNavigationBarHeightAndStatusBarHeight - CGRectGetHeight(self.prompLabel.frame) - 30)];
        _backView.backgroundColor = [UIColor whiteColor];
        
    }
    return _backView;
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
