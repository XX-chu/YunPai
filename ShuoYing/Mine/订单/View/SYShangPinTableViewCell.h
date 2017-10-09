//
//  SYShangPinTableViewCell.h
//  ShuoYing
//
//  Created by 硕影 on 2017/4/1.
//  Copyright © 2017年 硕影. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SYShangPinTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *headImageView;
@property (weak, nonatomic) IBOutlet UILabel *shangpinLabel;
@property (weak, nonatomic) IBOutlet UILabel *shangpinShuxingLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UILabel *countLabel;

@end
