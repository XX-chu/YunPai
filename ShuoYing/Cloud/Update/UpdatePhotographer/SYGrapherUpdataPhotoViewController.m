//
//  SYGrapherUpdataPhotoViewController.m
//  ShuoYing
//
//  Created by 硕影 on 2017/1/9.
//  Copyright © 2017年 硕影. All rights reserved.
//

#import "SYGrapherUpdataPhotoViewController.h"
#import <ContactsUI/ContactsUI.h>
#import "SYTextField.h"
@interface SYGrapherUpdataPhotoViewController ()<UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, XLPhotoBrowserDatasource, XLPhotoBrowserDelegate,CNContactPickerDelegate,CNContactViewControllerDelegate>
{
    UIView *_upView;
    SYTextField *_accountTF;
    UITextField *_moneyTF;
    UIButton *_selectBtn;
    UILabel *_isRegisterLabel;
    UILabel *_indicatorLabel;
}

@property (nonatomic, strong) NSMutableArray *imagesArr;

@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, strong) NSMutableArray *historyRecordArr;

@property (nonatomic, strong) UITableView *historyTableView;

@property (nonatomic, strong) NSMutableArray *selectedImagesArr;

@property (nonatomic, strong) NSMutableArray *selectedPhotoModelsArr;
@end


@implementation SYGrapherUpdataPhotoViewController


- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"传送照片";
    self.view.backgroundColor = BackGroundColor;
    
    [self loadUpViews];
    [self loadData];
    [self setRightbarItem];
    [self.view addSubview:self.historyTableView];
    [self getPrice];
    
}



- (void)loadUpViews{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, -40, kScreenWidth, 40)];
    label.backgroundColor = RGB(254, 239, 178);
    label.textColor = RGB(67, 67, 67);
    label.numberOfLines = 0;
