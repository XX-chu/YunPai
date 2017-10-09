//
//  QTWelcomeViewController.m
//  ReadingClub
//
//  Created by qtkj on 2016/10/26.
//  Copyright © 2016年 qtkj. All rights reserved.
//

#import "SYWelcomeViewController.h"

@interface SYWelcomeViewController ()<UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, strong) UIPageControl *pageControl;

@end

@implementation SYWelcomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSArray *images = @[@"引导页1", @"引导页2", @"引导页3", @"引导页4"];
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
    
    self.scrollView.contentSize = CGSizeMake(kScreenWidth * images.count, kScreenHeight);
    self.scrollView.delegate = self;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.bounces = NO;
    self.scrollView.pagingEnabled = YES;
    for (int i = 0; i < images.count; i ++) {
        UIImageView *imageview = [[UIImageView alloc] initWithFrame:CGRectMake(kScreenWidth * i, 0, kScreenWidth, kScreenHeight)];
        imageview.image = [UIImage imageNamed:images[i]];
        [self.scrollView addSubview:imageview];
    }
    [self.view addSubview:self.scrollView];
    
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 100)];
    btn.center = CGPointMake(kScreenWidth * 3 + kScreenWidth * 0.5, kScreenHeight - 50);
    btn.adjustsImageWhenHighlighted = NO;
    [btn addTarget:self action:@selector(gotoMainVC) forControlEvents:UIControlEventTouchUpInside];
    [self.scrollView addSubview:btn];
    
//    UIPageControl *pageControll = [[UIPageControl alloc] initWithFrame:CGRectMake(0, kScreenHeight - 50, kScreenWidth, 30)];
//    pageControll.numberOfPages = images.count;
//    pageControll.currentPageIndicatorTintColor = RGB(150, 119, 96);
//    pageControll.pageIndicatorTintColor = RGB(216, 216, 216);
//    [self.view addSubview:pageControll];
//    [self.view bringSubviewToFront:pageControll];
//    self.pageControl = pageControll;
}

- (void)gotoMainVC{
    if (_delegate && [_delegate respondsToSelector:@selector(gotoMainTabbar)]) {
        [_delegate gotoMainTabbar];
    }
}

@end
