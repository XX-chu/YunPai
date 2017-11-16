//
//  SYLabelTableViewCell.m
//  ShuoYing
//
//  Created by 硕影 on 2016/12/26.
//  Copyright © 2016年 硕影. All rights reserved.
//

#import "SYLabelTableViewCell.h"

@implementation SYLabelTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.oneBtn.tag = 1111;
    self.twoBtn.tag = 2222;
    self.threeBtn.tag = 3333;
    self.fourBtn.tag = 4444;
    self.fiveBtn.tag = 5555;
    [self.oneBtn addTarget:self action:@selector(btnclick:) forControlEvents:UIControlEventTouchUpInside];
    [self.twoBtn addTarget:self action:@selector(btnclick:) forControlEvents:UIControlEventTouchUpInside];
    [self.threeBtn addTarget:self action:@selector(btnclick:) forControlEvents:UIControlEventTouchUpInside];
    [self.fourBtn addTarget:self action:@selector(btnclick:) forControlEvents:UIControlEventTouchUpInside];
    [self.fiveBtn addTarget:self action:@selector(btnclick:) forControlEvents:UIControlEventTouchUpInside];

}

- (void)btnclick:(UIButton *)btn{
    if (self.click) {
        self.click(btn.tag);
    }
}

@end