//    label.text = @"该手机号还没有注册龙果云拍账号，请您及时联系他哦！";
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize:12];
    
    _isRegisterLabel = label;
    [self.view addSubview:label];
    
    UIView *upView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(label.frame), kScreenWidth, 88)];
    _upView = upView;
    upView.backgroundColor = [UIColor whiteColor];
    
    UILabel *phoneLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 2, 65, 40)];
    phoneLabel.text = @"对方账号";
    phoneLabel.font = [UIFont systemFontOfSize:15];
    [upView addSubview:phoneLabel];
    
    if (self.isFromHistory) {
        SYTextField *account = [[SYTextField alloc] initWithFrame:CGRectMake(CGRectGetMaxX(phoneLabel.frame) + 5, 2, kScreenWidth - 30 - 70, 40)];
        _accountTF = account;
        _accountTF.keyboardType = UIKeyboardTypeNumberPad;
        _accountTF.borderStyle = UITextBorderStyleNone;
        _accountTF.placeholder = @"请输入对方账号";
        account.attributedPlaceholder = [[NSAttributedString alloc] initWithString:_accountTF.placeholder attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:15]}];
        [upView addSubview:account];
    }else{
        SYTextField *account = [[SYTextField alloc] initWithFrame:CGRectMake(CGRectGetMaxX(phoneLabel.frame) + 5, 2, kScreenWidth - 15 - 70 - 60, 40)];
        _accountTF = account;
        _accountTF.keyboardType = UIKeyboardTypeNumberPad;
        _accountTF.borderStyle = UITextBorderStyleNone;
        _accountTF.placeholder = @"请输入对方账号";
        account.attributedPlaceholder = [[NSAttributedString alloc] initWithString:_accountTF.placeholder attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:15]}];
        [upView addSubview:account];
        
        UIView *lineView1 = [[UIView alloc] initWithFrame:CGRectMake(kScreenWidth - 60, 5, 1, 34)];
        lineView1.backgroundColor = HexRGB(0xcccccc);
        [upView addSubview:lineView1];
        
        UIButton *tongxunlu = [UIButton buttonWithType:UIButtonTypeCustom];
        tongxunlu.frame = CGRectMake(CGRectGetMaxX(lineView1.frame), 5, 59, 34) ;
        [tongxunlu setImage:[UIImage imageNamed:@"address_book"] forState:UIControlStateNormal];
        [tongxunlu addTarget:self action:@selector(tongxunluAction:) forControlEvents:UIControlEventTouchUpInside];
        [upView addSubview:tongxunlu];
    }
    
    
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 44, kScreenWidth, 1)];
    lineView.backgroundColor = RGB(242, 242, 242);
    [upView addSubview:lineView];
    
    UILabel *moneyLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, CGRectGetMaxY(lineView.frame) + 2, 65, 40)];
    moneyLabel.text = @"单张金额";
    moneyLabel.font = [UIFont systemFontOfSize:15];
    [upView addSubview:moneyLabel];
    
    UITextField *money = [[UITextField alloc] initWithFrame:CGRectMake(CGRectGetMaxX(moneyLabel.frame) + 5, CGRectGetMaxY(lineView.frame) + 2, kScreenWidth - 30 - 70, 40)];
    money.borderStyle = UITextBorderStyleNone;
    
    _moneyTF = money;
    _moneyTF.placeholder = @"请输入单张图片金额（元）";
    money.attributedPlaceholder = [[NSAttributedString alloc] initWithString:money.placeholder attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:15]}];
    [upView addSubview:money];
    [self.view addSubview:upView];
    
    UILabel *indicatorLabel = [[UILabel alloc] init];
    _indicatorLabel = indicatorLabel;
    indicatorLabel.font = [UIFont systemFontOfSize:13];
    indicatorLabel.numberOfLines = 0;
    indicatorLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    indicatorLabel.text = @"温馨提示：为保证图片质量，将不对图片进行压缩处理，传送原图时间较长，单次上传不超过15张。";
    indicatorLabel.textColor = RGB(107, 107, 107);
    CGSize maxSize = CGSizeMake(kScreenWidth - 30, MAXFLOAT);
    CGSize rectSize = [indicatorLabel sizeThatFits:maxSize];
    indicatorLabel.frame = CGRectMake(15, CGRectGetMaxY(upView.frame) + 10, kScreenWidth - 30, rectSize.height);
    [self.view addSubview:indicatorLabel];
    
    UIButton *selectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    selectBtn.frame = CGRectMake(15, CGRectGetMaxY(indicatorLabel.frame) + 15, 75, 75);
    [selectBtn setImage:[UIImage imageNamed:@"chuansong_xiangji-"] forState:UIControlStateNormal];
    _selectBtn = selectBtn;
    [selectBtn setAdjustsImageWhenHighlighted:NO];
    [selectBtn addTarget:self action:@selector(selectPhotoAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:selectBtn];
    
    UIScrollView *scroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(selectBtn.frame) + 15, kScreenWidth, kScreenHeight - kNavigationBarHeightAndStatusBarHeight - CGRectGetMaxY(selectBtn.frame) - 15)];
    _scrollView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:scroll];
    self.scrollView = scroll;

}


- (void)getPrice{
    
    NSString *url = [NSString stringWithFormat:@"%@%@",BaseUrl,@"/pho/fee.html"];
    NSDictionary *param = @{@"token":UserToken};
    [[SYHttpRequest sharedInstance] getDataWithUrl:url Parameter:param ResponseObject:^(NSDictionary *responseResult) {
        
        NSLog(@"获取价格 -- %@",responseResult);
        if ([responseResult objectForKey:@"resError"]) {
            
        }else{
            if ([[responseResult objectForKey:@"result"] integerValue] == 1) {
                //单张照片价格
                _moneyTF.text = [NSString stringWithFormat:@"%.2f",[[responseResult objectForKey:@"money"] floatValue] / 100];
                
                
            }else{
                
            }
        }
    }];
    
}

#pragma mark - 通讯录
- (void)tongxunluAction:(UIButton *)sender{
    if ([[UIDevice currentDevice].systemVersion floatValue]>=9.0) {
        CNContactPickerViewController *contactVC = [CNContactPickerViewController new];
        contactVC.delegate = self;
        contactVC.displayedPropertyKeys = @[CNContactGivenNameKey,CNContactPhoneNumbersKey,CNContactEmailAddressesKey];
//        contactVC.predicateForSelectionOfProperty = [NSPredicate predicateWithFormat:@"(key == 'emailAddresses') AND (value LIKE '*@mac.com')"];
        [self presentViewController:contactVC animated:YES completion:^{
            
        }];
    }else{
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"请升级您的系统版本，此功能紧支持iOS9以上版本" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:^{
            
        }];
    }
    
}
#pragma mark - CNContactViewControllerDelegate代理

