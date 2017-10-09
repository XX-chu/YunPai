//
//  SYUpdataMineCollectionViewCell.m
//  ShuoYing
//
//  Created by 硕影 on 2016/12/29.
//  Copyright © 2016年 硕影. All rights reserved.
//

#import "SYUpdataMineCollectionViewCell.h"
#import "SYNewAlbumModel.h"
@implementation SYUpdataMineCollectionViewCell

- (void)setAlbumModel:(SYNewAlbumModel *)albumModel{
    _albumModel = albumModel;
    if (_albumModel.img) {
        [self.imageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",ImgUrl,_albumModel.img]] placeholderImage:[UIImage imageNamed:@"shangchuan_wode_wutupian"]];
    }else{
        [self.imageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",ImgUrl,_albumModel.img_200]] placeholderImage:[UIImage imageNamed:@"shangchuan_wode_wutupian"]];
    }
    
    if (_albumModel.file) {
        self.oneLabel.text = _albumModel.file;
    }
    if (_albumModel.time) {
        self.oneLabel.text = _albumModel.time;
    }
    self.twoLabel.text = [NSString stringWithFormat:@"共%ld张",[_albumModel.count integerValue]];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.imageViewWidthConstraint.constant = (kScreenWidth - 40) / 3;

    self.imageViewHeightConstraint.constant = (kScreenWidth - 40) / 3;
}


@end
