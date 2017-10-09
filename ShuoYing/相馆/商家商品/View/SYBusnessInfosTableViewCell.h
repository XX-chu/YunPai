//
//  SYBusnessInfosTableViewCell.h
//  ShuoYing
//
//  Created by 硕影 on 2017/4/26.
//  Copyright © 2017年 硕影. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SYBusnessInfosModel;
typedef void(^BusnessInfosCallBlock)();
typedef void(^BusnessInfosAddressBlock)();
@interface SYBusnessInfosTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIView *addressView;

@property (nonatomic, strong) SYBusnessInfosModel *infosModel;

@property (nonatomic, copy) BusnessInfosCallBlock callBlock;

@property (nonatomic, copy) BusnessInfosAddressBlock addressBlock;

@end
