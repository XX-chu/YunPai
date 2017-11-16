//
//  SYYunPaiShopEditViewController.m
//  ShuoYing
//
//  Created by chu on 2017/11/13.
//  Copyright © 2017年 硕影. All rights reserved.
//

#import "SYYunPaiShopEditViewController.h"

#import "SYEditAvatorTableViewCell.h"
#import "SYYuePaiPriceTableViewCell.h"
#import "SYYunPaiDeviceTableViewCell.h"
#import "SYCustomTableViewCell.h"
#import "SYTitleAndImageTableViewCell.h"
#import "ZLPhotoActionSheet.h"
#import "SYMapViewController.h"
#import "SYYunPaiEditZiShuViewController.h"
#import "SYYunPaiSheBeiEditViewController.h"

#import "SYUpdateYunPaiShiViewController.h"
@interface SYYunPaiShopEditViewController ()<UITableViewDataSource, UITableViewDelegate>
{
    NSString *_address;
    NSNumber *_lat;
    NSNumber *_log;
    NSString *_info;
    NSString *_price;
    NSString *_xinghao;
    NSString *_xuliehao;
    UIImage *_image;
    NSDictionary *_dataSourceDic;
    
    NSInteger _count;
}
@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *dataSourceArr;
@end

@implementation SYYunPaiShopEditViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _xinghao = @"";
    _xuliehao = @"";
    _count = 1;
    self.title = @"云拍店铺编辑";
    [self.view addSubview:self.tableView];
    [self getSet];
    [self.tableView.mj_header beginRefreshing];
//    [self getData];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    __weak typeof(self)weaself= self;

    if (indexPath.section == 0) {
        ZLPhotoActionSheet *actionsheet = [[ZLPhotoActionSheet alloc] init];
        actionsheet.maxSelectCount = 1;
        actionsheet.maxPreviewCount = 8;
        [actionsheet showPreviewPhotoWithSender:self animate:YES lastSelectPhotoModels:nil completion:^(NSArray<UIImage *> * _Nonnull selectPhotos, NSArray<ZLSelectPhotoModel *> * _Nonnull selectPhotoModels, NSArray<NSData *> * _Nonnull imageDatas) {
            _image = [selectPhotos firstObject];
            [weaself.tableView reloadData];
            [weaself updateAva];
        }];
    }
    if (indexPath.section == 1) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"修改价格" message:@"" preferredStyle:UIAlertControllerStyleAlert];
        [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            [[NSNotificationCenter defaultCenter] addObserver:weaself selector:@selector(alertTextFieldDidChange:) name:UITextFieldTextDidChangeNotification object:textField];
            textField.placeholder = @"请输入新的预约价格";
        }];
        
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
            [weaself editYunPaiShiWithParam:@{@"token":UserToken, @"money":_price}];

            [weaself.tableView reloadData];
        }];
        UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];

        }];
        [alert addAction:action];
        [alert addAction:action1];

        [self presentViewController:alert animated:YES completion:nil];
    }
}

