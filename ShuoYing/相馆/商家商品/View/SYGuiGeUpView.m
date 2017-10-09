//
//  SYGuiGeUpView.m
//  ShuoYing
//
//  Created by 硕影 on 2017/4/27.
//  Copyright © 2017年 硕影. All rights reserved.
//

#import "SYGuiGeUpView.h"

@implementation SYGuiGeUpView

- (IBAction)closeAction:(UIButton *)sender {
    if (self.block) {
        self.block();
    }
}

@end
