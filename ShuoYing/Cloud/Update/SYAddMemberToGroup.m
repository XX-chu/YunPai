//
//  SYAddMemberToGroup.m
//  ShuoYing
//
//  Created by 硕影 on 2017/3/6.
//  Copyright © 2017年 硕影. All rights reserved.
//

#import "SYAddMemberToGroup.h"

@implementation SYAddMemberToGroup


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    self.phoneTF.layer.cornerRadius = 5;
    self.phoneTF.layer.masksToBounds = YES;
    self.phoneTF.layer.borderColor = RGB(234, 234, 234).CGColor;
    self.phoneTF.layer.borderWidth = 1;
    
    self.phoneTF.backgroundColor = RGB(234, 234, 234);
    self.phoneTF.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.phoneTF.placeholder attributes:@{NSForegroundColorAttributeName: RGB(132, 132, 132)}];
}
- (IBAction)doneAction:(UIButton *)sender {
    
    [self.phoneTF resignFirstResponder];
    
    if (self.block) {
        self.block(self.phoneTF.text);
    }
    
    if (self.phoneTF.text.length == 0) {
        
    }else{
        [self dismiss];
    }
}

- (IBAction)cancleAction:(UIButton *)sender {
    [self dismiss];
}

- (void)show{
    [self.phoneTF becomeFirstResponder];
    self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.6];
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    
    [window addSubview:self];
}

- (void)dismiss{
    [self removeFromSuperview];
}

@end
