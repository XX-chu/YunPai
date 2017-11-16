//
//  SYYunPaiSheBeiEditViewController.m
//  ShuoYing
//
//  Created by chu on 2017/11/14.
//  Copyright © 2017年 硕影. All rights reserved.
//

#import "SYYunPaiSheBeiEditViewController.h"

@interface SYYunPaiSheBeiEditViewController ()

@end

@implementation SYYunPaiSheBeiEditViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"修改设备";
    self.doneBtn.layer.cornerRadius = 5;
    self.doneBtn.layer.masksToBounds = YES;
}

- (IBAction)doneAction:(UIButton *)sender {
    if (self.xinghaoTF.text.length == 0 || self.xueliehaoTF.text.length == 0) {
        [self showHint:@"请输入您的设备信息"];
        return;
    }
    if (self.block) {
        self.block(self.xinghaoTF.text, self.xueliehaoTF.text);
    }
    [self.navigationController popViewControllerAnimated:YES];
}

@end
