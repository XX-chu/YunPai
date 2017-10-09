//
//  SYChangePhoneViewController.m
//  ShuoYing
//
//  Created by 硕影 on 2017/1/4.
//  Copyright © 2017年 硕影. All rights reserved.
//

#import "SYChangePhoneViewController.h"

@interface SYChangePhoneViewController ()<UITextFieldDelegate>
{
    NSTimer *_timer;
    NSInteger _countDown;
    
    NSString *_phoneNum;
    
    NSString *_lastImageViewStr;
    NSString *_currentPicCode;
}
@property (weak, nonatomic) IBOutlet UIView *OldPhoneView;
@property (weak, nonatomic) IBOutlet UIView *NewPhoneVIew;
@property (weak, nonatomic) IBOutlet UIView *VertificationView;
@property (weak, nonatomic) IBOutlet UIView *PasswordView;


@property (weak, nonatomic) IBOutlet UITextField *oldPhoneTF;
@property (weak, nonatomic) IBOutlet UITextField *NewPhoneTF;


@property (weak, nonatomic) IBOutlet UITextField *vertificationTF;
@property (weak, nonatomic) IBOutlet UITextField *passwordTF;

@property (weak, nonatomic) IBOutlet UIButton *getVertificationBtn;
@property (weak, nonatomic) IBOutlet UIButton *commitBtn;

@property (weak, nonatomic) IBOutlet UIView *pictureCodeView;
@property (weak, nonatomic) IBOutlet UITextField *pictureCodeTF;
@property (weak, nonatomic) IBOutlet UIImageView *pictureCodeImageView;
@property (nonatomic, strong) NSMutableArray *codeArr;

@end

@implementation SYChangePhoneViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setViewLayer];
    self.title = @"更改手机";
    _countDown = 60;
}


