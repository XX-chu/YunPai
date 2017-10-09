//
//  SYUserInfosViewController.m
//  ShuoYing
//
//  Created by 硕影 on 2017/1/4.
//  Copyright © 2017年 硕影. All rights reserved.
//

#import "SYUserInfosViewController.h"
#import "SYUserInfos.h"

#import <MobileCoreServices/MobileCoreServices.h>
#import "SYEditNickViewController.h"
#import "SYPersonalNotViewController.h"
#import "SYChangePhoneViewController.h"
#import "SYChangePasswordViewController.h"

@interface SYUserInfosViewController ()<UITableViewDelegate,UITableViewDataSource,UIImagePickerControllerDelegate,UINavigationControllerDelegate,XLPhotoBrowserDelegate,XLPhotoBrowserDatasource>
{
    NSArray *_labelArr;
    SYUserInfos *_userInfos;
    UIImage *_image;
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation SYUserInfosViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

    if ([[Tool sharedInstance] getObjectWithPath:Mobile]) {
        _userInfos = [[Tool sharedInstance] getObjectWithPath:Mobile];
        [self.tableView reloadData];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"个人设置";
    self.tableView.backgroundColor = BackGroundColor;
    _labelArr = @[@"性别",@"昵称",@"个人说明",@"更改手机",@"修改密码"];
    
//    [self.tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
}

#pragma mark - PrivateMethod
- (void)updateHeadPhotoAction:(UITapGestureRecognizer *)tap{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"查看大图" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        // 快速创建并进入浏览模式
        XLPhotoBrowser *browser = [XLPhotoBrowser showPhotoBrowserWithCurrentImageIndex:0 imageCount:1 datasource:self];
        browser.browserStyle = XLPhotoBrowserStylePageControl;
    }];
    UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"选择照片" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        ZLPhotoActionSheet *actionSheet = [[ZLPhotoActionSheet alloc] init];
        //设置照片最大选择数
        actionSheet.maxSelectCount = 1;
        //设置照片最大预览数
        actionSheet.maxPreviewCount = 8;
        //导航栏是否透明
        actionSheet.isTouMing = NO;
        weakify(self);
        [actionSheet showPreviewPhotoWithSender:self animate:YES lastSelectPhotoModels:nil completion:^(NSArray<UIImage *> * _Nonnull selectPhotos, NSArray<ZLSelectPhotoModel *> * _Nonnull selectPhotoModels, NSArray<NSData *> *imageDatas) {
            strongify(weakSelf);
            
            //        [strongSelf updateImagesToServerWithImages:selectPhotos withImageDatas:imageDatas];
            [strongSelf updateImagesWithFilesWithImages:selectPhotos WithImageDatas:imageDatas];
            
        }];
    }];
    UIAlertAction *action3 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alert addAction:action1];
    [alert addAction:action2];
    [alert addAction:action3];
    [self presentViewController:alert animated:YES completion:nil];
    
}

- (NSURL *)photoBrowser:(XLPhotoBrowser *)browser highQualityImageURLForIndex:(NSInteger)index{
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",ImgUrl,_userInfos.head]];
}

//文件上传
- (void)updateImagesWithFilesWithImages:(NSArray *)images WithImageDatas:(NSArray *)imageDatas{
    NSMutableArray *muDatas = [NSMutableArray arrayWithCapacity:0];
    [muDatas addObjectsFromArray:imageDatas];
    //一个一个上传 每次取第一个图片上传 成功后删除第一章图片
    NSData *data = muDatas[0];
    //判断图片类型
    NSString *mimaType = [[Tool sharedInstance] typeForImageData:data];
    NSInteger currentNum = images.count - muDatas.count + 1;
    
    NSString *url = [NSString stringWithFormat:@"%@%@",BaseUrl,@"/user/up_headX.html"];
    NSDictionary *param = @{@"token":UserToken};
    
    
    [[XBUpdatePhotoManager sharedInstance] updatePhotosWithFile:url param:param fileData:data name:@"img" fileName:[NSString stringWithFormat:@"img%lu.%@",currentNum, [mimaType substringWithRange:NSMakeRange(6, mimaType.length - 6)]] mimeType:mimaType currentNumber:currentNum allNumber:images.count result:^(NSDictionary *dic) {
        NSLog(@"dic - %@",dic);
        if (![dic objectForKey:@"resError"]) {
            if ([dic objectForKey:@"result"] && [[dic objectForKey:@"result"] integerValue] == 0) {
                _image = nil;
                [self showHint:[dic objectForKey:@"msg"]];
                return ;
            }
            //成功
            if (muDatas.count > 1) {
                [muDatas removeObjectAtIndex:0];
                [self updateImagesWithFilesWithImages:images WithImageDatas:muDatas];
            }else{
                if ([dic objectForKey:@"resError"]) {
                    [self showHint:@"服务器不给力，请稍后重试"];
                    _image = nil;
                    [self.tableView reloadData];
                }else{
                    if ([[dic objectForKey:@"result"] integerValue] == 1) {
                        //修改存储在本地的信息
                        _image = images[0];
                        _userInfos.head = [[dic objectForKey:@"data"] objectForKey:@"img_200"];
                        [[Tool sharedInstance] saveObject:_userInfos WithPath:Mobile];
                        [self.tableView reloadData];
                        [self showHint:@"上传头像成功"];
                    }else{
                        [self.tableView reloadData];
                        if ([dic objectForKey:@"msg"]) {
                            [self showHint:[dic objectForKey:@"msg"]];
                        }
                    }
                }
                
            }
            
        }else{
            
            [self showHint:@"请检查您的网络！"];
        }
    }];
}


