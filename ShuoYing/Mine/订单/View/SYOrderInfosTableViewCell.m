//
//  SYOrderInfosTableViewCell.m
//  ShuoYing
//
//  Created by chu on 2017/11/10.
//  Copyright © 2017年 硕影. All rights reserved.
//

#import "SYOrderInfosTableViewCell.h"

@implementation SYOrderInfosTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (IBAction)haveSelecteAction:(UIButton *)sender {
    if (self.block) {
        self.block();
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
