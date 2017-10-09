//
//  SYMyWalletTableViewCell.m
//  ShuoYing
//
//  Created by 硕影 on 2016/12/26.
//  Copyright © 2016年 硕影. All rights reserved.
//

#import "SYMyWalletTableViewCell.h"

@interface SYMyWalletTableViewCell()

@property (weak, nonatomic) IBOutlet UIView *backGroundView;


@end

@implementation SYMyWalletTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.backGroundView.layer.cornerRadius = 5;
    self.backGroundView.layer.masksToBounds = YES;
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
