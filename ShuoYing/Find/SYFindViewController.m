//
//  SYFindViewController.m
//  ShuoYing
//
//  Created by 硕影 on 2016/12/26.
//  Copyright © 2016年 硕影. All rights reserved.
//

#import "SYFindViewController.h"

#import "SGTopScrollMenu.h"
#import "SYAllViewController.h"
#import "SYPeopleViewController.h" //人物
#import "SYSceneryViewController.h" //风景
#import "SYChildrenViewController.h" //儿童
#import "SYWeddingVeilViewController.h" //婚纱
#import "SYPhotoViewController.h" //写真
#import "SYDocumentarViewController.h" //纪实
#import "SYNostalgiaViewController.h" //怀旧
#import "SYClassicalViewController.h" //古典

#import "QTSearchBar.h"
@interface SYFindViewController ()<SGTopScrollMenuDelegate, UIScrollViewDelegate,UISearchBarDelegate,UITextFieldDelegate,QTSearchBarDelegate>
{
    NSInteger _currentIndex;
}

@property (nonatomic, strong) SGTopScrollMenu *topScrollMenu;
@property (nonatomic, strong) UIScrollView *mainScrollView;
@property (nonatomic, strong) NSArray *titles;

@property (nonatomic, strong) UIView *backView;
@end

@implementation SYFindViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (self.titleView == nil) {
        [self loadSearchBar];
    }
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
//    [self.titleView removeFromSuperview];
//    self.titleView= nil;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    _currentIndex = 0;
    
    self.titles = @[@"全部", @"人物", @"风景", @"儿童", @"婚纱", @"写真", @"纪实", @"怀旧", @"古典"];
    
    self.topScrollMenu = [SGTopScrollMenu topScrollMenuWithFrame:CGRectMake(0, 0, kScreenWidth, 40)];
    _topScrollMenu.titlesArr = [NSArray arrayWithArray:_titles];
    _topScrollMenu.topScrollMenuDelegate = self;
    [self.view addSubview:_topScrollMenu];
    
    // 创建底部滚动视图
    self.mainScrollView = [[UIScrollView alloc] init];
    _mainScrollView.frame = CGRectMake(0, 40, kScreenWidth, kScreenHeight - 40 - 64 - self.tabBarController.tabBar.frame.size.height);
    _mainScrollView.contentSize = CGSizeMake(self.view.frame.size.width * _titles.count, 0);
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
    
    [self.view insertSubview:_mainScrollView belowSubview:_topScrollMenu];
    
    [self setupChildViewController];
    
    [self loadSearchBar];
}

- (void)loadSearchBar{
    //添加取消返回按钮
//    [self.navigationController.navigationBar addSubview:self.titleView];
    self.navigationItem.titleView = self.titleView;
}


- (void)SGTopScrollMenu:(SGTopScrollMenu *)topScrollMenu didSelectTitleAtIndex:(NSInteger)index{
    _currentIndex = index;
    // 1 计算滚动的位置
    CGFloat offsetX = index * self.view.frame.size.width;
    self.mainScrollView.contentOffset = CGPointMake(offsetX, 0);
    
    // 2.给对应位置添加对应子控制器
    [self showVc:index];
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
    
    // 2.把对应的标题选中
    [[NSNotificationCenter defaultCenter] postNotificationName:@"change" object:@(index) userInfo:nil];
    
    // 2.把对应的标题选中
    UILabel *selLabel = self.topScrollMenu.allTitleLabel[index];
    
    [self.topScrollMenu selectLabel:selLabel];
    
    // 3.让选中的标题居中
    [self.topScrollMenu setupTitleCenter:selLabel];
}

// 添加所有子控制器
- (void)setupChildViewController {
    SYAllViewController *all = [[SYAllViewController alloc] init];
    [self addChildViewController:all];
    [self.mainScrollView addSubview:all.view];
    //人物
    SYPeopleViewController *peopleVC = [[SYPeopleViewController alloc] init];
    [self addChildViewController:peopleVC];
    //风景
    SYSceneryViewController *sceneryVC = [[SYSceneryViewController alloc] init];
    [self addChildViewController:sceneryVC];
    //儿童
    SYChildrenViewController *childrenVC = [[SYChildrenViewController alloc] init];
    [self addChildViewController:childrenVC];
    //婚纱
    SYWeddingVeilViewController *weddingVC = [[SYWeddingVeilViewController alloc] init];
    [self addChildViewController:weddingVC];
    //写真
    SYPhotoViewController *photoVC = [[SYPhotoViewController alloc] init];
    [self addChildViewController:photoVC];
    //纪实
    SYDocumentarViewController *documentarVC = [[SYDocumentarViewController alloc] init];
    [self addChildViewController:documentarVC];
    //怀旧
    SYNostalgiaViewController *nostalgiaVC = [[SYNostalgiaViewController alloc] init];
    [self addChildViewController:nostalgiaVC];
    //古典
    SYClassicalViewController *classicalVC = [[SYClassicalViewController alloc] init];
    [self addChildViewController:classicalVC];
}

- (QTSearchBar *)titleView{
    if (!_titleView) {
//        _titleView = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width / 3, 30)];
//        _titleView.layer.cornerRadius = 15;
//        _titleView.layer.masksToBounds = YES;
//        _titleView.searchBarStyle = UISearchBarStyleProminent;
//        _titleView.backgroundColor = [UIColor clearColor];
//        _titleView.placeholder = @"大家都在搜:可爱宝贝";
//        _titleView.delegate = self;
        
        _titleView = [QTSearchBar searchBarWith:CGRectMake(40, 5, kScreenWidth - 80, 30)];
        _titleView.placeholder = @"大家都在搜：儿童";
        _titleView.returnKeyType = UIReturnKeySearch;
        _titleView.clearButtonMode = UITextFieldViewModeWhileEditing;
        _titleView.searchDelegate = self;
        
        
    }
    return _titleView;
}

- (void)keyBoardSearchWithText:(NSString *)text{
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"FindSearchResult" object:[NSNumber numberWithInteger:_currentIndex] userInfo:@{@"keywords":text}];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"FindSearchResult" object:[NSNumber numberWithInteger:100] userInfo:@{@"keywords":text}];
    [self dismiss];

}

- (void)textFieldShouldClearText{
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"FindSearchResultCancle" object:[NSNumber numberWithInteger:_currentIndex] userInfo:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"FindSearchResultCancle" object:[NSNumber numberWithInteger:100] userInfo:nil];
}

- (void)textFieldShouldBeginEdit{
    [self.view addSubview:self.backView];

}


- (UIView *)backView{
    if (!_backView) {
        _backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
        _backView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.6];
        _backView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss)];
        [_backView addGestureRecognizer:tap];
    }
    return _backView;
}

- (void)dismiss{
    if (self.titleView.text.length == 0) {
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"FindSearchResultCancle" object:[NSNumber numberWithInteger:_currentIndex] userInfo:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"FindSearchResultCancle" object:[NSNumber numberWithInteger:100] userInfo:nil];
    }
    [self.backView removeFromSuperview];
    [self.titleView resignFirstResponder];
}

@end
