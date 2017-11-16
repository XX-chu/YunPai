//
//  XBUpdatePhotoManager.m
//  ShuoYing
//
//  Created by 硕影 on 2016/12/30.
//  Copyright © 2016年 硕影. All rights reserved.
//

#import "XBUpdatePhotoManager.h"
#import "XBProgressView.h"

static XBUpdatePhotoManager *_sharedInstance = nil;

@interface XBUpdatePhotoManager ()
{
    UIView *_view1;
}

@property (nonatomic, strong) XBProgressView *progressView;

@property (nonatomic, strong) NSProgress *progress;

@end

@implementation XBUpdatePhotoManager

+ (instancetype)sharedInstance{
    
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            _sharedInstance = [[self alloc] init];
        });
        return _sharedInstance;
}

- (void)updatePhotosWithUrl:(NSString *)url param:(NSDictionary *)param view:(UIView *)view result:(UpdatePhotoResult)result{
    //遍历 把图片转换成base64

    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    
    UIView *view1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
    view1.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.6];
    [window addSubview:view1];
    
    [view1 addSubview:self.progressView];
    
    
    NSString *str = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    AFHTTPSessionManager *sessionManager = [AFHTTPSessionManager manager];
    sessionManager.responseSerializer = [AFHTTPResponseSerializer serializer];
    sessionManager.requestSerializer.timeoutInterval = 10.f;
    sessionManager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/json",@"text/html",@"text/javascript", nil];
    __weak typeof(self)waekself = self;
    [sessionManager POST:str parameters:param progress:^(NSProgress * _Nonnull uploadProgress) {
        
        [uploadProgress addObserver:waekself forKeyPath:@"fractionCompleted" options:NSKeyValueObservingOptionNew context:nil];
        waekself.progress = uploadProgress;
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [waekself.progress removeObserver:self forKeyPath:@"fractionCompleted"];
        [view1 removeFromSuperview];
        _progressView = nil;
        
        id resultData = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil];
        
        if ([resultData isKindOfClass:[NSDictionary class]]) {
            NSDictionary *resultDic = (NSDictionary *)resultData;
            result(resultDic);
        }
        
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        [waekself.progress removeObserver:self forKeyPath:@"fractionCompleted"];
        [view1 removeFromSuperview];
        _progressView = nil;
        
        NSDictionary *errorDic = @{@"resError":error};
        result(errorDic);
        
    }];

}

- (void)updatePhotosWithFile:(NSString *)url param:(NSDictionary *)param fileData:(NSData *)filedata name:(NSString *)name fileName:(NSString *)fileName mimeType:(NSString *)mimeType currentNumber:(NSInteger)currentNumber allNumber:(NSInteger)allNumber result:(UpdatePhotoResult)result{
    
    if (currentNumber == 1) {
        
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        
        UIView *view1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
        _view1 = view1;
        view1.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.6];
        [window addSubview:view1];
        
        [view1 addSubview:self.progressView];
    }
    if (allNumber == 0) {
        self.progressView.numberLabel.text = @"";
    }else{
        self.progressView.numberLabel.text = [NSString stringWithFormat:@"%ld/%ld",currentNumber,allNumber];
    }
    
    
    
    NSString *str = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    AFHTTPSessionManager *sessionManager = [AFHTTPSessionManager manager];
    sessionManager.responseSerializer = [AFHTTPResponseSerializer serializer];
    sessionManager.requestSerializer.timeoutInterval = 30.f;
    sessionManager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/json",@"text/html",@"text/javascript",@"application/octet-stream", nil];
    __weak typeof(self)waekself = self;
    [sessionManager POST:str parameters:param constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
        [formData appendPartWithFileData:filedata name:name fileName:fileName mimeType:mimeType];
        
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        
        [uploadProgress addObserver:waekself forKeyPath:@"fractionCompleted" options:NSKeyValueObservingOptionNew context:nil];
        waekself.progress = uploadProgress;
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        
        id resultData = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil];
        
        if ([resultData isKindOfClass:[NSDictionary class]]) {
            NSDictionary *resultDic = (NSDictionary *)resultData;
            if ([[resultDic objectForKey:@"result"] integerValue] == 0) {
                [waekself.progress removeObserver:self forKeyPath:@"fractionCompleted"];
                [_view1 removeFromSuperview];
                _progressView = nil;
            }else{
                if (currentNumber == allNumber) {
                    [waekself.progress removeObserver:self forKeyPath:@"fractionCompleted"];
                    [_view1 removeFromSuperview];
                    _progressView = nil;
                }
            }
            if (allNumber == 0) {
                [waekself.progress removeObserver:self forKeyPath:@"fractionCompleted"];
                [_view1 removeFromSuperview];
                _progressView = nil;
            }
            result(resultDic);
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        
        NSDictionary *errorDic = @{@"resError":error};
        result(errorDic);
        
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

//在当前window添加进度条
- (XBProgressView *)progressView{
    if (!_progressView) {
        _progressView = [[XBProgressView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth - 30, 170)];
        _progressView.center = CGPointMake(kScreenWidth / 2, kScreenHeight / 2);
//        _progressView.percent = 0;
//        _progressView.backgroundColor = [UIColor clearColor];
//        _progressView.progressColor = NavigationColor;
//        _progressView.progressBackgroundColor = BackGroundColor;
//        _progressView.clockwise = YES;
//        _progressView.textColor = NavigationColor;
    }
    return _progressView;
}

@end