#pragma mark - 上传头像
- (void)updateAva{
    [SVProgressHUD show];
    NSData *data = UIImageJPEGRepresentation(_image, 1);
    NSLog(@"上传图片长度 - %lu",(unsigned long)data.length);
    //判断图片类型
    NSString *mimaType = [[Tool sharedInstance] typeForImageData:data];
    
    NSString *str = [[NSString stringWithFormat:@"%@%@",BaseUrl, @"/master/set.html"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *param = @{@"token":UserToken};
    AFHTTPSessionManager *sessionManager = [AFHTTPSessionManager manager];
    sessionManager.responseSerializer = [AFHTTPResponseSerializer serializer];
    sessionManager.requestSerializer.timeoutInterval = 30.f;
    sessionManager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/json",@"text/html",@"text/javascript",@"application/octet-stream", nil];
    __weak typeof(self)waekself = self;
    [sessionManager POST:str parameters:param constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
        [formData appendPartWithFileData:data name:@"img" fileName:[NSString stringWithFormat:@"img1.%@", [mimaType substringWithRange:NSMakeRange(6, mimaType.length - 6)]] mimeType:mimaType];
        
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [SVProgressHUD dismiss];

        
        id resultData = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil];
        
        if ([resultData isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dic = (NSDictionary *)resultData;
            if ([[dic objectForKey:@"result"] integerValue] == 1) {
                [waekself showHint:[dic objectForKey:@"msg"]];
            }
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [SVProgressHUD dismiss];
        
    }];

}

- (void)alertTextFieldDidChange:(NSNotification *)notification{
    UIAlertController *alertController = (UIAlertController *)self.presentedViewController;
    if (alertController) {
        UITextField *login = alertController.textFields.firstObject;
        _price = login.text;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 6;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0 || section == 1) {
        return 1;
    }else if (section == 2){
        return 2;
    }else if (section == 3){
        if (_address.length > 0) {
            return 1;
        }
        return 0;
    }else if (section == 4){
        if (_info.length > 0) {
            return 1;
        }
        return 0;
    }
    return self.dataSourceArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        static NSString *identifier = @"avatorCell";
        SYEditAvatorTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (!cell) {
            cell = [[NSBundle mainBundle] loadNibNamed:@"SYEditAvatorTableViewCell" owner:self options:nil][0];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        if (_image) {
            cell.headImageView.image = _image;
        }else{
            [cell.headImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",ImgUrl, [_dataSourceDic objectForKey:@"head"]]] placeholderImage:[UIImage imageWithColor:HexRGB(0xeaeaea) Size:cell.headImageView.frame.size]];
        }
        return cell;
    }else if (indexPath.section == 1){
        static NSString *identifier = @"priceCell";
        SYYuePaiPriceTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (!cell) {
            cell = [[NSBundle mainBundle] loadNibNamed:@"SYYuePaiPriceTableViewCell" owner:self options:nil][0];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        cell.rightLabel.text = [NSString stringWithFormat:@"¥%.2f",[_price floatValue]];
        return cell;
    }else if (indexPath.section == 2){
        static NSString *identifier = @"deviceCell";
        SYYunPaiDeviceTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (!cell) {
            cell = [[NSBundle mainBundle] loadNibNamed:@"SYYunPaiDeviceTableViewCell" owner:self options:nil][0];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        if (indexPath.row == 0) {
            cell.titleLabel.text = [NSString stringWithFormat:@"相机型号  %@",_xinghao];
        }else{
            cell.titleLabel.text = [NSString stringWithFormat:@"相机序列号  %@",_xuliehao];

        }
        
        return cell;
    }else if (indexPath.section == 5){
        static NSString *identifier = @"titleAndImageCell";
        SYTitleAndImageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (!cell) {
            cell = [[NSBundle mainBundle] loadNibNamed:@"SYTitleAndImageTableViewCell" owner:self options:nil][0];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        __weak typeof(self)weakself = self;
        NSDictionary *dic = self.dataSourceArr[indexPath.row];
        cell.contentLabel.text = [dic objectForKey:@"info"];

        UIImage *image = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:[NSString stringWithFormat:@"%@%@",ImgUrl,[dic objectForKey:@"img_min"]]];
        if (image) {
            cell.delBtn.hidden = NO;
            cell.headImageView.image = image;
        }else{
            cell.delBtn.hidden = YES;
            [cell.headImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",ImgUrl,[dic objectForKey:@"img_min"]]] placeholderImage:[UIImage imageNamed:@"shangchuan_wode_wutupian"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                [self.tableView reloadData];
            }];
        }
        cell.block = ^{
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"确定要删除此作品吗？" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [weakself delWithIndexPath:indexPath];
            }];
            UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                
            }];
            [alert addAction:action];
            [alert addAction:action1];
            [weakself presentViewController:alert animated:YES completion:nil];
        };
        
        return cell;
    }else{
        static NSString *identifier = @"customCell";
        SYCustomTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (!cell) {
            cell = [[NSBundle mainBundle] loadNibNamed:@"SYCustomTableViewCell" owner:self options:nil][0];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        if (indexPath.section == 3) {
            cell.contentLabel.text = _address;
        }else{
            cell.contentLabel.text = _info;
        }

        return cell;
    }
    return nil;
}

- (void)delWithIndexPath:(NSIndexPath *)indexpath{
    
    [SVProgressHUD show];
    NSString *url = [NSString stringWithFormat:@"%@%@",BaseUrl,@"/master/del.html"];
    NSDictionary *dic = self.dataSourceArr[indexpath.row];
    NSDictionary *param = @{@"token":UserToken, @"id":[dic objectForKey:@"id"]};
    [[SYHttpRequest sharedInstance] getDataWithUrl:url Parameter:param ResponseObject:^(NSDictionary *responseResult) {
        NSLog(@"删除云拍师作品 -- %@",responseResult);
        [SVProgressHUD dismiss];
        if ([responseResult objectForKey:@"resError"]) {
            [self showHint:@"服务器不给力，请稍后重试"];
        }else{
            if ([[responseResult objectForKey:@"result"] integerValue] == 1) {
                [self.dataSourceArr removeObjectAtIndex:indexpath.row];
                
                [self.tableView reloadData];
                
            }else{
                if ([responseResult objectForKey:@"msg"] && ![[responseResult objectForKey:@"msg"] isKindOfClass:[NSNull class]]) {
                    [self showHint:[responseResult objectForKey:@"msg"]];
                }
            }
        }
    }];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        return 85;
    }else if (indexPath.section == 1 || indexPath.section == 2){
        return 50;
    }
    if (indexPath.section == 3) {
        
        CGFloat height = [[Tool sharedInstance] heightForString:_address andWidth:kScreenWidth - 26 fontSize:16];
        return height + 30;
    }
    if (indexPath.section == 4) {
        CGFloat height = [[Tool sharedInstance] heightForString:_info andWidth:kScreenWidth - 26 fontSize:16];
        return height + 30;
    }
    if (indexPath.section == 5) {
        NSDictionary *dic = self.dataSourceArr[indexPath.row];
        NSString *str = [dic objectForKey:@"info"];
        CGFloat strHeight = [[Tool sharedInstance] heightForString:str andWidth:kScreenWidth - 26 fontSize:16];
        UIImage *image = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:[NSString stringWithFormat:@"%@%@",ImgUrl,[dic objectForKey:@"img_min"]]];
        
        if (image) {
            return ((kScreenWidth - 26) * image.size.height) / image.size.width + 25 + strHeight + 15;
        }
    }
    
    return 200;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0 || section == 1) {
        return 0.00001f;
    }
    
    return 50;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = HexRGB(0xeaeaea);
    if (section == 2 || section == 3 || section == 4 || section == 5) {
        UIView *view1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 49)];
        view1.backgroundColor = [UIColor whiteColor];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(13, 14, (kScreenWidth - 26) / 2, 20)];
        label.font = [UIFont systemFontOfSize:16];
        label.textColor = HexRGB(0x444444);
        if (section == 2) {
            label.text = @"拍照设备";
        }else if (section == 3){
            label.text = @"工作地址";
        }else if (section == 4){
            label.text = @"摄影师自述";
        }else{
            label.text = @"作品展示";
        }
        [view1 addSubview:label];
        
        UIButton *edit = [UIButton buttonWithType:UIButtonTypeCustom];
        edit.frame = CGRectMake(kScreenWidth - 50 - 13, 0, 50, 49);
        [edit setTitle:@"修改" forState:UIControlStateNormal];
        [edit setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        edit.titleLabel.font = [UIFont systemFontOfSize:15];
        edit.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        edit.tag = section;
        [edit addTarget:self action:@selector(editAction:) forControlEvents:UIControlEventTouchUpInside];
        [view1 addSubview:edit];
        
        [view addSubview:view1];
        
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 49, kScreenWidth, 1)];
        lineView.backgroundColor = HexRGB(0xeaeaea);
        [view addSubview:lineView];
    }
    return view;
    
}

