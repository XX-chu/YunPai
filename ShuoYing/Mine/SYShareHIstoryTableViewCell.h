//
//  SYShareHIstoryTableViewCell.h
//  ShuoYing
//
//  Created by chu on 2017/11/1.
//  Copyright © 2017年 硕影. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void(^ShareBlock)();
@interface SYShareHIstoryTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *headImageView;
@property (weak, nonatomic) IBOutlet UILabel *phoneLabel;
@property (weak, nonatomic) IBOutlet UIButton *updateBtn;
@property (nonatomic, copy) ShareBlock block;
@end
