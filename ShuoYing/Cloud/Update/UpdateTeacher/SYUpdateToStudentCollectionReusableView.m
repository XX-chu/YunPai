//
//  SYUpdateToStudentCollectionReusableView.m
//  ShuoYing
//
//  Created by 硕影 on 2017/3/1.
//  Copyright © 2017年 硕影. All rights reserved.
//

#import "SYUpdateToStudentCollectionReusableView.h"

@implementation SYUpdateToStudentCollectionReusableView

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.historyLabel.textColor = NavigationColor;
    
    [self.addPhotoBtn addTarget:self action:@selector(updatePhoto:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)updatePhoto:(UIButton *)sender{
    if (self.block) {
        self.block();
    }
}

@end
