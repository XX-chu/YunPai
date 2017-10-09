//
//  SYForgetPasswordViewController.m
//  ShuoYing
//
//  Created by 硕影 on 2017/1/5.
//  Copyright © 2017年 硕影. All rights reserved.
//

#import "SYForgetPasswordViewController.h"

@interface SYForgetPasswordViewController ()
{
    NSTimer *_timer;
    float _countDown;
    
    NSString *_phoneNum;
    
    NSString *_lastImageViewStr;
    NSString *_currentPicCode;
}
@property (weak, nonatomic) IBOutlet UITextField *phoneTF;
@property (weak, nonatomic) IBOutlet UITextField *vertificationTF;
@property (weak, nonatomic) IBOutlet UITextField *passwordTF;
@property (weak, nonatomic) IBOutlet UITextField *ageinPasswordTF;
@property (weak, nonatomic) IBOutlet UIButton *getVertificationBtn;
@property (weak, nonatomic) IBOutlet UIButton *commitBtn;
@property (weak, nonatomic) IBOutlet UITextField *pictureCodeTF;
@property (weak, nonatomic) IBOutlet UIImageView *pictureCodeImageView;
@property (nonatomic, strong) NSMutableArray *codeArr;

@end

@implementation SYForgetPasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"找回密码";
    _countDown = 60;

    [self setViewsLayer];
}

- (IBAction)getVertificationAction:(UIButton *)sender {
    [self.view endEditing:YES];
    //先判断手机号
    BOOL isMobile = [[Tool sharedInstance] isMobile:self.phoneTF.text];
    if (!isMobile) {
        [self showHint:@"请确认您输入的手机号正确"];
        return;
    }
    
    if (self.pictureCodeTF.text.length == 0 || ![self.pictureCodeTF.text isEqualToString:_currentPicCode]) {
        [self showHint:@"请确认您输入的图片验证码正确"];
        return;
    }
    
    _phoneNum = self.phoneTF.text;
    sender.enabled = NO;
    
    
    //获取验证码
    [self getVertificationCode];
}

- (void)onTimer{
    if (_countDown > 0) {
        [self.getVertificationBtn setTitle:[NSString stringWithFormat:@"%ld秒重新获取", (long)_countDown] forState:UIControlStateNormal];
        _countDown--;
    }else{
        _countDown = 60;
        [_timer invalidate];
        _timer = nil;
        [self.getVertificationBtn setTitle:@"获取验证码" forState:UIControlStateNormal];
        self.getVertificationBtn.enabled = YES;
        
    }
}

#pragma mark - NetworkRequest
- (void)getVertificationCode{
    
    NSString *url = [NSString stringWithFormat:@"%@%@",BaseUrl,@"/logon/code.html"];
    NSDictionary *param = @{@"mobile":self.phoneTF.text, @"source":@"app", @"imgcode":@"app"};
    [[SYHttpRequest sharedInstance] getDataWithUrl:url Parameter:param ResponseObject:^(NSDictionary *responseResult) {
        NSLog(@"获取验证码 -- %@",responseResult);
        if ([responseResult objectForKey:@"resError"]) {
            self.getVertificationBtn.enabled = YES;
            [self showHint:@"服务器不给力，请稍后重试"];
        }else{
            if ([[responseResult objectForKey:@"result"] integerValue] == 1) {
                _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(onTimer) userInfo:nil repeats:YES];
            }else{
                if ([responseResult objectForKey:@"msg"] && ![[responseResult objectForKey:@"msg"] isKindOfClass:[NSNull class]]) {
                    self.getVertificationBtn.enabled = YES;
                    [self showHint:[responseResult objectForKey:@"msg"]];
                }
            }
        }
    }];
}

