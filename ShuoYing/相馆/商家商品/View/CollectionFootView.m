//
//  CollectionFootView.m
//  ShuoYing
//
//  Created by 硕影 on 2017/5/2.
//  Copyright © 2017年 硕影. All rights reserved.
//

#import "CollectionFootView.h"

@interface CollectionFootView ()
{
    NSInteger _count;
}

@end

@implementation CollectionFootView

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    _count = 1;
    [self.addBtn setAdjustsImageWhenHighlighted:NO];
    [self.minutBtn setAdjustsImageWhenHighlighted:NO];
}
- (IBAction)addAction:(UIButton *)sender {
    _count = [self.countLabel.text integerValue];
    if (self.addBlock) {
        self.addBlock(_count);
    }
}

- (IBAction)minutAction:(UIButton *)sender {
    _count = [self.countLabel.text integerValue];
    if (self.minutBlock) {
        self.minutBlock(_count);
    }
}

@end
