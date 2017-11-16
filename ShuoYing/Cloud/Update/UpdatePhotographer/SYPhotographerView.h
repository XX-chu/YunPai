//
//  SYPhotographerView.h
//  ShuoYing
//
//  Created by 硕影 on 2017/1/9.
//  Copyright © 2017年 硕影. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SYPhotographerView : UIView

@property (weak, nonatomic) IBOutlet UIImageView *xingjiImageView;

@property (weak, nonatomic) IBOutlet UIButton *updatePhotoBtn;
@property (weak, nonatomic) IBOutlet UILabel *updateHistoryLabel;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;


@end
