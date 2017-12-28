//
//  SYIDViewController.m
//  ShuoYing
//
//  Created by 硕影 on 2017/1/5.
//  Copyright © 2017年 硕影. All rights reserved.
//

#import "SYIDViewController.h"

#import "SYUserInfos.h"

#import "SYTeacherCertifiedViewController.h"
#import "SYGrapherCertifiedViewController.h"

@interface SYIDViewController ()
{
    NSTimer *_timer;
    float _countDown;
    SYUserInfos *_userInfos;
    
    NSString *_lastImageViewStr;
    NSString *_currentPicCode;
    
    UIView *_backView;
    UIImageView *_animationIMG;
    
//    NSTimer *_imgTimer;
    NSInteger _imgIndex;
    BOOL _isEndAnimation;
}
@property (weak, nonatomic) IBOutlet UIView *firstView;
@property (weak, nonatomic) IBOutlet UIView *secondView;
@property (weak, nonatomic) IBOutlet UIView *thirdView;
@property (weak, nonatomic) IBOutlet UIView *fourthView;
@property (weak, nonatomic) IBOutlet UIView *pictureCodeView;

@property (weak, nonatomic) IBOutlet UITextField *nameTF;
@property (weak, nonatomic) IBOutlet UITextField *IDTF;
@property (weak, nonatomic) IBOutlet UITextField *phoneTF;
@property (weak, nonatomic) IBOutlet UITextField *vertificationTF;
@property (weak, nonatomic) IBOutlet UIButton *vertificationBtn;
@property (weak, nonatomic) IBOutlet UIButton *commitBtn;
@property (weak, nonatomic) IBOutlet UITextField *pictureCodeTF;
@property (weak, nonatomic) IBOutlet UIImageView *pictureCodeImageView;
@property (nonatomic, strong) NSMutableArray *codeArr;
@end

@implementation SYIDViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"绑定身份证";
    _isEndAnimation = NO;
    _countDown = 60;
    if ([[Tool sharedInstance] getObjectWithPath:Mobile]) {
        _userInfos = [[Tool sharedInstance] getObjectWithPath:Mobile];
        self.phoneTF.text = _userInfos.user;
    }
    self.phoneTF.enabled = NO;
    [self setViewsLayer];
}



- (IBAction)vertificationAction:(UIButton *)sender {
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
    sender.enabled = NO;
    
    
    //获取验证码
    [self getVertificationCode];
}

