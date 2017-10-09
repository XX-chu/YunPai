//
//  SYErWeiMaViewController.m
//  ShuoYing
//
//  Created by 硕影 on 2017/3/7.
//  Copyright © 2017年 硕影. All rights reserved.
//

#import "SYErWeiMaViewController.h"

#import "QTShareView.h"



@interface SYErWeiMaViewController ()<QTShareViewDelegate>

{
    NSString *_share;
    NSString *_qrcode;
    UIImageView *_imageView;
}

@end

@implementation SYErWeiMaViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"分享二维码";
    
    [self getErWeiMa];
}

- (void)setRightBarItem{
    
    UIButton *buttom = [UIButton buttonWithType:UIButtonTypeCustom];
    [buttom setAdjustsImageWhenHighlighted:NO];
    buttom.frame = CGRectMake(0, 0, 70, 25);
    [buttom setImage:[UIImage imageNamed:@"mine_shareapp"] forState:UIControlStateNormal];
    buttom.imageView.contentMode = UIViewContentModeCenter;
    [buttom setImageEdgeInsets:UIEdgeInsetsMake(0, 25, 0, -25)];
    [buttom addTarget:self action:@selector(commitComment:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *right = [[UIBarButtonItem alloc] initWithCustomView:buttom];
    self.navigationItem.rightBarButtonItem = right;
}

- (void)loadSubView{
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight - 64)];
    _imageView = imageView;
    [imageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",ImgUrl, _share]]];
    imageView.userInteractionEnabled = YES;
    UILongPressGestureRecognizer *pres  = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
    [imageView addGestureRecognizer:pres];
    [self.view addSubview:imageView];
}

- (void)commitComment:(UIButton *)sender{
    [[QTShareView sharedInstance] showInView:self.view];
    [QTShareView sharedInstance].delegate = self;
}

- (void)longPress:(UILongPressGestureRecognizer *)pre{
    NSLog(@"prepreprepre");
    if (pre.state == UIGestureRecognizerStateBegan) {
        //分享
        [[QTShareView sharedInstance] showInView:self.view];
        [QTShareView sharedInstance].delegate = self;
    }else {
        
    }
    
    
}

- (void)didSelectedShareBtnWithTag:(NSInteger)tag{
    if (tag == 0) {
        [self shareImageToPlatformType:UMSocialPlatformType_QQ];
    }else if (tag == 1){
        [self shareImageToPlatformType:UMSocialPlatformType_Qzone];
    }else if (tag == 2){
        [self shareImageToPlatformType:UMSocialPlatformType_WechatSession];
    }else if (tag == 3){
       [self shareImageToPlatformType:UMSocialPlatformType_WechatTimeLine];
    }
}

- (void)shareImageToPlatformType:(UMSocialPlatformType)platformType
{
    //创建分享消息对象
    UMSocialMessageObject *messageObject = [UMSocialMessageObject messageObject];
    
    //创建图片内容对象
    UMShareImageObject *shareObject = [[UMShareImageObject alloc] init];
    //如果有缩略图，则设置缩略图
    shareObject.thumbImage = _imageView.image;
    [shareObject setShareImage:_imageView.image];
    
    //分享消息对象设置分享内容对象
    messageObject.shareObject = shareObject;
    
    //调用分享接口
    [[UMSocialManager defaultManager] shareToPlatform:platformType messageObject:messageObject currentViewController:self completion:^(id data, NSError *error) {
        if (error) {
            NSLog(@"************Share fail with error %@*********",error);
        }else{
            NSLog(@"response data is %@",data);
        }
    }];
}

- (void)getErWeiMa{
    [SVProgressHUD show];
    NSString *url = [NSString stringWithFormat:@"%@%@",BaseUrl,@"/user/qrcode.html"];
    NSDictionary *param = @{@"token":UserToken};
    [[SYHttpRequest sharedInstance] getDataWithUrl:url Parameter:param ResponseObject:^(NSDictionary *responseResult) {
        [SVProgressHUD dismiss];
        NSLog(@"二维码 -- %@",responseResult);
        if ([responseResult objectForKey:@"resError"]) {
            [self showHint:@"服务器不给力，请稍后重试"];
        }else{
            if ([[responseResult objectForKey:@"result"] integerValue] == 1) {
                _share = [responseResult objectForKey:@"share"];
                _qrcode = [responseResult objectForKey:@"qrcode"];
                [self loadSubView];
                [self setRightBarItem];
            }else{
                if ([responseResult objectForKey:@"msg"]) {
                    [self showHint:[responseResult objectForKey:@"msg"]];
                }
            }
        }
    }];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [SVProgressHUD dismiss];
}

@end
