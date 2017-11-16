//
//  SYCertifieYunPaiShiViewController.m
//  ShuoYing
//
//  Created by chu on 2017/11/11.
//  Copyright © 2017年 硕影. All rights reserved.
//

#import "SYCertifieYunPaiShiViewController.h"
#import "SYMapViewController.h"

@interface SYCertifieYunPaiShiViewController ()
{
    NSString *_address;
    NSNumber *_lat;
    NSNumber *_log;
}
@property (weak, nonatomic) IBOutlet UITextField *photoXingHaoLabel;
@property (weak, nonatomic) IBOutlet UITextField *photoXuLieHaoLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIButton *commitBtn;

@end

@implementation SYCertifieYunPaiShiViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"认证云拍师";
    
    self.commitBtn.layer.cornerRadius = 5;
    self.commitBtn.layer.masksToBounds = YES;
    self.contentViewHeightConstraint.constant = kScreenHeight - kNavigationBarHeightAndStatusBarHeight;
}

- (IBAction)addressAction:(UIButton *)sender {
    SYMapViewController *mapView = [[SYMapViewController alloc] init];
    __weak typeof(self)weakself = self;
    mapView.block = ^(NSString *address, NSNumber *lat, NSNumber *log) {
        weakself.addressLabel.text = address;
        _lat = lat;
        _log = log;
        _address = address;
    };
    [self.navigationController pushViewController:mapView animated:YES];
}

- (IBAction)commitAction:(UIButton *)sender {
    [self.view endEditing:YES];
    if (self.photoXingHaoLabel.text.length == 0) {
        [self showHint:@"请填写您的手机型号"];
        return;
    }
    if (self.photoXuLieHaoLabel.text.length == 0) {
        [self showHint:@"请填写您的手机序列号"];
        return;
    }

    if (!_lat || !_log || !_address) {
        [self showHint:@"请选择您的详细地址"];
        return;
    }
    [SVProgressHUD show];
    NSString *url = [NSString stringWithFormat:@"%@%@",BaseUrl,@"/master/reg.html"];
    NSDictionary *param = @{@"token":UserToken, @"ModelNo":self.photoXingHaoLabel.text, @"SerialNo":self.photoXuLieHaoLabel.text, @"lat":_lat, @"long":_log};
    [[SYHttpRequest sharedInstance] getDataWithUrl:url Parameter:param ResponseObject:^(NSDictionary *responseResult) {
        NSLog(@"验证云拍师 -- %@",responseResult);
        [SVProgressHUD dismiss];
        if ([responseResult objectForKey:@"resError"]) {
            [self showHint:@"服务器不给力，请稍后重试"];
        }else{
            if ([[responseResult objectForKey:@"result"] integerValue] == 1) {
                [self.navigationController popViewControllerAnimated:YES];
                [self showHint:[responseResult objectForKey:@"msg"]];

            }else{
                if ([responseResult objectForKey:@"msg"] && ![[responseResult objectForKey:@"msg"] isKindOfClass:[NSNull class]]) {
                    [self showHint:[responseResult objectForKey:@"msg"]];
                }
            }
        }
    }];
}

@end