//选择联系人属性
- (void)contactPicker:(CNContactPickerViewController *)picker didSelectContactProperty:(CNContactProperty *)contactProperty{
    NSLog(@"%@,%@",contactProperty.key,contactProperty.value);
    if ([contactProperty.key isEqualToString:@"phoneNumbers"]) {
        CNPhoneNumber *phone = contactProperty.value;
        _accountTF.text = phone.stringValue;
    }
    
}




- (void)loadData{
    
    if (self.isFromHistory) {
        _accountTF.text = [self.dataSourceDic objectForKey:@"tel"];
    }
    
    _accountTF.delegate = self;
    _accountTF.tableview = self.historyTableView;

}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    if ([_accountTF isFirstResponder]) {

        [self.view addSubview:self.historyTableView];
        [self.view bringSubviewToFront:self.historyTableView];
    }
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    if ([_accountTF isFirstResponder]) {
        [_accountTF resignFirstResponder];
        [self.historyTableView removeFromSuperview];
        [_moneyTF becomeFirstResponder];
    }
    
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    if (textField == _accountTF) {
        if ([[Tool sharedInstance] isMobile:textField.text]) {
            [self isRegister];
        }else{
            [self labelAnimationShowWithText:@"手机号格式不正确！"];
        }
        
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{

    if (textField == _accountTF) {
        NSString *text = @"";
        if (string.length == 0) {
            text = [textField.text substringWithRange:NSMakeRange(0, textField.text.length - 1)];
        }else{
            text = [NSString stringWithFormat:@"%@%@",textField.text, string];
        }
        [self getDataWithText:text];
        
    }
    return YES;
}


- (void)setRightbarItem{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 0, 44, 44);
    [btn setTitle:@"传送" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:15];
    [btn addTarget:self action:@selector(updatePhotosToUsers:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *right = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    right.width = -15;
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:btn];
    
    self.navigationItem.rightBarButtonItems = @[right, item];
}

#pragma mark - PrivateMethod
- (void)selectPhotoAction:(UIButton *)sender{
    if ([_accountTF isFirstResponder]) [_accountTF resignFirstResponder];
    if ([_moneyTF isFirstResponder]) [_moneyTF resignFirstResponder];
    
    
    ZLPhotoActionSheet *actionSheet = [[ZLPhotoActionSheet alloc] init];
    //设置照片最大选择数
    actionSheet.maxSelectCount = 15;
    //设置照片最大预览数
    actionSheet.maxPreviewCount = 8;
    weakify(self);
    [actionSheet showPreviewPhotoWithSender:self animate:YES lastSelectPhotoModels:_selectedPhotoModelsArr completion:^(NSArray<UIImage *> * _Nonnull selectPhotos, NSArray<ZLSelectPhotoModel *> * _Nonnull selectPhotoModels, NSArray<NSData *> *imageDatas) {
        strongify(weakSelf);
        [weakSelf.selectedImagesArr removeAllObjects];
        [weakSelf.selectedPhotoModelsArr removeAllObjects];
        
        [weakSelf.selectedImagesArr addObjectsFromArray:selectPhotos];
        [weakSelf.selectedPhotoModelsArr addObjectsFromArray:selectPhotoModels];
        
        [strongSelf updateImagesToServerWithImages:selectPhotos withImageDatas:imageDatas];
        
    }];
    
}

- (void)updateImagesToServerWithImages:(NSArray *)imagesArr withImageDatas:(NSArray<NSData *> *)datas{
    
    [self.imagesArr removeAllObjects];
    for (NSData *data in datas) {
        NSLog(@"data -- %lu",[data length] / 1000);
        [self.imagesArr addObject:data];
    }
    [self loadScrollViewSubViews];
}


- (void)loadScrollViewSubViews{
    [self.scrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    for (int i = 0; i < self.imagesArr.count; i++) {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(15 + ((kScreenWidth - 70) / 3) * (i % 3) + 20 *(i % 3), ((kScreenWidth - 70) / 3) * (i / 3) + 15 * (i / 3), (kScreenWidth - 70) / 3, (kScreenWidth - 70) / 3)];
        imageView.image = [UIImage imageWithData:self.imagesArr[i]];
        imageView.userInteractionEnabled = YES;
        imageView.tag = i;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(photoBrowers:)];
        [imageView addGestureRecognizer:tap];
        
        [self.scrollView addSubview:imageView];
        
        UIButton *deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        deleteBtn.frame = CGRectMake(CGRectGetWidth(imageView.frame) - 20, 0, 20, 20);
        [deleteBtn setImage:[UIImage imageNamed:@"chuansong_shanchu"] forState:UIControlStateNormal];
        
        [deleteBtn addTarget:self action:@selector(deleteAction:) forControlEvents:UIControlEventTouchUpInside];
        deleteBtn.tag = i;
        [imageView addSubview:deleteBtn];
    }
    NSInteger count = self.imagesArr.count;
    if (count % 3 == 0) {
        self.scrollView.contentSize = CGSizeMake(kScreenWidth, ((kScreenWidth - 70) / 3 + 15) * (count / 3));
    }else{
        self.scrollView.contentSize = CGSizeMake(kScreenWidth, ((kScreenWidth - 70) / 3 + 15) * (count / 3 + 1));
    }
    
    
}

