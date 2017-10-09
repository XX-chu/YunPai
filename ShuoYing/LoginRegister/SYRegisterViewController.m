//
//  SYRegisterViewController.m
//  ShuoYing
//
//  Created by 硕影 on 2016/12/28.
//  Copyright © 2016年 硕影. All rights reserved.
//

#import "SYRegisterViewController.h"
#import "SYXieYiViewController.h"

@interface SYRegisterViewController ()
{
    NSInteger _countDown;
    NSTimer *_timer;
    NSURLSessionTask *_dataTask;
    
    UIView *_backView;
    UIImageView *_animationIMG;
    
    NSTimer *_imgTimer;
    NSInteger _imgIndex;
    BOOL _isEndAnimation;
    
    NSString *_phoneNum;
    
    UIButton *_selecteSexBtn;
    
    NSString *_lastImageViewStr;
    NSString *_currentPicCode;
}
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentViewHeightCnstraint;

@property (weak, nonatomic) IBOutlet UIView *phoneView;
@property (weak, nonatomic) IBOutlet UITextField *phoneTextField;

@property (weak, nonatomic) IBOutlet UIView *passwordView;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;

@property (weak, nonatomic) IBOutlet UIView *sexView;
@property (weak, nonatomic) IBOutlet UIButton *manButton;
@property (weak, nonatomic) IBOutlet UIButton *womanButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sexViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sexViewBottomConstraint;

@property (weak, nonatomic) IBOutlet UIView *ageinPasswordView;
@property (weak, nonatomic) IBOutlet UITextField *ageinPasswordTF;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *ageinPasswordViewBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *ageinPasswordViewHeightConstraint;

@property (weak, nonatomic) IBOutlet UIView *pictureCodeView;
@property (weak, nonatomic) IBOutlet UITextField *pictureCodeTF;
@property (weak, nonatomic) IBOutlet UIImageView *pictureCodeImageView;

@property (weak, nonatomic) IBOutlet UIView *vertificationCodeView;
@property (weak, nonatomic) IBOutlet UITextField *vertificationCodeTextField;
@property (weak, nonatomic) IBOutlet UIButton *getVertificationCodeBtn;
@property (weak, nonatomic) IBOutlet UIButton *registerBtn;
@property (weak, nonatomic) IBOutlet UIButton *agreeBtn;
@property (weak, nonatomic) IBOutlet UIButton *userAgreementBtn;

@property (nonatomic, strong) NSMutableArray *codeArr;

@end

@implementation SYRegisterViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
    
    self.title = @"注册";
    
    _countDown = 60;
    _isEndAnimation = NO;
    self.agreeBtn.selected = YES;
    self.contentViewHeightCnstraint.constant = kScreenHeight - 64;
}

