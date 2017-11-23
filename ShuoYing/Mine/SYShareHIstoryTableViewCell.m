//
//  SYShareHIstoryTableViewCell.m
//  ShuoYing
//
//  Created by chu on 2017/11/1.
//  Copyright © 2017年 硕影. All rights reserved.
//

#import "SYShareHIstoryTableViewCell.h"

@implementation SYShareHIstoryTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.updateBtn.layer.cornerRadius = 5;
    self.updateBtn.layer.borderColor = HexRGB(0x3dcfbb).CGColor;
    self.updateBtn.layer.borderWidth = 1;
    self.updateBtn.layer.masksToBounds = YES;
    [self.updateBtn setAdjustsImageWhenHighlighted:NO];
    
    self.headImageView.layer.cornerRadius = self.headImageView.frame.size.height / 2;
    self.headImageView.layer.masksToBounds = YES;
}

- (IBAction)updateAction:(UIButton *)sender {
    if (self.block) {
        self.block();
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