//预览图片
- (void)photoBrowers:(UITapGestureRecognizer *)tap{
    NSLog(@"%lu",tap.view.tag);
    // 快速创建并进入浏览模式
    XLPhotoBrowser *browser = [XLPhotoBrowser showPhotoBrowserWithCurrentImageIndex:tap.view.tag imageCount:self.selectedImagesArr.count datasource:self];
    browser.browserStyle = XLPhotoBrowserStyleIndexLabel;
}

- (UIImage *)photoBrowser:(XLPhotoBrowser *)browser placeholderImageForIndex:(NSInteger)index{
    return self.selectedImagesArr[index];
}

- (void)deleteAction:(UIButton *)sender{
    [self.imagesArr removeObjectAtIndex:sender.tag];
    [self.selectedPhotoModelsArr removeObjectAtIndex:sender.tag];
    [self.selectedImagesArr removeObjectAtIndex:sender.tag];
    [self loadScrollViewSubViews];
}

- (void)updatePhotosToUsers:(UIButton *)sender{
    [self.view endEditing:YES];
    
    if (_accountTF.text.length == 0) {
        [self showHint:@"请输入对方账号"];
        return;
    }
    if (_moneyTF.text.length == 0) {
        [self showHint:@"请输入图片金额"];
        return;
    }
    if (self.imagesArr.count == 0) {
        [self showHint:@"请选择要上传的照片"];
        return;
    }
    
    NSMutableArray *muDatas = [NSMutableArray arrayWithCapacity:0];
    [muDatas addObjectsFromArray:self.imagesArr];
    //一个一个上传 每次取第一个图片上传 成功后删除第一章图片
    NSData *data = muDatas[0];
    NSLog(@"上传图片长度 - %lu",(unsigned long)data.length);
    //判断图片类型
    NSString *mimaType = [[Tool sharedInstance] typeForImageData:data];
    NSInteger currentNum = self.selectedImagesArr.count - muDatas.count + 1;

    NSString *url = [NSString stringWithFormat:@"%@%@",BaseUrl,@"/pho/upimgsX.html"];
    NSDictionary *param = @{@"token":UserToken, @"tel":_accountTF.text, @"money":_moneyTF.text};
    
    [[XBUpdatePhotoManager sharedInstance] updatePhotosWithFile:url param:param fileData:data name:@"img" fileName:[NSString stringWithFormat:@"img%lu.%@",currentNum, [mimaType substringWithRange:NSMakeRange(6, mimaType.length - 6)]] mimeType:mimaType currentNumber:currentNum allNumber:self.selectedImagesArr.count result:^(NSDictionary *dic) {
        NSLog(@"dic - %@",dic);
        if (![dic objectForKey:@"resError"]) {
            if ([dic objectForKey:@"result"] && [[dic objectForKey:@"result"] integerValue] == 0) {
                [self showHint:[dic objectForKey:@"msg"]];
                return ;
            }
            //成功
            if (muDatas.count > 1) {
                [self.imagesArr removeObjectAtIndex:0];
                [self updatePhotosToUsers:sender];
            }else{
                if ([dic objectForKey:@"msg"]) {
                    [self showHint:[dic objectForKey:@"msg"]];
                }
                [self.navigationController popViewControllerAnimated:YES];
            }
            
        }else{
            [self showHint:@"请检查您的网络！"];
        }
    }];

}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.historyRecordArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"historycell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
    }
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 40)];
    [btn addTarget:self action:@selector(selectedPhone:) forControlEvents:UIControlEventTouchUpInside];
    btn.tag = indexPath.row;
    [cell.contentView addSubview:btn];
    [cell.contentView bringSubviewToFront:btn];
    
    cell.textLabel.text = [self.historyRecordArr[indexPath.row] objectForKey:@"user"];
    cell.textLabel.textColor = [UIColor darkGrayColor];
    cell.textLabel.font = [UIFont systemFontOfSize:15];
    cell.detailTextLabel.textColor = [UIColor lightGrayColor];
    cell.detailTextLabel.font = [UIFont systemFontOfSize:15];
    if ([[self.historyRecordArr[indexPath.row] objectForKey:@"nick"] isEqualToString:@""] || [self.historyRecordArr[indexPath.row] objectForKey:@"nick"] == nil || [[self.historyRecordArr[indexPath.row] objectForKey:@"nick"] isKindOfClass:[NSNull class]]) {
        cell.detailTextLabel.text = @"";
    }else{
        cell.detailTextLabel.text = [self.historyRecordArr[indexPath.row] objectForKey:@"nick"];
    }
    
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 40;
}

