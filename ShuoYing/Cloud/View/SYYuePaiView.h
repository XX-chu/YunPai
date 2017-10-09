//
//  SYYuePaiView.h
//  ShuoYing
//
//  Created by 硕影 on 2017/1/16.
//  Copyright © 2017年 硕影. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^ViewSelecteBtnBlock)(NSInteger tag);

@interface SYYuePaiView : UIView

@property (weak, nonatomic) IBOutlet UILabel *phoneLabel;
@property (weak, nonatomic) IBOutlet UIButton *cancleBtn;
@property (weak, nonatomic) IBOutlet UIButton *callBtn;
@property (weak, nonatomic) IBOutlet UIButton *aplayBtn;

@property (nonatomic, copy) ViewSelecteBtnBlock bolck;

@end
