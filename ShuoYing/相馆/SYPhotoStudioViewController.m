//
//  SYPhotoStudioViewController.m
//  ShuoYing
//
//  Created by 硕影 on 2017/3/23.
//  Copyright © 2017年 硕影. All rights reserved.
//

#import "SYPhotoStudioViewController.h"
#import "JSDropDownMenu.h"
#import "QTSearchBar.h"
#import "SYPhotoStudioTableViewCell.h"
#import "SYPhotoStudioModel.h"

#import "SYPhotoStudioHeaderOneCollectionReusableView.h"
#import "SYPhotoStudioHistoryCollectionViewCell.h"

#import "SYBisnessViewController.h"

@interface SYPhotoStudioViewController ()<QTSearchBarDelegate, JSDropDownMenuDataSource,JSDropDownMenuDelegate, UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource, UIGestureRecognizerDelegate>
{
    NSInteger _currentData1Index;
    NSInteger _currentData2Index;
    NSInteger _count;
    UILabel *_rightLabel;
}
@property (nonatomic, strong) NSMutableArray *leftMuArr;

@property (nonatomic, strong) NSMutableArray *rightMuArr;

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *dataSourceArr;

@property (nonatomic, strong) JSDropDownMenu *menu;

@property (nonatomic, strong) UICollectionView *historyCollectionView;

@property (nonatomic, strong) UIView *historyBackView;

@property (nonatomic, strong) NSMutableArray *historySearchArr;

@end

static NSString *identifier = @"historyCell";
static NSString *oneHeaderIdentifier = @"oneheader";

@implementation SYPhotoStudioViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fangqixiangying) name:@"fangqixiangying" object:nil];
    self.navBarBgAlpha = @"1.0";
    self.tabBarController.navigationItem.rightBarButtonItem = self.rightBarItem;
    self.tabBarController.navigationItem.titleView = self.titleView;
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"fangqixiangying" object:nil];
}

- (void)fangqixiangying{
    [self.titleView resignFirstResponder];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _currentData1Index = 0;
    _currentData2Index = 0;
    
    NSUserDefaults *us = [NSUserDefaults standardUserDefaults];
    if ([us objectForKey:@"selectequyucity"]) {
        NSArray *city = [us objectForKey:@"selectequyucity"];
        [self.leftMuArr addObjectsFromArray:city];
    }
    
    _count = 1;

    [self.view addSubview:self.menu];
    
    [self.view addSubview:self.tableView];
    
    [self getDataWithText:@"" WithKey:@""];
    
    //读取搜索历史记录
    [self getHistoryRecord];
    [self loadRightTarbar];

}

- (void)loadRightTarbar{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
    view.userInteractionEnabled = YES;
//    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dingweiAction:)];
//    [view addGestureRecognizer:tap];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 44, 44-13)];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.image = [UIImage imageNamed:@"shouye_icon_dizhi"];
    [view addSubview:imageView];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(view.frame) - 13, 44, 13)];
    label.text = @"定位";
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"dingweiCity"]) {
        label.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"dingweiCity"];
    }
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize:13];
    label.textColor = [UIColor whiteColor];
    _rightLabel = label;
    [view addSubview:label];
    
    self.rightBarItem = [[UIBarButtonItem alloc] initWithCustomView:view];
}

- (void)getHistoryRecord{
    NSUserDefaults *us = [NSUserDefaults standardUserDefaults];
    if ([us objectForKey:@"photoStudioSearchHistory"]) {
        NSArray *arr = [us objectForKey:@"photoStudioSearchHistory"];
        [self.historySearchArr addObjectsFromArray:arr];
    }
}

