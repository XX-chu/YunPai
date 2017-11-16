//
//  SYYunPaiShiCommentTableViewCell.h
//  ShuoYing
//
//  Created by chu on 2017/11/14.
//  Copyright © 2017年 硕影. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SYYuYueOrderModel;
@interface SYYunPaiShiCommentTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *headImageView;
@property (weak, nonatomic) IBOutlet UILabel *nickLabel;

@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *xiaoguoImages;

@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *fenggeImages;

@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *guochengImages;
@property (nonatomic, strong) SYYuYueOrderModel *model;
@end
