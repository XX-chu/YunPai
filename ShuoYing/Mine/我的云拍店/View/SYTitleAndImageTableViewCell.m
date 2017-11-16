//
//  SYTitleAndImageTableViewCell.m
//  ShuoYing
//
//  Created by chu on 2017/11/13.
//  Copyright © 2017年 硕影. All rights reserved.
//

#import "SYTitleAndImageTableViewCell.h"

@implementation SYTitleAndImageTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (IBAction)delAction:(UIButton *)sender {
    if (self.block) {
        self.block();
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