#pragma mark - UITableViewDataSource

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    SYBisnessViewController *bisness = [[SYBisnessViewController alloc] init];
    SYPhotoStudioModel *photoStudio = self.dataSourceArr[indexPath.section];
    bisness.photoID = photoStudio.photoStudioID;
    [self.navigationController pushViewController:bisness animated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"photoStudioCell";
    SYPhotoStudioTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[NSBundle mainBundle] loadNibNamed:@"SYPhotoStudioTableViewCell" owner:nil options:nil][0];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    SYPhotoStudioModel *photoStudio = self.dataSourceArr[indexPath.section];
    cell.photoStudioModel = photoStudio;
    
    
    return cell;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.dataSourceArr.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 98;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return 14;
    }
    return 0.00001f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 14;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = HexRGB(0xf3f3f3);
    return view;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = HexRGB(0xf3f3f3);
    return view;
}

#pragma mark - QTSearchbarDelegate
- (void)keyBoardSearchWithText:(NSString *)text{
    [self historyViewDismiss];
    //搜索时候记录历史记录
    if (text.length > 0) {
        NSUserDefaults *us = [NSUserDefaults standardUserDefaults];
        if ([us objectForKey:@"photoStudioSearchHistory"]) {
            NSArray *arr = [us objectForKey:@"photoStudioSearchHistory"];
            NSMutableArray *muArr = [NSMutableArray arrayWithCapacity:0];
            [muArr addObjectsFromArray:arr];
            BOOL ishave = NO;
            for (NSString *historyStr in arr) {
                if ([historyStr isEqualToString:text]) {
                    ishave = YES;
                    break;
                }else{
                    ishave = NO;
                }
            }
            if (ishave == NO) {
                [muArr addObject:text];
                [us setObject:muArr forKey:@"photoStudioSearchHistory"];
                [us synchronize];
            }
        }else{
            NSMutableArray *muArr = [NSMutableArray arrayWithCapacity:0];
            [muArr addObject:text];
            [us setObject:muArr forKey:@"photoStudioSearchHistory"];
            [us synchronize];
        }
    }
    if (_currentData1Index == 0) {
        [self getDataWithText:@"" WithKey:text];
    }else{
        [self getDataWithText:self.leftMuArr[_currentData1Index] WithKey:text];
    }
}

- (void)textFieldShouldClearText{

}

- (void)textFieldShouldBeginEdit{

    for (UIView *view in self.view.subviews) {
        if (view.tag == 1111111) {
            [self.menu backgroundTapped:nil];
        }
    }
    
    NSUserDefaults *us = [NSUserDefaults standardUserDefaults];
    if ([us objectForKey:@"photoStudioSearchHistory"]) {
        [self.historySearchArr removeAllObjects];
        NSArray *arr = [us objectForKey:@"photoStudioSearchHistory"];
        [self.historySearchArr addObjectsFromArray:arr];
    }
    
    [self historyViewShow];
}

#pragma mark - pullViewDelegate
- (NSInteger)numberOfColumnsInMenu:(JSDropDownMenu *)menu {
    
    return 2;
}

-(BOOL)displayByCollectionViewInColumn:(NSInteger)column{
    
    return NO;
}

-(BOOL)haveRightTableViewInColumn:(NSInteger)column{
    
    return NO;
}

-(CGFloat)widthRatioOfLeftColumn:(NSInteger)column{
    
    return 1;
}

-(NSInteger)currentLeftSelectedRow:(NSInteger)column{
    
    if (column == 0) {
        return _currentData1Index;
    }
    
    if (column == 1) {
        return _currentData2Index;
    }
    
    return 0;
}

- (NSInteger)menu:(JSDropDownMenu *)menu numberOfRowsInColumn:(NSInteger)column leftOrRight:(NSInteger)leftOrRight leftRow:(NSInteger)leftRow{
    
    if (column==0) {
        
        return self.leftMuArr.count;
    }else{
        return self.rightMuArr.count;
    }
    
    return 0;
}

- (NSString *)menu:(JSDropDownMenu *)menu titleForColumn:(NSInteger)column{
    
    switch (column) {
        case 0: return self.leftMuArr[_currentData1Index];
            break;
        case 1: return self.rightMuArr[_currentData2Index];
            break;

        default:
            return nil;
            break;
    }
}

