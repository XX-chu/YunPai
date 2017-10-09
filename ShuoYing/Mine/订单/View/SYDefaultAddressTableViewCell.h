//
//  SYDefaultAddressTableViewCell.h
//  ShuoYing
//
//  Created by 硕影 on 2017/4/5.
//  Copyright © 2017年 硕影. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SYDefaultAddressTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *noAddressLabel;
@property (weak, nonatomic) IBOutlet UIView *addressView;
@property (weak, nonatomic) IBOutlet UILabel *shouhuorenLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UILabel *phoneLabel;
@property (weak, nonatomic) IBOutlet UIImageView *arrowImageView;

@end