- (IBAction)getVertificationAction:(UIButton *)sender {
    [self.view endEditing:YES];
    //先判断手机号
    BOOL isMobile = [[Tool sharedInstance] isMobile:self.NewPhoneTF.text];
    if (!isMobile) {
        [self showHint:@"请确认您输入的手机号正确"];
        return;
    }
    if (self.pictureCodeTF.text.length == 0 || ![self.pictureCodeTF.text isEqualToString:_currentPicCode]) {
        [self showHint:@"请确认您输入的图片验证码正确"];
        return;
    }
    _phoneNum = self.NewPhoneTF.text;
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

- (IBAction)commitAction:(UIButton *)sender {
    if (self.oldPhoneTF.text.length == 0 || self.NewPhoneTF.text.length == 0 || self.vertificationTF.text.length == 0 || self.passwordTF.text.length == 0) {
        [self showHint:@"请完善您的信息"];
        return;
    }
    
    if (![[Tool sharedInstance] isMobile:self.oldPhoneTF.text]) {
        [self showHint:@"您的原手机号格式不正确"];
        return;
    }
    
    if (![[Tool sharedInstance] isMobile:self.NewPhoneTF.text]) {
        [self showHint:@"您的新手机号格式不正确"];
        return;
    }
    
    if ([self.oldPhoneTF.text isEqualToString:self.NewPhoneTF.text]) {
        [self showHint:@"您的新手机号不能与原手机号相同"];
        return;
    }
    
    if (self.pictureCodeTF.text.length == 0 || ![self.pictureCodeTF.text isEqualToString:_currentPicCode]) {
        [self showHint:@"请输入您的图片验证码"];
        return;
    }
    
    [self changePicture:nil];
    
    NSString *url = [NSString stringWithFormat:@"%@%@",BaseUrl,@"/logon/setuser.html"];
    NSDictionary *param = @{@"tel":self.oldPhoneTF.text, @"mobile":self.NewPhoneTF.text, @"code":self.vertificationTF.text, @"pass":self.passwordTF.text};
    [[SYHttpRequest sharedInstance] getDataWithUrl:url Parameter:param ResponseObject:^(NSDictionary *responseResult) {
        NSLog(@"更换手机号 -- %@",responseResult);
        if ([responseResult objectForKey:@"resError"]) {
            [self showHint:@"服务器不给力，请稍后重试"];
        }else{
            if ([[responseResult objectForKey:@"result"] integerValue] == 1) {
                NSUserDefaults *us = [NSUserDefaults standardUserDefaults];
                [us setObject:self.NewPhoneTF.text forKey:@"mobile"];
                [us synchronize];
            }else{
                if ([responseResult objectForKey:@"msg"] && ![[responseResult objectForKey:@"msg"] isKindOfClass:[NSNull class]]) {
                    [self showHint:[responseResult objectForKey:@"msg"]];
                }
            }
        }
    }];

    
}

#pragma mark - NetworkRequest
- (void)getVertificationCode{
    
    NSString *url = [NSString stringWithFormat:@"%@%@",BaseUrl,@"/logon/code.html"];
    NSDictionary *param = @{@"mobile":self.NewPhoneTF.text, @"source":@"app", @"imgcode":@"app"};
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

- (void)setViewLayer{
    self.OldPhoneView.layer.cornerRadius = 5;
    self.OldPhoneView.layer.masksToBounds = YES;
    self.OldPhoneView.layer.borderWidth = 1;
    self.OldPhoneView.layer.borderColor = RGB(242, 242, 242).CGColor;
    self.OldPhoneView.backgroundColor = BackGroundColor;
    
    self.NewPhoneVIew.layer.cornerRadius = 5;
    self.NewPhoneVIew.layer.masksToBounds = YES;
    self.NewPhoneVIew.layer.borderWidth = 1;
    self.NewPhoneVIew.layer.borderColor = RGB(242, 242, 242).CGColor;
    self.NewPhoneVIew.backgroundColor = BackGroundColor;

    self.VertificationView.layer.cornerRadius = 5;
    self.VertificationView.layer.masksToBounds = YES;
    self.VertificationView.layer.borderWidth = 1;
    self.VertificationView.layer.borderColor = RGB(242, 242, 242).CGColor;
    self.VertificationView.backgroundColor = BackGroundColor;

    self.PasswordView.layer.cornerRadius = 5;
    self.PasswordView.layer.masksToBounds = YES;
    self.PasswordView.layer.borderWidth = 1;
    self.PasswordView.layer.borderColor = RGB(242, 242, 242).CGColor;
    self.PasswordView.backgroundColor = BackGroundColor;

    [self.getVertificationBtn setTitleColor:NavigationColor forState:UIControlStateNormal];
    self.getVertificationBtn.layer.cornerRadius = 5;
    self.getVertificationBtn.layer.masksToBounds = YES;
    self.getVertificationBtn.layer.borderWidth = 1;
    self.getVertificationBtn.layer.borderColor = NavigationColor.CGColor;
    
    [self.commitBtn setBackgroundImage:[UIImage imageWithColor:NavigationColor Size:self.commitBtn.frame.size] forState:UIControlStateNormal];
    [self.commitBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    self.commitBtn.layer.cornerRadius = 5;
    self.commitBtn.layer.masksToBounds = YES;
    [self.commitBtn setAdjustsImageWhenHighlighted:NO];
    
    self.oldPhoneTF.delegate = self;
    self.NewPhoneTF.delegate = self;
    
    self.pictureCodeView.layer.cornerRadius = 5;
    self.pictureCodeView.layer.masksToBounds = YES;
    self.pictureCodeView.layer.borderWidth = 1;
    self.pictureCodeView.layer.borderColor = RGB(242, 242, 242).CGColor;
    self.pictureCodeView.backgroundColor = BackGroundColor;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(changePicture:)];
    self.pictureCodeImageView.userInteractionEnabled = YES;
    [self.pictureCodeImageView addGestureRecognizer:tap];
    [self changePicture:nil];
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

- (NSMutableArray *)codeArr{
    if (!_codeArr) {
        NSArray *arr = @[@"0", @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"a", @"b", @"c", @"d", @"e", @"f", @"g", @"h", @"i", @"j", @"k", @"l", @"m", @"n", @"o", @"p", @"q", @"r", @"s", @"t", @"u", @"v", @"w", @"x", @"y", @"z"];
        _codeArr = [NSMutableArray arrayWithArray:arr];
    }
    return _codeArr;
}

@end
