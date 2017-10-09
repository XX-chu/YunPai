//
//  SYMyAlbumInfosCollectionViewCell.h
//  ShuoYing
//
//  Created by 硕影 on 2016/12/30.
//  Copyright © 2016年 硕影. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SYMyPhotoModel;



@interface SYMyAlbumInfosCollectionViewCell : UICollectionViewCell
typedef void(^DownloadImage)(SYMyAlbumInfosCollectionViewCell *cell);
typedef void(^DeleteImage)(SYMyAlbumInfosCollectionViewCell *cell);
@property (weak, nonatomic) IBOutlet UIImageView *backImageView;
@property (weak, nonatomic) IBOutlet UIButton *downloadBtn;
@property (weak, nonatomic) IBOutlet UIButton *deleteBtn;
@property (nonatomic, strong) SYMyPhotoModel *photoModel;

@property (nonatomic, copy) DownloadImage downloadImage;
@property (nonatomic, copy) DeleteImage deleteImage;

@end
