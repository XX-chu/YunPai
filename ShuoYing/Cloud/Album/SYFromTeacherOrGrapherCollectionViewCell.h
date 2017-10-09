//
//  SYFromTeacherOrGrapherCollectionViewCell.h
//  ShuoYing
//
//  Created by 硕影 on 2017/2/27.
//  Copyright © 2017年 硕影. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SYMyPhotoModel;
@interface SYFromTeacherOrGrapherCollectionViewCell : UICollectionViewCell

typedef void(^DownloadImage1)(SYFromTeacherOrGrapherCollectionViewCell *cell);

@property (weak, nonatomic) IBOutlet UIImageView *backImageView;
@property (weak, nonatomic) IBOutlet UIButton *downloadBtn;
@property (nonatomic, strong) SYMyPhotoModel *photoModel;

@property (nonatomic, copy) DownloadImage1 downloadImage;
@end