- (void)editAction:(UIButton *)sender{
    __weak typeof(self)weakself = self;
    if (sender.tag == 2) {
        //拍照设备
        SYYunPaiSheBeiEditViewController *shebei = [[SYYunPaiSheBeiEditViewController alloc] init];
        shebei.xinghaoTF.text = [_dataSourceDic objectForKey:@"ModelNo"];
        shebei.xueliehaoTF.text = [_dataSourceDic objectForKey:@"SerialNo"];
        shebei.block = ^(NSString *ModelNo, NSString *SerialNo) {
            _xinghao = ModelNo;
            _xuliehao = SerialNo;
            [weakself.tableView reloadData];
            [weakself editYunPaiShiWithParam:@{@"token":UserToken, @"ModelNo":ModelNo, @"SerialNo":SerialNo}];
        };
        
        [self.navigationController pushViewController:shebei animated:YES];
    }else if (sender.tag == 3){
        //工作地址
        SYMapViewController *map = [[SYMapViewController alloc] init];
        map.block = ^(NSString *address, NSNumber *lat, NSNumber *log) {
            if (_address.length > 0) {
                _address = address;
                _lat = lat;
                _log = log;
                [weakself.tableView reloadData];
                [weakself editYunPaiShiWithParam:@{@"token":UserToken, @"lat":lat, @"long":log}];

            }
        };
        [self.navigationController pushViewController:map animated:YES];
    }else if (sender.tag == 4){
        //摄影师自述
        SYYunPaiEditZiShuViewController *zishu = [[SYYunPaiEditZiShuViewController alloc] init];
        zishu.zishuBlock = ^(NSString *content) {
            _info = content;
            [weakself.tableView reloadData];
            [weakself editYunPaiShiWithParam:@{@"token":UserToken, @"info":content}];
        };
        [self.navigationController pushViewController:zishu animated:YES];
    }else{
        //作品展示
        SYUpdateYunPaiShiViewController *update = [[SYUpdateYunPaiShiViewController alloc] init];
        [self.navigationController pushViewController:update animated:YES];
    }
}