#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell ) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.font = [UIFont systemFontOfSize:15];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:15];
        cell.backgroundColor = BackGroundColor;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    cell.textLabel.text = _labelArr[indexPath.row];
    if (indexPath.row == 0) {
        if ([_userInfos.sex isEqualToString:@"未知"]) {
            cell.detailTextLabel.text = @"";
        }else{
            cell.detailTextLabel.text = _userInfos.sex;
        }
    }else if (indexPath.row == 1){
        cell.detailTextLabel.text = _userInfos.nick;
    }else if (indexPath.row == 2){
        if (_userInfos.info.length == 0) {
            cell.detailTextLabel.text = @"未设置";
        }else{
            cell.detailTextLabel.text = _userInfos.info;
        }
    }
    else{
        cell.detailTextLabel.text = @"";
    }

    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 150;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = BackGroundColor;
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 120, 120)];
    imageView.layer.cornerRadius = 60;
    imageView.layer.masksToBounds = YES;
    imageView.center = CGPointMake(kScreenWidth / 2, 150 / 2);
    if (_image) {
        imageView.image = _image;
    }else{
    [imageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",ImgUrl,_userInfos.head]] placeholderImage:[UIImage imageNamed:@"shezhi_photo_photo"]];
    }
    
    [view addSubview:imageView];
    view.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(updateHeadPhotoAction:)];
    [view addGestureRecognizer:tap];
    return view;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"男" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self editSexWithsex:@"男"];
        }];
        UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"女" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self editSexWithsex:@"女"];
        }];
        UIAlertAction *action3 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        [alertVC addAction:action1];
        [alertVC addAction:action2];
        [alertVC addAction:action3];
        
        [self presentViewController:alertVC animated:YES completion:nil];

    }else if (indexPath.row == 1){
        SYEditNickViewController *nickVC = [[SYEditNickViewController alloc] initWithNibName:@"SYEditNickViewController" bundle:nil];
        nickVC.userInfos = _userInfos;
        [self.navigationController pushViewController:nickVC animated:YES];
    }else if (indexPath.row == 2){
        SYPersonalNotViewController *personVC = [[SYPersonalNotViewController alloc] initWithNibName:@"SYPersonalNotViewController" bundle:nil];
        personVC.userInfos = _userInfos;
        [self.navigationController pushViewController:personVC animated:YES];
    }else if (indexPath.row == 3){
        SYChangePhoneViewController *changePhone = [[SYChangePhoneViewController alloc] initWithNibName:@"SYChangePhoneViewController" bundle:nil];
        [self.navigationController pushViewController:changePhone animated:YES];
        
    }else {
        SYChangePasswordViewController *changePW = [[SYChangePasswordViewController alloc] initWithNibName:@"SYChangePasswordViewController" bundle:nil];
        [self.navigationController pushViewController:changePW animated:YES];
    }
}

- (void)editSexWithsex:(NSString *)sex{
    NSString *url = [NSString stringWithFormat:@"%@%@",BaseUrl,@"/user/setsex.html"];
    NSDictionary *param = @{@"token":UserToken, @"sex":sex};
    [[SYHttpRequest sharedInstance] getDataWithUrl:url Parameter:param ResponseObject:^(NSDictionary *responseResult) {
        
        NSLog(@"修改性别 -- %@",responseResult);
        if ([responseResult objectForKey:@"resError"]) {
            [self showHint:@"服务器不给力，请稍后重试"];
        }else{
            if ([[responseResult objectForKey:@"result"] integerValue] == 1) {
                //修改存储在本地的信息
                _userInfos.sex = sex;
                [[Tool sharedInstance] saveObject:_userInfos WithPath:Mobile];
                [self.tableView reloadData];
            }else{
                if ([responseResult objectForKey:@"msg"]) {
                    [self showHint:[responseResult objectForKey:@"msg"]];
                }
            }
        }
    }];
}

@end
