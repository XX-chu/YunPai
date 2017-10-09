//
//  SYTiXianTixingView.m
//  ShuoYing
//
//  Created by 硕影 on 2017/3/15.
//  Copyright © 2017年 硕影. All rights reserved.
//

#import "SYTiXianTixingView.h"

@implementation SYTiXianTixingView


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    self.backView.layer.cornerRadius = 10;
    self.backView.layer.masksToBounds = YES;
}

- (IBAction)certifierGrapher:(UIButton *)sender {
    if (self.block) {
        self.block();
        [self disMiss];
    }
}
- (IBAction)cancle:(UIButton *)sender {
    [self disMiss];
}

- (void)show{
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    
    self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.6];
    [window addSubview:self];
    
}

- (void)disMiss{
    [self removeFromSuperview];
}

@end
