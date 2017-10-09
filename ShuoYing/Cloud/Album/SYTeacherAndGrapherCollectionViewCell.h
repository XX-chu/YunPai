//
//  SYTeacherAndGrapherCollectionViewCell.h
//  ShuoYing
//
//  Created by 硕影 on 2017/1/11.
//  Copyright © 2017年 硕影. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SYTeacherAndGrapherModel;


@interface SYTeacherAndGrapherCollectionViewCell : UICollectionViewCell

typedef void(^TeacherAndGrapherAlipyImage)(SYTeacherAndGrapherCollectionViewCell *cell);
typedef void(^TeacherAndGrapherDownloadImage)(SYTeacherAndGrapherCollectionViewCell *cell);

@property (weak, nonatomic) IBOutlet UIImageView *headImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *phoneLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageViewWidthConstraint;

@property (nonatomic, strong) UIButton *downloadBtn;
@property (nonatomic, strong) SYTeacherAndGrapherModel *model;

@property (nonatomic, copy) TeacherAndGrapherAlipyImage alipyBlock;
@property (nonatomic, copy) TeacherAndGrapherDownloadImage downloadBlock;

@end
