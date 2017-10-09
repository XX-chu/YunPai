//
//  DeleteOrderView.m
//  ShuoYing
//
//  Created by 硕影 on 2017/4/7.
//  Copyright © 2017年 硕影. All rights reserved.
//

#import "DeleteOrderView.h"

@implementation DeleteOrderView


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    self.backView.layer.cornerRadius = 6;
    self.backView.layer.masksToBounds = YES;
    [self.leftBtn setTitleColor:HexRGB(0x434343) forState:UIControlStateNormal];
    [self.leftBtn setAdjustsImageWhenHighlighted:NO];
    [self.rightBtn setTitleColor:NavigationColor forState:UIControlStateNormal];
    [self.rightBtn setAdjustsImageWhenHighlighted:NO];
}

- (void)show{
    
    self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.6];
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    
    [window addSubview:self];
}

- (void)dismiss{
    [self removeFromSuperview];
}

- (IBAction)leftAction:(UIButton *)sender {
    if (self.leftBlock) {
        self.leftBlock ();
    }
}

- (IBAction)rightAction:(UIButton *)sender {
    if (self.rightBlock) {
        self.rightBlock ();
    }
}

@end
