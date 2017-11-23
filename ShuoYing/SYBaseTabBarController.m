//
//  SYBaseTabBarController.m
//  ShuoYing
//
//  Created by 硕影 on 2016/12/26.
//  Copyright © 2016年 硕影. All rights reserved.
//

#import "SYBaseTabBarController.h"
#import "SYCloudViewController.h"
#import "SYPhotoStudioViewController.h"
#import "SYMineViewController.h"
#import "SYMyFaBuViewController.h"
#import "SYShopcartViewController.h"
#import "SYLoginViewController.h"

@interface SYBaseTabBarController ()<UITabBarDelegate, UITabBarControllerDelegate>
{
    NSInteger _currentItemTag;
}

@property (nonatomic, strong) SYCloudViewController *cloudVC;

//@property (nonatomic, strong) SYPhotoStudioViewController *photoVC;

@property (nonatomic, strong) SYMyFaBuViewController *fabuVC;

@property (nonatomic, strong) SYShopcartViewController *shopcartVC;

@property (nonatomic, strong) SYMineViewController *mineVC;


@end

@implementation SYBaseTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    _currentItemTag = 0;
    self.delegate = self;
    [self setupSubviews];
    
    self.navigationItem.leftBarButtonItem = _cloudVC.leftBarItem;
    self.navigationItem.rightBarButtonItem = _cloudVC.rightBarItem;
    self.navigationItem.titleView = _cloudVC.titleView;
}


#pragma mark - UITabBarDelegate

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
    if (_currentItemTag == item.tag) {
        return;
    }
    _currentItemTag = item.tag;
    self.navigationItem.rightBarButtonItem = nil;
    self.navigationItem.leftBarButtonItem = nil;
    self.navigationItem.titleView = nil;
    self.navigationItem.title = nil;
    self.navigationController.navigationBar.translucent = NO;
    
    if (item.tag == 0) {
        
        
        self.navigationItem.leftBarButtonItem = _cloudVC.leftBarItem;
        self.navigationItem.rightBarButtonItem = _cloudVC.rightBarItem;
        self.navigationItem.titleView = _cloudVC.titleView;
        [self.navigationController setNavigationBarHidden:NO animated:NO];
    }else if (item.tag == 1){
//        self.navigationItem.titleView = _photoVC.titleView;
//        self.navigationItem.rightBarButtonItem = _photoVC.rightBarItem;
        self.navigationItem.title = @"我的发布";

        [self.navigationController setNavigationBarHidden:NO animated:NO];
        
    }else if (item.tag == 3){
        if (!LoginStatus) {
            
            return;
        }
        self.navigationItem.rightBarButtonItem = nil;
        self.navigationItem.leftBarButtonItem = nil;
        self.navigationItem.titleView = nil;
        [self.navigationController setNavigationBarHidden:YES animated:NO];
        
    }else{
        self.navigationItem.title = @"购物车";
        self.navigationItem.rightBarButtonItem = _shopcartVC.rightItem;

        [self.navigationController setNavigationBarHidden:NO animated:NO];

    }
}

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController{
    if ([viewController isKindOfClass:[SYMineViewController class]] || [viewController isKindOfClass:[SYMyFaBuViewController class]] || [viewController isKindOfClass:[SYShopcartViewController class]]) {
        if (!LoginStatus) {
            SYLoginViewController *loginVC = [[SYLoginViewController alloc] initWithNibName:@"SYLoginViewController" bundle:nil];
            [self.navigationController pushViewController:loginVC animated:YES];
            return NO;
        }
    }
    return YES;
}

#pragma mark - private

- (void)setupSubviews
{
    
    _cloudVC = [[SYCloudViewController alloc] initWithNibName:nil bundle:nil];
    _cloudVC.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"首页"
                                                           image:[[UIImage imageNamed:@"footer_icon_shouye_nor"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
                                                   selectedImage:[[UIImage imageNamed:@"footer_icon_shouye_sel"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    _cloudVC.tabBarItem.tag = 0;
    [self unSelectedTapTabBarItems:_cloudVC.tabBarItem];
    [self selectedTapTabBarItems:_cloudVC.tabBarItem];
    
    _fabuVC = [[SYMyFaBuViewController alloc] init];
    _fabuVC.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"记录"
                                                       image:[[UIImage imageNamed:@"shouye-jilu1"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
                                               selectedImage:[[UIImage imageNamed:@"shouye-jilu"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];

    _fabuVC.tabBarItem.tag = 1;
    [self unSelectedTapTabBarItems:_fabuVC.tabBarItem];
    [self selectedTapTabBarItems:_fabuVC.tabBarItem];
    
    _shopcartVC = [[SYShopcartViewController alloc] init];
    _shopcartVC.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"购物车"
                                                       image:[[UIImage imageNamed:@"shouye-gouwuche1"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
                                                   selectedImage:[[UIImage imageNamed:@"shouye-gouwuche2"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    
    _shopcartVC.tabBarItem.tag = 2;
    [self unSelectedTapTabBarItems:_shopcartVC.tabBarItem];
    [self selectedTapTabBarItems:_shopcartVC.tabBarItem];
    
    _mineVC = [[SYMineViewController alloc] init];
    _mineVC.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"我的"
                                                           image:[[UIImage imageNamed:@"footer_icon_wode_nor"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
                                                   selectedImage:[[UIImage imageNamed:@"footer_icon_wode_sel"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    _mineVC.tabBarItem.tag = 3;
    
    [self unSelectedTapTabBarItems:_mineVC.tabBarItem];
    [self selectedTapTabBarItems:_mineVC.tabBarItem];
    
    self.viewControllers = @[_cloudVC, _fabuVC, _shopcartVC, _mineVC];
    [self selectedTapTabBarItems:_cloudVC.tabBarItem];
}

-(void)unSelectedTapTabBarItems:(UITabBarItem *)tabBarItem
{
    [tabBarItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                        [UIFont systemFontOfSize:14], NSFontAttributeName,
                                        [UIColor blackColor],NSForegroundColorAttributeName,
                                        nil] forState:UIControlStateNormal];
}

-(void)selectedTapTabBarItems:(UITabBarItem *)tabBarItem
{
    [tabBarItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                        [UIFont systemFontOfSize:14],NSFontAttributeName,
                                        NavigationColor,NSForegroundColorAttributeName,
                                        nil] forState:UIControlStateSelected];
}



@end
