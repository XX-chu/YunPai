//
//  SYAddStudentToClassView.m
//  ShuoYing
//
//  Created by 硕影 on 2017/2/23.
//  Copyright © 2017年 硕影. All rights reserved.
//

#import "SYAddStudentToClassView.h"

@interface SYAddStudentToClassView ()

@property (weak, nonatomic) IBOutlet UIView *backView;


@end

@implementation SYAddStudentToClassView

- (void)show{
    [self.nameTF becomeFirstResponder];
    self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.6];
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    
    [window addSubview:self];
}

- (void)dismiss{
    [self removeFromSuperview];
}



// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    self.backView.layer.cornerRadius = 10;
    self.backView.layer.masksToBounds = YES;
    
    self.nameTF.backgroundColor = RGB(234, 234, 234);
    self.phoneTF.backgroundColor = RGB(234, 234, 234);
    self.nameTF.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.nameTF.placeholder attributes:@{NSForegroundColorAttributeName: RGB(132, 132, 132)}];
    self.phoneTF.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.phoneTF.placeholder attributes:@{NSForegroundColorAttributeName: RGB(132, 132, 132)}];

    self.nameTF.layer.cornerRadius = 5;
    self.nameTF.layer.masksToBounds = YES;
    self.nameTF.layer.borderColor = RGB(234, 234, 234).CGColor;
    self.nameTF.layer.borderWidth = 1;
    self.phoneTF.layer.cornerRadius = 5;
    self.phoneTF.layer.masksToBounds = YES;
    self.phoneTF.layer.borderColor = RGB(234, 234, 234).CGColor;
    self.phoneTF.layer.borderWidth = 1;
}

- (IBAction)doneAction:(UIButton *)sender {
    
    [self.nameTF resignFirstResponder];
    [self.phoneTF resignFirstResponder];

    if (self.block) {
        self.block(self.nameTF.text, self.phoneTF.text);
    }
    
    if (self.nameTF.text.length == 0 || self.phoneTF.text.length == 0) {
        
    }else{
        [self dismiss];
    }
    
}
- (IBAction)cancleAction:(UIButton *)sender {
    [self dismiss];
}

@end
