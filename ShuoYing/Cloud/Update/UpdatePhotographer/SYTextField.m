//
//  SYTextField.m
//  ShuoYing
//
//  Created by 硕影 on 2017/2/5.
//  Copyright © 2017年 硕影. All rights reserved.
//

#import "SYTextField.h"

@implementation SYTextField


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    [super drawRect:rect];
}

- (BOOL)resignFirstResponder{
    [super resignFirstResponder];
    [self.tableview removeFromSuperview];
    return YES;
}


@end
