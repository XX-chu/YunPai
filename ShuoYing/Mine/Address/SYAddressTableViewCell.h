//
//  SYAddressTableViewCell.h
//  ShuoYing
//
//  Created by 硕影 on 2016/12/26.
//  Copyright © 2016年 硕影. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SYAddressModel;

@protocol SYAddressTableViewCellDelegate <NSObject>

- (void)didSelectedEditOrDeleteBtn:(UIButton *)sender;

- (void)didSelectedIsDefaultBtn:(UIButton *)sender;

@end

@interface SYAddressTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UILabel *phoneLabel;

@property (weak, nonatomic) IBOutlet UIButton *isDefauleBtn;

@property (weak, nonatomic) IBOutlet UIButton *editBtn;
@property (weak, nonatomic) IBOutlet UIButton *deleteBtn;

@property (nonatomic, strong) SYAddressModel *addressModel;

@property (nonatomic, weak) id<SYAddressTableViewCellDelegate> delegate;

@end