- (void)editYunPaiShiWithParam:(NSDictionary *)param{
    
    [SVProgressHUD show];
    NSString *url = [NSString stringWithFormat:@"%@%@",BaseUrl,@"/master/set.html"];
    [[SYHttpRequest sharedInstance] getDataWithUrl:url Parameter:param ResponseObject:^(NSDictionary *responseResult) {
        NSLog(@"获取云拍师设置 -- %@",responseResult);
        [SVProgressHUD dismiss];
        if ([responseResult objectForKey:@"resError"]) {
            [self showHint:@"服务器不给力，请稍后重试"];
        }else{
            if ([[responseResult objectForKey:@"result"] integerValue] == 1) {
                [self showHint:[responseResult objectForKey:@"msg"]];

            }else{
                if ([responseResult objectForKey:@"msg"] && ![[responseResult objectForKey:@"msg"] isKindOfClass:[NSNull class]]) {
                    [self showHint:[responseResult objectForKey:@"msg"]];
                }
            }
        }
    }];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 10;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = HexRGB(0xeaeaea);
    return view;
}

/**
 获取店铺设置
 */
- (void)getSet{

    [SVProgressHUD show];
    NSString *url = [NSString stringWithFormat:@"%@%@",BaseUrl,@"/master/sel.html"];
    NSDictionary *param = @{@"token":UserToken};
    [[SYHttpRequest sharedInstance] getDataWithUrl:url Parameter:param ResponseObject:^(NSDictionary *responseResult) {
        NSLog(@"获取云拍师设置 -- %@",responseResult);
        [SVProgressHUD dismiss];
        if ([responseResult objectForKey:@"resError"]) {
            [self showHint:@"服务器不给力，请稍后重试"];
        }else{
            if ([[responseResult objectForKey:@"result"] integerValue] == 1) {
                _dataSourceDic = [responseResult objectForKey:@"data"];
                _address = [[responseResult objectForKey:@"data"] objectForKey:@"address"];
                _info = [[responseResult objectForKey:@"data"] objectForKey:@"info"];
                _price = [[responseResult objectForKey:@"data"] objectForKey:@"money"];
                _xinghao = [[responseResult objectForKey:@"data"] objectForKey:@"ModelNo"];
                _xuliehao = [[responseResult objectForKey:@"data"] objectForKey:@"SerialNo"];

                [self.tableView reloadData];
                
            }else{
                if ([responseResult objectForKey:@"msg"] && ![[responseResult objectForKey:@"msg"] isKindOfClass:[NSNull class]]) {
                    [self showHint:[responseResult objectForKey:@"msg"]];
                }
            }
        }
    }];
}