- (NSString *)menu:(JSDropDownMenu *)menu titleForRowAtIndexPath:(JSIndexPath *)indexPath {
    
    if (indexPath.column==0) {
        return self.leftMuArr[indexPath.row];
    } else {
        
        return self.rightMuArr[indexPath.row];
    }
}

- (void)menu:(JSDropDownMenu *)menu didSelectRowAtIndexPath:(JSIndexPath *)indexPath {
    if (indexPath.column == 0) {
        
        _currentData1Index = indexPath.row;
        
    }  else{
        
        _currentData2Index = indexPath.row;
    }
    
    if (_currentData1Index >= 0) {
        if (_currentData1Index == 0) {
            [self getDataWithText:@"" WithKey:self.titleView.text];
        }else if (_currentData1Index == 1){
            NSUserDefaults *us = [NSUserDefaults standardUserDefaults];
            if ([us objectForKey:@"selectequyuprov"]) {
                NSString *city = [us objectForKey:@"selectequyuprov"];

                [self getDataWithText:city WithKey:self.titleView.text];
            }
            
        }else{
            NSString *city = self.leftMuArr[_currentData1Index];
            [self getDataWithText:city WithKey:self.titleView.text];
        }
    }
    
}

- (void)getDataWithText:(NSString *)text WithKey:(NSString *)key{
    [SVProgressHUD show];
    NSUserDefaults *us = [NSUserDefaults standardUserDefaults];
    NSNumber *jingdu = [us objectForKey:@"jingdu"];
    NSNumber *weidu = [us objectForKey:@"weidu"];
    
    NSString *url = [NSString stringWithFormat:@"%@%@",BaseUrl,@"/store/index.html"];
    NSString *order = @"";
    if (_currentData2Index >= 0) {
        if (_currentData2Index == 0) {
            order = @"juli";
        }else{
            order = @"ping";
        }
    }
    NSDictionary *param = @{@"lat":weidu, @"long":jingdu, @"gps":@"gcj02ll", @"city":text, @"order":order, @"page":@1, @"key":key};
    NSLog(@"param - %@",param);
    [[SYHttpRequest sharedInstance] getDataWithUrl:url Parameter:param ResponseObject:^(NSDictionary *responseResult) {
        if ([self.tableView.mj_header isRefreshing]) {
            [self.tableView.mj_header endRefreshing];
        }
        _count = 1;
        [SVProgressHUD dismiss];
        NSLog(@"获取相馆列表 -- %@",responseResult);
        if ([responseResult objectForKey:@"resError"]) {
            
        }else{
            if ([[responseResult objectForKey:@"result"] integerValue] == 1) {
                if ([responseResult objectForKey:@"data"]) {
                    NSArray *data = [responseResult objectForKey:@"data"];
                    [self.dataSourceArr removeAllObjects];
                    for (NSDictionary *dic in data) {
                        SYPhotoStudioModel *model = [SYPhotoStudioModel photoStudioWithDictionary:dic];
                        [self.dataSourceArr addObject:model];
                    }
                    
                    [self.tableView reloadData];
                }
                
                NSUserDefaults *us = [NSUserDefaults standardUserDefaults];
                [us setObject:[responseResult objectForKey:@"prov"] forKey:@"selectequyuprov"];
                [us setObject:[responseResult objectForKey:@"city"] forKey:@"selectequyucity"];
                [us synchronize];
                if ([responseResult objectForKey:@"city"]) {
                    NSArray *city = [responseResult objectForKey:@"city"];
                    if (city.count > 0) {
                        [self.leftMuArr removeAllObjects];
                        [self.leftMuArr addObject:@"全部"];
                        [self.leftMuArr addObject:[responseResult objectForKey:@"prov"]];
                        [self.leftMuArr addObjectsFromArray:[responseResult objectForKey:@"city"]];
                    }
                }
                [self.menu removeFromSuperview];
                self.menu = nil;
                [self.view addSubview:self.menu];
                
            }else{
                if ([responseResult objectForKey:@"msg"]) {
                    [self showHint:[responseResult objectForKey:@"msg"]];
                }
            }
        }
    }];
}

