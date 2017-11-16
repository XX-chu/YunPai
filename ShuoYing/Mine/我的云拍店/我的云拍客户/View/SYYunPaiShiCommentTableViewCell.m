//
//  SYYunPaiShiCommentTableViewCell.m
//  ShuoYing
//
//  Created by chu on 2017/11/14.
//  Copyright © 2017年 硕影. All rights reserved.
//

#import "SYYunPaiShiCommentTableViewCell.h"
#import "SYYuYueOrderModel.h"
@implementation SYYunPaiShiCommentTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.headImageView.layer.cornerRadius = self.headImageView.frame.size.height / 2;
    self.headImageView.layer.masksToBounds = YES;
}

- (void)setModel:(SYYuYueOrderModel *)model{
    _model = model;
    [self.headImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",ImgUrl, model.head]] placeholderImage:NoPicture];
    self.nickLabel.text = model.link;
    
    for (int i = 0; i < self.xiaoguoImages.count; i++) {
        UIImageView *imgView = self.xiaoguoImages[i];
        if (i > [_model.ping1 integerValue] - 1) {
            imgView.image = [UIImage imageNamed:@"pingjia_nor"];
        }else{
            imgView.image = [UIImage imageNamed:@"PhotoShop_xingji"];
        }
    }
    
    for (int i = 0; i < self.fenggeImages.count; i++) {
        UIImageView *imgView = self.fenggeImages[i];
        if (i > [_model.ping2 integerValue] - 1) {
            imgView.image = [UIImage imageNamed:@"pingjia_nor"];
        }else{
            imgView.image = [UIImage imageNamed:@"PhotoShop_xingji"];
        }
    }
    
    for (int i = 0; i < self.guochengImages.count; i++) {
        UIImageView *imgView = self.guochengImages[i];
        if (i > [_model.ping3 integerValue] - 1) {
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
