//
//  SYTeacherPhotoHistoryCollectionViewCell.m
//  ShuoYing
//
//  Created by 硕影 on 2017/1/9.
//  Copyright © 2017年 硕影. All rights reserved.
//

#import "SYTeacherPhotoHistoryCollectionViewCell.h"

@implementation SYTeacherPhotoHistoryCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.editBtn.hidden = YES;
}


- (IBAction)editAction:(UIButton *)sender {
    if (self.editBlock) {
        self.editBlock();
    }

}

@end