- (void)getMoreDataWithText:(NSString *)text WithKey:(NSString *)key{
    _count ++;
    NSUserDefaults *us = [NSUserDefaults standardUserDefaults];
    NSNumber *jingdu = [us objectForKey:@"jingdu"];
    NSNumber *weidu = [us objectForKey:@"weidu"];
    
    NSString *url = [NSString stringWithFormat:@"%@%@",BaseUrl,@"/store/index.html"];
    NSString *order = @"";
    if (_currentData2Index >= 0) {
        if (_currentData2Index == 0) {
            order = @"juli";
        }else{
            order = @"ping";
        }
    }
    NSDictionary *param = @{@"lat":weidu, @"long":jingdu, @"gps":@"gcj02ll",@"key":key, @"city":text ,@"order":order, @"page":[NSNumber numberWithInteger:_count]};
    [[SYHttpRequest sharedInstance] getDataWithUrl:url Parameter:param ResponseObject:^(NSDictionary *responseResult) {
        if ([self.tableView.mj_footer isRefreshing]) {
            [self.tableView.mj_footer endRefreshing];
        }
        NSLog(@"获取相馆列表 -- %@",responseResult);
        if ([responseResult objectForKey:@"resError"]) {
            
        }else{
            if ([[responseResult objectForKey:@"result"] integerValue] == 1) {
                if ([responseResult objectForKey:@"data"]) {
                    NSArray *data = [responseResult objectForKey:@"data"];
                    if (data.count > 0) {
                        
                        for (NSDictionary *dic in data) {
                            SYPhotoStudioModel *model = [SYPhotoStudioModel photoStudioWithDictionary:dic];
                            [self.dataSourceArr addObject:model];
                        }
                    }
                    [self.tableView reloadData];
                }
                
            }else{
                if ([responseResult objectForKey:@"msg"]) {
                    [self showHint:[responseResult objectForKey:@"msg"]];
                }
            }
        }
    }];
}

#pragma mark - UICollectionViewDelegate

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        UICollectionReusableView *reusableview = nil;
        if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
            SYPhotoStudioHeaderOneCollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:oneHeaderIdentifier forIndexPath:indexPath];
            
            headerView.contentLabel.text = @"热门搜索";
            reusableview = headerView;
        }
        return reusableview;
        
    }else{
        UICollectionReusableView *reusableview = nil;
        if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
            SYPhotoStudioHeaderOneCollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:oneHeaderIdentifier forIndexPath:indexPath];
            
            headerView.contentLabel.text = @"搜索历史";
            reusableview = headerView;
        }
        return reusableview;
    }
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    if (section == 0) {
        return 6;
    }
    return self.historySearchArr.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    SYPhotoStudioHistoryCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    if (indexPath.section == 0) {
        NSArray *arr = @[@"写真", @"冲印", @"毕业照", @"全家福", @"儿童摄影", @"证件照"];
        cell.contentLabel.text = arr[indexPath.item];
    }else{
        cell.contentLabel.text = self.historySearchArr[indexPath.item];
    }
    
    return cell;
}


- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    if (self.historySearchArr.count == 0) {
        return 1;
    }
    return 2;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"select");
    [self historyViewDismiss];
    NSArray *arr = @[@"写真", @"冲印", @"毕业照", @"全家福", @"儿童摄影", @"证件照"];
    NSString *city = @"";
    if (_currentData1Index != 0) {
       city = self.leftMuArr[_currentData1Index];
    }

    if (indexPath.section == 0) {
        [self getDataWithText:city WithKey:arr[indexPath.item]];
        self.titleView.text = arr[indexPath.item];
    }else{
        [self getDataWithText:city WithKey:self.historySearchArr[indexPath.item]];
        self.titleView.text = self.historySearchArr[indexPath.item];
    }
    
}

