//
//  SYYunPaiDianTableViewCell.m
//  ShuoYing
//
//  Created by chu on 2017/11/14.
//  Copyright © 2017年 硕影. All rights reserved.
//

#import "SYYunPaiDianTableViewCell.h"
#import "SYYuYueOrderModel.h"
@implementation SYYunPaiDianTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.headImageView.layer.cornerRadius = self.headImageView.frame.size.height / 2;
    self.headImageView.layer.masksToBounds = YES;
}

- (void)setModel:(SYYuYueOrderModel *)model{
    _model = model;
    [self.headImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",ImgUrl, _model.head]] placeholderImage:NoPicture];
    self.nickLabel.text = model.nick;
    self.nameLabel.text = [NSString stringWithFormat:@"联系人：%@",model.link];
    self.phoneLabel.text = [NSString stringWithFormat:@"联系电话：%@",model.tel];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
