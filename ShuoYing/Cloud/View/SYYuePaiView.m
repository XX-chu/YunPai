//
//  SYYuePaiView.m
//  ShuoYing
//
//  Created by 硕影 on 2017/1/16.
//  Copyright © 2017年 硕影. All rights reserved.
//

#import "SYYuePaiView.h"

@implementation SYYuePaiView

- (void)drawRect:(CGRect)rect{
    
    [self.cancleBtn setTitle:@"取消" forState:UIControlStateNormal];
    [self.cancleBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    self.cancleBtn.layer.masksToBounds = YES;
    self.cancleBtn.layer.cornerRadius = 5;
    self.cancleBtn.layer.borderWidth = 1;
    self.cancleBtn.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.cancleBtn.tag = 0;
    self.cancleBtn.titleLabel.font = [UIFont systemFontOfSize:13];
    [self.cancleBtn setAdjustsImageWhenHighlighted:NO];
    
    [self.callBtn setTitle:@"呼叫" forState:UIControlStateNormal];
    [self.callBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.callBtn.tag = 1;
    [self.callBtn setBackgroundImage:[UIImage imageWithColor:RGB(251, 88, 91) Size:self.callBtn.frame.size] forState:UIControlStateNormal];
    self.callBtn.layer.masksToBounds = YES;
    self.callBtn.layer.cornerRadius = 5;
    self.callBtn.titleLabel.font = [UIFont systemFontOfSize:13];
    [self.callBtn setAdjustsImageWhenHighlighted:NO];
    
    [self.aplayBtn setTitle:@"支付" forState:UIControlStateNormal];
    [self.aplayBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.aplayBtn.tag = 2;
    [self.aplayBtn setBackgroundImage:[UIImage imageWithColor:NavigationColor Size:self.aplayBtn.frame.size] forState:UIControlStateNormal];
    self.aplayBtn.layer.masksToBounds = YES;
    self.aplayBtn.layer.cornerRadius = 5;
    self.aplayBtn.titleLabel.font = [UIFont systemFontOfSize:13];

    [self.aplayBtn setAdjustsImageWhenHighlighted:NO];
}


- (IBAction)cancleAction:(UIButton *)sender {
    if (self.bolck) {
        self.bolck(sender.tag);
    }
}
- (IBAction)callAction:(UIButton *)sender {
    if (self.bolck) {
        self.bolck(sender.tag);
    }
}
- (IBAction)alipyAction:(UIButton *)sender {
    if (self.bolck) {
        self.bolck(sender.tag);
    }
}

@end