#pragma mark - PrivatyMethod
- (void)historyViewShow{
    if (self.historyBackView) {
        [self.historyBackView removeFromSuperview];
        self.historyBackView = nil;
    }
    [self reloadCollectionViewFrame];
    self.historyBackView = [[UIView alloc] initWithFrame:CGRectMake(0, 64, kScreenWidth, kScreenHeight)];
    self.historyBackView.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:.6f];
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, self.historyCollectionView.frame.size.height)];
    if (self.historySearchArr.count > 0) {
        view.frame = CGRectMake(0, 0, kScreenWidth, self.historyCollectionView.frame.size.height + 45);
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(0, self.historyCollectionView.frame.size.height, kScreenWidth, 45);
        [btn setAdjustsImageWhenHighlighted:NO];
        [btn setTitle:@"清除历史记录" forState:UIControlStateNormal];
        [btn setTitleColor:NavigationColor forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont systemFontOfSize:17];
        [btn addTarget:self action:@selector(clearHistoryRecord:) forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:btn];

    }
    view.backgroundColor = [UIColor whiteColor];
    [view addSubview:self.historyCollectionView];
    [self.historyCollectionView reloadData];
    [self.historyBackView addSubview:view];
    
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    [window addSubview:self.historyBackView];
    [self.historyBackView setUserInteractionEnabled:YES];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(historyViewDismiss)];
    tap.delegate = self;
    
    [self.historyBackView addGestureRecognizer:tap];
    
}
//清除历史记录
- (void)clearHistoryRecord:(UIButton *)sender{
    [self.historySearchArr removeAllObjects];
    NSUserDefaults *us = [NSUserDefaults standardUserDefaults];
    if ([us objectForKey:@"photoStudioSearchHistory"]) {
        [us removeObjectForKey:@"photoStudioSearchHistory"];
        [us synchronize];
    }
    [self historyViewShow];

}

- (void)historyViewDismiss{
    [self.historyBackView removeFromSuperview];
    [self.titleView resignFirstResponder];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    if ([touch.view isDescendantOfView:self.historyCollectionView]) {
        return NO;
    }
    return YES;
}

- (void)reloadCollectionViewFrame{
    
    if (kScreenWidth > 321) {
        if (self.historySearchArr.count == 0) {
            _historyCollectionView.frame = CGRectMake(0, 0, kScreenWidth, 135);
        }else if (self.historySearchArr.count <= 3 && self.historySearchArr.count > 0){
            _historyCollectionView.frame = CGRectMake(0, 0, kScreenWidth, 225);
        }else{
            _historyCollectionView.frame = CGRectMake(0, 0, kScreenWidth, 270);
        }
    }else{
        if (self.historySearchArr.count == 0) {
            _historyCollectionView.frame = CGRectMake(0, 0, kScreenWidth, 135);
        }else{
            _historyCollectionView.frame = CGRectMake(0, 0, kScreenWidth, 220);
        }
    }
    
}

#pragma mark - LayzLoad
- (QTSearchBar *)titleView{
    if (!_titleView) {
        
        _titleView = [QTSearchBar searchBarWith:CGRectMake(15, 5, kScreenWidth - 80, 30)];
        _titleView.placeholder = @"相馆、摄影";
        _titleView.returnKeyType = UIReturnKeySearch;
        _titleView.clearButtonMode = UITextFieldViewModeWhileEditing;
        _titleView.searchDelegate = self;
    
    }
    return _titleView;
}

- (NSMutableArray *)leftMuArr{
    if (!_leftMuArr) {
        _leftMuArr = [NSMutableArray arrayWithCapacity:0];
        [_leftMuArr addObject:@"全部"];
        [_leftMuArr addObject:@"全城"];
    }
    return _leftMuArr;
}

- (NSMutableArray *)rightMuArr{
    if (!_rightMuArr) {
        _rightMuArr = [NSMutableArray arrayWithCapacity:0];
        [_rightMuArr addObject:@"离我最近"];
        [_rightMuArr addObject:@"好评榜"];
    }
    return _rightMuArr;
}

