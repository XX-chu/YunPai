//
//  SYChangePasswordViewController.m
//  ShuoYing
//
//  Created by 硕影 on 2017/1/5.
//  Copyright © 2017年 硕影. All rights reserved.
//

#import "SYChangePasswordViewController.h"

@interface SYChangePasswordViewController ()
@property (weak, nonatomic) IBOutlet UITextField *OldPasswordTF;
@property (weak, nonatomic) IBOutlet UITextField *NewPasswordTF;
@property (weak, nonatomic) IBOutlet UITextField *AeginPasswordTF;
@property (weak, nonatomic) IBOutlet UIButton *commitBtn;

@end

@implementation SYChangePasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"修改密码";
    [self.commitBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.commitBtn setTitle:@"确定" forState:UIControlStateNormal];
    [self.commitBtn setBackgroundImage:[UIImage imageWithColor:NavigationColor Size:self.commitBtn.frame.size] forState:UIControlStateNormal];
    self.commitBtn.layer.cornerRadius = 5;
    self.commitBtn.layer.masksToBounds = YES;
    [self.commitBtn setAdjustsImageWhenHighlighted:NO];
    
}

- (IBAction)commitAction:(UIButton *)sender {
    [self.view endEditing:YES];
    //判断新密码长度
    if (self.OldPasswordTF.text.length == 0) {
        [self showHint:@"请输入原密码"];
        return;
    }
    if (self.NewPasswordTF.text.length < 6 || self.NewPasswordTF.text.length > 16) {
        [self showHint:@"密码长度为6-16位"];
        return;
    }
    
    if (![self.NewPasswordTF.text isEqualToString:self.AeginPasswordTF.text]) {
        [self showHint:@"请确认您两次输入的密码一致"];
        return;
    }
    
    if ([self.NewPasswordTF.text isEqualToString:self.OldPasswordTF.text]) {
        [self showHint:@"您的新密码和旧密码不能相同"];
        return;
    }
    
    NSString *url = [NSString stringWithFormat:@"%@%@",BaseUrl,@"/user/setpass.html"];
    NSDictionary *param = @{@"token":UserToken, @"pass":self.OldPasswordTF.text, @"pass1":self.NewPasswordTF.text};
    [[SYHttpRequest sharedInstance] getDataWithUrl:url Parameter:param ResponseObject:^(NSDictionary *responseResult) {
        
        NSLog(@"修改个人密码 -- %@",responseResult);
        if ([responseResult objectForKey:@"resError"]) {
            [self showHint:@"服务器不给力，请稍后重试"];
        }else{
            if ([[responseResult objectForKey:@"result"] integerValue] == 1) {
                
                [self showHint:@"修改成功"];
                [self.navigationController popViewControllerAnimated:YES];
            }else{
                if ([responseResult objectForKey:@"msg"]) {
                    [self showHint:[responseResult objectForKey:@"msg"]];
                }
            }
        }
    }];

    
}


@end
