//
//  SYRedBagViewController.m
//  ShuoYing
//
//  Created by 硕影 on 2017/8/4.
//  Copyright © 2017年 硕影. All rights reserved.
//

#import "SYRedBagViewController.h"

@interface SYRedBagViewController ()<UIWebViewDelegate>

{
    NSTimer *_timer;
    NSInteger _count;
    NSInteger _imageCount;
    UIView *_backView;
    UIImageView *_openImageView;
    NSString *_money;
    
    UIView *_view1;
}

@property (nonatomic, strong) NSDictionary *dataSourceDic;

@property (nonatomic, strong) UIWebView *webView;

@property (nonatomic, strong) UIView *redbagView;

@property (nonatomic, strong) UILabel *redbagLabel;

@end

@implementation SYRedBagViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"详情";
    _imageCount = 1;
    [self getData];
    [self initwebView];
}

- (void)initwebView{
    UIWebView *web = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
    
    web.delegate = self;
    web.backgroundColor = [UIColor whiteColor];
    web.opaque = NO;
//    web.scalesPageToFit = NO;
//    web.autoresizesSubviews = NO;
//    web.autoresizingMask=(UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
    web.scrollView.backgroundColor = [UIColor whiteColor];
    web.scrollView.contentInset = UIEdgeInsetsMake(0, 0, 220, 0);
    self.webView = web;
    [self.view addSubview:self.webView];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    [SVProgressHUD dismiss];
    NSString *str = [NSString stringWithFormat:@"var script = document.createElement('script');"
                     "script.type = 'text/javascript';"
                     "script.text = \"function ResizeImages() { "
                     "var myimg,oldwidth,oldheight;"
                     "var maxwidth=%f;"// 图片宽度
                     "for(i=0;i <document.images.length;i++){"
                     "myimg = document.images[i];"
                     "if(myimg.width > maxwidth){"
                     "myimg.width = maxwidth;"
                     "}"
                     "}"
                     "}\";"
                     "document.getElementsByTagName('head')[0].appendChild(script);",(kScreenWidth - 20)];
    
    [webView stringByEvaluatingJavaScriptFromString:
     str];
    [webView stringByEvaluatingJavaScriptFromString:@"ResizeImages();"];
    CGSize cotentSize = webView.scrollView.contentSize;
    NSLog(@"cotentSize - %f",cotentSize.height);

    //HTML5的高度
    NSString *htmlHeight = [self.webView stringByEvaluatingJavaScriptFromString:@"document.body.scrollHeight"];
    //HTML5的宽度
    NSString *htmlWidth = [self.webView stringByEvaluatingJavaScriptFromString:@"document.body.scrollWidth"];
    //宽高比
    float i = [htmlWidth floatValue]/[htmlHeight floatValue];
    
    //webview控件的最终高度
    float height = kScreenWidth/i;
    NSLog(@"height - %f",height);

    self.redbagView.center = CGPointMake(kScreenWidth / 2, height + 140 / 2);
    [webView.scrollView addSubview:self.redbagView];

    _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(onTimer) userInfo:nil repeats:YES];
}

- (void)onTimer{
    if (_count > 0) {
        self.redbagLabel.text = [NSString stringWithFormat:@"红包%ld秒后开抢",_count];
        self.redbagLabel.font = [UIFont systemFontOfSize:13];
        _count--;
    }else{
        
        [_timer invalidate];
        _timer = nil;
        self.redbagLabel.text = @"戳我抢红包";
        self.redbagLabel.font = [UIFont fontWithName:@"Baskerville-BoldItalic" size:16];
        self.redbagView.userInteractionEnabled = YES;
        
    }
}

- (void)qianhongbao:(UITapGestureRecognizer *)tap{
    NSLog(@"戳我抢红包");
    NSString *url = [NSString stringWithFormat:@"%@%@",BaseUrl,@"/earn/claim.html"];
    NSDictionary *param = @{@"id":self.redbagID, @"token":UserToken};
    [[SYHttpRequest sharedInstance] getDataWithUrl:url Parameter:param ResponseObject:^(NSDictionary *responseResult) {
        
        NSLog(@"抢红包 -- %@",responseResult);
        if ([responseResult objectForKey:@"resError"]) {
            
            
        }else{
            if ([responseResult objectForKey:@"result"] && [[responseResult objectForKey:@"result"] integerValue] == 1) {
                _money = [responseResult objectForKey:@"money"];
                [self showRedbag];
            }else{
                [self showHint:[responseResult objectForKey:@"msg"]];
            }
            
        }
    }];
}

