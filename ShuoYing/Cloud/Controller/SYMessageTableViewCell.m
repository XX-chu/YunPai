//
//  SYMessageTableViewCell.m
//  ShuoYing
//
//  Created by 硕影 on 2017/1/16.
//  Copyright © 2017年 硕影. All rights reserved.
//

#import "SYMessageTableViewCell.h"
#import "SYMessageModel.h"

@implementation SYMessageTableViewCell

- (void)setModel:(SYMessageModel *)model{
    _model = model;
    self.timeLabel.text = model.addtime;
    self.contentLabel.text = model.title;
    if ([model.state integerValue] == 0) {
        self.readLabel.text = @"未读";
        self.readLabel.textColor = NavigationColor;
    }else{
        self.readLabel.text = @"已读";
        self.readLabel.textColor = [UIColor darkGrayColor];

    }
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
