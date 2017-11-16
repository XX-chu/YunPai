//
//  SYEditImageCollectionViewCell.m
//  ShuoYing
//
//  Created by chu on 2017/11/14.
//  Copyright © 2017年 硕影. All rights reserved.
//

#import "SYEditImageCollectionViewCell.h"

@implementation SYEditImageCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.editView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.4];
}
- (IBAction)deleAction:(UIButton *)sender {
    if (self.delBlock) {
        self.delBlock();
    }
}

- (IBAction)editAction:(UIButton *)sender {
    if (self.editBlock) {
        self.editBlock();
    }
}

@end
