//
//  SYGrapherUpdatePhotoToCloudViewController.m
//  ShuoYing
//
//  Created by 硕影 on 2017/1/10.
//  Copyright © 2017年 硕影. All rights reserved.
//

#import "SYGrapherUpdatePhotoToCloudViewController.h"

#import "OSAddressPickerView.h"

@interface SYGrapherUpdatePhotoToCloudViewController ()<UITextViewDelegate,XLPhotoBrowserDatasource, XLPhotoBrowserDelegate, UIScrollViewDelegate>
{
    OSAddressPickerView *_pickerview;
    
    NSString *_prov;
    NSString *_city;
    
    NSNumber *_num;//上传到云拍的参数num

}

@property (weak, nonatomic) IBOutlet UIScrollView *bigScrollView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *containerViewHeight;
@property (weak, nonatomic) IBOutlet UIView *containerView;

@property (weak, nonatomic) IBOutlet UIView *imagesView;

@property (weak, nonatomic) IBOutlet UITextView *introTextView;
@property (weak, nonatomic) IBOutlet UILabel *placeHoldLabel;
@property (weak, nonatomic) IBOutlet UILabel *textNumLabel;

@property (weak, nonatomic) IBOutlet UIButton *oneBtn;
@property (weak, nonatomic) IBOutlet UIButton *twoBtn;
@property (weak, nonatomic) IBOutlet UIButton *threeBtn;
@property (weak, nonatomic) IBOutlet UIButton *fourBtn;
@property (weak, nonatomic) IBOutlet UIButton *fiveBtn;
@property (weak, nonatomic) IBOutlet UIButton *sixBtn;
@property (weak, nonatomic) IBOutlet UIButton *sevenBrn;
@property (weak, nonatomic) IBOutlet UIButton *eightBtn;

@property (weak, nonatomic) IBOutlet UILabel *areaLabel;
@property (weak, nonatomic) IBOutlet UIView *selecteAeraView;

@property (weak, nonatomic) IBOutlet UIButton *seletePhotos;

@property (nonatomic, strong) NSMutableArray *currentSelectedBtnsArr;

@property (nonatomic, strong) NSMutableArray *imagesArr;

@property (nonatomic, strong) NSMutableArray *selectedPhotosArr;

@property (nonatomic, strong) NSMutableArray *selectedPhotoModelsArr;

@property (weak, nonatomic) IBOutlet UITextField *yuyueTF;
@property (weak, nonatomic) IBOutlet UITextField *danzhangTF;

@end

