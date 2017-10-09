//
//  SYGroupPhotoCollectionViewCell.m
//  ShuoYing
//
//  Created by 硕影 on 2017/3/6.
//  Copyright © 2017年 硕影. All rights reserved.
//

#import "SYGroupPhotoCollectionViewCell.h"

@implementation SYGroupPhotoCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.heightContrains.constant = (kScreenWidth - 50) / 3;
    self.widthContrains.constant = (kScreenWidth - 50) / 3;
}

@end
