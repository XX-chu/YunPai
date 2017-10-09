//
//  SYGrapherCertifiedViewController.m
//  ShuoYing
//
//  Created by 硕影 on 2017/1/9.
//  Copyright © 2017年 硕影. All rights reserved.
//

#import "SYGrapherCertifiedViewController.h"

#import <MobileCoreServices/MobileCoreServices.h>
#import "SYUserInfos.h"

#import "XBProgressView.h"
@interface SYGrapherCertifiedViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate>
{
    SYUserInfos *_userInfos;
    
    UIView *_view1;
    
    UIImage *_shenfenImage;
    
    NSData *_shenfenData;

}

@property (nonatomic, strong) NSProgress *progress;

@property (nonatomic, strong) XBProgressView *progressView;

@property (weak, nonatomic) IBOutlet UIImageView *shenfenzhengImageView;

@property (weak, nonatomic) IBOutlet UIButton *updateBtn;

@property (nonatomic, strong) NSMutableArray *selectedPhotosArr;

@property (nonatomic, strong) NSMutableArray *selectedPhotoDatasArr;

@property (nonatomic, strong) NSMutableArray *selectedPhotoModelsArr;

@property (nonatomic, strong) UIButton *shenfenDelete;


@end

@implementation SYGrapherCertifiedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"摄影师认证";
    [self setSubviewsLayer];
}

- (void)setSubviewsLayer{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectedShenfen:)];
    self.shenfenzhengImageView.userInteractionEnabled = YES;
    [self.shenfenzhengImageView addGestureRecognizer:tap];
    
    [self.updateBtn setTitle:@"上传" forState:UIControlStateNormal];
    [self.updateBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.updateBtn setBackgroundImage:[UIImage imageWithColor:NavigationColor Size:self.updateBtn.frame.size] forState:UIControlStateNormal];
    [self.updateBtn setAdjustsImageWhenHighlighted:NO];
    self.updateBtn.layer.masksToBounds = YES;
    self.updateBtn.layer.cornerRadius = 5;
    
}

- (void)selectedShenfen:(UITapGestureRecognizer *)tap{
    ZLPhotoActionSheet *actionSheet = [[ZLPhotoActionSheet alloc] init];
    //设置照片最大选择数
    actionSheet.maxSelectCount = 1;
    //设置照片最大预览数
    actionSheet.maxPreviewCount = 8;
    //导航栏是否透明
    actionSheet.isTouMing = NO;

    [actionSheet showPreviewPhotoWithSender:self animate:YES lastSelectPhotoModels:nil completion:^(NSArray<UIImage *> * _Nonnull selectPhotos, NSArray<ZLSelectPhotoModel *> * _Nonnull selectPhotoModels, NSArray<NSData *> *imageDatas) {

        
        if (selectPhotos.count > 0) {
            _shenfenImage = selectPhotos[0];
        }
        self.shenfenzhengImageView.image = _shenfenImage;
        [self.shenfenzhengImageView addSubview:self.shenfenDelete];
        
        if (imageDatas.count > 0) {
            _shenfenData = imageDatas[0];
        }
        
        
    }];

}


- (void)shenfenDeleteAction:(UIButton *)sender{
    self.shenfenzhengImageView.image = [UIImage imageNamed:@"shenfenzheng"];
    _shenfenImage = nil;
    _shenfenData = nil;
    [self.shenfenDelete removeFromSuperview];
}