- (void)showRedbag{
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    
    UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
    backView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.4];
    _backView = backView;
    [window addSubview:backView];

    
    UIView *redbagview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 217, 291)];
    redbagview.center = CGPointMake(kScreenWidth / 2, kScreenHeight / 2);
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(ActionFanzhuan)];
    [redbagview addGestureRecognizer:tap];
    redbagview.userInteractionEnabled = YES;
    UIImage *image = [UIImage imageNamed:@"close_red"];
    redbagview.layer.contents = (id)image.CGImage;
    [backView addSubview:redbagview];
    redbagview.userInteractionEnabled = YES;
    _view1 = redbagview;
    
    UILabel *contentLabel = [[UILabel alloc] init];
    contentLabel.text = self.dataSourceDic[@"msg"];
    contentLabel.textColor = HexRGB(0xfbdeb0);
    contentLabel.font = [UIFont systemFontOfSize:12];
    contentLabel.textAlignment = NSTextAlignmentCenter;
    contentLabel.numberOfLines = 0;
    CGSize maxSize = [contentLabel sizeThatFits:CGSizeMake(redbagview.frame.size.width - 40, MAXFLOAT)];
    contentLabel.frame = CGRectMake(20, 60, maxSize.width, maxSize.height);
    [redbagview addSubview:contentLabel];
    
    UIImageView *openImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 78, 78)];
    _openImageView = openImageView;
    openImageView.center = CGPointMake(redbagview.frame.size.width / 2, 200);
    openImageView.image = [UIImage imageNamed:@"open"];
    [redbagview addSubview:openImageView];
    
    [UIView animateWithDuration:.3 animations:^{
        backView.alpha = 1;
    }];
    
}

-(void)ActionFanzhuan{
    
    //获取当前画图的设备上下文
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //开始准备动画
    
    [UIView beginAnimations:nil context:context];
    
    //设置动画曲线，翻译不准，见苹果官方文档
    
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    
    //设置动画持续时间
    
    [UIView setAnimationDuration:1.0];
    
    //因为没给viewController类添加成员变量，所以用下面方法得到viewDidLoad添加的子视图
    
    UIView *parentView = _openImageView;
    
    //设置动画效果
    
    //    [UIView setAnimationTransition: UIViewAnimationTransitionCurlDown forView:parentView cache:YES];  //从上向下
    
    // [UIView setAnimationTransition: UIViewAnimationTransitionCurlUp forView:parentView cache:YES];   //从下向上
    
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:parentView cache:YES];//从左向右
    
    //     [UIView setAnimationTransition: UIViewAnimationTransitionFlipFromRight forView:parentView cache:YES];//从右向左
    
    //设置动画委托
    
    [UIView setAnimationDelegate:self];
    
    //当动画执行结束，执行animationFinished方法
    
    [UIView setAnimationDidStopSelector:@selector(animationFinished:)];
    
    //提交动画
    
    [UIView commitAnimations];
    
}

