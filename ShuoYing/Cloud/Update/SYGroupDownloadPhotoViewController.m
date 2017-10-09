//
//  SYGroupDownloadPhotoViewController.m
//  ShuoYing
//
//  Created by 硕影 on 2017/3/6.
//  Copyright © 2017年 硕影. All rights reserved.
//

#import "SYGroupDownloadPhotoViewController.h"
#import "SYGroupPhotoCollectionViewCell.h"
#import "SYPaymentInfosViewController.h"
#import "CircleProgressView.h"
#import "LXNetworking.h"
#import "ZLPhotoTool.h"
@interface SYGroupDownloadPhotoViewController ()<UICollectionViewDelegate,UICollectionViewDataSource, XLPhotoBrowserDelegate, XLPhotoBrowserDatasource>
{
    NSInteger _count;
    XLPhotoBrowser *_browers;
}

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, strong) NSMutableArray *dataSourceArr;

@property (nonatomic, strong) UICollectionViewFlowLayout *flowLayout;

@property (nonatomic, strong) CircleProgressView *progressView;

@end

static NSString *identifier = @"cell";

@implementation SYGroupDownloadPhotoViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self getData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"协会相册";
    _count = 1;
    [self getData];
    [self loadCollectionView];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.dataSourceArr.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    SYGroupPhotoCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    
    [cell.imageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",ImgUrl, [self.dataSourceArr[indexPath.item] objectForKey:@"img_200"]]] placeholderImage:[UIImage imageNamed:@"shangchuan_wode_wutupian"]];
    
    cell.oneLabel.text = [self.dataSourceArr[indexPath.item] objectForKey:@"nick"];
    cell.twoLabel.text = [NSString stringWithFormat:@"%@",[self.dataSourceArr[indexPath.item] objectForKey:@"user"]];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    XLPhotoBrowser *browser = [XLPhotoBrowser showPhotoBrowserWithCurrentImageIndex:indexPath.item imageCount:self.dataSourceArr.count datasource:self];
    _browers = browser;
    browser.browserStyle = XLPhotoBrowserStyleDownload;
    __weak typeof(self)weakself = self;
    __weak typeof(browser)weakBrowser = browser;
    browser.downloadBlock = ^(NSInteger currentIndex){
        if (![weakself.dataSourceArr[indexPath.item] objectForKey:@"img"] || [weakself.dataSourceArr[indexPath.item] objectForKey:@"img"] == nil || [[weakself.dataSourceArr[indexPath.item] objectForKey:@"img"] isKindOfClass:[NSNull class]] || [[weakself.dataSourceArr[indexPath.item] objectForKey:@"img"] isEqualToString:@""]) {
            [weakBrowser dismiss];
            SYPaymentInfosViewController *infos = [[SYPaymentInfosViewController alloc] initWithType:isFromGroup];
            infos.dataSourceDic = weakself.dataSourceArr[indexPath.item];
            [weakself.navigationController pushViewController:infos animated:YES];
        }else{
            NSLog(@"下载图片到本地");
            [weakself downloadImageWithUrl:[weakself.dataSourceArr[indexPath.item] objectForKey:@"img"]];
        }
    };
}

- (void)downloadImageWithUrl:(NSString *)url{
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    
    UIView __block *view1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
    view1.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.6];
    [window addSubview:view1];
    [view1 addSubview:self.progressView];
    
    
    [LXNetworking downloadWithUrl:[NSString stringWithFormat:@"%@%@",ImgUrl, url] saveToPath:nil progress:^(int64_t bytesProgress, int64_t totalBytesProgress) {
        //封装方法里已经回到主线程，所有这里不用再调主线程了
        _progressView.centerLabel.text = [NSString stringWithFormat:@"%.2f%@",1.0 * bytesProgress/totalBytesProgress,@"%"];
        [_progressView setPercent:1.0 * bytesProgress/totalBytesProgress];
        
    } success:^(id response) {
        NSLog(@"---------%@",response);
        [view1 removeFromSuperview];
        _progressView = nil;
        
        [self saveImageToPhoto:[NSURL URLWithString:(NSString *)response]];
        
        
    } failure:^(NSError *error) {
        
    } showHUD:NO];

}

//保存到相册
- (void)saveImageToPhoto:(NSURL *)url{
    // 将相片添加到相册
    [[ZLPhotoTool sharePhotoTool] saveImageToAblumWithUrl:url completion:^(BOOL suc, PHAsset *asset) {
        if (suc) {
            dispatch_async(dispatch_get_main_queue(), ^{
                MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:_browers animated:YES];
                hud.userInteractionEnabled = NO;
                hud.bezelView.color = [UIColor blackColor];
                hud.contentColor = [UIColor whiteColor];
                // Configure for text only and offset down
                hud.mode = MBProgressHUDModeText;
                //    hud.labelText = hint;
                hud.detailsLabel.text = @"成功保存到相册！";
                hud.margin = 10.f;
                CGPoint oldOffset = hud.offset;
                hud.offset = CGPointMake(oldOffset.x, 180);
                hud.removeFromSuperViewOnHide = YES;
                [hud hideAnimated:YES afterDelay:2];
                
            });
            NSLog(@"保存成功！");
        }else{
            NSLog(@"保存失败");
        }
    }];
}