- (IBAction)commitAction:(UIButton *)sender {
    
    if (self.nameTF.text.length == 0 || self.phoneTF.text.length == 0 || self.IDTF.text.length == 0 || self.vertificationTF.text.length == 0) {
        [self showHint:@"请填写您的完整信息"];
        return;
    }
    if (self.pictureCodeTF.text.length == 0 || ![self.pictureCodeTF.text isEqualToString:_currentPicCode]) {
        [self showHint:@"请输入您的图片验证码"];
        return;
    }
    
    [self changePicture:nil];
    
    NSString *url = [NSString stringWithFormat:@"%@%@",BaseUrl,@"/user/setidcard.html"];
    NSDictionary *param = @{@"token":UserToken, @"name":self.nameTF.text, @"mobile":self.phoneTF.text, @"idcard":self.IDTF.text, @"code":self.vertificationTF.text};
    [SVProgressHUD show];
    [[SYHttpRequest sharedInstance] getDataWithUrl:url Parameter:param ResponseObject:^(NSDictionary *responseResult) {
        NSLog(@"绑定身份证 -- %@",responseResult);
        [SVProgressHUD dismiss];
        if ([responseResult objectForKey:@"resError"]) {
            [self showHint:@"服务器不给力，请稍后重试"];
        }else{
            if ([[responseResult objectForKey:@"result"] integerValue] == 1) {
                if (self.state == isFromGrapher || self.state == isFromGroup) {
                    
                    SYGrapherCertifiedViewController *grapher = [[SYGrapherCertifiedViewController alloc] initWithNibName:@"SYGrapherCertifiedViewController" bundle:nil];
                    [self.navigationController pushViewController:grapher animated:YES];
                }else if (self.state == isFromTeacher){
                    
                    SYTeacherCertifiedViewController *certifi = [[SYTeacherCertifiedViewController alloc] initWithNibName:@"SYTeacherCertifiedViewController" bundle:nil];
                    [self.navigationController pushViewController:certifi animated:YES];
                    
                }else if (self.state == isFromYunPaiShi){
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

- (void)onTimer{
    if (_countDown > 0) {
        [self.vertificationBtn setTitle:[NSString stringWithFormat:@"%ld秒重新获取", (long)_countDown] forState:UIControlStateNormal];
        _countDown--;
    }else{
        _countDown = 60;
        [_timer invalidate];
        _timer = nil;
        [self.vertificationBtn setTitle:@"获取验证码" forState:UIControlStateNormal];
        self.vertificationBtn.enabled = YES;
        
    }
}

#pragma mark - NetworkRequest
- (void)getVertificationCode{
    [self.view endEditing:YES];
    NSString *url = [NSString stringWithFormat:@"%@%@",BaseUrl,@"/logon/code.html"];
    NSDictionary *param = @{@"mobile":self.phoneTF.text, @"source":@"app", @"imgcode":@"app"};
    [[SYHttpRequest sharedInstance] getDataWithUrl:url Parameter:param ResponseObject:^(NSDictionary *responseResult) {
        NSLog(@"获取验证码 -- %@",responseResult);
        if ([responseResult objectForKey:@"resError"]) {
            self.vertificationBtn.enabled = YES;
            [self showHint:@"服务器不给力，请稍后重试"];
        }else{
            if ([[responseResult objectForKey:@"result"] integerValue] == 1) {
                _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(onTimer) userInfo:nil repeats:YES];
            }else{
                if ([responseResult objectForKey:@"msg"] && ![[responseResult objectForKey:@"msg"] isKindOfClass:[NSNull class]]) {
                    self.vertificationBtn.enabled = YES;
                    [self showHint:[responseResult objectForKey:@"msg"]];
                }
            }
        }
    }];
}

- (void)setViewsLayer{
    self.firstView.backgroundColor = BackGroundColor;
    self.firstView.layer.cornerRadius = 5;
    self.firstView.layer.masksToBounds = YES;
    self.firstView.layer.borderWidth = 1;
    self.firstView.layer.borderColor = RGB(226, 226, 226).CGColor;
    
    self.secondView.backgroundColor = BackGroundColor;
    self.secondView.layer.cornerRadius = 5;
    self.secondView.layer.masksToBounds = YES;
    self.secondView.layer.borderWidth = 1;
    self.secondView.layer.borderColor = RGB(226, 226, 226).CGColor;
    
    self.thirdView.backgroundColor = BackGroundColor;
    self.thirdView.layer.cornerRadius = 5;
    self.thirdView.layer.masksToBounds = YES;
    self.thirdView.layer.borderWidth = 1;
    self.thirdView.layer.borderColor = RGB(226, 226, 226).CGColor;
    
    self.fourthView.backgroundColor = BackGroundColor;
    self.fourthView.layer.cornerRadius = 5;
    self.fourthView.layer.masksToBounds = YES;
    self.fourthView.layer.borderWidth = 1;
    self.fourthView.layer.borderColor = RGB(226, 226, 226).CGColor;
    
    [self.vertificationBtn setTitle:@"获取验证码" forState:UIControlStateNormal];
    [self.vertificationBtn setTitleColor:NavigationColor forState:UIControlStateNormal];
    self.vertificationBtn.layer.cornerRadius = 5;
    self.vertificationBtn.layer.masksToBounds = YES;
    self.vertificationBtn.layer.borderWidth = 1;
    self.vertificationBtn.layer.borderColor = NavigationColor.CGColor;
    
    [self.commitBtn setTitle:@"确定" forState:UIControlStateNormal];
    [self.commitBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.commitBtn setBackgroundImage:[UIImage imageWithColor:NavigationColor Size:self.commitBtn.frame.size] forState:UIControlStateNormal];
    self.commitBtn.layer.cornerRadius = 5;
    self.commitBtn.layer.masksToBounds = YES;
    [self.commitBtn setAdjustsImageWhenHighlighted:NO];
    
    self.pictureCodeView.backgroundColor = BackGroundColor;
    self.pictureCodeView.layer.cornerRadius = 5;
    self.pictureCodeView.layer.masksToBounds = YES;
    self.pictureCodeView.layer.borderWidth = 1;
    self.pictureCodeView.layer.borderColor = RGB(226, 226, 226).CGColor;
    
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
