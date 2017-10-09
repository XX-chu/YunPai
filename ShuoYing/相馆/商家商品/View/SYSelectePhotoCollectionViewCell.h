//
//  SYSelectePhotoCollectionViewCell.h
//  ShuoYing
//
//  Created by 硕影 on 2017/5/9.
//  Copyright © 2017年 硕影. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void(^DeletePhotoBlock)();
@interface SYSelectePhotoCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *contentImageView;
@property (weak, nonatomic) IBOutlet UIButton *deleteBtn;

@property (nonatomic, copy)DeletePhotoBlock deletePhoto;

@end
