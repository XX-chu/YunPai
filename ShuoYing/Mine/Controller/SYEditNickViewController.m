//
//  SYEditNickViewController.m
//  ShuoYing
//
//  Created by 硕影 on 2017/1/4.
//  Copyright © 2017年 硕影. All rights reserved.
//

#import "SYEditNickViewController.h"
#import "SYUserInfos.h"

@interface SYEditNickViewController ()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *nickTF;

@end

#define kMaxLength 8

@implementation SYEditNickViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"修改昵称";
    [self setRightBar];
    self.nickTF.delegate = self;
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textFiledEditChanged:)
                                               name:@"UITextFieldTextDidChangeNotification"
                                             object:self.nickTF];
}

-(void)textFiledEditChanged:(NSNotification*)obj{
    UITextField *textField = (UITextField *)obj.object;
    
    NSString *toBeString = textField.text;
    NSString *lang = [[UITextInputMode currentInputMode] primaryLanguage]; // 键盘输入模式
    if([lang isEqualToString:@"zh-Hans"]) { //简体中文输入，包括简体拼音，健体五笔，简体手写
        UITextRange *selectedRange = [textField markedTextRange];
        //获取高亮部分
        UITextPosition *position = [textField positionFromPosition:selectedRange.start offset:0];
        //没有高亮选择的字，则对已输入的文字进行字数统计和限制
        if(!position) {
            if(toBeString.length > kMaxLength) {
                textField.text = [toBeString substringToIndex:kMaxLength];
            }
        }
        //有高亮选择的字符串，则暂不对文字进行统计和限制
        else{
            
        }
    }
    //中文输入法以外的直接对其统计限制即可，不考虑其他语种情况
    else{
        if(toBeString.length > kMaxLength) {
            textField.text= [toBeString substringToIndex:kMaxLength];
        }
    }
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
    NSString *nick = self.nickTF.text;
    if (nick.length == 0) {
        return;
    }
    
    [self editSexWithnick:nick];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string;
{  //string就是此时输入的那个字符textField就是此时正在输入的那个输入框返回YES就是可以改变输入框的值NO相反
    
    if ([string isEqualToString:@"\n"])  //按会车可以改变
    {
        return YES;
    }
    
    NSString * toBeString = [textField.text stringByReplacingCharactersInRange:range withString:string]; //得到输入框的内容
    
    if (self.nickTF == textField)  //判断是否时我们想要限定的那个输入框
    {
        if ([toBeString length] > 8) { //如果输入框内容大于20则弹出警告
            textField.text = [toBeString substringToIndex:8];
            
            return NO;
        }
    }
    return YES;
}

- (void)editSexWithnick:(NSString *)nick{
    NSString *url = [NSString stringWithFormat:@"%@%@",BaseUrl,@"/user/setnick.html"];
    NSDictionary *param = @{@"token":UserToken, @"nick":nick};
    [[SYHttpRequest sharedInstance] getDataWithUrl:url Parameter:param ResponseObject:^(NSDictionary *responseResult) {
        
        NSLog(@"修改性别 -- %@",responseResult);
        if ([responseResult objectForKey:@"resError"]) {
            [self showHint:@"服务器不给力，请稍后重试"];
        }else{
            if ([[responseResult objectForKey:@"result"] integerValue] == 1) {
                //修改存储在本地的信息
                self.userInfos.nick = nick;
                [[Tool sharedInstance] saveObject:_userInfos WithPath:Mobile];
                [self.navigationController popViewControllerAnimated:YES];
            }else{
                if ([responseResult objectForKey:@"msg"]) {
                    [self showHint:[responseResult objectForKey:@"msg"]];
                }
            }
        }
    }];
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self
                                                  name:@"UITextFieldTextDidChangeNotification"
                                                object:self.nickTF];
}
@end