- (void)selectedPhone:(UIButton *)btn{
    NSString *mobile = [self.historyRecordArr[btn.tag] objectForKey:@"user"];
    _accountTF.text = @"";
    _accountTF.text = mobile;
    [_accountTF resignFirstResponder];
}

- (void)getDataWithText:(NSString *)text{
    NSLog(@"text - %@",text);
    //获取手机历史记录
    NSString *url = [NSString stringWithFormat:@"%@%@",BaseUrl,@"/pho/history_tel.html"];
    NSDictionary *param = @{@"token":UserToken, @"tel":text};
    [[SYHttpRequest sharedInstance] getDataWithUrl:url Parameter:param ResponseObject:^(NSDictionary *responseResult) {
        
        NSLog(@"获取手机历史记录 -- %@",responseResult);
        if ([responseResult objectForKey:@"resError"]) {
            
        }else{
            
            if ([[responseResult objectForKey:@"result"] integerValue] == 1) {
                [self.historyRecordArr removeAllObjects];
                if ([responseResult objectForKey:@"data"] && ![[responseResult objectForKey:@"data"] isKindOfClass:[NSNull class]]) {
                    [self.historyRecordArr addObjectsFromArray:[responseResult objectForKey:@"data"]];
                }
                self.historyTableView.frame = CGRectMake(0, 45, kScreenWidth, 40 * self.historyRecordArr.count);
                [self.historyTableView reloadData];
            }else{
                if ([responseResult objectForKey:@"msg"]) {
                    [self showHint:[responseResult objectForKey:@"msg"]];
                }
            }
        }
    }];
    
}

//手机号是否注册
- (void)isRegister{

    NSString *url = [NSString stringWithFormat:@"%@%@",BaseUrl,@"/pho/reg.html"];
    NSDictionary *param = @{@"token":UserToken, @"tel":_accountTF.text};
    [[SYHttpRequest sharedInstance] getDataWithUrl:url Parameter:param ResponseObject:^(NSDictionary *responseResult) {
        
        NSLog(@"手机号是否注册过 -- %@",responseResult);
        if ([responseResult objectForKey:@"resError"]) {
            
        }else{
            
            if ([[responseResult objectForKey:@"result"] integerValue] == 0) {
                [self labelAnimationShowWithText:[responseResult objectForKey:@"msg"]];
            }else if ([[responseResult objectForKey:@"result"] integerValue] == 1){
//                self.isRegisterText = [responseResult objectForKey:@"msg"];
//                [self labelAnimationShow];
            }else if ([[responseResult objectForKey:@"result"] integerValue] == 2){
//                self.isRegisterText = [responseResult objectForKey:@"msg"];
//                [self labelAnimationShow];
            }else{
                if ([responseResult objectForKey:@"msg"]) {
                    [self showHint:[responseResult objectForKey:@"msg"] Offset:64 - kScreenHeight / 2];
                }
                [self.navigationController popToRootViewControllerAnimated:YES];
            }
        }
    }];
    
}