/**
 获取数据
 */
- (void)getData{
    NSString *url = [NSString stringWithFormat:@"%@%@",BaseUrl,@"/master/works.html"];
    NSDictionary *param = @{@"token":UserToken, @"page":@1};
    [[SYHttpRequest sharedInstance] getDataWithUrl:url Parameter:param ResponseObject:^(NSDictionary *responseResult) {
        NSLog(@"云拍师所有作品 -- %@",responseResult);
        if ([self.tableView.mj_header isRefreshing]) {
            [self.tableView.mj_header endRefreshing];
        }
        if ([responseResult objectForKey:@"resError"]) {
            [self showHint:@"服务器不给力，请稍后重试"];
        }else{
            if ([[responseResult objectForKey:@"result"] integerValue] == 1) {
                _count = 1;
                NSArray *data = [responseResult objectForKey:@"data"];
                [self.dataSourceArr removeAllObjects];
                [self.dataSourceArr addObjectsFromArray:data];
                [self.tableView reloadData];
                
            }else{
                if ([responseResult objectForKey:@"msg"] && ![[responseResult objectForKey:@"msg"] isKindOfClass:[NSNull class]]) {
                    [self showHint:[responseResult objectForKey:@"msg"]];
                }
            }
        }
    }];
}

- (void)getMoreData{
    _count ++;
    NSString *url = [NSString stringWithFormat:@"%@%@",BaseUrl,@"/master/works.html"];
    NSDictionary *param = @{@"token":UserToken, @"page":[NSNumber numberWithInteger:_count]};
    [[SYHttpRequest sharedInstance] getDataWithUrl:url Parameter:param ResponseObject:^(NSDictionary *responseResult) {
        NSLog(@"云拍师所有作品 -- %@",responseResult);
        if ([self.tableView.mj_footer isRefreshing]) {
            [self.tableView.mj_footer endRefreshing];
        }
        if ([responseResult objectForKey:@"resError"]) {
            _count --;
            [self showHint:@"服务器不给力，请稍后重试"];
        }else{
            if ([[responseResult objectForKey:@"result"] integerValue] == 1) {
                NSArray *data = [responseResult objectForKey:@"data"];
                [self.dataSourceArr addObjectsFromArray:data];
                [self.tableView reloadData];
                
            }else{
                if ([responseResult objectForKey:@"msg"] && ![[responseResult objectForKey:@"msg"] isKindOfClass:[NSNull class]]) {
                    _count --;
                    [self showHint:[responseResult objectForKey:@"msg"]];
                }
            }
        }
    }];
}

- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight - kNavigationBarHeightAndStatusBarHeight) style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.backgroundColor = HexRGB(0xeaeaea);
        _tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
            [self getSet];
            [self getData];
        }];
        _tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
            [self getMoreData];
        }];
    }
    return _tableView;
}

- (NSMutableArray *)dataSourceArr{
    if (!_dataSourceArr) {
        _dataSourceArr = [NSMutableArray arrayWithCapacity:0];
    }
    return _dataSourceArr;
}
@end
