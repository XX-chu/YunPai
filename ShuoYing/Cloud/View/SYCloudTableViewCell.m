//
//  SYCloudTableViewCell.m
//  ShuoYing
//
//  Created by 硕影 on 2016/12/29.
//  Copyright © 2016年 硕影. All rights reserved.
//

#import "SYCloudTableViewCell.h"

#import "SYCloudModel.h"

@implementation SYCloudTableViewCell

- (void)setCloudModel:(SYCloudModel *)cloudModel{
    _cloudModel = cloudModel;
    [self.headImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",ImgUrl,_cloudModel.head]] placeholderImage:[UIImage imageWithColor:BackGroundColor Size:self.headImageView.frame.size]];
    
    self.nicknameLabel.text = _cloudModel.nick;
    self.introLabel.text = _cloudModel.info;
    
    if (_cloudModel.imgs.count == 1) {
        [self.firstImageVIew sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",ImgUrl,_cloudModel.imgs[0]]] placeholderImage:[UIImage imageWithColor:BackGroundColor Size:self.firstImageVIew.frame.size]];
    }else if (_cloudModel.imgs.count == 0){
        
    }else if (_cloudModel.imgs.count == 2){
        [self.firstImageVIew sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",ImgUrl,_cloudModel.imgs[0]]] placeholderImage:[UIImage imageWithColor:BackGroundColor Size:self.firstImageVIew.frame.size]];
        [self.secondImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",ImgUrl,_cloudModel.imgs[1]]] placeholderImage:[UIImage imageWithColor:BackGroundColor Size:self.firstImageVIew.frame.size]];
    }else{
        [self.firstImageVIew sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",ImgUrl,_cloudModel.imgs[0]]] placeholderImage:[UIImage imageWithColor:BackGroundColor Size:self.firstImageVIew.frame.size]];
        [self.secondImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",ImgUrl,_cloudModel.imgs[1]]] placeholderImage:[UIImage imageWithColor:BackGroundColor Size:self.firstImageVIew.frame.size]];
        [self.thirdImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",ImgUrl,_cloudModel.imgs[2]]] placeholderImage:[UIImage imageWithColor:BackGroundColor Size:self.firstImageVIew.frame.size]];
    }
    
    if ([_cloudModel.pholv integerValue] == 1) {
        self.xingjiImageView.image = [UIImage imageNamed:@"xingji-one"];
    }else if ([_cloudModel.pholv integerValue] == 2){
        self.xingjiImageView.image = [UIImage imageNamed:@"xingji-two"];
    }else{
        self.xingjiImageView.image = [UIImage imageNamed:@"xingji-three"];
    }
    
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.headImageView.layer.cornerRadius = self.headImageView.frame.size.width / 2;
    self.headImageView.layer.masksToBounds = YES;
    
    self.firstIVWidthConstraint.constant = (kScreenWidth - 50) / 3;
    self.firstIVHeightContrainst.constant = (kScreenWidth - 50) / 3;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

}

@end