- (NSMutableArray *)dataSourceArr{
    if (!_dataSourceArr) {
        _dataSourceArr = [NSMutableArray arrayWithCapacity:0];
    }
    return _dataSourceArr;
}

- (NSMutableArray *)historySearchArr{
    if (!_historySearchArr) {
        _historySearchArr = [NSMutableArray arrayWithCapacity:0];
    }
    return _historySearchArr;
}

- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 47, kScreenWidth, kScreenHeight - 64 - 49 - 47) style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = HexRGB(0xf3f3f3);
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
            [self getDataWithText:@"" WithKey:@""];
        }];
        
        
        
        _tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
            if (_currentData1Index >= 0) {
                if (_currentData1Index == 0) {
                    [self getMoreDataWithText:@"" WithKey:self.titleView.text];
                }else if (_currentData1Index == 1){
                    NSUserDefaults *us = [NSUserDefaults standardUserDefaults];
                    if ([us objectForKey:@"selectequyuprov"]) {
                        NSString *city = [us objectForKey:@"selectequyuprov"];
                        
                        [self getMoreDataWithText:city WithKey:self.titleView.text];
                    }
                    
                }else{
                    NSString *city = self.leftMuArr[_currentData1Index];
                    [self getMoreDataWithText:city WithKey:self.titleView.text];
                }
            }
        }];
    }
    return _tableView;
}

- (JSDropDownMenu *)menu{
    if (!_menu) {
        _menu = [[JSDropDownMenu alloc] initWithOrigin:CGPointMake(0, 0) andHeight:47];
        _menu.indicatorColor = [UIColor colorWithRed:175.0f/255.0f green:175.0f/255.0f blue:175.0f/255.0f alpha:1.0];
        _menu.separatorColor = [UIColor colorWithRed:241.0f/255.0f green:241.0f/255.0f blue:241.0f/255.0f alpha:1.0];
        _menu.textColor = [UIColor colorWithRed:83.f/255.0f green:83.f/255.0f blue:83.f/255.0f alpha:1.0f];
        _menu.dataSourceArr = @[self.leftMuArr, self.rightMuArr];
        _menu.dataSource = self;
        _menu.delegate = self;
    }
    return _menu;
}

- (UICollectionView *)historyCollectionView{
    if (!_historyCollectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        layout.itemSize = CGSizeMake((kScreenWidth - 2) / 3, 45);
        layout.headerReferenceSize = CGSizeMake(kScreenWidth, 45);
        layout.sectionInset = UIEdgeInsetsMake(1, 0, 1, 0);
        layout.minimumLineSpacing = 1;
        layout.minimumInteritemSpacing = 1;
        
        _historyCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 200) collectionViewLayout:layout];
        if (kScreenWidth > 321) {
            if (self.historySearchArr.count == 0) {
                _historyCollectionView.frame = CGRectMake(0, 0, kScreenWidth, 135);
            }else if (self.historySearchArr.count <= 3 && self.historySearchArr.count > 0){
                _historyCollectionView.frame = CGRectMake(0, 0, kScreenWidth, 225);
            }else{
            _historyCollectionView.frame = CGRectMake(0, 0, kScreenWidth, 270);
            }
        }else{
            if (self.historySearchArr.count == 0) {
                _historyCollectionView.frame = CGRectMake(0, 0, kScreenWidth, 135);
            }else{
                _historyCollectionView.frame = CGRectMake(0, 0, kScreenWidth, 220);
            }
        }
        
        
        _historyCollectionView.backgroundColor = RGB(243, 243, 243);
        _historyCollectionView.bounces = NO;
        _historyCollectionView.delegate = self;
        _historyCollectionView.dataSource = self;
        [_historyCollectionView registerNib:[UINib nibWithNibName:@"SYPhotoStudioHistoryCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:identifier];

        [_historyCollectionView registerNib:[UINib nibWithNibName:@"SYPhotoStudioHeaderOneCollectionReusableView" bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:oneHeaderIdentifier];

        
    }
    return _historyCollectionView;
}


@end
