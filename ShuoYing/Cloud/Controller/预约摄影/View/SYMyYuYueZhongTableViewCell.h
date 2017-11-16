//
//  SYMyYuYueZhongTableViewCell.h
//  ShuoYing
//
//  Created by chu on 2017/11/15.
//  Copyright © 2017年 硕影. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SYYuYueOrderModel;
@interface SYMyYuYueZhongTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *headImageView;
@property (weak, nonatomic) IBOutlet UILabel *nickLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *phoneLabel;
@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *stars;
@property (nonatomic, strong) SYYuYueOrderModel *model;
@end
