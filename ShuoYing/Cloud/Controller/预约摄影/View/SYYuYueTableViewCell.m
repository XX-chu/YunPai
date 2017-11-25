//
//  SYYuYueTableViewCell.m
//  ShuoYing
//
//  Created by chu on 2017/11/14.
//  Copyright © 2017年 硕影. All rights reserved.
//

#import "SYYuYueTableViewCell.h"
#import "SYYuYueModel.h"
@implementation SYYuYueTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.imagesViewHeightConstraint.constant = (kScreenWidth - 118) * 62 / 227;
    self.yiwanchengLabel.hidden = YES;
}

- (void)setModel:(SYYuYueModel *)model{
    _model = model;
    [self.headImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",ImgUrl, _model.head]] placeholderImage:NoPicture];
    self.nickLabel.text = _model.nick;
    for (int i = 0; i < self.stars.count; i++) {
        UIImageView *imgView = self.stars[i];
        if (i > [_model.ping integerValue] - 1) {
            imgView.image = [UIImage imageNamed:@"pingjia_nor"];
        }else{
            imgView.image = [UIImage imageNamed:@"PhotoShop_xingji"];
        }
    }
    
    self.juliLabel.text = [NSString stringWithFormat:@"距您%@km",_model.juli];
    self.yiwanchengLabel.text = [NSString stringWithFormat:@"已完成拍摄%@",_model.done];
    self.xinghaoLabel.text = [NSString stringWithFormat:@"相机型号:%@",_model.ModelNo];
    self.priceLabel.text = [NSString stringWithFormat:@"¥%@",_model.money];
    self.zishuLabel.text = _model.info;
    for (int i = 0; i < self.zuopinS.count; i++) {
        UIImageView *imageView = self.zuopinS[i];
        if (i < _model.works.count) {
            NSDictionary *dic = _model.works[i];
            [imageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",ImgUrl, [dic objectForKey:@"img_200"]]] placeholderImage:NoPicture];
        }
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