- (void)labelAnimationShowWithText:(NSString *)text{
    if (text.length > 0) {
        _isRegisterLabel.text = text;
        [UIView animateWithDuration:.35 animations:^{
            _isRegisterLabel.frame = CGRectMake(0, 0, kScreenWidth, 40);
            _upView.frame = CGRectMake(0, CGRectGetMaxY(_isRegisterLabel.frame), kScreenWidth, 88);
            _indicatorLabel.frame = CGRectMake(_indicatorLabel.frame.origin.x, CGRectGetMaxY(_upView.frame) + 10, _indicatorLabel.frame.size.width, _indicatorLabel.frame.size.height);
            
            _selectBtn.frame = CGRectMake(15, CGRectGetMaxY(_indicatorLabel.frame) + 15, 75, 75);
            _scrollView.frame = CGRectMake(0, CGRectGetMaxY(_selectBtn.frame) + 15, kScreenWidth, kScreenHeight - kNavigationBarHeightAndStatusBarHeight - CGRectGetMaxY(_selectBtn.frame) - 15);
            self.historyTableView.frame = CGRectMake(0, 45 + 40, kScreenWidth, 0);
        } completion:^(BOOL finished) {
            //开启定时器
            [self performSelector:@selector(labelAnimationDismiss) withObject:nil afterDelay:2];
        }];
    }
}

- (void)labelAnimationDismiss{
    [UIView animateWithDuration:.35 animations:^{
        _isRegisterLabel.frame = CGRectMake(0, -40, kScreenWidth, 40);
        _upView.frame = CGRectMake(0, CGRectGetMaxY(_isRegisterLabel.frame), kScreenWidth, 88);
        _indicatorLabel.frame = CGRectMake(_indicatorLabel.frame.origin.x, CGRectGetMaxY(_upView.frame) + 10, _indicatorLabel.frame.size.width, _indicatorLabel.frame.size.height);
        _selectBtn.frame = CGRectMake(15, CGRectGetMaxY(_indicatorLabel.frame) + 15, 75, 75);
        _scrollView.frame = CGRectMake(0, CGRectGetMaxY(_selectBtn.frame) + 15, kScreenWidth, kScreenHeight - kNavigationBarHeightAndStatusBarHeight - CGRectGetMaxY(_selectBtn.frame) - 15);
        self.historyTableView.frame = CGRectMake(0, 45, kScreenWidth, 0);

    } completion:^(BOOL finished) {
        //关闭定时器
        
    }];
}

- (void)viewWillLayoutSubviews{
    if ([self.historyTableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.historyTableView setSeparatorInset:UIEdgeInsetsMake(0, 0, 0, 0)];
    }
    
    if ([self.historyTableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.historyTableView setLayoutMargins:UIEdgeInsetsMake(0, 0, 0, 0)];
    }
    
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsMake(0, 0, 0, 0)];
    }
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsMake(0, 0, 0, 0)];
    }
    
}


#pragma mark - Layzload
- (NSMutableArray *)imagesArr{
    if (!_imagesArr) {
        _imagesArr = [NSMutableArray arrayWithCapacity:0];
    }
    return _imagesArr;
}

- (NSMutableArray *)selectedImagesArr{
    if (!_selectedImagesArr) {
        _selectedImagesArr = [NSMutableArray arrayWithCapacity:0];
    }
    return _selectedImagesArr;
}

- (NSMutableArray *)selectedPhotoModelsArr{
    if (!_selectedPhotoModelsArr) {
        _selectedPhotoModelsArr = [NSMutableArray arrayWithCapacity:0];
    }
    return _selectedPhotoModelsArr;
}

- (NSMutableArray *)historyRecordArr{
    if (!_historyRecordArr) {
        _historyRecordArr = [NSMutableArray arrayWithCapacity:0];
    }
    return _historyRecordArr;
}

- (UITableView *)historyTableView{
    if (!_historyTableView) {
        _historyTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 45, kScreenWidth, 0) style:UITableViewStylePlain];
        _historyTableView.delegate = self;
        _historyTableView.dataSource = self;
        _historyTableView.bounces = NO;
//        _historyTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return _historyTableView;
}
@end
