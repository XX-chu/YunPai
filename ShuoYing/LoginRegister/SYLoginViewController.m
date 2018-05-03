//
//  SYLoginViewController.m
//  ShuoYing
//
//  Created by 硕影 on 2016/12/28.
//  Copyright © 2016年 硕影. All rights reserved.
//

#import "SYLoginViewController.h"
#import "SYRegisterViewController.h"
#import "SYUserInfos.h"

#import "SYForgetPasswordViewController.h"

@interface SYLoginViewController ()
{
    NSURLSessionTask *_dataTask;
    UIButton *_backBtn;
    
    UIView *_backView;
    UIImageView *_animationIMG;
    BOOL _isEndAnimation;

}
@property (weak, nonatomic) IBOutlet UIImageView *headImageView;
@property (weak, nonatomic) IBOutlet UIView *phoneView;
@property (weak, nonatomic) IBOutlet UITextField *phoneTextField;
@property (weak, nonatomic) IBOutlet UIView *passwordView;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *savePhoneBtn;
@property (weak, nonatomic) IBOutlet UIButton *forgetPassword;
@property (weak, nonatomic) IBOutlet UIButton *registerBtn;
@property (weak, nonatomic) IBOutlet UIButton *loginBtn;

@end

@implementation SYLoginViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    if([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    }
    [_dataTask cancel];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"登录";
    if([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"LastMobile"]) {
        self.phoneTextField.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"LastMobile"];
    }
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"isRememberPhone"]) {
        self.savePhoneBtn.selected = [[NSUserDefaults standardUserDefaults] boolForKey:@"isRememberPhone"];
        if ([[NSUserDefaults standardUserDefaults] objectForKey:@"LastTimeMobile"]) {
            self.passwordTextField.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"LastTimeMobile"];
        }
    }
    
    if (self.isFromLogout) {
        [self setrightBarItem];
    }
    
}

- (void)setrightBarItem{
    self.navigationItem.leftBarButtonItem = nil;
    _backBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
    [_backBtn setImageEdgeInsets:UIEdgeInsetsMake(0, -25, 0, 25)];
    [_backBtn setImage:[UIImage imageNamed:@"wode_photo_gerenshezhi_fanhui"] forState:UIControlStateNormal];
    [_backBtn setAdjustsImageWhenHighlighted:NO];
    [_backBtn addTarget:self action:@selector(popAction) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_backBtn];
    
    self.navigationItem.leftBarButtonItem = backBarButtonItem;
}

- (void)popAction{
    if ([self.navigationController.viewControllers[0] isKindOfClass:[UITabBarController class]]) {
        [(UITabBarController *)self.navigationController.viewControllers[0] setSelectedIndex:0];
    }
    
    [self.navigationController popToRootViewControllerAnimated:YES];
    
}

- (void)loadView{
    [super loadView];
    self.phoneView.layer.cornerRadius = 5;
    self.phoneView.layer.masksToBounds = YES;
    self.phoneView.layer.borderWidth = 1;
    self.phoneView.layer.borderColor = RGB(232, 232, 232).CGColor;

    
    self.passwordView.layer.cornerRadius = 5;
    self.passwordView.layer.masksToBounds = YES;
    self.passwordView.layer.borderWidth = 1;
    self.passwordView.layer.borderColor = RGB(232, 232, 232).CGColor;
    
    self.registerBtn.layer.cornerRadius = 5;
    self.registerBtn.layer.masksToBounds = YES;
    self.registerBtn.layer.borderWidth = 1;
    self.registerBtn.layer.borderColor = NavigationColor.CGColor;
    [self.registerBtn setTitleColor:NavigationColor forState:UIControlStateNormal];
    [self.registerBtn addTarget:self action:@selector(userRegist) forControlEvents:UIControlEventTouchUpInside];
    
    self.loginBtn.layer.cornerRadius = 5;
    self.loginBtn.layer.masksToBounds = YES;
    self.loginBtn.layer.borderWidth = 1;
    self.loginBtn.layer.borderColor = NavigationColor.CGColor;
//    [self.loginBtn setBackgroundImage:[UIImage imageWithColor:NavigationColor Size:self.loginBtn.frame.size] forState:UIControlStateNormal];
    [self.loginBtn setTitleColor:NavigationColor forState:UIControlStateNormal];
    [self.loginBtn setAdjustsImageWhenHighlighted:NO];
    [self.loginBtn addTarget:self action:@selector(loginAction) forControlEvents:UIControlEventTouchUpInside];
    
}

#pragma mark - privateMethod
- (void)userRegist{
    SYRegisterViewController *registe = [[SYRegisterViewController alloc] initWithNibName:@"SYRegisterViewController" bundle:nil];
    registe.sucessBlock = ^(NSString *phone, NSString *password) {
        self.phoneTextField.text = phone;
        self.passwordTextField.text = password;
        [self loginAction];
    };
    [self.navigationController pushViewController:registe animated:YES];
}


