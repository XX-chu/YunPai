//
//  SYTiXianJiLuTableViewCell.h
//  ShuoYing
//
//  Created by chu on 2018/1/23.
//  Copyright © 2018年 硕影. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SYTiXianJiLuTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *headImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *tixianState;

@end
