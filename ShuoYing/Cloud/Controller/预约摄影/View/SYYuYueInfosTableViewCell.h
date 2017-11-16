//
//  SYYuYueInfosTableViewCell.h
//  ShuoYing
//
//  Created by chu on 2017/11/15.
//  Copyright © 2017年 硕影. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SYYunPaiShiInfos;
@interface SYYuYueInfosTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *xinghaoLabel;
@property (weak, nonatomic) IBOutlet UIImageView *headImageView;
@property (weak, nonatomic) IBOutlet UILabel *nickLabel;
@property (weak, nonatomic) IBOutlet UILabel *yiwanchengLabel;
@property (weak, nonatomic) IBOutlet UILabel *juliLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *stars;
@property (nonatomic, strong) SYYunPaiShiInfos *infos;
@end
