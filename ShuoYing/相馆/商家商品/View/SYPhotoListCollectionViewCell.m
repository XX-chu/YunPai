//
//  SYPhotoListCollectionViewCell.m
//  ShuoYing
//
//  Created by 硕影 on 2017/5/9.
//  Copyright © 2017年 硕影. All rights reserved.
//

#import "SYPhotoListCollectionViewCell.h"
#import "SYMyPhotoModel.h"

@implementation SYPhotoListCollectionViewCell

- (void)setMyPhoto:(SYMyPhotoModel *)myPhoto{
    _myPhoto = myPhoto;
    [self.contentImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",ImgUrl,_myPhoto.img_200]] placeholderImage:NoPicture];
    if ([_myPhoto.isSelected boolValue]) {
        [self.selecteBtn setImage:[UIImage imageNamed:@"myspace_choice_sel"] forState:UIControlStateNormal];
    }else{
        [self.selecteBtn setImage:[UIImage imageNamed:@"myspace_choice_nor"] forState:UIControlStateNormal];
    }
}
- (IBAction)selecteAction:(UIButton *)sender {
    if (self.block) {
        self.block();
    }
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    [self.selecteBtn setAdjustsImageWhenHighlighted:NO];
}

@end
