//
//  SYSelectePhotoCollectionViewCell.m
//  ShuoYing
//
//  Created by 硕影 on 2017/5/9.
//  Copyright © 2017年 硕影. All rights reserved.
//

#import "SYSelectePhotoCollectionViewCell.h"

@implementation SYSelectePhotoCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
- (IBAction)deleteAction:(UIButton *)sender {
    if (self.deletePhoto) {
        self.deletePhoto();
    }
}

@end
