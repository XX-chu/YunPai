//
//  SYYuYueInfosTableViewCell.m
//  ShuoYing
//
//  Created by chu on 2017/11/15.
//  Copyright © 2017年 硕影. All rights reserved.
//

#import "SYYuYueInfosTableViewCell.h"
#import "SYYunPaiShiInfos.h"
@implementation SYYuYueInfosTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setInfos:(SYYunPaiShiInfos *)infos{
    _infos = infos;
    
    [self.headImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",ImgUrl, infos.head]] placeholderImage:NoPicture];
    self.nickLabel.text = _infos.nick;
    self.xinghaoLabel.text = [NSString stringWithFormat:@"相机型号:%@",_infos.ModelNo];
    self.yiwanchengLabel.text = [NSString stringWithFormat:@"已完成拍摄%@",_infos.done];
    self.juliLabel.text = [NSString stringWithFormat:@"距您%@km",_infos.juli];
    self.priceLabel.text = [NSString stringWithFormat:@"¥%@",_infos.money];

    for (int i = 0; i < self.stars.count; i++) {
        UIImageView *imgView = self.stars[i];
        if (i > [_infos.ping integerValue] - 1) {
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
