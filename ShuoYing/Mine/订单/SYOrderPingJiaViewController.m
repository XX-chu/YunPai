//
//  SYOrderPingJiaViewController.m
//  ShuoYing
//
//  Created by 硕影 on 2017/4/7.
//  Copyright © 2017年 硕影. All rights reserved.
//

#import "SYOrderPingJiaViewController.h"
#import "DeleteOrderView.h"

@interface SYOrderPingJiaViewController ()<UITextViewDelegate>

{
    NSInteger _miaoshuTag;
    NSInteger _wuliuTag;
    NSInteger _fuwuTag;
    
    BOOL _hasPingjia;
    UIButton *_backBtn;
    UIButton *_rightBtn;
}
@property (weak, nonatomic) IBOutlet UIView *scrollViewContainerView;
@property (weak, nonatomic) IBOutlet UIView *imageContainerView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *backViewHeightConstraints;

@property (weak, nonatomic) IBOutlet UIButton *miaoshu1;
@property (weak, nonatomic) IBOutlet UIButton *miaoshu2;
@property (weak, nonatomic) IBOutlet UIButton *miaoshu3;
@property (weak, nonatomic) IBOutlet UIButton *miaoshu4;
@property (weak, nonatomic) IBOutlet UIButton *miaoshu5;

@property (weak, nonatomic) IBOutlet UITextView *pingjiaTV;
@property (weak, nonatomic) IBOutlet UILabel *placeHolderLabel;
@property (weak, nonatomic) IBOutlet UILabel *countLabel;

@property (weak, nonatomic) IBOutlet UIButton *wuliu1;
@property (weak, nonatomic) IBOutlet UIButton *wuliu2;
@property (weak, nonatomic) IBOutlet UIButton *wuliu3;
@property (weak, nonatomic) IBOutlet UIButton *wuliu4;
@property (weak, nonatomic) IBOutlet UIButton *wuliu5;

@property (weak, nonatomic) IBOutlet UIButton *fuwu1;
@property (weak, nonatomic) IBOutlet UIButton *fuwu2;
@property (weak, nonatomic) IBOutlet UIButton *fuwu3;
@property (weak, nonatomic) IBOutlet UIButton *fuwu4;
@property (weak, nonatomic) IBOutlet UIButton *fuwu5;

@property (weak, nonatomic) IBOutlet UILabel *updateLabel;
@property (weak, nonatomic) IBOutlet UIButton *updateBtn;

@property (nonatomic, strong) NSArray *miaoshuArr;
@property (nonatomic, strong) NSArray *wuliuArr;
@property (nonatomic, strong) NSArray *fuwuArr;

@property (nonatomic, strong) NSMutableArray *selectedImagesArr;
@property (nonatomic, strong) NSMutableArray *selectedImageDatasArr;
@property (nonatomic, strong) NSMutableArray *selectedImageModelsArr;

@end

#define MAX_LIMIT_NUMS 100

