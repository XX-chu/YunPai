//
//  SYMyReciveViewController.m
//  ShuoYing
//
//  Created by chu on 2017/10/31.
//  Copyright © 2017年 硕影. All rights reserved.
//

#import "SYMyReciveViewController.h"
#import "SYMyReciveGrapherViewController.h"
#import "SYMyReciveTeacherViewController.h"
@interface SYMyReciveViewController ()<UIScrollViewDelegate>
{
    UIButton *_currentSelectedBtn;
    UIView *_currentLineView;
    NSInteger _currentIndex;
    
    SYMyReciveTeacherViewController *_teacherVC;
    SYMyReciveGrapherViewController *_grapherVC;
}

@property (nonatomic, strong) UIView *labelView;

@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, strong) NSMutableArray *btnArr;


@end

@implementation SYMyReciveViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    NSLog(@"1111");

}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    _currentIndex = 0;
    self.title = @"我的接收";
    self.automaticallyAdjustsScrollViewInsets = NO;
    //初始化子控制器
    [self.view addSubview:self.labelView];
    [self.view addSubview:self.scrollView];

    [self addChildControllers];
    
}

#pragma mark - PrivateMethod
- (void)labelBtnSelected:(UIButton *)btn{
    if ([_currentSelectedBtn.titleLabel.text isEqualToString:btn.titleLabel.text]) {
        return;
    }
    _currentSelectedBtn.selected = NO;
    btn.selected = YES;
    _currentSelectedBtn = btn;
    
    NSInteger length = _currentSelectedBtn.titleLabel.text.length;
    [UIView animateWithDuration:.2 animations:^{
        _currentLineView.frame = CGRectMake(0, 0, 15 * length + 10, 1);
        _currentLineView.center = CGPointMake(_currentSelectedBtn.center.x, 0);
        
    }];
    
    // 定位到指定位置
    
    CGPoint offset = self.scrollView.contentOffset;
    offset.x = _currentSelectedBtn.tag * kScreenWidth;
    [self.scrollView setContentOffset:offset animated:YES];
}

#pragma mark - loadChildControllers
- (void)addChildControllers{
    if (!_teacherVC) {
        _teacherVC = [[SYMyReciveTeacherViewController alloc] init];
    }
    [self addChildViewController:_teacherVC];
    [self.scrollView addSubview:_teacherVC.view];

    if (!_grapherVC) {
        _grapherVC = [[SYMyReciveGrapherViewController alloc] init];
    }
    [self addChildViewController:_grapherVC];

}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView{
    NSInteger index = scrollView.contentOffset.x / scrollView.frame.size.width;
    _currentIndex = index;
    //上标签
    [self labelBtnSelected:self.btnArr[_currentIndex]];
    //取出子控制器
    UIViewController *vc = self.childViewControllers[_currentIndex];
    
    if([vc isViewLoaded]) return;
    //    CGRect newFrame = CGRectMake(scrollView.contentOffset.x, 0, kScreenWidth, scrollView.frame.size.height);
    CGRect newFrame = CGRectMake(kScreenWidth * index, 0, kScreenWidth, scrollView.frame.size.height);
    vc.view.frame = newFrame;
    
    [scrollView addSubview:vc.view];
}

/**
 *  当手指抬起停止减速的时候会调用这个方法,
 */
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self scrollViewDidEndScrollingAnimation:scrollView]; //加载ctrl
}

// 将要减速
-(void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView{
    [self scrollViewDidEndScrollingAnimation:scrollView]; //上面title和ctrl保持一致
    
}

#pragma mark - LazyLoad
- (UIView *)labelView{
    if (!_labelView) {
        _labelView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 40)];
        _labelView.backgroundColor = [UIColor whiteColor];
        NSArray *arr = @[@"来自云拍圈", @"来自云拍师及会员"];
        for (int i = 0; i < arr.count; i++) {
            UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake((kScreenWidth / 2) * i, 0, kScreenWidth / 2, 39)];
            [btn setTitle:arr[i] forState:UIControlStateNormal];
            btn.titleLabel.font = [UIFont systemFontOfSize:15];
            [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            btn.tag = i;
            [btn setTitleColor:NavigationColor forState:UIControlStateSelected];
            [btn addTarget:self action:@selector(labelBtnSelected:) forControlEvents:UIControlEventTouchUpInside];
            if (i == 0) {
                _currentSelectedBtn = btn;
                btn.selected = YES;
            }
            [_labelView addSubview:btn];
            [self.btnArr insertObject:btn atIndex:i];
        }
        
        UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0, 39, kScreenWidth, 1)];
        backView.backgroundColor = BackGroundColor;
        [_labelView addSubview:backView];
        
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 75, 1)];
        lineView.backgroundColor = NavigationColor;
        lineView.center = CGPointMake(_currentSelectedBtn.center.x, 0);
        _currentLineView = lineView;
        [backView addSubview:lineView];
    }
    return _labelView;
}

- (UIScrollView *)scrollView{
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 40, kScreenWidth, kScreenHeight - 40 - kNavigationBarHeightAndStatusBarHeight)];
        _scrollView.contentSize = CGSizeMake(kScreenWidth * 2, kScreenHeight - 40 - kNavigationBarHeightAndStatusBarHeight);
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.pagingEnabled = YES;
        _scrollView.bounces = NO;
        _scrollView.delegate = self;
        
    }
    return _scrollView;
}

- (NSMutableArray *)btnArr{
    if (!_btnArr) {
        _btnArr = [NSMutableArray arrayWithCapacity:0];
    }
    return _btnArr;
}


@end
