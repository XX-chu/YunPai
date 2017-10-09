//
//  SYCloudCommentContentTableViewCell.m
//  ShuoYing
//
//  Created by 硕影 on 2017/7/5.
//  Copyright © 2017年 硕影. All rights reserved.
//

#import "SYCloudCommentContentTableViewCell.h"

@implementation SYCloudCommentContentTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

// 用于UIMenuController显示，缺一不可
-(BOOL)canBecomeFirstResponder{
    
    return YES;
    
}

@end
