//
//  SYTeacherAndGrapherCollectionViewCell.m
//  ShuoYing
//
//  Created by 硕影 on 2017/1/11.
//  Copyright © 2017年 硕影. All rights reserved.
//

#import "SYTeacherAndGrapherCollectionViewCell.h"
#import "SYTeacherAndGrapherModel.h"


@implementation SYTeacherAndGrapherCollectionViewCell

- (void)setModel:(SYTeacherAndGrapherModel *)model{
    _model = model;
    
    [self.headImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",ImgUrl,_model.img_200]] placeholderImage:[UIImage imageNamed:@"shangchuan_wode_wutupian"]];
    
    self.nameLabel.text = _model.name;
    self.phoneLabel.text = _model.tel;
    
    if ([_model.state integerValue] == 0) {
        //未下载
        [self.downloadBtn setImage:[UIImage imageNamed:@"xiazai"] forState:UIControlStateNormal];
    }else{
        [self.downloadBtn setImage:[UIImage imageNamed:@"yixiazai"] forState:UIControlStateNormal];
    }
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self.downloadBtn setTitle:@"点击下载" forState:UIControlStateNormal];
    [self.downloadBtn setTitleColor:NavigationColor forState:UIControlStateNormal];
    self.downloadBtn.layer.masksToBounds = YES;
    self.downloadBtn.layer.cornerRadius = 5;
    self.downloadBtn.layer.borderColor = NavigationColor.CGColor;
    self.downloadBtn.layer.borderWidth = 1;
    
    [self.downloadBtn setAdjustsImageWhenHighlighted:NO];
    
    self.imageViewWidthConstraint.constant = (kScreenWidth - 50) / 3;
    self.imageViewHeightConstraint.constant = (kScreenWidth - 50) / 3;
    self.headImageView.userInteractionEnabled = YES;
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.downloadBtn = btn;
    btn.frame = CGRectMake((kScreenWidth - 50) / 3 - 25, (kScreenWidth - 50) / 3 - 25, 25, 25);
//    [btn setImage:[UIImage imageNamed:@"xiazai"] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(downloadAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.headImageView addSubview:btn];
    
}

- (void)downloadAction:(UIButton *)sender{
    NSLog(@"xiazai");
    if ([self.model.state integerValue] == 0) {
        //未下载
        if (self.alipyBlock) {
            SYTeacherAndGrapherCollectionViewCell *cell = (SYTeacherAndGrapherCollectionViewCell *)sender.superview.superview.superview;
            self.alipyBlock(cell);
        }
    }else{
        if (self.downloadBlock) {
            SYTeacherAndGrapherCollectionViewCell *cell = (SYTeacherAndGrapherCollectionViewCell *)sender.superview.superview.superview;
            self.downloadBlock(cell);
        }
    }
    
}

@end