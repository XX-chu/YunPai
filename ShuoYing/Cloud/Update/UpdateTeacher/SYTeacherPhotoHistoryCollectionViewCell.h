//
//  SYTeacherPhotoHistoryCollectionViewCell.h
//  ShuoYing
//
//  Created by 硕影 on 2017/1/9.
//  Copyright © 2017年 硕影. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SYTeacherPhotoHistoryCollectionViewCell : UICollectionViewCell


typedef void(^TeacherAndGrapherEdit)();

@property (weak, nonatomic) IBOutlet UIImageView *headImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *headImageViewHeightConstraint;
@property (nonatomic, copy) TeacherAndGrapherEdit editBlock;
@property (weak, nonatomic) IBOutlet UIButton *editBtn;

@end
