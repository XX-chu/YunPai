//
//  SYMineTableViewCell.m
//  ShuoYing
//
//  Created by 硕影 on 2016/12/26.
//  Copyright © 2016年 硕影. All rights reserved.
//

#import "SYMineTableViewCell.h"

@implementation SYMineTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.lineView.backgroundColor = [UIColor lightGrayColor];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
