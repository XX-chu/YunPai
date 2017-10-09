//
//  SYFenZuTableViewCell.h
//  ShuoYing
//
//  Created by 硕影 on 2017/1/6.
//  Copyright © 2017年 硕影. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^EditStudentBlock)();
typedef void(^CallPhoneBlock)();

@interface SYFenZuTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIButton *editBtn;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIButton *phoneNumBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *qunzhuIMGWidthContrains;
@property (weak, nonatomic) IBOutlet UIImageView *qunzhuImageView;

@property (nonatomic, copy) EditStudentBlock editBlock;
@property (nonatomic, copy) CallPhoneBlock callBlock;

@end
