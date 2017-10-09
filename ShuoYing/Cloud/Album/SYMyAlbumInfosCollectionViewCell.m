//
//  SYMyAlbumInfosCollectionViewCell.m
//  ShuoYing
//
//  Created by 硕影 on 2016/12/30.
//  Copyright © 2016年 硕影. All rights reserved.
//

#import "SYMyAlbumInfosCollectionViewCell.h"
#import "SYMyPhotoModel.h"

@interface SYMyAlbumInfosCollectionViewCell ()

@property (weak, nonatomic) IBOutlet UIView *backView;

@end

@implementation SYMyAlbumInfosCollectionViewCell

- (void)setPhotoModel:(SYMyPhotoModel *)photoModel{
    _photoModel = photoModel;
    
    [self.backImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",ImgUrl,_photoModel.img_200]] placeholderImage:[UIImage imageWithColor:BackGroundColor Size:self.backImageView.frame.size]];
    
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.backView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.6];
}
- (IBAction)downloadAction:(UIButton *)sender {
    SYMyAlbumInfosCollectionViewCell *cell = (SYMyAlbumInfosCollectionViewCell *)sender.superview.superview.superview;
    self.downloadImage(cell);
}

- (IBAction)deleteAction:(UIButton *)sender {
    SYMyAlbumInfosCollectionViewCell *cell = (SYMyAlbumInfosCollectionViewCell *)sender.superview.superview.superview;
    self.deleteImage(cell);
}

@end
