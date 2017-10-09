//
//  SYFromTeacherOrGrapherCollectionViewCell.m
//  ShuoYing
//
//  Created by 硕影 on 2017/2/27.
//  Copyright © 2017年 硕影. All rights reserved.
//

#import "SYFromTeacherOrGrapherCollectionViewCell.h"
#import "SYMyPhotoModel.h"
@implementation SYFromTeacherOrGrapherCollectionViewCell

- (void)setPhotoModel:(SYMyPhotoModel *)photoModel{
    _photoModel = photoModel;
    
    [self.backImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",ImgUrl,_photoModel.img_200]] placeholderImage:[UIImage imageWithColor:BackGroundColor Size:self.backImageView.frame.size]];
    
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
- (IBAction)downloadAction:(UIButton *)sender {
    SYFromTeacherOrGrapherCollectionViewCell *cell = (SYFromTeacherOrGrapherCollectionViewCell *)sender.superview.superview.superview;
    self.downloadImage(cell);
}

@end
