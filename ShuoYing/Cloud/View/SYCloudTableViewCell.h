//
//  SYCloudTableViewCell.h
//  ShuoYing
//
//  Created by 硕影 on 2016/12/29.
//  Copyright © 2016年 硕影. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SYCloudModel;
@interface SYCloudTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *headImageView;
@property (weak, nonatomic) IBOutlet UILabel *nicknameLabel;
@property (weak, nonatomic) IBOutlet UILabel *introLabel;
@property (weak, nonatomic) IBOutlet UIImageView *firstImageVIew;
@property (weak, nonatomic) IBOutlet UIImageView *secondImageView;
@property (weak, nonatomic) IBOutlet UIImageView *thirdImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *firstIVWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *firstIVHeightContrainst;
@property (weak, nonatomic) IBOutlet UIImageView *xingjiImageView;

@property (nonatomic, strong) SYCloudModel *cloudModel;

@end
