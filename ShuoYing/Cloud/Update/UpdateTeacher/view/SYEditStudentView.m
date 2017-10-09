//
//  SYEditStudentView.m
//  ShuoYing
//
//  Created by 硕影 on 2017/2/23.
//  Copyright © 2017年 硕影. All rights reserved.
//

#import "SYEditStudentView.h"

@interface SYEditStudentView ()<UIScrollViewDelegate, UITextFieldDelegate>


@end

@implementation SYEditStudentView


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    self.backView.layer.cornerRadius = 10;
    self.backView.layer.masksToBounds = YES;
    
    [self.renameStudent setTitleColor:NavigationColor forState:UIControlStateSelected];
    [self.renameStudent setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    
    [self.deleteStudent setTitleColor:NavigationColor forState:UIControlStateSelected];
    [self.deleteStudent setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    
    self.renameStudent.selected = YES;
    
    self.scrollView.scrollEnabled = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.showsHorizontalScrollIndicator = NO;

    self.renameTF.borderStyle = UITextBorderStyleRoundedRect;
    self.renameTF.layer.cornerRadius = 5;
    self.renameTF.layer.masksToBounds = YES;
    self.renameTF.layer.borderColor = RGB(234, 234, 234).CGColor;
    self.renameTF.layer.borderWidth = 1;
    self.renameTF.backgroundColor = RGB(234, 234, 234);
    self.renameTF.attributedPlaceholder = [[NSAttributedString alloc] initWithString:_renameTF.placeholder attributes:@{NSAttachmentAttributeName : RGB(132, 132, 132)}];
    self.renameTF.delegate = self;
    
    self.deleteLabel.font = [UIFont systemFontOfSize:16];
    self.deleteLabel.textColor = HexRGB(0xff5577);
    self.deleteLabel.textAlignment = NSTextAlignmentCenter;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if (textField == self.renameTF) {
        if (range.length == 1 && string.length == 0){
            return YES;
        }else if (self.renameTF.text.length >= 10){
            self.renameTF.text = [textField.text substringToIndex:10];
            return NO;
        }
    }
    return YES;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    NSLog(@"content.x - %f",scrollView.contentOffset.x);
    NSLog(@"content.y - %f",scrollView.contentOffset.y);
}

- (IBAction)renameAction:(UIButton *)sender {
    self.renameStudent.selected = YES;
    self.deleteStudent.selected = NO;
    self.scrollView.contentOffset = CGPointMake(0, 0);
    
//    self.scrollContentViewLeftContrains. = 0;
}
- (IBAction)deleteAction:(UIButton *)sender {
    self.renameStudent.selected = NO;
    self.deleteStudent.selected = YES;
    self.scrollView.contentOffset = CGPointMake(self.contentView.frame.size.width, 0);
//    self.scrollContentViewLeftContrains.constant = - self.contentView.frame.size.width;
}

- (IBAction)cancleAction:(UIButton *)sender {
    [self dismiss];
}
- (IBAction)doneAction:(UIButton *)sender {
    NSDictionary *resultDic = nil;
    resultDic = @{@"renameStudentSelected" : [NSNumber numberWithBool:self.renameStudent.selected]};
    if (self.renameStudent.selected) {
        if (_renameTF.text.length == 0) {
            resultDic = @{@"renameStudentSelected" : [NSNumber numberWithBool:self.renameStudent.selected], @"studentName" : _renameTF.text};
            
            self.block(resultDic);
        }else{
            
            resultDic = @{@"renameStudentSelected" : [NSNumber numberWithBool:self.renameStudent.selected], @"studentName" : _renameTF.text};
            [self dismiss];
            self.block(resultDic);
        }
    }else{
        self.block(resultDic);
        [self dismiss];
    }
}

- (void)show{
    
    self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.6];
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    
    [window addSubview:self];
}

- (void)dismiss{
    [self removeFromSuperview];
}




@end
