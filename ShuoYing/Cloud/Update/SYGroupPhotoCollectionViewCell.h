//
//  SYGroupPhotoCollectionViewCell.h
//  ShuoYing
//
//  Created by 硕影 on 2017/3/6.
//  Copyright © 2017年 硕影. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SYGroupPhotoCollectionViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *oneLabel;
@property (weak, nonatomic) IBOutlet UILabel *twoLabel;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *widthContrains;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightContrains;
@end
