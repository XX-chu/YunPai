//
//  SYXianXiaViewController.m
//  ShuoYing
//
//  Created by 硕影 on 2017/3/31.
//  Copyright © 2017年 硕影. All rights reserved.
//

#import "SYXianXiaViewController.h"
#import "UIButton+Badge.h"
#import "SYXXAllViewController.h"
#import "SYXXFuKuanViewController.h"
#import "SYXXShiYongViewController.h"
#import "SYXXPingJiaViewController.h"
@interface SYXianXiaViewController ()<UIScrollViewDelegate>

{
    NSInteger _currentIndex;
}

@property (nonatomic, strong) UIScrollView *mainScrollView;

@property (nonatomic, strong) NSMutableArray *btnsArr;

@property (nonatomic, strong) NSDictionary *unreadMsgDic;

@end

#define LabelViewHeight 46

@implementation SYXianXiaViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(unreadMessage:) name:@"xxorderUnreadMessage" object:nil];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"xxorderUnreadMessage" object:nil];
}

- (void)unreadMessage:(NSNotification *)tifi{
    NSDictionary *count = tifi.userInfo;
    self.unreadMsgDic = count;
    
    [self setLabelView];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.unreadMsgDic = nil;
    self.view.backgroundColor = BackGroundColor;
    _currentIndex = 0;
    // 创建底部滚动视图
    self.mainScrollView = [[UIScrollView alloc] init];
    _mainScrollView.frame = CGRectMake(0, LabelViewHeight, kScreenWidth, kScreenHeight - kNavigationBarHeightAndStatusBarHeight - 42 - 16 - LabelViewHeight);
    _mainScrollView.contentSize = CGSizeMake(self.view.frame.size.width * 4, 0);
    _mainScrollView.backgroundColor = [UIColor clearColor];
    // 开启分页
    _mainScrollView.pagingEnabled = YES;
    // 没有弹簧效果
    _mainScrollView.bounces = NO;
    // 隐藏水平滚动条
    _mainScrollView.showsHorizontalScrollIndicator = NO;
    // 设置代理
    _mainScrollView.delegate = self;
    [self.view addSubview:_mainScrollView];
    
    [self setLabelView];
    
    [self setChildViewControllers];
}

- (void)orderState:(UIButton *)btn{
    
    _currentIndex = btn.tag;
    for (int i = 0 ; i < self.btnsArr.count; i++) {
        UIButton *btn = self.btnsArr[i];
        if (btn.tag == _currentIndex) {
            [btn setTitleColor:NavigationColor forState:UIControlStateNormal];
            btn.badgeValue = nil;
        }else{
            [btn setTitleColor:HexRGB(0x5f5f5f) forState:UIControlStateNormal];
        }
    }
    // 1 计算滚动的位置
    CGFloat offsetX = btn.tag * self.view.frame.size.width;
    self.mainScrollView.contentOffset = CGPointMake(offsetX, 0);
    
    // 2.给对应位置添加对应子控制器
    [self showVc:btn.tag];
}

// 显示控制器的view
- (void)showVc:(NSInteger)index {
    _currentIndex = index;
    
    CGFloat offsetX = index * self.view.frame.size.width;
    
    UIViewController *vc = self.childViewControllers[index];
    
    // 判断控制器的view有没有加载过,如果已经加载过,就不需要加载
    if (vc.isViewLoaded) return;
    
    [self.mainScrollView addSubview:vc.view];
    vc.view.frame = CGRectMake(offsetX, 0, self.view.frame.size.width, self.mainScrollView.frame.size.height);
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    
    // 计算滚动到哪一页
    NSInteger index = scrollView.contentOffset.x / scrollView.bounds.size.width;
    _currentIndex = index;
    // 1.添加子控制器view
    [self showVc:index];
    
    [self orderState:self.btnsArr[_currentIndex]];
}

//标签view
- (void)setLabelView{
    NSArray *titles = @[@"全部", @"待付款", @"可使用", @"待评价"];
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, LabelViewHeight)];
    view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:view];
    [view.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    for (int i = 0 ; i < titles.count; i++) {
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(i * (kScreenWidth / 4), 5, kScreenWidth / 4, 35)];
        
        btn.tag = i;
        [btn setTitle:titles[i] forState:UIControlStateNormal];
        [btn setTitleColor:HexRGB(0x5f5f5f) forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont systemFontOfSize:15];
        [btn addTarget:self action:@selector(orderState:) forControlEvents:UIControlEventTouchUpInside];
        if (i == 0) {
            [btn setTitleColor:NavigationColor forState:UIControlStateNormal];
        }
        [view addSubview:btn];
        
        if (self.unreadMsgDic.count > 0) {
            if (i > 0) {
                NSString *value = @"";
                if (i > 1) {
                    value = [[self.unreadMsgDic objectForKey:[NSString stringWithFormat:@"c%d",i+1]] stringValue];
                }else{
                    value = [[self.unreadMsgDic objectForKey:[NSString stringWithFormat:@"c%d",i]] stringValue];
                }
                
                if (![value isEqualToString:@"0"]) {
                    btn.badgeValue = value;
                }
                btn.badgePadding = 1;
                btn.badgeFont = [UIFont systemFontOfSize:14];
                btn.badgeOriginX = (btn.frame.size.width - 45) / 2 + 45 - 10;
                btn.badgeOriginY = 0;
            }
        }
        
        [self.btnsArr addObject:btn];
    }
}

- (void)setChildViewControllers{
    SYXXAllViewController *all = [[SYXXAllViewController alloc] init];
    all.view.frame = CGRectMake(0, 0, kScreenWidth, self.mainScrollView.frame.size.height);
    [self.mainScrollView addSubview:all.view];
    [self addChildViewController:all];
    
    SYXXFuKuanViewController *fukuan = [[SYXXFuKuanViewController alloc] init];
    [self addChildViewController:fukuan];
    
    SYXXShiYongViewController *fahuo = [[SYXXShiYongViewController alloc] init];
    [self addChildViewController:fahuo];
    
    SYXXPingJiaViewController *shouhuo = [[SYXXPingJiaViewController alloc] init];
    [self addChildViewController:shouhuo];
    
}

- (NSMutableArray *)btnsArr{
    if (!_btnsArr) {
        _btnsArr = [NSMutableArray arrayWithCapacity:0];
    }
    return _btnsArr;
}

@end
