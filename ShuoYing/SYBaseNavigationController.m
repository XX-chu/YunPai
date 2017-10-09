//
//  SYBaseNavigationViewController.m
//  ShuoYing
//
//  Created by 硕影 on 2016/12/26.
//  Copyright © 2016年 硕影. All rights reserved.
//

#import "SYBaseNavigationController.h"

@interface SYBaseNavigationController ()<UINavigationControllerDelegate>

@property (nonatomic, weak) id PopDelegate;

@property (nonatomic, strong) UIButton *backBtn;

@end

@implementation SYBaseNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    
    self.navigationBar.barTintColor = [UIColor whiteColor];
    [self.navigationBar setBackgroundImage:[UIImage imageWithColor:NavigationColor Size:CGSizeMake(kScreenWidth, 64)] forBarMetrics:UIBarMetricsDefault];
    self.navigationBar.shadowImage = [UIImage imageWithColor:NavigationColor Size:CGSizeMake(kScreenWidth, 1)];
    self.navigationBar.translucent = NO;
    self.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor], NSFontAttributeName : [UIFont systemFontOfSize:17]};
    self.PopDelegate = self.interactivePopGestureRecognizer.delegate;
    self.delegate = self;
}


#pragma mark --------navigation delegate
//该方法可以解决popRootViewController时tabbar的bug
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated{
    //删除系统自带的tabBarButton
    for (UIView *tabBar in self.tabBarController.tabBar.subviews) {
        if ([tabBar isKindOfClass:NSClassFromString(@"UITabBarButton")]) {
            [tabBar removeFromSuperview];
        }
    }
    
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated{
    
    if (viewController == self.viewControllers[0]) {
        self.interactivePopGestureRecognizer.delegate = self.PopDelegate;
    }else{
        self.interactivePopGestureRecognizer.delegate = nil;
    }
    
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated{
    viewController.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleDone target:self action:@selector(popAction)];
    if (self.viewControllers.count > 0) {
        
        viewController.navigationItem.hidesBackButton = YES;
        _backBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
        [_backBtn setImageEdgeInsets:UIEdgeInsetsMake(0, -25, 0, 25)];
        [_backBtn setImage:[UIImage imageNamed:@"wode_photo_gerenshezhi_fanhui"] forState:UIControlStateNormal];
        [_backBtn setAdjustsImageWhenHighlighted:NO];
        [_backBtn addTarget:self action:@selector(popAction) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_backBtn];
        
        viewController.navigationItem.leftBarButtonItem = backBarButtonItem;
        
    }
    
    [super pushViewController:viewController animated:animated];
    
    
}


- (void)popAction{
    [self popViewControllerAnimated:YES];
}

//设置状态栏颜色
- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleDefault;
}
@end
