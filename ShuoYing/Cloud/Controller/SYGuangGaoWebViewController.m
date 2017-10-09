//
//  SYGuangGaoWebViewController.m
//  ShuoYing
//
//  Created by 硕影 on 2017/3/19.
//  Copyright © 2017年 硕影. All rights reserved.
//

#import "SYGuangGaoWebViewController.h"

@interface SYGuangGaoWebViewController ()<UIWebViewDelegate>

{
    
    UIWebView *_webView;
}

@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, strong) NSDictionary *resultDic;

@end

@implementation SYGuangGaoWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    UIWebView *web =[[UIWebView alloc] init];
    web.delegate = self;
    web.backgroundColor = [UIColor clearColor];
    web.opaque = NO;
    web.scrollView.scrollEnabled = NO;
//    [web loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://wap.yunxiangguan.cn/scrollBannerMsgApp.html?id=%@",self.gundongID]]]];
    _webView = web;
    [SVProgressHUD show];
    [self loadScrollView];
    [self getData];
}

- (void)loadScrollView{
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight - 64)];
    self.scrollView.contentSize = CGSizeMake(kScreenWidth, 10000);
    [self.view addSubview:self.scrollView];
}

- (void)loadSubViews{
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 15, kScreenWidth - 20, 20)];
    label.font = [UIFont systemFontOfSize:15];
    label.textAlignment = NSTextAlignmentCenter;
    if (self.resultDic.count > 0) {
        label.text = [self.resultDic objectForKey:@"title"];
    }
    [self.scrollView addSubview:label];
    
    UILabel *time = [[UILabel alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(label.frame) + 5, kScreenWidth - 20, 20)];
    time.font = [UIFont systemFontOfSize:13];
    time.textColor = [UIColor lightGrayColor];
    time.textAlignment = NSTextAlignmentCenter;
    if (self.resultDic.count > 0) {
        time.text = [self.resultDic objectForKey:@"addtime"];
        
    }
    [self.scrollView addSubview:time];
    
    _webView.frame = CGRectMake(0, CGRectGetMaxY(time.frame), kScreenWidth, kScreenHeight - 64 - CGRectGetMaxY(time.frame));
    
    
    [self.scrollView addSubview:_webView];
    //    [self.scrollView setContentSize:CGSizeMake(kScreenWidth, CGRectGetMaxY(_webView.frame) + 15)];
}



- (void)webViewDidFinishLoad:(UIWebView *)webView{
    [SVProgressHUD dismiss];
    [self loadSubViews];
    
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
    //方法1
    //HTML5的高度
    NSString *htmlHeight = [webView stringByEvaluatingJavaScriptFromString:@"document.body.scrollHeight"];
    //HTML5的宽度
    NSString *htmlWidth = [webView stringByEvaluatingJavaScriptFromString:@"document.body.scrollWidth"];
    //宽高比
    float i = [htmlWidth floatValue]/[htmlHeight floatValue];
    
    //webview控件的最终高度
    float height = kScreenWidth/i;
    
    CGRect frame = _webView.frame;
    _webView.frame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, height + 10);
    
    self.scrollView.contentSize = CGSizeMake(kScreenWidth, CGRectGetMaxY(_webView.frame));

}


- (void)getData{
    NSString *url = [NSString stringWithFormat:@"%@%@",BaseUrl,@"/get/msg.html"];
    NSDictionary *param = @{@"id":self.gundongID};
    [[SYHttpRequest sharedInstance] getDataWithUrl:url Parameter:param ResponseObject:^(NSDictionary *responseResult) {
        
        NSLog(@"滚动 -- %@",responseResult);
        if ([responseResult objectForKey:@"resError"]) {
            
        }else{
            if ([[responseResult objectForKey:@"result"] integerValue] == 1) {
                NSDictionary *dic = [responseResult objectForKey:@"data"];
                self.resultDic = dic;
//                NSString *htmlStr = [NSString stringWithFormat:@"<head><style>img{max-width:%dpx !important;}</style></head>%@",(int)(kScreenWidth - 20), [dic objectForKey:@"content"]];
                NSString *htmlStr = [dic objectForKey:@"content"];
                [_webView loadHTMLString:htmlStr baseURL:[NSURL URLWithString:BaseUrl]];
                
            }else{
                if ([responseResult objectForKey:@"msg"]) {
                    [self showHint:[responseResult objectForKey:@"msg"]];
                }
            }
        }
    }];
}


@end
