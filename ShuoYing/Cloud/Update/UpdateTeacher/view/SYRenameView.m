//
//  SYRenameView.m
//  ShuoYing
//
//  Created by 硕影 on 2017/2/23.
//  Copyright © 2017年 硕影. All rights reserved.
//

#import "SYRenameView.h"

@implementation SYRenameView


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    self.backView.layer.cornerRadius = 10;
    self.backView.layer.masksToBounds = YES;
    
    self.renameTF.layer.cornerRadius = 5;
    self.renameTF.layer.masksToBounds = YES;
    self.renameTF.layer.borderColor = RGB(234, 234, 234).CGColor;
    self.renameTF.layer.borderWidth = 1;
    self.renameTF.backgroundColor = RGB(234, 234, 234);
    self.renameTF.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.renameTF.placeholder attributes:@{NSAttachmentAttributeName : RGB(132, 132, 132)}];
    
    self.renameTF.delegate = self;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if (textField == self.renameTF) {
        if (range.length == 1 && string.length == 0){
            return YES;
        }else if (self.renameTF.text.length >= 12){
            self.renameTF.text = [textField.text substringToIndex:12];
            return NO;
        }
    }
    return YES;
}


- (void)show{
    [self.renameTF becomeFirstResponder];
    self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.6];
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    
    [window addSubview:self];
}

- (void)dismiss{
    [self removeFromSuperview];
}

- (IBAction)doneAction:(UIButton *)sender {
    [self.renameTF resignFirstResponder];
    
    if (self.block) {
        self.block(self.renameTF.text);
    }
    
    if (self.renameTF.text.length == 0) {
        
    }else{
        [self dismiss];
    }
}
- (IBAction)calcleAction:(UIButton *)sender {
    [self dismiss];
}

@end
