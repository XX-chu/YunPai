//
//  SYUpdateToStudentCollectionViewCell.h
//  ShuoYing
//
//  Created by 硕影 on 2017/1/7.
//  Copyright © 2017年 硕影. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SYUpdateToStudentCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *contentImageView;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *infoLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentIMGHeightConstraint;

@end
