//
//  SYOrderViewController.m
//  ShuoYing
//
//  Created by 硕影 on 2017/3/31.
//  Copyright © 2017年 硕影. All rights reserved.
//

#import "SYOrderViewController.h"

#import "SYXianXiaViewController.h"
#import "SYXianShangViewController.h"

@interface SYOrderViewController ()
{
    NSInteger _currentSelectedState;
}

@property (nonatomic, strong) UISegmentedControl *segmentControl;

@property (nonatomic, strong) UIView *childView;

@end

#define SegmentHeight 42

@implementation SYOrderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"我的订单";
    _currentSelectedState = 0;
    [self setSegmentView];
    [self setChildViewControllers];
}
//分段控制器事件方法
- (void)changeOrderState:(UISegmentedControl *)cor{
    if (_currentSelectedState == cor.selectedSegmentIndex) {
        return;
    }
    _currentSelectedState = cor.selectedSegmentIndex;
    
    [self.childView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    UIViewController *vc = self.childViewControllers[cor.selectedSegmentIndex];
    vc.view.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight - 64 - SegmentHeight - 16);
    
    [self.childView addSubview:vc.view];
    
}

- (void)setChildViewControllers{
    SYXianShangViewController *xianshang = [[SYXianShangViewController alloc] init];
    xianshang.view.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight - 64 - SegmentHeight - 16);
    
    [self addChildViewController:xianshang];
    [self.childView addSubview:xianshang.view];
    
    SYXianXiaViewController *xianxia = [[SYXianXiaViewController alloc] init];
    
    [self addChildViewController:xianxia];
}

- (void)setSegmentView{
    UIView *segView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, SegmentHeight + 16)];
    segView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:segView];
    [segView addSubview:self.segmentControl];
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, segView.frame.size.height - 1, kScreenWidth, 1)];
    lineView.backgroundColor = RGB(234, 234, 234);
    [segView addSubview:lineView];
    
    [self.view addSubview:self.childView];
}

- (UIView *)childView{
    if (!_childView) {
        _childView = [[UIView alloc] initWithFrame:CGRectMake(0, SegmentHeight + 16, kScreenWidth, kScreenHeight - 64 - SegmentHeight - 16)];
        
    }
    return _childView;
}

- (UISegmentedControl *)segmentControl{
    if (!_segmentControl) {
        NSArray *items = @[@"线上订单", @"线下订单"];
        _segmentControl = [[UISegmentedControl alloc] initWithItems:items];
        _segmentControl.frame = CGRectMake(0, 0, 92 * 2, SegmentHeight);
        _segmentControl.center = CGPointMake(kScreenWidth / 2, (SegmentHeight + 16) / 2);
        _segmentControl.tintColor = NavigationColor;
        _segmentControl.selectedSegmentIndex = 0;
        [_segmentControl addTarget:self action:@selector(changeOrderState:) forControlEvents:UIControlEventValueChanged];
    }
    return _segmentControl;
}

@end
