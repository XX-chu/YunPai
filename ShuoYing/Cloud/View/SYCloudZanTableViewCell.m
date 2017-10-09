//
//  SYCloudZanTableViewCell.m
//  ShuoYing
//
//  Created by 硕影 on 2017/7/5.
//  Copyright © 2017年 硕影. All rights reserved.
//

#import "SYCloudZanTableViewCell.h"

@implementation SYCloudZanTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.headImageView.layer.cornerRadius = self.headImageView.frame.size.height / 2;
    self.headImageView.layer.masksToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