- (IBAction)remenberPhone:(UIButton *)sender {
    sender.selected = !sender.selected;
    BOOL isRememberPhone = sender.selected;
    NSUserDefaults *us = [NSUserDefaults standardUserDefaults];
    [us setBool:isRememberPhone forKey:@"isRememberPhone"];
    [us synchronize];
}
- (IBAction)forgetPassword:(UIButton *)sender {
    SYForgetPasswordViewController *forget = [[SYForgetPasswordViewController alloc] initWithNibName:@"SYForgetPasswordViewController" bundle:nil];
    [self.navigationController pushViewController:forget animated:YES];
}


- (void)loginAction{
    //去空格判断
    if ([self.phoneTextField.text stringByReplacingOccurrencesOfString:@" " withString:@""].length == 0) {
        [self showHint:@"请输入您的手机号"];
        return;
    }
    if ([self.passwordTextField.text stringByReplacingOccurrencesOfString:@" " withString:@""].length == 0) {
        [self showHint:@"请输入您的密码"];
        return;
    }
    self.loginBtn.enabled = NO;
    
    if (self.savePhoneBtn.selected) {
        NSUserDefaults *us = [NSUserDefaults standardUserDefaults];
        [us setObject:self.passwordTextField.text forKey:@"LastTimeMobile"];
        [us synchronize];
    }
    [SVProgressHUD showWithStatus:@"登录中..."];
    NSString *url = [NSString stringWithFormat:@"%@%@",BaseUrl,@"/logon/login.html"];
    NSDictionary *param = @{@"mobile":self.phoneTextField.text, @"pass":self.passwordTextField.text};
    _dataTask = [[SYHttpRequest sharedInstance] getDataWithUrl:url Parameter:param ResponseObject:^(NSDictionary *responseResult) {
        [SVProgressHUD dismiss];

        self.loginBtn.enabled = YES;
        NSLog(@"responseResult -- %@",responseResult);
        if ([responseResult objectForKey:@"resError"]) {
            [self showHint:@"服务器不给力，请稍后重试"];
        }else{
            if ([[responseResult objectForKey:@"result"] integerValue] == 1) {
                NSUserDefaults *us = [NSUserDefaults standardUserDefaults];
                [us setObject:[responseResult objectForKey:@"token"] forKey:@"token"];
                [us setObject:self.phoneTextField.text forKey:@"mobile"];
                [us setObject:self.passwordTextField.text forKey:[NSString stringWithFormat:@"%@password",self.phoneTextField.text]];
                [us setBool:YES forKey:@"LoginStatus"];
                [us setObject:self.phoneTextField.text forKey:@"LastMobile"];
                [us synchronize];
                [self getUserInfosWithDic:responseResult];
                
                
            }else{
                if ([responseResult objectForKey:@"msg"]) {
                    [self showHint:[responseResult objectForKey:@"msg"]];
                }
            }
        }
    }];
}

//获取用户信息
- (void)getUserInfosWithDic:(NSDictionary *)dic{
    
    NSString *url = [NSString stringWithFormat:@"%@%@",BaseUrl,@"/user/user.html"];
    NSDictionary *param = @{@"token":UserToken};
    _dataTask = [[SYHttpRequest sharedInstance] getDataWithUrl:url Parameter:param ResponseObject:^(NSDictionary *responseResult) {
        [SVProgressHUD dismiss];
        NSLog(@"获取用户信息 -- %@",responseResult);
        if ([responseResult objectForKey:@"resError"]) {
            [self showHint:@"服务器不给力，请稍后重试"];
        }else{
            if ([[responseResult objectForKey:@"result"] integerValue] == 1) {
                NSDictionary *data = [responseResult objectForKey:@"data"];
                SYUserInfos *userinfos = [SYUserInfos userinfosWithDictionry:data];
                //归档
                [[Tool sharedInstance] saveObject:userinfos WithPath:[NSString stringWithFormat:@"%@",Mobile]];
                
                if ([[dic objectForKey:@"one"] integerValue] != 0) {
                    if ([[dic objectForKey:@"xuni"] integerValue] == 0) {
                        //不是虚拟号
                        [self redBag];
                    }else{
                        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"亲！你的手机号码在国家电信局显示非正常状态，不能获取红包及分享奖励，您仍可正常使用云拍的其他功能。" preferredStyle:UIAlertControllerStyleAlert];
                        UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                            [self.navigationController popViewControllerAnimated:YES];
                        }];
                        UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                            [self.navigationController popViewControllerAnimated:YES];
                        }];
                        [alert addAction:action];
                        [alert addAction:action1];
                        [self presentViewController:alert animated:YES completion:nil];
                    }
                }else{
                    [self.navigationController popViewControllerAnimated:YES];
                }
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
    imageView.image = [UIImage imageNamed:@"hongbao_weikai"];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    [view addSubview:imageView];
    
    
}

- (void)imageViewAnimation:(UITapGestureRecognizer *)tap{
    if (_isEndAnimation) {
        [self disMissView];
        
    }else{
        if (![_animationIMG isAnimating]) {
            _animationIMG.image = [UIImage imageNamed:@"lingqu"];
            
            NSArray *imgArr = @[@"hongbao1", @"hongbao2", @"hongbao3", @"hongbao4", @"hongbao5", @"hongbao6", @"hongbao7", @"hongbao8", @"hongbao9", @"hongbao10", @"hongbao11", @"hongbao12", @"hongbao13"];
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


@end
