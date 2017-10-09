//
//  SYPersonalNotViewController.m
//  ShuoYing
//
//  Created by 硕影 on 2017/1/4.
//  Copyright © 2017年 硕影. All rights reserved.
//

#import "SYPersonalNotViewController.h"
#import "SYUserInfos.h"

@interface SYPersonalNotViewController ()<UITextViewDelegate>

#define MAX_LIMIT_NUMS 100

@property (weak, nonatomic) IBOutlet UITextView *textView;

@property (weak, nonatomic) IBOutlet UILabel *placeHolderLabel;
@property (weak, nonatomic) IBOutlet UILabel *textNumLabel;

@end

@implementation SYPersonalNotViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"个人说明";
    self.textView.delegate = self;
    [self setRightBar];
}

- (void)setRightBar{
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [btn setTitle:@"确定" forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:15];
    [btn setTitleEdgeInsets:UIEdgeInsetsMake(0, 15, 0, -15)];
    [btn addTarget:self action:@selector(editNickAction:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *bar = [[UIBarButtonItem alloc] initWithCustomView:btn];
    
    self.navigationItem.rightBarButtonItem = bar;
}

- (void)editNickAction:(UIButton *)sender{
    
    if (self.textView.text.length == 0) {
        [self showHint:@"快来设置个人说明吧,不能超过100个字哦！"];
        return;
    }
    
    [self editPersonNot:self.textView.text];
}

- (void)editPersonNot:(NSString *)text{
    NSString *url = [NSString stringWithFormat:@"%@%@",BaseUrl,@"/user/setinfo.html"];
    NSDictionary *param = @{@"token":UserToken, @"info":text};
    [[SYHttpRequest sharedInstance] getDataWithUrl:url Parameter:param ResponseObject:^(NSDictionary *responseResult) {
        
        NSLog(@"修改个人说明 -- %@",responseResult);
        if ([responseResult objectForKey:@"resError"]) {
            [self showHint:@"服务器不给力，请稍后重试"];
        }else{
            if ([[responseResult objectForKey:@"result"] integerValue] == 1) {
                //修改存储在本地的信息
                self.userInfos.info = text;
                [[Tool sharedInstance] saveObject:self.userInfos WithPath:Mobile];
                [self.navigationController popViewControllerAnimated:YES];
            }else{
                if ([responseResult objectForKey:@"msg"]) {
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
            
            self.textNumLabel.text = [NSString stringWithFormat:@"%d/%ld",0,(long)MAX_LIMIT_NUMS];
            
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
    self.textNumLabel.text = [NSString stringWithFormat:@"%ld/%d",MAX(0,MAX_LIMIT_NUMS - existTextNum),MAX_LIMIT_NUMS];
    
}

@end
