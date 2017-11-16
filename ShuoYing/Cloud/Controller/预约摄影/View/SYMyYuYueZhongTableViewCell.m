//
//  SYMyYuYueZhongTableViewCell.m
//  ShuoYing
//
//  Created by chu on 2017/11/15.
//  Copyright © 2017年 硕影. All rights reserved.
//

#import "SYMyYuYueZhongTableViewCell.h"
#import "SYYuYueOrderModel.h"
@implementation SYMyYuYueZhongTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setModel:(SYYuYueOrderModel *)model{
    _model = model;
    [self.headImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",ImgUrl, _model.head]] placeholderImage:NoPicture];
    self.nickLabel.text = model.nick;
    self.nameLabel.text = [NSString stringWithFormat:@"摄影师：%@",model.name];
    self.phoneLabel.text = [NSString stringWithFormat:@"联系电话：%@",model.tel];
    
    for (int i = 0; i < self.stars.count; i++) {
        UIImageView *imgView = self.stars[i];
        if (i > [_model.ping integerValue] - 1) {
            imgView.image = [UIImage imageNamed:@"pingjia_nor"];
            
        }else{
            imgView.image = [UIImage imageNamed:@"PhotoShop_xingji"];
        }
        
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
