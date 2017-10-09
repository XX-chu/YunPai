//
//  SYFenZuTableViewCell.m
//  ShuoYing
//
//  Created by 硕影 on 2017/1/6.
//  Copyright © 2017年 硕影. All rights reserved.
//

#import "SYFenZuTableViewCell.h"

@implementation SYFenZuTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self.phoneNumBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.phoneNumBtn setAdjustsImageWhenHighlighted:NO];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (IBAction)editAction:(UIButton *)sender {
    NSLog(@"superview - %@",sender.superview.superview.superview);
    
    if (self.editBlock) {
        self.editBlock();
    }
}
- (IBAction)callPhoneAction:(UIButton *)sender {
    if (self.callBlock) {
        self.callBlock();
    }
}

@end