- (void)loadView{
    [super loadView];
    _selecteSexBtn = self.manButton;
    [self.manButton setAdjustsImageWhenHighlighted:NO];
    [self.womanButton setAdjustsImageWhenHighlighted:NO];
    
    self.phoneView.layer.cornerRadius = 5;
    self.phoneView.layer.masksToBounds = YES;
    self.phoneView.layer.borderWidth = 1;
    self.phoneView.layer.borderColor = RGB(231, 231, 231).CGColor;
    
    self.passwordView.layer.cornerRadius = 5;
    self.passwordView.layer.masksToBounds = YES;
    self.passwordView.layer.borderWidth = 1;
    self.passwordView.layer.borderColor = RGB(231, 231, 231).CGColor;
    
    self.ageinPasswordView.layer.cornerRadius = 5;
    self.ageinPasswordView.layer.masksToBounds = YES;
    self.ageinPasswordView.layer.borderWidth = 1;
    self.ageinPasswordView.layer.borderColor = RGB(231, 231, 231).CGColor;
    self.ageinPasswordView.userInteractionEnabled = YES;

    
    self.vertificationCodeView.layer.cornerRadius = 5;
    self.vertificationCodeView.layer.masksToBounds = YES;
    self.vertificationCodeView.layer.borderWidth = 1;
    self.vertificationCodeView.layer.borderColor = RGB(231, 231, 231).CGColor;
    
    self.pictureCodeView.layer.cornerRadius = 5;
    self.pictureCodeView.layer.masksToBounds = YES;
    self.pictureCodeView.layer.borderWidth = 1;
    self.pictureCodeView.layer.borderColor = RGB(231, 231, 231).CGColor;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(changePicture:)];
    self.pictureCodeImageView.userInteractionEnabled = YES;
    [self.pictureCodeImageView addGestureRecognizer:tap];
    [self changePicture:nil];
    
    self.sexView.layer.cornerRadius = 5;
    self.sexView.layer.masksToBounds = YES;
    self.sexView.layer.borderWidth = 1;
    self.sexView.layer.borderColor = RGB(231, 231, 231).CGColor;
    self.sexViewBottomConstraint.constant = 0;
    self.sexViewHeightConstraint.constant = 0;
    
    self.getVertificationCodeBtn.layer.cornerRadius = 5;
    self.getVertificationCodeBtn.layer.masksToBounds = YES;
    self.getVertificationCodeBtn.layer.borderWidth = 1;
    self.getVertificationCodeBtn.layer.borderColor = NavigationColor.CGColor;
    [self.getVertificationCodeBtn setTitleColor:NavigationColor forState:UIControlStateNormal];
    [self.getVertificationCodeBtn addTarget:self action:@selector(countDownAction:) forControlEvents:UIControlEventTouchUpInside];
    
    self.registerBtn.layer.cornerRadius = 5;
    self.registerBtn.layer.masksToBounds = YES;
    [self.registerBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.registerBtn setBackgroundImage:[UIImage imageWithColor:NavigationColor Size:self.registerBtn.frame.size] forState:UIControlStateNormal];
    [self.registerBtn setBackgroundImage:[UIImage imageWithColor:[UIColor lightGrayColor] Size:self.registerBtn.frame.size] forState:UIControlStateDisabled];
    
    
    [self.registerBtn setAdjustsImageWhenHighlighted:NO];
    [self.registerBtn addTarget:self action:@selector(registeAction:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.userAgreementBtn setTitleColor:NavigationColor forState:UIControlStateNormal];
    [self.userAgreementBtn addTarget:self action:@selector(yonghuxieyiAction:) forControlEvents:UIControlEventTouchUpInside];
}
- (IBAction)agreeAction:(UIButton *)sender {
    sender.selected = !sender.selected;
    
    if (sender.selected == YES) {
        [self.agreeBtn setImage:[UIImage imageNamed:@"register_icon_xieyi"] forState:UIControlStateNormal];
        self.registerBtn.enabled = YES;
    }else{
        [self.agreeBtn setImage:[UIImage imageNamed:@"dizhi_icon_moren_nor"] forState:UIControlStateNormal];
        self.registerBtn.enabled = NO;
    }
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

- (IBAction)selecteSexAction:(UIButton *)sender {
    if (sender.tag == 111) {
        //男
        _selecteSexBtn = self.manButton;
        [self.manButton setImage:[UIImage imageNamed:@"jubao_anniu_sel"] forState:UIControlStateNormal];
        [self.womanButton setImage:[UIImage imageNamed:@"jubao_anniu_nor"] forState:UIControlStateNormal];
    }else if (sender.tag == 222){
        //女
        _selecteSexBtn = self.womanButton;
        [self.manButton setImage:[UIImage imageNamed:@"jubao_anniu_nor"] forState:UIControlStateNormal];
        [self.womanButton setImage:[UIImage imageNamed:@"jubao_anniu_sel"] forState:UIControlStateNormal];
    }
}

- (void)yonghuxieyiAction:(UIButton *)btn{
    SYXieYiViewController *xieyi = [[SYXieYiViewController alloc] init];
    [self.navigationController pushViewController:xieyi animated:YES];
}

#pragma mark - PrivateMethod
- (void)countDownAction:(UIButton *)sender{
    [self.view endEditing:YES];
    //先判断手机号
    BOOL isMobile = [[Tool sharedInstance] isMobile:self.phoneTextField.text];
    if (!isMobile) {
        [self showHint:@"请确认您输入的手机号正确"];
        return;
    }
    if (self.pictureCodeTF.text.length == 0 || ![self.pictureCodeTF.text isEqualToString:_currentPicCode]) {
        [self showHint:@"请确认您输入的图片验证码正确"];
        return;
    }

    _phoneNum = self.phoneTextField.text;
    sender.enabled = NO;
    
    
    //获取验证码
    [self getVertificationCode];
}

- (void)onTimer{
    if (_countDown > 0) {
        [self.getVertificationCodeBtn setTitle:[NSString stringWithFormat:@"%ld秒重新获取", (long)_countDown] forState:UIControlStateNormal];
        _countDown--;
    }else{
        _countDown = 60;
        [_timer invalidate];
        _timer = nil;
        [self.getVertificationCodeBtn setTitle:@"获取验证码" forState:UIControlStateNormal];
        self.getVertificationCodeBtn.enabled = YES;
        
    }
}

//注册按钮
- (void)registeAction:(UIButton *)sender{
    [self.view endEditing:YES];
    //去空格判断
    if ([self.phoneTextField.text stringByReplacingOccurrencesOfString:@" " withString:@""].length == 0) {
        [self showHint:@"请输入您的手机号"];
        return;
    }
    if ([self.passwordTextField.text stringByReplacingOccurrencesOfString:@" " withString:@""].length == 0) {
        [self showHint:@"请输入您的密码"];
        return;
    }

    if ([self.ageinPasswordTF.text stringByReplacingOccurrencesOfString:@" " withString:@""].length == 0) {
        [self showHint:@"请输入您的密码"];
        return;
    }
    
    if (![self.passwordTextField.text isEqualToString:self.ageinPasswordTF.text]) {
        [self showHint:@"您两次输入的密码不一致"];
        return;
    }
    
    if (self.pictureCodeTF.text.length == 0 || ![self.pictureCodeTF.text isEqualToString:_currentPicCode]) {
        [self showHint:@"请输入您的图片验证码"];
        return;
    }

    if ([self.vertificationCodeTextField.text stringByReplacingOccurrencesOfString:@" " withString:@""].length == 0) {
        [self showHint:@"请输入您的验证码"];
        return;
    }
    
    if (self.passwordTextField.text.length < 6 || self.passwordTextField.text.length > 16) {
        [self showHint:@"密码长度为6-16位"];
        return;
    }
    
    
    [self changePicture:nil];
    
    sender.enabled = NO;

    NSString *url = [NSString stringWithFormat:@"%@%@",BaseUrl,@"/logon/register.html"];
    NSDictionary *param = nil;
    param = @{@"mobile":self.phoneTextField.text, @"code":self.vertificationCodeTextField.text, @"pass":self.passwordTextField.text, @"sex":@"男"};
//    if (_selecteSexBtn.tag == 111) {
//        //男
//        param = @{@"mobile":self.phoneTextField.text, @"code":self.vertificationCodeTextField.text, @"pass":self.passwordTextField.text, @"sex":@"男"};
//    }else if (_selecteSexBtn.tag == 222){
//        //女
//        param = @{@"mobile":self.phoneTextField.text, @"code":self.vertificationCodeTextField.text, @"pass":self.passwordTextField.text, @"sex":@"女"};
//    }
    NSLog(@"param - %@",param);
    [[SYHttpRequest sharedInstance] getDataWithUrl:url Parameter:param ResponseObject:^(NSDictionary *responseResult) {
        sender.enabled = YES;
        
        NSLog(@"responseResult -- %@",responseResult);
        if ([responseResult objectForKey:@"resError"]) {
            [self showHint:@"服务器不给力，请稍后重试"];
        }else{
            if ([[responseResult objectForKey:@"result"] integerValue] == 1) {
                [self redBag];
            }else{
                if ([responseResult objectForKey:@"msg"]) {
                    [self showHint:[responseResult objectForKey:@"msg"]];
                }
            }
        }
    }];
}

//红包
- (void)redBag{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
    view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.6];
    view.userInteractionEnabled = YES;
    UITapGestureRecognizer *distap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(disMissView)];
    [view addGestureRecognizer:distap];
    _backView = view;
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    [window addSubview:view];
    
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 100, kScreenWidth - 40, kScreenHeight / 2 + 40)];
    _animationIMG = imageView;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageViewAnimation:)];
    [imageView addGestureRecognizer:tap];
    imageView.userInteractionEnabled = YES;
    imageView.image = [UIImage imageNamed:@"chai"];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    [view addSubview:imageView];
    
    
}