- (void)animationFinished:(id)sender{
    [_view1 removeFromSuperview];
    UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss)];
    [_backView addGestureRecognizer:tap1];
    _backView.userInteractionEnabled = YES;
    
    UIView *haveOpenImageView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 214, 326)];
    haveOpenImageView.center = CGPointMake(kScreenWidth / 2, kScreenHeight / 2);
    UIImage *image = [UIImage imageNamed:@"open_red"];
    haveOpenImageView.layer.contents = (id)image.CGImage;
    
    UILabel *contentLabel = [[UILabel alloc] initWithFrame:CGRectMake((haveOpenImageView.frame.size.width - 141) / 2, 132, 141, 31)];
    contentLabel.text = self.dataSourceDic[@"msg"];
    contentLabel.textColor = HexRGB(0xf9d7ab);
    contentLabel.font = [UIFont systemFontOfSize:11];
    contentLabel.numberOfLines = 2;
    contentLabel.textAlignment = NSTextAlignmentCenter;
    [haveOpenImageView addSubview:contentLabel];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(contentLabel.frame) + 24, haveOpenImageView.frame.size.width - 20, 27)];
    NSString *money = [NSString stringWithFormat:@"%@元",_money];
    NSMutableAttributedString *muStr = [[NSMutableAttributedString alloc] initWithString:money];
    [muStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:26] range:NSMakeRange(0, money.length - 1)];
    [muStr addAttribute:NSForegroundColorAttributeName value:HexRGB(0xfedb72) range:NSMakeRange(0, money.length - 1)];
    
    [muStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:7] range:NSMakeRange(money.length - 1, 1)];
    [muStr addAttribute:NSForegroundColorAttributeName value:HexRGB(0xfedb72) range:NSMakeRange(money.length - 1, 1)];
    
    label.textAlignment = NSTextAlignmentCenter;
    label.attributedText = muStr;
    [haveOpenImageView addSubview:label];
    
    
    UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(label.frame) + 6, haveOpenImageView.frame.size.width - 20, 10)];
    label1.textAlignment = NSTextAlignmentCenter;
    label1.text = @"已存入我钱包余额";
    label1.font = [UIFont systemFontOfSize:7];
    label1.textColor = HexRGB(0xfbdeb0);
    [haveOpenImageView addSubview:label1];
    
    UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(10, 326 - 30, haveOpenImageView.frame.size.width - 20, 10)];
    label2.text = @"您可在我的-我的钱包中查看";
    label2.font = [UIFont systemFontOfSize:8];
    label2.textColor = HexRGB(0xfbdeb0);
    label2.textAlignment = NSTextAlignmentCenter;
    [haveOpenImageView addSubview:label2];
    
    [_backView addSubview:haveOpenImageView];
}

- (void)dismiss{
    [UIView animateWithDuration:.3 animations:^{
        _backView.alpha  = 0;
    } completion:^(BOOL finished) {
        [_backView removeFromSuperview];
    }];
}

- (void)getData{
    [SVProgressHUD show];
    NSString *url = [NSString stringWithFormat:@"%@%@",BaseUrl,@"/earn/look.html"];
    NSDictionary *param = @{@"id":self.redbagID, @"token":UserToken};
    [[SYHttpRequest sharedInstance] getDataWithUrl:url Parameter:param ResponseObject:^(NSDictionary *responseResult) {
        
        NSLog(@"hongbao -- %@",responseResult);
        if ([responseResult objectForKey:@"resError"]) {
            [SVProgressHUD dismiss];
            
        }else{
            if ([responseResult objectForKey:@"result"] && [[responseResult objectForKey:@"result"] integerValue] == 1) {
                NSDictionary *data = [responseResult objectForKey:@"data"];
                self.dataSourceDic = data;
                _count = [(NSNumber *)[data objectForKey:@"wait"] integerValue];
                [self.webView loadHTMLString:[data objectForKey:@"content"] baseURL:[NSURL URLWithString:BaseUrl]];
            }else{
                [SVProgressHUD dismiss];

                [self showHint:[responseResult objectForKey:@"msg"]];
                [self.navigationController popViewControllerAnimated:YES];
            }
            
        }
    }];
}

- (UIView *)redbagView{
    if (!_redbagView) {
        _redbagView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 176, 140)];
        UIImage *image = [UIImage imageNamed:@"red_but"];
        _redbagView.layer.contents = (id)image.CGImage;
        _redbagView.userInteractionEnabled = NO;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(qianhongbao:)];
        [_redbagView addGestureRecognizer:tap];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 98, 32)];
        label.center = CGPointMake(_redbagView.frame.size.width / 2 + 5, 16);
        label.text = @"红包秒后开抢";
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = HexRGB(0xffad1f);
        label.font = [UIFont systemFontOfSize:13];
        [_redbagView addSubview:label];
        self.redbagLabel = label;
    }
    return _redbagView;
}

@end