@implementation SYOrderPingJiaViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self setleftBarItem];

}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    NSLog(@"miaoshuTag - %ld",_miaoshuTag);
    NSLog(@"wuliuTag - %ld",_wuliuTag);
    NSLog(@"fuwuTag - %ld",_fuwuTag);
    if([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
    
    self.title = @"评价";

    _miaoshuTag = 5;
    _wuliuTag = 0;
    _fuwuTag = 0;
    _hasPingjia = NO;
    self.backViewHeightConstraints.constant = kScreenHeight - kNavigationBarHeightAndStatusBarHeight;
    [self setBtnLayer];
    self.miaoshuArr = @[self.miaoshu1, self.miaoshu2, self.miaoshu3, self.miaoshu4, self.miaoshu5];
    self.wuliuArr = @[self.wuliu1, self.wuliu2, self.wuliu3, self.wuliu4, self.wuliu5];
    self.fuwuArr = @[self.fuwu1, self.fuwu2, self.fuwu3, self.fuwu4, self.fuwu5];
    [self setRightBarItem];
}

- (IBAction)selectePhotoAction:(UIButton *)sender {
    
    ZLPhotoActionSheet *actionSheet = [[ZLPhotoActionSheet alloc] init];
    //设置照片最大选择数
    actionSheet.maxSelectCount = 3;
    //设置照片最大预览数
    //    actionSheet.maxPreviewCount = 8;
    weakify(self);
    [actionSheet showPreviewPhotoWithSender:self animate:YES lastSelectPhotoModels:self.selectedImageModelsArr completion:^(NSArray<UIImage *> * _Nonnull selectPhotos, NSArray<ZLSelectPhotoModel *> * _Nonnull selectPhotoModels, NSArray<NSData *> *imageDatas) {
        
        [weakSelf.selectedImagesArr removeAllObjects];
        [weakSelf.selectedImageDatasArr removeAllObjects];
        [weakSelf.selectedImageModelsArr removeAllObjects];
        
        [weakSelf.selectedImagesArr addObjectsFromArray:selectPhotos];
        [weakSelf.selectedImageDatasArr addObjectsFromArray:imageDatas];
        [weakSelf.selectedImageModelsArr addObjectsFromArray:selectPhotoModels];
        
        [weakSelf zhanshiSelectedPhoto];
    }];
}

- (void)zhanshiSelectedPhoto{
    
    self.updateLabel.text = [NSString stringWithFormat:@"温馨提示：您还可以上传%ld张图片",3-self.selectedImageModelsArr.count];

    [self.imageContainerView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    for (int i = 0; i < self.selectedImagesArr.count; i++) {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(15 + ((kScreenWidth - 70) / 3) * (i % 3) + 20 *(i % 3), ((kScreenWidth - 70) / 3) * (i / 3) + 15 * (i / 3), (kScreenWidth - 70) / 3, (kScreenWidth - 70) / 3)];
        imageView.image = [UIImage imageWithData:self.selectedImageDatasArr[i]];
        imageView.userInteractionEnabled = YES;
        imageView.tag = i;
//        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(photoBrowers:)];
//        [imageView addGestureRecognizer:tap];
        
        [self.imageContainerView addSubview:imageView];
        
        UIButton *deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        deleteBtn.frame = CGRectMake(CGRectGetWidth(imageView.frame) - 20, 0, 20, 20);
        [deleteBtn setImage:[UIImage imageNamed:@"chuansong_shanchu"] forState:UIControlStateNormal];
        
        [deleteBtn addTarget:self action:@selector(deleteAction:) forControlEvents:UIControlEventTouchUpInside];
        deleteBtn.tag = i;
        [imageView addSubview:deleteBtn];
    }
    
    NSInteger count = self.selectedImagesArr.count;
    if (count != 0) {
        self.backViewHeightConstraints.constant = 487 + (kScreenWidth - 14 * 2 - 21 * 2) / 3 + 15;
    }else{
        self.backViewHeightConstraints.constant = kScreenHeight - kNavigationBarHeightAndStatusBarHeight;
    }

}

- (void)deleteAction:(UIButton *)sender{
    [self.selectedImagesArr removeObjectAtIndex:sender.tag];
    [self.selectedImageDatasArr removeObjectAtIndex:sender.tag];
    [self.selectedImageModelsArr removeObjectAtIndex:sender.tag];
    [self zhanshiSelectedPhoto];
}

- (IBAction)miaoshuAction:(UIButton *)sender {
    _miaoshuTag = sender.tag;
    for (UIButton *miaoshuBtn in self.miaoshuArr) {
        if (miaoshuBtn.tag <= sender.tag) {
            [miaoshuBtn setBackgroundImage:[UIImage imageNamed:@"pingjia_sel"] forState:UIControlStateNormal];
        }else{
            [miaoshuBtn setBackgroundImage:[UIImage imageNamed:@"pingjia_nor"] forState:UIControlStateNormal];
        }
    }
}

- (IBAction)wuliuAction:(UIButton *)sender {
    //物流服务
    _wuliuTag = sender.tag;
    for (UIButton *miaoshuBtn in self.wuliuArr) {
        if (miaoshuBtn.tag <= sender.tag) {
            [miaoshuBtn setBackgroundImage:[UIImage imageNamed:@"pingjia_sel"] forState:UIControlStateNormal];
        }else{
            [miaoshuBtn setBackgroundImage:[UIImage imageNamed:@"pingjia_nor"] forState:UIControlStateNormal];
        }
    }
}

- (IBAction)fuwuAction:(UIButton *)sender {
    //服务态度
    _fuwuTag = sender.tag;
    for (UIButton *miaoshuBtn in self.fuwuArr) {
        if (miaoshuBtn.tag <= sender.tag) {
            [miaoshuBtn setBackgroundImage:[UIImage imageNamed:@"pingjia_sel"] forState:UIControlStateNormal];
        }else{
            [miaoshuBtn setBackgroundImage:[UIImage imageNamed:@"pingjia_nor"] forState:UIControlStateNormal];
        }
    }
}

- (void)setRightBarItem{
    _rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _rightBtn.frame = CGRectMake(0, 0, 65, 40);
    _rightBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [_rightBtn setTitle:@"发表评价" forState:UIControlStateNormal];
    [_rightBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 15, 0, -15)];
    [_rightBtn setAdjustsImageWhenHighlighted:NO];
    [_rightBtn addTarget:self action:@selector(pingjiaAction:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_rightBtn];
    self.navigationItem.rightBarButtonItem = backBarButtonItem;
}


- (void)pingjiaAction:(UIButton *)sender{
    //先上传图片
    if (self.selectedImageDatasArr.count > 0) {
        [self updatePhotos];
    }else{
        //提交评价
        [SVProgressHUD show];
        NSString *url = [NSString stringWithFormat:@"%@%@",BaseUrl,@"/order/editinfo.html"];
        NSDictionary *param = @{@"token":UserToken, @"id":self.orderID, @"info":self.pingjiaTV.text, @"miaoshu":[NSNumber numberWithInteger:_miaoshuTag], @"wuliu":[NSNumber numberWithInteger:_wuliuTag], @"fuwu":[NSNumber numberWithInteger:_fuwuTag]};
        
        __weak typeof(self)weakself = self;
        [[SYHttpRequest sharedInstance] getDataWithUrl:url Parameter:param ResponseObject:^(NSDictionary *responseResult) {
            [SVProgressHUD dismiss];
            NSLog(@"上传评价 -- %@",responseResult);
            if ([responseResult objectForKey:@"resError"]) {
                [weakself showHint:@"服务器不给力，请稍后重试"];
                
            }else{
                if ([[responseResult objectForKey:@"result"] integerValue] == 1) {
                    [weakself.navigationController popViewControllerAnimated:YES];
                }else{
                    [weakself showHint:[responseResult objectForKey:@"msg"]];
                }
            }
        }];
    }
    
}

- (void)updatePhotos{
    if (self.selectedImageDatasArr.count == 0) {
        [self pingjiaAction:nil];
        return;
    }
    [self.view endEditing:YES];
    
    NSMutableArray *muDatas = [NSMutableArray arrayWithCapacity:0];
    [muDatas addObjectsFromArray:self.selectedImageDatasArr];
    //一个一个上传 每次取第一个图片上传 成功后删除第一章图片
    NSData *data = muDatas[0];
    //判断图片类型
    NSString *mimaType = [[Tool sharedInstance] typeForImageData:data];
    NSInteger currentNum = self.selectedImageModelsArr.count - muDatas.count + 1;
    NSString *url = [NSString stringWithFormat:@"%@%@",BaseUrl,@"/order/editup.html"];
    NSDictionary *param = @{@"token":UserToken, @"id":self.orderID, @"img":[NSString stringWithFormat:@"img%lu",currentNum]};
    
    [[XBUpdatePhotoManager sharedInstance] updatePhotosWithFile:url param:param fileData:data name:[NSString stringWithFormat:@"img%lu",currentNum] fileName:[NSString stringWithFormat:@"img%lu.%@",currentNum, [mimaType substringWithRange:NSMakeRange(6, mimaType.length - 6)]] mimeType:mimaType currentNumber:currentNum allNumber:self.selectedImagesArr.count result:^(NSDictionary *dic) {
        NSLog(@"dic - %@",dic);
        if (![dic objectForKey:@"resError"]) {
            if ([dic objectForKey:@"result"] && [[dic objectForKey:@"result"] integerValue] == 0) {
                [self showHint:[dic objectForKey:@"msg"]];
                return ;
            }
            //成功
            if (muDatas.count > 1) {
                [self.selectedImageDatasArr removeObjectAtIndex:0];
                [self updatePhotos];
            }else{
//                if ([dic objectForKey:@"msg"]) {
//                    [self showHint:[dic objectForKey:@"msg"]];
//                }
                [self.selectedImageDatasArr removeAllObjects];
                [self pingjiaAction:nil];
            }
        }else{
            [self showHint:@"请检查您的网络！"];
        }
    }];
    
}


- (void)setleftBarItem{
    
    _backBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
    [_backBtn setImageEdgeInsets:UIEdgeInsetsMake(0, -25, 0, 25)];
    [_backBtn setImage:[UIImage imageNamed:@"wode_photo_gerenshezhi_fanhui"] forState:UIControlStateNormal];
    [_backBtn setAdjustsImageWhenHighlighted:NO];
    [_backBtn addTarget:self action:@selector(popAction) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_backBtn];
    self.navigationItem.backBarButtonItem = backBarButtonItem;
    self.navigationItem.leftBarButtonItem = backBarButtonItem;
    
}

- (void)popAction{
    NSLog(@"11111");
    if (!_hasPingjia) {
        DeleteOrderView *delete = [[[NSBundle mainBundle] loadNibNamed:@"DeleteOrderView" owner:self options:nil] lastObject];
        delete.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
        delete.tishiLabel.text = @"您的评价还没完成，确定离开此页面吗？";
        [delete.leftBtn setTitle:@"确定" forState:UIControlStateNormal];
        [delete.rightBtn setTitle:@"取消" forState:UIControlStateNormal];
        __weak typeof(self)weakself = self;
        __weak typeof(delete)weakdelete = delete;
        delete.leftBlock = ^{
            [weakdelete dismiss];
            [weakself.navigationController popViewControllerAnimated:YES];
        };
        delete.rightBlock = ^{
            [weakdelete dismiss];
        };
        [delete show];
    }
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
            
            self.countLabel.text = [NSString stringWithFormat:@"%d/%ld",0,(long)MAX_LIMIT_NUMS];
            
        }
        return NO;
    }
}