- (IBAction)commitAction:(UIButton *)sender {
    //判断新密码长度
    if (self.passwordTF.text.length == 0) {
        [self showHint:@"请输入密码" Offset:-kScreenHeight/2 + 80];
        return;
    }
    if (self.passwordTF.text.length < 6 || self.passwordTF.text.length > 16) {
        [self showHint:@"密码长度为6-16位" Offset:-kScreenHeight/2 + 80];
        return;
    }
    
    if (![self.passwordTF.text isEqualToString:self.ageinPasswordTF.text]) {
        [self showHint:@"请确认您两次输入的密码一致" Offset:-kScreenHeight/2 + 80];
        return;
    }
    
    if (![_phoneNum isEqualToString:self.phoneTF.text]) {
        [self showHint:@"您的手机号与获取验证码的手机号不一致，请重新输入！"];
        return;
    }
    
    if (self.pictureCodeTF.text.length == 0 || ![self.pictureCodeTF.text isEqualToString:_currentPicCode]) {
        [self showHint:@"请输入您的图片验证码"];
        return;
    }
    
    [self changePicture:nil];
    
    NSString *url = [NSString stringWithFormat:@"%@%@",BaseUrl,@"/logon/setpass.html"];
    NSDictionary *param = @{@"mobile":self.phoneTF.text, @"code":self.vertificationTF.text, @"pass":self.passwordTF.text};
    [[SYHttpRequest sharedInstance] getDataWithUrl:url Parameter:param ResponseObject:^(NSDictionary *responseResult) {
        NSLog(@"忘记密码 -- %@",responseResult);
        if ([responseResult objectForKey:@"resError"]) {
            [self showHint:@"服务器不给力，请稍后重试"];
        }else{
            if ([[responseResult objectForKey:@"result"] integerValue] == 1) {
                if ([responseResult objectForKey:@"msg"]) {
                    [self showHint:@"密码重置成功！"];
                    [self.navigationController popViewControllerAnimated:YES];
                }
            }else{
                if ([responseResult objectForKey:@"msg"] && ![[responseResult objectForKey:@"msg"] isKindOfClass:[NSNull class]]) {
                    [self showHint:[responseResult objectForKey:@"msg"]];
                }
            }
        }
    }];
}

//获取图片验证码
- (void)changePicture:(UITapGestureRecognizer *)tap{
    NSString *code = [self creatPictureCode];
    NSLog(@"code - %@",code);
    UIImage *image = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:_lastImageViewStr];
    if (image) {
        [self.pictureCodeImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@?str=%@",BaseUrl,@"/logon/imgcode.html",code]] placeholderImage:image];
    }else{
        [self.pictureCodeImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@?str=%@",BaseUrl,@"/logon/imgcode.html",code]] placeholderImage:[UIImage imageNamed:@"yanzhengma_refresh"]];
    }
    
    _lastImageViewStr = [NSString stringWithFormat:@"%@%@?str=%@",BaseUrl,@"/logon/imgcode.html",code];
}

- (NSString *)creatPictureCode{
    NSString *code = @"";
    for (int i = 0; i < 4; i++) {
        NSString *b = self.codeArr[arc4random() % 10];
        NSLog(@"b - %@",b);
        code = [code stringByAppendingString:b];
        NSLog(@"code - %@",code);
    }
    _currentPicCode = code;
    return code;
}

- (void)setViewsLayer{
    [self.getVertificationBtn setTitle:@"获取验证码" forState:UIControlStateNormal];
    [self.getVertificationBtn setTitleColor:NavigationColor forState:UIControlStateNormal];
    self.getVertificationBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    self.getVertificationBtn.layer.cornerRadius = 5;
    self.getVertificationBtn.layer.masksToBounds = YES;
    self.getVertificationBtn.layer.borderWidth = 1;
    self.getVertificationBtn.layer.borderColor = NavigationColor.CGColor;
    
    [self.commitBtn setTitle:@"完成" forState:UIControlStateNormal];
    [self.commitBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.commitBtn setAdjustsImageWhenHighlighted:NO];
    self.commitBtn.layer.cornerRadius = 5;
    self.commitBtn.layer.masksToBounds = YES;
    [self.commitBtn setBackgroundImage:[UIImage imageWithColor:NavigationColor Size:self.commitBtn.frame.size] forState:UIControlStateNormal];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(changePicture:)];
    self.pictureCodeImageView.userInteractionEnabled = YES;
    [self.pictureCodeImageView addGestureRecognizer:tap];
    [self changePicture:nil];
    
}

- (NSMutableArray *)codeArr{
    if (!_codeArr) {
        NSArray *arr = @[@"0", @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"a", @"b", @"c", @"d", @"e", @"f", @"g", @"h", @"i", @"j", @"k", @"l", @"m", @"n", @"o", @"p", @"q", @"r", @"s", @"t", @"u", @"v", @"w", @"x", @"y", @"z"];
        _codeArr = [NSMutableArray arrayWithArray:arr];
    }
    return _codeArr;
}

@end
