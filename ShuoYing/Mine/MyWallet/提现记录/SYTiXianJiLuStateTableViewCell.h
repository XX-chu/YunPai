//
//  SYTiXianJiLuStateTableViewCell.h
//  ShuoYing
//
//  Created by chu on 2018/1/23.
//  Copyright © 2018年 硕影. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SYTiXianJiLuStateTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIView *upView;
@property (weak, nonatomic) IBOutlet UIView *downView;
@property (weak, nonatomic) IBOutlet UIImageView *stateImageView;
@property (weak, nonatomic) IBOutlet UILabel *stateLabel;
@property (weak, nonatomic) IBOutlet UILabel *miaoshuLabel;
@property (weak, nonatomic) IBOutlet UIView *lineView;

@end