- (NSURL *)photoBrowser:(XLPhotoBrowser *)browser highQualityImageURLForIndex:(NSInteger)index{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",ImgUrl, [self.dataSourceArr[index] objectForKey:@"img_min"]]];
    return url;
}

- (void)loadCollectionView{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumLineSpacing = 10;
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    layout.itemSize = CGSizeMake((kScreenWidth - 50) / 3, (kScreenWidth - 50) / 3 + 50);
    layout.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
    self.flowLayout = layout;
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight - 64) collectionViewLayout:layout];
    self.collectionView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [self getData];
    }];
    self.collectionView.mj_footer = [MJRefreshAutoStateFooter footerWithRefreshingBlock:^{
        [self getMoreData];
    }];
    self.collectionView.backgroundColor = BackGroundColor;
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    [self.collectionView registerNib:[UINib nibWithNibName:@"SYGroupPhotoCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:identifier];
    [self.view addSubview:self.collectionView];
}


- (void)getData{
    NSString *url = [NSString stringWithFormat:@"%@%@",BaseUrl,@"/group/photoinfo.html"];
    NSDictionary *param = @{@"token":UserToken, @"id":self.groupID, @"page":@1, @"data":[self.dataSourceDic objectForKey:@"time"]};
    
    [[SYHttpRequest sharedInstance] getDataWithUrl:url Parameter:param ResponseObject:^(NSDictionary *responseResult) {
        _count = 1;
        if ([self.collectionView.mj_header isRefreshing]) {
            [self.collectionView.mj_header endRefreshing];
        }
        NSLog(@"群相册详情 -- %@",responseResult);
        if ([responseResult objectForKey:@"resError"]) {
            [self showHint:@"服务器不给力，请稍后重试"];
        }else{
            if ([[responseResult objectForKey:@"result"] integerValue] == 1) {
                if ([responseResult objectForKey:@"data"]) {
                    NSArray *data = [responseResult objectForKey:@"data"];
                    if (data.count >= 10) {
                        [self.collectionView.mj_footer resetNoMoreData];
                    }
                    if (data.count < 10) {
                        [self.collectionView.mj_footer endRefreshingWithNoMoreData];
                    }
                    if (data.count > 0) {
                        [self.dataSourceArr removeAllObjects];
                        [self.dataSourceArr addObjectsFromArray:data];
                    }
                }
                [self.collectionView reloadData];
            }else{
                if ([responseResult objectForKey:@"msg"]) {
                    [self showHint:[responseResult objectForKey:@"msg"]];
                }
            }
        }
    }];
}

- (void)getMoreData{
    _count ++;
    NSString *url = [NSString stringWithFormat:@"%@%@",BaseUrl,@"/group/photoinfo.html"];
    NSDictionary *param = @{@"token":UserToken, @"id":self.groupID, @"page":[NSNumber numberWithInteger:_count], @"data":[self.dataSourceDic objectForKey:@"time"]};
    
    [[SYHttpRequest sharedInstance] getDataWithUrl:url Parameter:param ResponseObject:^(NSDictionary *responseResult) {
        
        if ([self.collectionView.mj_footer isRefreshing]) {
            [self.collectionView.mj_footer endRefreshing];
        }
        NSLog(@"群相册信息更多 -- %@",responseResult);
        if ([responseResult objectForKey:@"resError"]) {
            [self showHint:@"服务器不给力，请稍后重试"];
        }else{
            if ([[responseResult objectForKey:@"result"] integerValue] == 1) {
                if ([responseResult objectForKey:@"data"]) {
                    NSArray *data = [responseResult objectForKey:@"data"];
                    if (data.count < 10) {
                        [self.collectionView.mj_footer endRefreshingWithNoMoreData];
                    }
                    if (data.count > 0) {
                        [self.dataSourceArr addObjectsFromArray:data];
                    }
                }
                [self.collectionView reloadData];
            }else{
                if ([responseResult objectForKey:@"msg"]) {
                    [self showHint:[responseResult objectForKey:@"msg"]];
                }
            }
        }
    }];
}

- (NSMutableArray *)dataSourceArr{
    if (!_dataSourceArr) {
        _dataSourceArr = [NSMutableArray arrayWithCapacity:0];
    }
    return _dataSourceArr;
}

//在当前window添加进度条
- (CircleProgressView *)progressView{
    if (!_progressView) {
        _progressView = [[CircleProgressView alloc] initWithFrame:CGRectMake(0, 0, 80, 80)];
        _progressView.center = CGPointMake(kScreenWidth / 2, kScreenHeight / 2);
        
    }
    return _progressView;
}

@end
