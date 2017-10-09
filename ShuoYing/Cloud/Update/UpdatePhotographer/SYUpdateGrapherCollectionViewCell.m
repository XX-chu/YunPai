//
//  SYUpdateGrapherCollectionViewCell.m
//  ShuoYing
//
//  Created by 硕影 on 2017/1/12.
//  Copyright © 2017年 硕影. All rights reserved.
//

#import "SYUpdateGrapherCollectionViewCell.h"

@implementation SYUpdateGrapherCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.IMGHeightContraint.constant = (kScreenWidth - 50) / 3;
    self.IMGWidthConstraint.constant = (kScreenWidth - 50) / 3;
    
}

@end
