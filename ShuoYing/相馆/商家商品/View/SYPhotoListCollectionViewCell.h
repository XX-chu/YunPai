//
//  SYPhotoListCollectionViewCell.h
//  ShuoYing
//
//  Created by 硕影 on 2017/5/9.
//  Copyright © 2017年 硕影. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SYMyPhotoModel;
typedef void(^SelecteBtnBlock)();
@interface SYPhotoListCollectionViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *contentImageView;
@property (weak, nonatomic) IBOutlet UIButton *selecteBtn;

@property (nonatomic, strong) SYMyPhotoModel *myPhoto;

@property (nonatomic, copy) SelecteBtnBlock block;
@end
