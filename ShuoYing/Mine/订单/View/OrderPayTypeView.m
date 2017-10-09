//
//  OrderPayTypeView.m
//  ShuoYing
//
//  Created by 硕影 on 2017/4/6.
//  Copyright © 2017年 硕影. All rights reserved.
//

#import "OrderPayTypeView.h"

#define PayTypeCount 4

@implementation OrderPayTypeView


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.6f];
    self.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss)];
    [self addGestureRecognizer:tap];
}

- (void)show{
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    [window addSubview:self];
    
}

- (void)dismiss{
    [self removeFromSuperview];
}

- (IBAction)dismissAction:(UIButton *)sender {
    [self dismiss];
}

- (IBAction)weixinAction:(UIButton *)sender {
    if (self.weixin) {
        self.weixin();
    }
}

- (IBAction)zhifubaoAction:(UIButton *)sender {
    if (self.zhifubao) {
        self.zhifubao();
    }
}

- (IBAction)yueAction:(UIButton *)sender {
    if (self.yue) {
        self.yue();
    }
}

@end