#define MAX_LIMIT_NUMS 50
#define BtnNormalCorlor [UIColor colorWithRed:145/255.0 green:145/255.0 blue:145/255.0 alpha:1.0]
@implementation SYGrapherUpdatePhotoToCloudViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"发布到首页";
    _num = @0;
    self.containerViewHeight.constant = kScreenHeight - 64;
    self.introTextView.delegate = self;
    self.bigScrollView.delegate = self;
    self.selecteAeraView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selecteCityAction:)];
    [self.selecteAeraView addGestureRecognizer:tap];
    [self setSubViewsLayer];
    [self setRightbarItem];
    [self getData];
}
//发布
- (void)updatePhotosToCloud:(UIButton *)sender{
    if (self.introTextView.text.length == 0) {
        [self showHint:@"请输入您的作品说明"];
        return;
    }
    
    if (self.introTextView.text.length < 10) {
        [self showHint:@"作品说明最少10个字哦！"];
        return;
    }
    
    if (self.currentSelectedBtnsArr.count == 0) {
        [self showHint:@"请选择您发布作品的类型"];
        return;
    }
    
    if (_prov.length == 0 || _city.length == 0) {
        [self showHint:@"请选择您要发布的地区"];
        return;
    }
    
    if (self.selectedPhotosArr.count <= 2) {
        [self showHint:@"发布到首页最少要上传3张图片哦！"];
        return;
    }
    
    NSMutableArray *seletedTypeTag = [NSMutableArray arrayWithCapacity:0];
    for (NSString *type in self.currentSelectedBtnsArr) {
        if ([type isEqualToString:@"人物"]) {
            [seletedTypeTag addObject:@1];
        }else if ([type isEqualToString:@"风景"]){
            [seletedTypeTag addObject:@2];
        }else if ([type isEqualToString:@"儿童"]){
            [seletedTypeTag addObject:@3];
        }else if ([type isEqualToString:@"婚纱"]){
            [seletedTypeTag addObject:@4];
        }else if ([type isEqualToString:@"写真"]){
            [seletedTypeTag addObject:@5];
        }else if ([type isEqualToString:@"纪实"]){
            [seletedTypeTag addObject:@6];
        }else if ([type isEqualToString:@"怀旧"]){
            [seletedTypeTag addObject:@7];
        }else{
            [seletedTypeTag addObject:@8];
        }
    }
    
    NSMutableArray *muDatas = [NSMutableArray arrayWithCapacity:0];
    [muDatas addObjectsFromArray:self.imagesArr];
    //一个一个上传 每次取第一个图片上传 成功后删除第一章图片
    NSData *data = muDatas[0];
    //判断图片类型
    NSString *mimaType = [[Tool sharedInstance] typeForImageData:data];
    NSInteger currentNum = self.selectedPhotosArr.count - muDatas.count + 1;
    
    NSString *url = [NSString stringWithFormat:@"%@%@",BaseUrl,@"/pho/cloudX.html"];
    NSDictionary *param = @{@"token":UserToken, @"prov":_prov, @"city":_city, @"type":seletedTypeTag, @"info":self.introTextView.text, @"num":_num, @"fee":self.yuyueTF.text, @"cash":self.danzhangTF.text};
    NSLog(@"param = %@",param);
    [[XBUpdatePhotoManager sharedInstance] updatePhotosWithFile:url param:param fileData:data name:@"img" fileName:[NSString stringWithFormat:@"img%lu.%@",(long)currentNum, [mimaType substringWithRange:NSMakeRange(6, mimaType.length - 6)]] mimeType:mimaType currentNumber:currentNum allNumber:self.selectedPhotosArr.count result:^(NSDictionary *dic) {
        NSLog(@"dic - %@",dic);
        if (![dic objectForKey:@"resError"]) {
            if ([dic objectForKey:@"result"] && [[dic objectForKey:@"result"] integerValue] == 0) {
                [self showHint:[dic objectForKey:@"msg"]];
                return ;
            }
            //成功
            if (muDatas.count > 1) {
                [self.imagesArr removeObjectAtIndex:0];
                _num = [dic objectForKey:@"num"];
                [self updatePhotosToCloud:sender];
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

//选择城市
- (void)selecteCityAction:(UITapGestureRecognizer *)tap{
    [self.view endEditing:YES];
    _pickerview = [OSAddressPickerView shareInstance];
    [_pickerview showBottomView];
    [self.view addSubview:_pickerview];
    [self.view bringSubviewToFront:_pickerview];
    
    __weak typeof(self)weakself = self;
    _pickerview.block = ^(NSString *province,NSString *city,NSString *district)
    {
        weakself.areaLabel.text =[NSString stringWithFormat:@"%@%@%@",province,city,district];
        _prov = province;
        _city = city;
    };
}

- (IBAction)selecteTypeAction:(UIButton *)sender {
//    NSLog(@"sender - %@",sender.titleLabel.text);
    if (sender.selected == YES)  {
        for (int i = 0; i<self.currentSelectedBtnsArr.count; i++) {
            NSString *type = self.currentSelectedBtnsArr[i];
            if ([type isEqualToString:sender.titleLabel.text]) {
                [self.currentSelectedBtnsArr removeObject:type];
            }
        }
    }else{
        if (self.currentSelectedBtnsArr.count > 2) {
            for (int i = 0; i<self.currentSelectedBtnsArr.count; i++) {
                NSString *type = self.currentSelectedBtnsArr[i];
                if ([type isEqualToString:sender.titleLabel.text]) {
                    [self.currentSelectedBtnsArr removeObject:type];
                }
            }
            return;
        }else{
            [self.currentSelectedBtnsArr addObject:sender.titleLabel.text];

        }
    }
    
    sender.selected = !sender.selected;
    
    NSLog(@"currentSelectedBtnsArr - %@",self.currentSelectedBtnsArr);
    
}
//选择图片
- (IBAction)selectePhotoAction:(UIButton *)sender {
    ZLPhotoActionSheet *actionSheet = [[ZLPhotoActionSheet alloc] init];
    //设置照片最大选择数
    actionSheet.maxSelectCount = 15;
    //设置照片最大预览数
    actionSheet.maxPreviewCount = 8;
    
    weakify(self);
    [actionSheet showPreviewPhotoWithSender:self animate:YES lastSelectPhotoModels:self.selectedPhotoModelsArr completion:^(NSArray<UIImage *> * _Nonnull selectPhotos, NSArray<ZLSelectPhotoModel *> * _Nonnull selectPhotoModels, NSArray<NSData *> *imageDatas) {
        strongify(weakSelf);
        [weakSelf.selectedPhotosArr removeAllObjects];
        [weakSelf.selectedPhotoModelsArr removeAllObjects];
        
        [weakSelf.selectedPhotosArr addObjectsFromArray:selectPhotos];
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
    [self reloadScrollView];
}

     
     


- (void)setSubViewsLayer{
    [self.oneBtn setTitle:@"人物" forState:UIControlStateNormal];
    [self.oneBtn setTitleColor:BtnNormalCorlor forState:UIControlStateNormal];
    [self.oneBtn setTitleColor:NavigationColor forState:UIControlStateSelected];
    
    [self.twoBtn setTitle:@"风景" forState:UIControlStateNormal];
    [self.twoBtn setTitleColor:BtnNormalCorlor forState:UIControlStateNormal];
    [self.twoBtn setTitleColor:NavigationColor forState:UIControlStateSelected];
    
    [self.threeBtn setTitle:@"古典" forState:UIControlStateNormal];
    [self.threeBtn setTitleColor:BtnNormalCorlor forState:UIControlStateNormal];
    [self.threeBtn setTitleColor:NavigationColor forState:UIControlStateSelected];
    
    [self.fourBtn setTitle:@"儿童" forState:UIControlStateNormal];
    [self.fourBtn setTitleColor:BtnNormalCorlor forState:UIControlStateNormal];
    [self.fourBtn setTitleColor:NavigationColor forState:UIControlStateSelected];
    
    [self.fiveBtn setTitle:@"婚纱" forState:UIControlStateNormal];
    [self.fiveBtn setTitleColor:BtnNormalCorlor forState:UIControlStateNormal];
    [self.fiveBtn setTitleColor:NavigationColor forState:UIControlStateSelected];
    
    [self.sixBtn setTitle:@"怀旧" forState:UIControlStateNormal];
    [self.sixBtn setTitleColor:BtnNormalCorlor forState:UIControlStateNormal];
    [self.sixBtn setTitleColor:NavigationColor forState:UIControlStateSelected];
    
    [self.sevenBrn setTitle:@"写真" forState:UIControlStateNormal];
    [self.sevenBrn setTitleColor:BtnNormalCorlor forState:UIControlStateNormal];
    [self.sevenBrn setTitleColor:NavigationColor forState:UIControlStateSelected];
    
    [self.eightBtn setTitle:@"纪实" forState:UIControlStateNormal];
    [self.eightBtn setTitleColor:BtnNormalCorlor forState:UIControlStateNormal];
    [self.eightBtn setTitleColor:NavigationColor forState:UIControlStateSelected];
}

- (void)setRightbarItem{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 0, 44, 44);
    [btn setTitle:@"发布" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:15];
    [btn addTarget:self action:@selector(updatePhotosToCloud:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *right = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    right.width = -15;
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:btn];
    
    self.navigationItem.rightBarButtonItems = @[right, item];
}


#pragma mark -限制输入字数(最多不超过50个字)
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    //不支持系统表情的输入
    if ([[textView textInputMode]primaryLanguage]==nil||[[[textView textInputMode]primaryLanguage]isEqualToString:@"emoji"]) {
        return NO;
    }
    
    UITextRange *selectedRange = [textView markedTextRange];
    
    //获取高亮部分
    
    UITextPosition *pos = [textView positionFromPosition:selectedRange.start offset:0];
    
    //获取高亮部分内容
    //NSString * selectedtext = [textView textInRange:selectedRange];
    //如果有高亮且当前字数开始位置小于最大限制时允许输入
    if (selectedRange && pos) {
        NSInteger startOffset = [textView offsetFromPosition:textView.beginningOfDocument toPosition:selectedRange.start];
        
        NSInteger endOffset = [textView offsetFromPosition:textView.beginningOfDocument toPosition:selectedRange.end];
        
        NSRange offsetRange =NSMakeRange(startOffset, endOffset - startOffset);
        
        if (offsetRange.location < MAX_LIMIT_NUMS) {
            
            return YES;
        }else{
            
            return NO;
        }
    }
    
    NSString *comcatstr = [textView.text stringByReplacingCharactersInRange:range withString:text];
    NSInteger caninputlen =MAX_LIMIT_NUMS - comcatstr.length;
    if (caninputlen >= 0){
        return YES;
    }else{
        
        NSInteger len = text.length + caninputlen;
        //防止当text.length + caninputlen < 0时，使得rg.length为一个非法最大正数出错
        NSRange rg = {0,MAX(len,0)};
        if (rg.length >0){
            
            NSString *s =@"";
            
            //判断是否只普通的字符或asc码(对于中文和表情返回NO)
            
            BOOL asc = [text canBeConvertedToEncoding:NSASCIIStringEncoding];
            
            if (asc) {
                
                s = [text substringWithRange:rg];//因为是ascii码直接取就可以了不会错
                
            }else{
                
                __block NSInteger idx =0;
                
                __block NSString  *trimString =@"";//截取出的字串
                
                //使用字符串遍历，这个方法能准确知道每个emoji是占一个unicode还是两个
                
                [text enumerateSubstringsInRange:NSMakeRange(0, [text length])
                 
                                         options:NSStringEnumerationByComposedCharacterSequences
                 
                                      usingBlock: ^(NSString* substring,NSRange substringRange,NSRange enclosingRange,BOOL* stop) {
                                          
                                          if (idx >= rg.length) {
                                              
                                              *stop =YES;//取出所需要就break，提高效率
                                              
                                              return ;
                                          }
                                          
                                          trimString = [trimString stringByAppendingString:substring];
                                          
                                          idx++;
                                          
                                      }];
                
                s = trimString;
                
            }
            
            //rang是指从当前光标处进行替换处理(注意如果执行此句后面返回的是YES会触发didchange事件)
            
            [textView setText:[textView.text stringByReplacingCharactersInRange:range withString:s]];
            
            //既然是超出部分截取了，哪一定是最大限制了。
            
            self.textNumLabel.text = [NSString stringWithFormat:@"%d/%ld",0,(long)MAX_LIMIT_NUMS];
            
        }
        return NO;
    }
}


#pragma mark -显示当前可输入字数/总字数
- (void)textViewDidChange:(UITextView *)textView{
    
    if ([textView.text length] == 0) {
        [self.placeHoldLabel setHidden:NO];
    }else{
        [self.placeHoldLabel setHidden:YES];
    }
    
    
    //    _liuyanHeight.constant = textView.contentSize.height;
    
    UITextRange *selectedRange = [textView markedTextRange];
    
    //获取高亮部分
    
    UITextPosition *pos = [textView positionFromPosition:selectedRange.start offset:0];
    
    //如果在变化中是高亮部分在变，就不要计算字符了
    
    if (selectedRange && pos) {
        
        return;
    }
    
    NSString  *nsTextContent = textView.text;
    
    NSInteger existTextNum = nsTextContent.length;
    
    if (existTextNum > MAX_LIMIT_NUMS){
        //截取到最大位置的字符(由于超出截部分在should时被处理了所在这里这了提高效率不再判断)
        
        NSString *s = [nsTextContent substringToIndex:MAX_LIMIT_NUMS];
        
        [textView setText:s];
        
    }
    //不让显示负数
    self.textNumLabel.text = [NSString stringWithFormat:@"%ld/%d",MAX(0,MAX_LIMIT_NUMS - existTextNum),MAX_LIMIT_NUMS];
    
}

- (void)reloadScrollView{
    [self.imagesView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    for (int i = 0; i < self.imagesArr.count; i++) {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(15 + ((kScreenWidth - 70) / 3) * (i % 3) + 20 *(i % 3), ((kScreenWidth - 70) / 3) * (i / 3) + 15 * (i / 3), (kScreenWidth - 70) / 3, (kScreenWidth - 70) / 3)];
        imageView.image = [UIImage imageWithData:self.imagesArr[i]];
        imageView.userInteractionEnabled = YES;
        imageView.tag = i;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(photoBrowers:)];
        [imageView addGestureRecognizer:tap];
        [self.imagesView addSubview:imageView];
        
        UIButton *deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        deleteBtn.frame = CGRectMake(CGRectGetWidth(imageView.frame) - 20, 0, 20, 20);
        [deleteBtn setImage:[UIImage imageNamed:@"chuansong_shanchu"] forState:UIControlStateNormal];
        
        [deleteBtn addTarget:self action:@selector(deleteAction:) forControlEvents:UIControlEventTouchUpInside];
        deleteBtn.tag = i;
        [imageView addSubview:deleteBtn];
    }
    NSInteger count = self.imagesArr.count;
    if (count % 3 == 0) {
//        self.scrollView.contentSize = CGSizeMake(kScreenWidth, ((kScreenWidth - 70) / 3 + 15) * (count / 3));
        self.containerViewHeight.constant = CGRectGetMaxY(self.seletePhotos.frame) + 15 + ((kScreenWidth - 70) / 3 + 15) * (count / 3);
    }else{
//        self.scrollView.contentSize = CGSizeMake(kScreenWidth, ((kScreenWidth - 70) / 3 + 15) * (count / 3 + 1));
        self.containerViewHeight.constant = CGRectGetMaxY(self.seletePhotos.frame) + 15 + ((kScreenWidth - 70) / 3 + 15) * (count / 3 + 1);
    }
    NSLog(@"self.co - %f",self.containerViewHeight.constant - kScreenHeight + 64);
    if (self.containerViewHeight.constant > (kScreenHeight - 64)) {
        [self.bigScrollView setContentOffset:CGPointMake(0, self.containerViewHeight.constant - (kScreenHeight - 64)) animated:NO];
    }
    

}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    NSLog(@"%F",scrollView.contentOffset.x);
    NSLog(@"%F",scrollView.contentOffset.y);
}


//预览图片
- (void)photoBrowers:(UITapGestureRecognizer *)tap{
    NSLog(@"%lu",tap.view.tag);
    // 快速创建并进入浏览模式
    XLPhotoBrowser *browser = [XLPhotoBrowser showPhotoBrowserWithCurrentImageIndex:tap.view.tag imageCount:self.selectedPhotosArr.count datasource:self];
    browser.browserStyle = XLPhotoBrowserStyleIndexLabel;
}

- (UIImage *)photoBrowser:(XLPhotoBrowser *)browser placeholderImageForIndex:(NSInteger)index{
    return self.selectedPhotosArr[index];
}

- (void)deleteAction:(UIButton *)sender{
    [self.imagesArr removeObjectAtIndex:sender.tag];
    [self.selectedPhotoModelsArr removeObjectAtIndex:sender.tag];
    [self.selectedPhotosArr removeObjectAtIndex:sender.tag];
    
    [self reloadScrollView];
}


- (void)getData{
    
    NSString *url = [NSString stringWithFormat:@"%@%@",BaseUrl,@"/pho/fee.html"];
    NSDictionary *param = @{@"token":UserToken};
    [[SYHttpRequest sharedInstance] getDataWithUrl:url Parameter:param ResponseObject:^(NSDictionary *responseResult) {
        
        NSLog(@"获取价格 -- %@",responseResult);
        if ([responseResult objectForKey:@"resError"]) {
            
        }else{
            if ([[responseResult objectForKey:@"result"] integerValue] == 1) {
                //单张照片价格
//                _money = [NSString stringWithFormat:@"%.2f",[[responseResult objectForKey:@"money"] floatValue] / 100];
                //约拍价格
                self.yuyueTF.text = [NSString stringWithFormat:@"%.2f",[[responseResult objectForKey:@"fee"] floatValue] / 100];
                //发布到首页价格
                self.danzhangTF.text = [NSString stringWithFormat:@"%.2f",[[responseResult objectForKey:@"cash"] floatValue] / 100];
                
            }else{
                if ([responseResult objectForKey:@"msg"]) {
                    [self showHint:[responseResult objectForKey:@"msg"]];
                }
            }
        }
    }];
    
}

- (NSMutableArray *)currentSelectedBtnsArr{
    if (!_currentSelectedBtnsArr) {
        _currentSelectedBtnsArr = [NSMutableArray arrayWithCapacity:0];
    }
    return _currentSelectedBtnsArr;
}


- (NSMutableArray *)imagesArr{
    if (!_imagesArr) {
        _imagesArr = [NSMutableArray arrayWithCapacity:0];
    }
    return _imagesArr;
}

- (NSMutableArray *)selectedPhotosArr{
    if (!_selectedPhotosArr) {
        _selectedPhotosArr = [NSMutableArray arrayWithCapacity:0];
    }
    return _selectedPhotosArr;
}

- (NSMutableArray *)selectedPhotoModelsArr{
    if (!_selectedPhotoModelsArr) {
        _selectedPhotoModelsArr = [NSMutableArray arrayWithCapacity:0];
    }
    return _selectedPhotoModelsArr;
}

@end
