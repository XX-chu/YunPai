//
//  SYLiJiYuYueViewController.m
//  ShuoYing
//
//  Created by chu on 2017/11/15.
//  Copyright © 2017年 硕影. All rights reserved.
//

#import "SYLiJiYuYueViewController.h"
#import "DateTimePickerView.h"
#import "SYYunPaiOrderInfosViewController.h"
@interface SYLiJiYuYueViewController ()<UITextViewDelegate, DateTimePickerViewDelegate>
@property (weak, nonatomic) IBOutlet UITextField *addressTF;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UITextView *zhutiTV;
@property (weak, nonatomic) IBOutlet UITextField *nameTF;
@property (weak, nonatomic) IBOutlet UITextField *phoneTF;
@property (weak, nonatomic) IBOutlet UIButton *yuyueBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UILabel *placeHoledLabel;
@property (weak, nonatomic) IBOutlet UILabel *countLabel;

@end

#define MAX_LIMIT_NUMS 60

@implementation SYLiJiYuYueViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"预约摄影";
    self.yuyueBtn.layer.cornerRadius = 5;
    self.yuyueBtn.layer.masksToBounds = YES;
    self.contentViewHeightConstraint.constant = kScreenHeight;
    self.zhutiTV.delegate = self;
}

- (IBAction)selecteTImeAction:(UIButton *)sender {
    [self.view endEditing:YES];
    DateTimePickerView *pickerView = [[DateTimePickerView alloc] init];
    pickerView.delegate = self;
    pickerView.pickerViewMode = DatePickerViewDateTimeMode;
    [self.view addSubview:pickerView];
    [pickerView showDateTimePickerView];
}

- (void)didClickFinishDateTimePickerView:(NSString *)date{
    NSLog(@"date - %@",date);
    self.timeLabel.text = date;
}

- (IBAction)yuyueAction:(UIButton *)sender {
    [self.view endEditing:YES];
    if (self.addressTF.text.length == 0) {
        [self showHint:@"请输入您的详细拍摄地址"];
        return;
    }
    if (self.timeLabel.text.length == 0) {
        [self showHint:@"请选择您的拍摄时间"];
        return;
    }
    if (self.zhutiTV.text.length == 0) {
        [self showHint:@"请输入您的拍摄主题"];
        return;
    }
    if (self.nameTF.text.length == 0) {
        [self showHint:@"请输入您的姓名"];
        return;
    }
    if (self.phoneTF.text.length == 0) {
        [self showHint:@"请输入您的电话"];
        return;
    }

    [SVProgressHUD show];
    NSString *url = [NSString stringWithFormat:@"%@%@",BaseUrl,@"/masters/addorder.html"];
    
    NSDictionary *param = @{@"token":UserToken, @"id":self.yuyueID, @"link":self.nameTF.text, @"tel":self.phoneTF.text, @"address":self.addressTF.text, @"theme":self.zhutiTV.text, @"time":self.timeLabel.text};
    
    [[SYHttpRequest sharedInstance] getDataWithUrl:url Parameter:param ResponseObject:^(NSDictionary *responseResult) {
        NSLog(@"预约云拍师 -- %@",responseResult);
        [SVProgressHUD dismiss];
        if ([responseResult objectForKey:@"resError"]) {
            [self showHint:@"服务器不给力，请稍后重试"];
        }else{
            if ([[responseResult objectForKey:@"result"] integerValue] == 1) {
                SYYunPaiOrderInfosViewController *order = [[SYYunPaiOrderInfosViewController alloc] init];
                order.orderID = [responseResult objectForKey:@"order"];
                order.dataSourceArr = @[[NSString stringWithFormat:@"摄影师：%@",self.sheyingshiName],
                                        [NSString stringWithFormat:@"摄影师电话：%@",self.sheyingshiPhone],
                                        [NSString stringWithFormat:@"拍摄地址：%@",self.addressTF.text],
                                        [NSString stringWithFormat:@"拍摄时间：%@",self.timeLabel.text],
                                        [NSString stringWithFormat:@"拍摄主题：%@",self.zhutiTV.text],
                                        [NSString stringWithFormat:@"联系人姓名：%@",self.nameTF.text],
                                        [NSString stringWithFormat:@"联系人电话：%@",self.phoneTF.text],
                                        ];
                [self.navigationController pushViewController:order animated:YES];
            }else{
                if ([responseResult objectForKey:@"msg"] && ![[responseResult objectForKey:@"msg"] isKindOfClass:[NSNull class]]) {
                    [self showHint:[responseResult objectForKey:@"msg"]];
                }
            }
        }
    }];
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
        [self.placeHoledLabel setHidden:NO];
    }else{
        [self.placeHoledLabel setHidden:YES];
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

@end