#pragma mark -显示当前可输入字数/总字数
- (void)textViewDidChange:(UITextView *)textView{
    
    if ([textView.text length] == 0) {
        [self.placeHolderLabel setHidden:NO];
    }else{
        [self.placeHolderLabel setHidden:YES];
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
    self.countLabel.text = [NSString stringWithFormat:@"%ld/%d",MAX(0,MAX_LIMIT_NUMS - existTextNum),MAX_LIMIT_NUMS];
}


- (void)setBtnLayer{
    [self.miaoshu1 setAdjustsImageWhenHighlighted:NO];
    [self.miaoshu2 setAdjustsImageWhenHighlighted:NO];
    [self.miaoshu3 setAdjustsImageWhenHighlighted:NO];
    [self.miaoshu4 setAdjustsImageWhenHighlighted:NO];
    [self.miaoshu5 setAdjustsImageWhenHighlighted:NO];
    
    [self.wuliu1 setAdjustsImageWhenHighlighted:NO];
    [self.wuliu2 setAdjustsImageWhenHighlighted:NO];
    [self.wuliu3 setAdjustsImageWhenHighlighted:NO];
    [self.wuliu4 setAdjustsImageWhenHighlighted:NO];
    [self.wuliu5 setAdjustsImageWhenHighlighted:NO];
    
    [self.fuwu1 setAdjustsImageWhenHighlighted:NO];
    [self.fuwu2 setAdjustsImageWhenHighlighted:NO];
    [self.fuwu3 setAdjustsImageWhenHighlighted:NO];
    [self.fuwu4 setAdjustsImageWhenHighlighted:NO];
    [self.fuwu5 setAdjustsImageWhenHighlighted:NO];
    
    [self.updateBtn setAdjustsImageWhenHighlighted:NO];
    
    self.pingjiaTV.delegate = self;
}

- (NSMutableArray *)selectedImagesArr{
    if (!_selectedImagesArr) {
        _selectedImagesArr = [NSMutableArray arrayWithCapacity:0];
    }
    return _selectedImagesArr;
}

- (NSMutableArray *)selectedImageDatasArr{
    if (!_selectedImageDatasArr) {
        _selectedImageDatasArr = [NSMutableArray arrayWithCapacity:0];
    }
    return _selectedImageDatasArr;
}

- (NSMutableArray *)selectedImageModelsArr{
    if (!_selectedImageModelsArr) {
        _selectedImageModelsArr = [NSMutableArray arrayWithCapacity:0];
    }
    return _selectedImageModelsArr;
}

@end
