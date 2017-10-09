//
//  SYShangPinTableViewCell.m
//  ShuoYing
//
//  Created by 硕影 on 2017/4/1.
//  Copyright © 2017年 硕影. All rights reserved.
//

#import "SYShangPinTableViewCell.h"

@implementation SYShangPinTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.shangpinLabel.textColor = HexRGB(0x434343);
    self.shangpinShuxingLabel.textColor = HexRGB(0x828282);
    self.priceLabel.textColor = HexRGB(0xff8401);
    self.countLabel.textColor = HexRGB(0x434343);
}


@end
