//
//  SYNoNetworkView.m
//  ShuoYing
//
//  Created by 硕影 on 2017/3/7.
//  Copyright © 2017年 硕影. All rights reserved.
//

#import "SYNoNetworkView.h"

@implementation SYNoNetworkView


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    [self.loadDataBtn setAdjustsImageWhenHighlighted:NO];
}

- (IBAction)loadDataAction:(UIButton *)sender {
    if (self.block) {
        self.block();
    }
}

@end