- (IBAction)updateAction:(UIButton *)sender {
    
    //把图片转换成base64
    
    if (!_shenfenImage || _shenfenImage == nil) {
        [self showHint:@"必须上传您的身份证"];
        return;
    }
    
    NSDictionary *param = nil;
    param = @{@"token":UserToken};

    
    NSString *url = [NSString stringWithFormat:@"%@%@",BaseUrl,@"/user/phoX.html"];
    
    NSString *str = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    
    UIView *view1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
    _view1 = view1;
    view1.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.6];
    [window addSubview:view1];
    
    [view1 addSubview:self.progressView];
    self.progressView.numberLabel.text = @"";
    
    AFHTTPSessionManager *sessionManager = [AFHTTPSessionManager manager];
    sessionManager.responseSerializer = [AFHTTPResponseSerializer serializer];
    sessionManager.requestSerializer.timeoutInterval = 10.f;
    sessionManager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/json",@"text/html",@"text/javascript", nil];
    __weak typeof(self)waekself = self;
    [sessionManager POST:str parameters:param constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
        NSString *mimaType = [[Tool sharedInstance] typeForImageData:_shenfenData];
        [formData appendPartWithFileData:_shenfenData name:@"photo" fileName:[NSString stringWithFormat:@"photo%d.%@",0, [mimaType substringWithRange:NSMakeRange(6, mimaType.length - 6)]] mimeType:mimaType];
        
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        
        [uploadProgress addObserver:waekself forKeyPath:@"fractionCompleted" options:NSKeyValueObservingOptionNew context:nil];
        waekself.progress = uploadProgress;
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        [waekself.progress removeObserver:self forKeyPath:@"fractionCompleted"];
        [_view1 removeFromSuperview];
        _progressView = nil;
        
        id resultData = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil];
        
        if ([resultData isKindOfClass:[NSDictionary class]]) {
            NSDictionary *resultDic = (NSDictionary *)resultData;
            NSLog(@"resultDic - %@",resultDic);
            if ([[resultDic objectForKey:@"result"] integerValue] == 1) {
                //修改存储在本地的信息
                _userInfos.pho = @3;
                [[Tool sharedInstance] saveObject:_userInfos WithPath:Mobile ];
                if ([resultDic objectForKey:@"msg"]) {
                    [waekself showHint:[resultDic objectForKey:@"msg"]];
                }
                [self.navigationController popViewControllerAnimated:YES];
            }else{
                [self showHint:[resultDic objectForKey:@"msg"]];
            }
            
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        NSDictionary *errorDic = @{@"resError":error};
        NSLog(@"errorDic -- %@",errorDic);
        [waekself.progress removeObserver:self forKeyPath:@"fractionCompleted"];
        [_view1 removeFromSuperview];
        _progressView = nil;
        
    }];

}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    if ([keyPath isEqualToString:@"fractionCompleted"] && [object isKindOfClass:[NSProgress class]]) {
        NSProgress *progress = (NSProgress *)object;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            _progressView.centerLabel.text = [NSString stringWithFormat:@"%.2f%@",progress.fractionCompleted * 100,@"%"];
            _progressView.percent = progress.fractionCompleted;
        });
    }
}

- (NSMutableArray *)selectedPhotosArr{
    if (!_selectedPhotosArr) {
        _selectedPhotosArr = [NSMutableArray arrayWithCapacity:0];
    }
    return _selectedPhotosArr;
}

- (NSMutableArray *)selectedPhotoModelsArr{
    if (!_selectedPhotoModelsArr) {
        _selectedPhotoModelsArr = [NSMutableArray arrayWithCapacity:0];
    }
    return _selectedPhotoModelsArr;
}

- (NSMutableArray *)selectedPhotoDatasArr{
    if (!_selectedPhotoDatasArr) {
        _selectedPhotoDatasArr = [NSMutableArray arrayWithCapacity:0];
    }
    return _selectedPhotoDatasArr;
}

//在当前window添加进度条
- (XBProgressView *)progressView{
    if (!_progressView) {
        _progressView = [[XBProgressView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth - 30, 170)];
        _progressView.center = CGPointMake(kScreenWidth / 2, kScreenHeight / 2);
    }
    return _progressView;
}

- (UIButton *)shenfenDelete{
    if (!_shenfenDelete) {
        _shenfenDelete = [UIButton buttonWithType:UIButtonTypeCustom];
        _shenfenDelete.frame = CGRectMake(self.shenfenzhengImageView.frame.size.width - 20, 0, 20, 20);
        [_shenfenDelete setImage:[UIImage imageNamed:@"chuansong_shanchu"] forState:UIControlStateNormal];
        
        [_shenfenDelete addTarget:self action:@selector(shenfenDeleteAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _shenfenDelete;
}


@end
