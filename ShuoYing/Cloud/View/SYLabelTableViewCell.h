//
//  SYLabelTableViewCell.h
//  ShuoYing
//
//  Created by 硕影 on 2016/12/26.
//  Copyright © 2016年 硕影. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void(^BtnClick)(NSInteger btnType);
@interface SYLabelTableViewCell : UITableViewCell


@property (nonatomic, copy) BtnClick click;

@property (weak, nonatomic) IBOutlet UIButton *oneBtn;
@property (weak, nonatomic) IBOutlet UIButton *twoBtn;
@property (weak, nonatomic) IBOutlet UIButton *threeBtn;
@property (weak, nonatomic) IBOutlet UIButton *fourBtn;

@end