- (void)imageViewAnimation:(UITapGestureRecognizer *)tap{
    if (_isEndAnimation) {
        [self disMissView];

    }else{
        if (![_animationIMG isAnimating]) {
            _animationIMG.image = [UIImage imageNamed:@"yilingqu"];
            
            NSArray *imgArr = @[@"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"10", @"11", @"12", @"13", @"14", @"15"];
            NSMutableArray *images = [NSMutableArray arrayWithCapacity:0];
            for (int i = 0; i < 13; i++) {
                UIImage *image = [UIImage imageNamed:imgArr[i]];
                [images addObject:image];
            }
            _animationIMG.animationImages = images;
            _animationIMG.animationDuration = .6;
            _animationIMG.animationRepeatCount = 1;
            [_animationIMG startAnimating];
            _isEndAnimation = YES;
        }
    }
    
    
}



- (void)disMissView{
    if (![_animationIMG isAnimating]) {
        [UIView animateWithDuration:.3 animations:^{
            _backView.alpha = 0;
        } completion:^(BOOL finished) {
            [_backView removeFromSuperview];
            _backView = nil;
            [self.navigationController popViewControllerAnimated:YES];
        }];
    }
}

#pragma mark - NetworkRequest
- (void)getVertificationCode{
    self.getVertificationCodeBtn.enabled = NO;
    NSString *url = [NSString stringWithFormat:@"%@%@",BaseUrl,@"/logon/code.html"];
    NSDictionary *param = @{@"mobile":self.phoneTextField.text, @"source":@"app", @"imgcode":@"app"};
    [[SYHttpRequest sharedInstance] getDataWithUrl:url Parameter:param ResponseObject:^(NSDictionary *responseResult) {
        NSLog(@"获取验证码 -- %@",responseResult);
        if ([responseResult objectForKey:@"resError"]) {
            self.getVertificationCodeBtn.enabled = YES;
            [self showHint:@"服务器不给力，请稍后重试"];
        }else{
            if ([[responseResult objectForKey:@"result"] integerValue] == 1) {
                _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(onTimer) userInfo:nil repeats:YES];
            }else{
                if ([responseResult objectForKey:@"msg"] && ![[responseResult objectForKey:@"msg"] isKindOfClass:[NSNull class]]) {
                    self.getVertificationCodeBtn.enabled = YES;
                    [self showHint:[responseResult objectForKey:@"msg"]];
                }
            }
        }
    }];
}


#pragma mark - LayzLoad


- (NSMutableArray *)codeArr{
    if (!_codeArr) {
        NSArray *arr = @[@"0", @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"a", @"b", @"c", @"d", @"e", @"f", @"g", @"h", @"i", @"j", @"k", @"l", @"m", @"n", @"o", @"p", @"q", @"r", @"s", @"t", @"u", @"v", @"w", @"x", @"y", @"z"];
        _codeArr = [NSMutableArray arrayWithArray:arr];
    }
    return _codeArr;
}

@end
