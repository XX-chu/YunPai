//
//  SYXieYiViewController.m
//  ShuoYing
//
//  Created by 硕影 on 2017/1/19.
//  Copyright © 2017年 硕影. All rights reserved.
//

#import "SYXieYiViewController.h"

@interface SYXieYiViewController ()

@end

@implementation SYXieYiViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"用户协议";
    [self setImageView];
}

- (void)setImageView{
    UIScrollView *scrollview = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight - kNavigationBarHeightAndStatusBarHeight)];
    scrollview.bounces = NO;
    [self.view addSubview:scrollview];
    
    UIImage *xieyi = [UIImage imageNamed:@"用户协议.jpg"];
    UIImageView *imageview = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenWidth / xieyi.size.width * xieyi.size.height)];
    imageview.contentMode = UIViewContentModeScaleAspectFit;
    imageview.image = xieyi;
    scrollview.contentSize = CGSizeMake(kScreenWidth, imageview.frame.size.height);
    scrollview.showsHorizontalScrollIndicator = NO;
    [scrollview addSubview:imageview];
}

@end
